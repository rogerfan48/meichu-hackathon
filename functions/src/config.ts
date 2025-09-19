import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

let initialized = false;
export function init() {
  if (!initialized) {
    admin.initializeApp();
    initialized = true;
    if (!process.env.VERTEX_PROJECT_ID) {
      functions.logger.warn('VERTEX_PROJECT_ID not set; AI features will use fallback stubs.');
    }
  }
  return { admin, functions };
}

export { admin, functions };
export const REGION = 'us-central1';
