import { init, REGION } from './config';
import * as functions from 'firebase-functions';
import { createSessionPipeline } from './flow/createSessionPipeline';

init();

export const runSessionPipeline = functions.region(REGION).https.onCall(async (data, context) => {
  const userId = data.userId as string;
  const sessionId = data.sessionId as string;
  if (!userId || !sessionId) {
    throw new functions.https.HttpsError('invalid-argument', 'userId and sessionId required');
  }
  await createSessionPipeline({ userId, sessionId });
  return { status: 'started' };
});
