const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');
const { FieldValue, FieldPath } = require('firebase-admin/firestore');
const { ACTIONS, careDate, assignMissing } = require('./daily-care');
const db = admin.firestore();

function identity(request) {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', '로그인이 필요해요.');
  const familyId = request.data?.familyId;
  if (typeof familyId !== 'string' || !/^[A-Z0-9]{8}$/.test(familyId)) {
    throw new HttpsError('invalid-argument', '가족 코드가 올바르지 않아요.');
  }
  return { uid, familyId };
}

async function ensureCare(familyId, uid, dateId = careDate()) {
  const family = db.collection('families').doc(familyId);
  const ref = family.collection('dailyCare').doc(dateId);
  await db.runTransaction(async tx => {
    const familyDoc = await tx.get(family);
    const members = familyDoc.data()?.members ?? {};
    if (!familyDoc.exists || (uid && !Object.hasOwn(members, uid))) {
      throw new HttpsError('permission-denied', '가족 구성원만 사용할 수 있어요.');
    }
    const snapshot = await tx.get(ref);
    const existing = snapshot.data() ?? {};
    const assignments = assignMissing(members, existing);
    if (Object.keys(assignments).length !== Object.keys(existing).length) tx.set(ref, assignments);
  });
  return dateId;
}

exports.ensureDailyCare = onCall(async request => {
  const { uid, familyId } = identity(request);
  return { dateId: await ensureCare(familyId, uid) };
});

exports.completeDailyCare = onCall(async request => {
  const { uid, familyId } = identity(request);
  const action = request.data?.action;
  if (!ACTIONS.includes(action)) throw new HttpsError('invalid-argument', '올바른 돌봄 행동이 아니에요.');
  const dateId = await ensureCare(familyId, uid);
  const family = db.collection('families').doc(familyId);
  const ref = family.collection('dailyCare').doc(dateId);
  return db.runTransaction(async tx => {
    const familyDoc = await tx.get(family);
    if (!Object.hasOwn(familyDoc.data()?.members ?? {}, uid)) {
      throw new HttpsError('permission-denied', '가족 구성원만 사용할 수 있어요.');
    }
    const snapshot = await tx.get(ref);
    const record = snapshot.data()?.[uid];
    if (!record || record.action !== action || record.completedAt) return { completed: false };
    tx.set(ref, { [uid]: { ...record, completedAt: FieldValue.serverTimestamp() } }, { merge: true });
    return { completed: true };
  });
});

exports.assignDailyCare = onSchedule({
  schedule: '0 8 * * *', timeZone: 'Asia/Seoul', retryCount: 3,
}, async event => {
  const dateId = careDate(new Date(event.scheduleTime));
  let cursor;
  while (true) {
    let query = db.collection('families').orderBy(FieldPath.documentId()).limit(100);
    if (cursor) query = query.startAfter(cursor);
    const page = await query.get();
    if (page.empty) break;
    for (const family of page.docs) await ensureCare(family.id, null, dateId);
    cursor = page.docs[page.docs.length - 1];
  }
});
