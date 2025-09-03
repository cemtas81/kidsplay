#!/usr/bin/env node
/*
  Safely purge ALL root-level Firestore collections.
  - --dry-run: lists collections only
  - --yes: required to actually delete

  Requires GOOGLE_APPLICATION_CREDENTIALS or default ADC.
  Optional GCLOUD_PROJECT to set project.
*/
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const args = new Set(process.argv.slice(2));
const DRY_RUN = args.has('--dry-run');
const CONFIRM = args.has('--yes');

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

async function listRootCollections() {
  const cols = await db.listCollections();
  return cols.map((c) => c.id).sort();
}

async function deleteCollection(collId, batchSize = 300) {
  const collRef = db.collection(collId);
  while (true) {
    const snap = await collRef.limit(batchSize).get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const doc of snap.docs) batch.delete(doc.ref);
    await batch.commit();
  }
}

(async () => {
  const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || (await db.getDatabaseId()).projectId;
  const collections = await listRootCollections();
  console.log(`Project: ${projectId}`);
  if (collections.length === 0) {
    console.log('No root collections found.');
    process.exit(0);
  }
  console.log('Root collections:');
  for (const c of collections) console.log('-', c);

  if (DRY_RUN) {
    console.log('\nDry run complete. No deletions performed.');
    process.exit(0);
  }

  if (!CONFIRM) {
    console.error('\nRefusing to delete without --yes. Re-run with --dry-run to inspect.');
    process.exit(1);
  }

  console.warn('\nDELETING all documents in all root collections...');
  for (const c of collections) {
    console.log('Deleting =>', c);
    await deleteCollection(c);
  }
  console.log('Purge complete.');
})();