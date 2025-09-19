# AI Coding Agent Instructions

Concise, project-specific guidance so an AI agent can be productive immediately. Keep edits actionable and aligned with the existing spec (`spec.md`). Avoid generic advice.

## 1. Purpose / Product
Assist dyslexia users by: (a) uploading mixed media (PDF, text, images, camera) -> (b) generating multimodal summarized explanations (images + speech + textual summary) -> (c) producing study cards -> (d) enabling review & memory game.
A single logical unit of processing = a "session" (files + derived assets + generated cards + summaries).

## 2. High-Level Architecture
Flutter client (MVVM) + Firebase (Auth, Firestore, Storage, Cloud Functions) + Vertex AI / Gemini Pro for LLM, vision, image & explanation generation + (optional) OCR pipeline.
Data Flow: User uploads → store raw files in Storage under `userDocID/sessionID/` → Firestore session doc stub → Cloud Function orchestrates: summarization, extraction of candidate card terms, image explanation generation, audio generation → Firestore updates (session + cards) → Client listeners update UI.
Parallelization: All independent AI summarization/extraction calls SHOULD execute in parallel; aggregate when all complete.

## 3. Data Model (Firestore)
Root path: `apps/hackathon/users/{userDocID}`.
Current sample (`database-sample.json`) shows `cards` and `sessions` stored as MAPS of objects keyed by IDs (not arrays). Inside a session `fileResources` and `imgExplanations` are also MAPS keyed by IDs. Keep implementation consistent or migrate to sub-collections when counts grow (> ~200 items) for pagination.
Logical shapes (map style):
- card: `{ sessionID, tags[], imgURL, text }`
- session: `{ sessionName, fileResources: {fileId -> fileResource}, summary, imgExplanations: {imgExpId -> imgExplanation}, cardIDs[] }`
- fileResource: `{ fileURL, fileSummary }`
- imgExplanation: `{ imgURL, explanation }`
Referential integrity rules:
1. When creating cards for a session: add entry under `cards.{cardId}` AND push `cardId` into `sessions.{sessionId}.cardIDs`.
2. On card delete: remove from `cards` map AND pull from session `cardIDs`.
3. On regeneration of explanations: append new `imgExpId` under that session map—never mutate existing unless user explicitly edits.
Migration note: To shift to sub-collections later, mirror interface in repositories so UI code is insulated (e.g., `CardRepository.listBySession(sessionId)` implementation swaps without UI changes).
Query patterns (pseudo):
```dart
// Listen to a single session
_fire.doc('apps/hackathon/users/$uid').snapshots().map((u) => Session.fromUserDoc(u, sessionId));

// Add card
userRef.update({
	'cards.$cardId': card.toJson(),
	'sessions.$sessionId.cardIDs': FieldValue.arrayUnion([cardId])
});
```

## 4. Flutter MVVM Conventions (Target)
Directories (expected):
- `models/` Firestore DTOs (immutable, `fromJson/toJson`).
- `repositories/` Data access (Firestore / Storage / Cloud Functions abstraction). No UI logic.
- `services/` Cross-cut concerns (AI invocation wrapper, speech synthesis config, OCR adapter).
- `view_models/` StateNotifiers/ChangeNotifiers (one per page: Upload, CardList, SessionHistory, Settings, Game). Expose reactive streams for Firestore snapshots.
- `pages/` Widget screens composed from `widgets/`.
Name view models `<Feature>ViewModel` and expose explicit intent methods: `startUploadSession()`, `regenerateExplanation(sessionId)`, etc.

## 5. Backend Functions (TypeScript)
`functions/src/` structure (spec): `config.ts` (init firebase, env), `type.ts` (shared interfaces mirroring models), `flow/` (session orchestration steps), `index.ts` (HTTP + background triggers).
Implement orchestrator: `createSessionPipeline(userId, sessionId)` launching parallel tasks:
1. Summarize each file (PDF vs text vs vision OCR).
2. Aggregate global summary.
3. Extract candidate card terms.
4. Generate explanatory images (multi-image) from summary.
5. For each generated image, produce explanation + optional audio (store URL in Firestore).
Update Firestore incrementally to allow progressive UI updates; mark completion flag at end.

## 6. AI & Media Generation
Gemini / Vertex AI usage patterns:
- Use consistent system prompts referencing dyslexia-friendly output: short sentences, high-contrast description cues.
- For OCR pipeline: call vision OCR first; feed extracted text chunks via RAG style prompt (include original file summaries) when forming global summary.
- Regeneration: store original prompt + parameters to allow reproducible re-run.

## 7. Performance & Parallel Calls
Group independent API calls with Promise.all (Cloud Functions) / Future.wait (Dart). Avoid serial waits except when dependency chain (e.g., need global summary before generating explanation images). Emit interim Firestore fields (e.g., `status: processing | generatingImages | complete`).

## 8. Naming & IDs
`sessonID` & `cardID`: use Firestore auto IDs. Storage path: `/{userDocID}/{sessionID}/{originalFileName}`. Keep generated images under `.../generated/` and audio under `.../audio/` for cleanup clarity.

## 9. Common Implementation Patterns
- Validation: Ensure at least one file OR text content before creating session.
- Accessibility: Provide hover-to-speak (central service for TTS; respect `defaultSpeechRate`).
- Regeneration: New explanations appended; allow delete of specific `imgExplanation` entries.
- Tagging: Derive initial tags from key terms extraction; allow user edits.

## 10. Adding New Features (Checklist)
1. Define/extend model & update shared `type.ts` + Flutter model.
2. Update repository + serialization.
3. Add orchestrator step (if backend) with isolated function in `flow/`.
4. Expose new intent method in relevant view model.
5. Wire UI with reactive listener & loading states.
6. Maintain session/card referential integrity.

## 11. Assumptions / Gaps
Repo now includes a `database-sample.json` confirming map-based storage (nested objects) rather than arrays. Implement repositories with an abstraction layer anticipating optional future migration to:
- `users/{userDocID}/cards/{cardId}`
- `users/{userDocID}/sessions/{sessionId}/fileResources/{fileId}`
Add lightweight translation helpers to normalize map vs collection reads.

## 12. Non-Goals
Do not add unrelated tooling or alter data model without spec reason. Do not block UI for long AI tasks—stream progress.

Provide future edits here; keep under ~70 lines. When modifying, preserve sections 1–12.
