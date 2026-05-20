const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const https = require('https');
const crypto = require('crypto');

const BUCKET = 'vybe-bata-c07aa.firebasestorage.app';
const PROJECT = 'vybe-bata-c07aa';
const IMAGE_DIR = path.join(__dirname, '../예시이미지');

const images = fs.readdirSync(IMAGE_DIR).filter(f => !f.startsWith('.'));

const CLUB_IDS = [
  '0xhYvbbj3GlVgSHKpqOB','1kX6M1jUZBhRRQJ6ZRFb','1kkVWo8FnhUb1EwvHF3F',
  '2XWYzRhz6caZIugBb0Zd','3e5GxQwFDXe4RGyB6Qj6','3eRW2hluq9O8GKcovB9B',
  '5UWQ8e3bI2upv9Kyu6fs','62VaHypRMWcCySNQZEaa','6Fb4zB53qWZoGUWm6oWL',
  '6PAo5hmpLPJwIb8tQ59y','6szPA0bjE9GANvuEYW21','6t5FIpyaZn5xnoGl6R2l',
  '7Gpo1PBrWmT90Y4MXT0n','8huHBjtOhWPJhkmKxU40','AITx9K2G7AYpgnhziEwd',
  'BLIa57JoSau0GPlEzWPy','Ci76EuxN93whLhRb5mKi','Clrsbfjc3iKBrkPbMYAT',
  'D6G22ppiCz7ZdszW9iFB','DxQpgtocSDZ2dCiY1N4C','FX9UhIMKNfDRlZc69zqJ',
  'FmYj2CVHaQ0F6F4TYThX','GJpxS3l6PwYUWr7FY1xo','I2OISjNPfVQtjYXlTsAE',
  'IuH9oCb1Vzli174Og25x','JIE2uPSFCsQy7qMn3bQ4','JRws0pvU10wLykZSs4ZP',
  'JnXGDAqYF6qMrutdLXaC','JxytvRaS96LjPQKX6XI8','KAFbE1thTkfbV44xtdgp',
  'KPNQLOHqIpGaTnLbtJTi','Kq5Nz6dBmxva0lNnExoP','KuooN4tjuW2UGpHJcHoT',
  'LFinSnL0vjtTSPQpHBov','LPPAaLtrm5IbFbhvZLBJ','LV6rAXmfRKAnUhHww0YI',
  'LllRPz93KNAawmgdqZDj','MlsfYzc1qoHxfoU4DDM6','NFFsSltzv4waCMd1HT1x',
  'NXkpj9RgvydBCnDoJHxD','Nond2I0OQJIQ9HFPSyn2','OLYIv5dztdZSGveoK52t',
  'PjXKJks9Z5AxjBHmsGMg','QAFvczRj5Ri3YkF8Fkjx','QJUB21rpPpSKYtgfrrdE',
  'QpEXzQwz6x76fHrHPdvK','QsTUYp1m6bx0d2FxCIYr','R2Jb4uu0f9nf85Cif98o',
  'RMEiUfCy2WSQFqXcAzzu','TzbMN3PXg4Ch9jXMk8lY','UnVq1pMF4dqMDZgOm9so',
  'VMlKDTyMneHttOIoU7XQ','W1hgcFlg5GVPHFL53OaA','W3dFPEkGkYPfqEEqUfUi',
  'WKnDohGnCAonVeeFol1k','X1XTUKKAMLqA7luAAdiR','X7F8oCjNcG76rRUBXNFy',
  'XI019KnsE4ZULkIqitd5','Y4PsGnCUo1lduP5LIkFC','YOpiqy1nsoWtFFh3YYlz',
  'ZHYXwPIXrXxiR74dhgv2','ZXXSqpI88FHuFq0Y9POP','a5Lvm7RwAdXgwgYkJ3eY',
  'bJ5fOfFcVAf1MpQK12BP','bKrdZtDGondmN5rWPxbb','bz7TnC5bN0pOSX7Y292a',
  'dPw0XzwpeIfPmIYvUY8x','dvcNNxmpbw868im4YwUB','dwkkVM1R8fbTuDMTn6Is',
  'e0kifqpxXDW9ZhXWS9h9','e3ikLrnerzpW4sXtsNe0','fTGLO4GhDm12k1TLwJnY',
  'fiPWiolenfGOhc1aZaQL','gMWvFD6tbTgmNxdBjcbP','gfM7B93tZdRjAhzFCUbU',
  'hLJ82lzQ5Ic1icEjIHmY','ibJ7AScFEPANj9vuB8Jc','j3wbTcldZCNPKJomvM7z',
  'jFMmojFlaRiq7pOaSo4F','jYoj8SBG2skf2ldomljQ','jcakiA7PXMT5Sw6iZht2',
  'jjMbGOFdzWHGQ2jvIeZv','ksiqWWyZmxl8u8IzlYZu','l3NeZlfPizs4WrNdZDTB',
  'l5unThaaS2WHoFqGghDg','m0ecQgGIlFb8EAKMduWV','nQxoL0mQa8cpAyP2vJ0c',
  'nre9W0498h0VuWS3dX1d','oGhkCl8LxBdfDe27GVbD','pk9Mi4HioJ7ZoBXd3Jeu',
  'psY68Gybg8TCd4BDOhtp','ptm0saks4oeqAVBvcQUv','pvt4A7r8DaaR4HboW2ai',
  'qH3tSyZJuSEGoyH5Oagx','qkjULKj3K1kAuwWF17BV','qqJmepTi2RoLC8NQOtqp',
  'rK7e8tMsYBBbMFfkEipO','ryvTDxJdBsau6G8bg3Z3','sMIeiwGTCs8kvO5PmttF',
  'sSXf0UdJCZ6fC3i9dfzK','tENHMZhh2PWTYkyaTODa','tewzOf1uYnTxvkzUIpSy',
  'tk7iI9ic587YBzxnyZZ1','tylInZWcpqdRqfLs3R10','vE7NklPiNqmOt8VsFKkS',
  'vuvQIwJasm9du8Yo0IEm','xxLcWb4FlWYDKrECS8wl','xyiex7pKH379MiuDwfEI',
  'yol2vWKiQlYDrbkVUMRj','zSSqbMKhdeTGLmGamiOs','zUFnGFj1KGlKcv9tPWRw',
  'ziCJUUvvyGd8SB4MkWki','ziJ8J2zSxLRRmb7Z8N9Q','zlIxpvPgDNq0agKvqcsl',
];

