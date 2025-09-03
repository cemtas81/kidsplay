#!/usr/bin/env node
/*
  Seed Firestore from repo assets (idempotent upsert):
  - tools  <= kidsplay/kidsplay/assets/data/tools.json
  - hobbies <= kidsplay/kidsplay/assets/data/hobbies.json
  - skills <= kidsplay/kidsplay/assets/data/skills.json

  Each JSON array item must contain: { id: string, ... }
  Other fields (e.g., nameKey, category) are merged.

  Requires GOOGLE_APPLICATION_CREDENTIALS or default ADC.
  Optional GCLOUD_PROJECT to set project.
*/
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DATA_DIR = path.resolve(__dirname, '../../kidsplay/assets/data');
const FILES = [
  { file: 'tools.json', coll: 'tools' },
  { file: 'hobbies.json', coll: 'hobbies' },
  { file: 'skills.json', coll: 'skills' }
];

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

function loadArrayJson(p) {
  if (!fs.existsSync(p)) {
    console.warn(`WARN: File not found: ${p} (skipping)`);
    return [];
  }
  const raw = fs.readFileSync(p, 'utf8');
  try {
    const data = JSON.parse(raw);
    if (!Array.isArray(data)) throw new Error('Top-level JSON is not an array');
    return data;
  } catch (e) {
    throw new Error(`Failed to parse ${p}: ${e.message}`);
  }
}

async function upsertCollection(coll, items) {
  let ok = 0, skipped = 0;
  for (const item of items) {
    const { id, ...rest } = item || {};
    if (!id || typeof id !== 'string') { skipped++; continue; }
    const ref = db.collection(coll).doc(id);
    await ref.set(rest, { merge: true });
    ok++;
  }
  return { ok, skipped };
}

(async () => {
  const projectId = process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || (await db.getDatabaseId()).projectId;
  console.log('Project:', projectId);
  console.log('Data dir:', DATA_DIR);

  for (const { file, coll } of FILES) {
    const p = path.join(DATA_DIR, file);
    const items = loadArrayJson(p);
    console.log(`\nSeeding ${coll} from ${file} (items: ${items.length})`);
    const { ok, skipped } = await upsertCollection(coll, items);
    console.log(`Done: upserted=${ok}, skipped=${skipped}`);
  }

  console.log('\nSeed complete.');
})();