// Run only against local Firebase emulators: node care-smoke.cjs
const assert = require('node:assert/strict');
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';
const admin = require('firebase-admin');
admin.initializeApp({ projectId: 'demo-mira-care' });
const db = admin.firestore();
const authUrl = 'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1';
const base = 'http://127.0.0.1:5001/demo-mira-care/us-central1';
const familyId = 'TESTCARE';

async function account(email) {
  const body = { email, password: 'CareTest123!', returnSecureToken: true };
  let response = await fetch(`${authUrl}/accounts:signUp?key=demo-api-key`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
  });
  if (!response.ok) response = await fetch(`${authUrl}/accounts:signInWithPassword?key=demo-api-key`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
  });
  assert.equal(response.status, 200);
  return response.json();
}

async function call(name, data, token) {
  const response = await fetch(`${base}/${name}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: JSON.stringify({ data }),
  });
  return { status: response.status, body: await response.json() };
}

async function main() {
  const dad = await account('dad@care.test');
  const mom = await account('mom@care.test');
  const outsider = await account('outsider@care.test');
  await db.doc(`families/${familyId}`).set({ members: { [dad.localId]: '아빠', [mom.localId]: '엄마' } });
  for (const [user, role] of [[dad, '아빠'], [mom, '엄마']]) {
    await db.doc(`users/${user.localId}`).set({ name: role, role, familyId, email: user.email });
  }
  // Repeatable test: only reset this fixture in the isolated demo emulator.
  const { careDate, ACTIONS } = require('./daily-care');
  const ref = db.doc(`families/${familyId}/dailyCare/${careDate()}`);
  await ref.delete();
  const results = await Promise.all(Array.from({ length: 8 }, (_, i) =>
    call('ensureDailyCare', { familyId }, (i % 2 ? dad : mom).idToken)));
  assert.ok(results.every(r => r.status === 200), JSON.stringify(results));
  const before = (await ref.get()).data();
  assert.equal(Object.keys(before).length, 2);
  assert.notEqual(before[dad.localId].action, before[mom.localId].action);
  console.log('PASS: concurrent authenticated requests share one assignment');
  assert.equal((await call('ensureDailyCare', { familyId })).status, 401);
  assert.equal((await call('ensureDailyCare', { familyId }, outsider.idToken)).status, 403);
  const wrong = ACTIONS.find(a => a !== before[dad.localId].action);
  assert.equal((await call('completeDailyCare', { familyId, action: wrong }, dad.idToken)).body.result.completed, false);
  const completed = await call('completeDailyCare', { familyId, action: before[dad.localId].action }, dad.idToken);
  assert.equal(completed.body.result.completed, true, JSON.stringify(completed));
  const after = (await ref.get()).data();
  assert.ok(after[dad.localId].completedAt);
  assert.equal(after[mom.localId].completedAt, null);
  assert.equal((await call('completeDailyCare', { familyId, action: before[dad.localId].action }, dad.idToken)).body.result.completed, false);
  console.log('PASS: auth, membership, matching action and idempotent completion');
  const firestoreUrl = `http://127.0.0.1:8080/v1/projects/demo-mira-care/databases/(default)/documents/families/${familyId}/dailyCare/${careDate()}`;
  const read = await fetch(firestoreUrl, { headers: { Authorization: `Bearer ${mom.idToken}` } });
  assert.equal(read.status, 200);
  const write = await fetch(firestoreUrl, { method: 'PATCH', headers: {
    Authorization: `Bearer ${mom.idToken}`, 'Content-Type': 'application/json',
  }, body: JSON.stringify({ fields: {} }) });
  assert.equal(write.status, 403);
  console.log('PASS: deployed emulator rules allow family reads and reject direct writes');
  // Leave a known overdue feeding fixture for the user's manual UI check.
  await ref.set({ [dad.localId]: { action: ACTIONS[0], completedAt: null },
    [mom.localId]: { action: ACTIONS[2], completedAt: null } });
  console.log('UI accounts: dad@care.test / mom@care.test; password: CareTest123!');
}

main().then(() => db.terminate()).catch(error => { console.error(error); process.exitCode = 1; db.terminate(); });
