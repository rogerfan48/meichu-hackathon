import * as admin from 'firebase-admin';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

/*
 Path specification:
 Session documents: apps/lexiaid/user/{uid}/sessions/{sessionID}
 Card documents:    apps/lexiaid/user/{uid}/cards/{cardID}
 When a session is deleted, delete all cards whose field `sessionID` equals {sessionID}.
*/
export const onSessionDeleted = onDocumentDeleted(
  'apps/lexiaid/user/{uid}/sessions/{sessionID}',
  async (event) => {
    const { uid, sessionID } = event.params;
    console.log(`[SessionCleanup] Deletion detected. uid=${uid} sessionID=${sessionID}`);

    try {
      const cardsColPath = `apps/lexiaid/user/${uid}/cards`;
      const snap = await db
        .collection(cardsColPath)
        .where('sessionID', '==', sessionID)
        .get();

      if (snap.empty) {
        console.log(`[SessionCleanup] No cards to delete for session ${sessionID}.`);
        return null;
      }

      console.log(`[SessionCleanup] Found ${snap.size} cards to delete for session ${sessionID}.`);

      let batch = db.batch();
      let opCount = 0;
      let deleted = 0;

      for (const doc of snap.docs) {
        batch.delete(doc.ref);
        opCount++;
        deleted++;
        if (opCount === 500) {
          await batch.commit();
          console.log(`[SessionCleanup] Committed batch of 500 deletions (running total ${deleted}).`);
          batch = db.batch();
          opCount = 0;
        }
      }

      if (opCount > 0) {
        await batch.commit();
        console.log(`[SessionCleanup] Committed final batch of ${opCount} deletions (total ${deleted}).`);
      }

      console.log(`[SessionCleanup] Completed. Deleted ${deleted} cards for session ${sessionID}.`);
    } catch (e) {
      console.error(`[SessionCleanup] Error cleaning cards for session ${sessionID}:`, e);
    }
    return null;
  }
);
