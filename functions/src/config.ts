import {genkit} from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  apiKey: "AIzaSyCTtxssYFoJ8otNLQdkkktQOlGqaxepmrU",
  authDomain: "foodie-4dee6.firebaseapp.com",
  projectId: "foodie-4dee6",
  storageBucket: "foodie-4dee6.firebasestorage.app",
  messagingSenderId: "346523381880",
  appId: "1:346523381880:web:3205cd3d27cd436b43bd8d",
  measurementId: "G-X8QC682NEV"
};

export const getProjectId = () => firebaseConfig.projectId;

export const ai = genkit({
  plugins: [
    vertexAI({
      projectId: getProjectId(),
      location: 'us-central1',
    }),
  ],
});
