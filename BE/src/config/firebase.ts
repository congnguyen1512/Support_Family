import { App, applicationDefault, cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging, Messaging } from 'firebase-admin/messaging';
import fs from 'fs';

function parseServiceAccountFromEnv() {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (!raw) {
    return null;
  }

  try {
    const parsed = JSON.parse(raw);
    return parsed;
  } catch (error) {
    console.error('FIREBASE_SERVICE_ACCOUNT_JSON is invalid JSON', error);
    return null;
  }
}

function initializeFirebaseApp(): App | null {
  if (getApps().length > 0) {
    return getApps()[0]!;
  }

  try {
    const serviceAccount = parseServiceAccountFromEnv();

    if (serviceAccount) {
      return initializeApp({
        credential: cert(serviceAccount),
      });
    }

    const credentialPath = process.env.GOOGLE_APPLICATION_CREDENTIALS?.trim();
    if (!credentialPath || !fs.existsSync(credentialPath)) {
      console.warn(
        '[firebase] No service account found (GOOGLE_APPLICATION_CREDENTIALS / FIREBASE_SERVICE_ACCOUNT_JSON). Push notifications are DISABLED.',
      );
      return null;
    }

    return initializeApp({
      credential: applicationDefault(),
    });
  } catch (error) {
    console.error('[firebase] Init failed. Push notifications are DISABLED.', error);
    return null;
  }
}

const firebaseApp = initializeFirebaseApp();

// null when Firebase is not configured -> push delivery is skipped.
export const firebaseMessaging: Messaging | null = firebaseApp
  ? getMessaging(firebaseApp)
  : null;