function randomImage() {
  return images[Math.floor(Math.random() * images.length)];
}

function contentTypeOf(filename) {
  return filename.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
}

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, res => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function uploadToStorage(token, localPath, destination, contentType, downloadToken) {
  const fileData = fs.readFileSync(localPath);
  const metadata = JSON.stringify({
    name: destination,
    contentType,
    metadata: { firebaseStorageDownloadTokens: downloadToken },
  });

  // multipart upload
  const boundary = '-------314159265358979323846';
  const delim = `\r\n--${boundary}\r\n`;
  const closeDelim = `\r\n--${boundary}--`;

  const body = Buffer.concat([
    Buffer.from(
      `--${boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n${metadata}${delim}Content-Type: ${contentType}\r\n\r\n`
    ),
    fileData,
    Buffer.from(closeDelim),
  ]);

  const encodedDest = encodeURIComponent(destination);
  const res = await request(
    {
      hostname: 'storage.googleapis.com',
      path: `/upload/storage/v1/b/${encodeURIComponent(BUCKET)}/o?uploadType=multipart&name=${encodedDest}`,
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': `multipart/related; boundary="${boundary}"`,
        'Content-Length': body.length,
      },
    },
    body
  );

  if (res.status !== 200) throw new Error(`Storage upload failed: ${res.status} ${res.body}`);
}

async function updateFirestore(token, clubId, thumbnailUrl) {
  const body = JSON.stringify({
    fields: { thumbnailUrl: { stringValue: thumbnailUrl } },
  });

  const res = await request(
    {
      hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJECT}/databases/(default)/documents/clubs/${clubId}?updateMask.fieldPaths=thumbnailUrl`,
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    },
    body
  );

  if (res.status !== 200) throw new Error(`Firestore update failed: ${res.status} ${res.body}`);
}

async function run() {
  const token = execSync('gcloud auth print-access-token').toString().trim();
  console.log(`이미지 ${images.length}개, 클럽 ${CLUB_IDS.length}개\n`);

  for (let i = 0; i < CLUB_IDS.length; i++) {
    const clubId = CLUB_IDS[i];
    const imgFile = randomImage();
    const imgPath = path.join(IMAGE_DIR, imgFile);
    const ext = path.extname(imgFile).toLowerCase();
    const destination = `clubs/${clubId}/thumbnail${ext}`;
    const downloadToken = crypto.randomUUID();

    try {
      await uploadToStorage(token, imgPath, destination, contentTypeOf(imgFile), downloadToken);

      const encodedPath = encodeURIComponent(destination);
      const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodedPath}?alt=media&token=${downloadToken}`;

      await updateFirestore(token, clubId, downloadUrl);

      console.log(`[${i + 1}/${CLUB_IDS.length}] ✓ ${clubId.slice(0, 8)}… → ${imgFile.slice(0, 30)}`);
    } catch (err) {
      console.error(`[${i + 1}/${CLUB_IDS.length}] ✗ ${clubId}: ${err.message.slice(0, 80)}`);
    }
  }

  console.log('\n완료!');
}

run();
