import * as admin from 'firebase-admin';
import { onDocumentDeleted } from 'firebase-functions/v2/firestore';

if (admin.apps.length === 0) {
  admin.initializeApp();
}
const db = admin.firestore();

/*
 Cards:   apps/lexiaid/user/{uid}/cards/{cardID}
 Sessions: apps/lexiaid/user/{uid}/sessions/{sessionID}

 When a card is deleted:
   1. Read its sessionID from the deleted (before) snapshot.
   2. If sessionID exists, remove the cardID from that session's cardIDs array (if session doc exists).
   3. Safe no-op if session missing or card had no sessionID.
*/
export const onCardDeleted = onDocumentDeleted(
  'apps/lexiaid/user/{uid}/cards/{cardID}',
  async (event) => {
    const { uid, cardID } = event.params;
    const beforeData = event.data?.data();

    console.log(`[CardCleanup] Card deleted uid=${uid} cardID=${cardID}`);

    if (!beforeData) {
      console.log(`[CardCleanup] No before data; nothing to do.`);
      return null;
    }

    const sessionID = beforeData.sessionID as string | undefined;
    if (!sessionID) {
      console.log(`[CardCleanup] Deleted card has no sessionID. Skipping session update.`);
      return null;
    }

    const sessionRef = db.doc(`apps/lexiaid/user/${uid}/sessions/${sessionID}`);
    const sessionSnap = await sessionRef.get();
    if (!sessionSnap.exists) {
      console.log(`[CardCleanup] Session ${sessionID} not found; nothing to update.`);
      return null;
    }

    try {
      await sessionRef.set(
        {
          cardIDs: admin.firestore.FieldValue.arrayRemove(cardID),
        },
        { merge: true }
      );
      console.log(`[CardCleanup] Removed cardID ${cardID} from session ${sessionID}.`);
    } catch (e) {
      console.error(`[CardCleanup] Failed to update session ${sessionID}:`, e);
    }

    return null;
  }
);
