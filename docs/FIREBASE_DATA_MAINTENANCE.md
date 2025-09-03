# Firebase Data Maintenance (Safe Purge, Seed, and Storage Lifecycle)

This guide describes how to:
- Back up Firestore
- Purge existing Firestore data (safe, explicit confirmation required)
- Seed Firestore from repo assets (idempotent upserts)
- Configure Cloud Storage automatic deletion (lifecycle rules)

Prerequisites
- Google Cloud SDK installed and authenticated
- A Firebase service account JSON with proper permissions for Firestore/Storage
- Node.js 18+

Environment
- Project ID: Use your Firebase/GCP project ID. Examples below use placeholders; replace <project-id>.
- Bucket: Typically <project-id>.appspot.com unless customized.

1) Back up Firestore (recommended)
```bash
# Exports a backup to the specified bucket path
BACKUP_PATH="gs://<project-id>.appspot.com/firestore-backups/$(date +%Y%m%d-%H%M%S)"
gcloud firestore export $BACKUP_PATH --project=<project-id>
```

2) Purge all Firestore collections (explicit confirmation required)
```bash
cd tools/firestore-utils
npm ci
# Point to a service account file
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
# (Optional) set project explicitly if needed
export GCLOUD_PROJECT="<project-id>"

# Dry run first (safe)
npm run purge -- --dry-run

# Actual purge (requires --yes)
npm run purge -- --yes
```
Notes
- The purge script deletes ALL root-level collections in batches.
- Always verify you are on the intended project before running with --yes.

3) Seed Firestore from repo assets (idempotent)
This seeds three collections from the repo:
- tools from kidsplay/kidsplay/assets/data/tools.json
- hobbies from kidsplay/kidsplay/assets/data/hobbies.json
- skills from kidsplay/kidsplay/assets/data/skills.json

```bash
cd tools/firestore-utils
npm ci
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
# (Optional) set project explicitly if needed
export GCLOUD_PROJECT="<project-id>"

npm run seed
```

Seeding behavior
- Each JSON entry must include an "id" field; it becomes the Firestore document ID.
- Other fields (e.g., nameKey, category) are written with merge=true, so repeated runs update existing docs.
- Missing files are skipped with a warning.

4) Configure Cloud Storage lifecycle (automatic deletion)
This repository includes a sample lifecycle config at cloud/storage-lifecycle.json which deletes objects under the prefix videos/ after 15 days.

Apply via gsutil (recommended):
```bash
# Update the bucket lifecycle to delete after 15 days for objects in videos/
gsutil lifecycle set cloud/storage-lifecycle.json gs://<project-id>.appspot.com
```

Or via gcloud storage:
```bash
gcloud storage buckets update gs://<project-id>.appspot.com --lifecycle-file=cloud/storage-lifecycle.json
```

Important
- Adjust age or matchesPrefix in cloud/storage-lifecycle.json if required.
- This does not change Firebase Security Rules.

5) Verifications
- After purge: Firestore should have zero documents at root collections.
- After seed: Firestore should contain tools, hobbies, skills with counts matching respective JSON files.
- After lifecycle apply: In GCS bucket settings, verify lifecycle rule is active and test-upload to videos/ to confirm deletion after the set age.