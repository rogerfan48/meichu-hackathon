// import { onCallGenkit } from "firebase-functions/https";

import { genSessionSummaryFlow } from "./flow/genSessionSummary";
export const genSessionSummary = genSessionSummaryFlow;

import { genCardsFlow } from "./flow/genCardsFlow";
export const genCards = genCardsFlow;

import { onSessionDeleted } from "./onSessionDeleted";
export { onSessionDeleted };

import { onCardDeleted } from "./onCardDeleted";
export { onCardDeleted };

// NEW: process existing session (summaries + images)
import { processExistingSessionFlow } from "./flow/processExistingSession";
export { processExistingSessionFlow };