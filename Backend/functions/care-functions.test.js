const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const { ACTIONS, careDate } = require('./daily-care');

// Exercise callable handlers against an in-memory transaction adapter.
// Production transaction conflict retries and rules still need the Firebase emulator.
function setup() {
  const familyPath = 'families/ABCDEFGH';
  const carePath = `${familyPath}/dailyCare/${careDate()}`;
  const records = new Map([[familyPath, { members: { dad: '아빠', mom: '엄마' } }]]);
  const ref = id => ({ id, collection: name => ref(`${id}/${name}`), doc: name => ref(`${id}/${name}`) });
  const db = {
    collection: ref,
    runTransaction: async callback => callback({
      get: async document => ({ exists: records.has(document.id), data: () => records.get(document.id) }),
      set: (document, value, options) => records.set(document.id,
        options?.merge ? { ...records.get(document.id), ...value } : value),
    }),
  };
  const firestore = () => db;
  firestore.FieldValue = { serverTimestamp: () => 'server-time' };
  class HttpsError extends Error {
    constructor(code, message) { super(message); this.code = code; }
  }
  const context = {
    exports: {}, require: name => {
      if (name === 'firebase-admin') return { firestore };
      if (name === 'firebase-admin/firestore') return { FieldValue: firestore.FieldValue };
      if (name === 'firebase-functions/v2/https') return { onCall: callback => callback, HttpsError };
      if (name === 'firebase-functions/v2/scheduler') return { onSchedule: (_, callback) => callback };
      return require(name);
    },
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, 'care-functions.js'), 'utf8'), context);
  return { api: context.exports, records, carePath };
}

test('assignment requires authentication and actual family membership', async () => {
  const { api } = setup();
  await assert.rejects(api.ensureDailyCare({ data: { familyId: 'ABCDEFGH' } }), { code: 'unauthenticated' });
  await assert.rejects(api.ensureDailyCare({ auth: { uid: 'outsider' }, data: { familyId: 'ABCDEFGH' } }), { code: 'permission-denied' });
  await assert.rejects(api.ensureDailyCare({ auth: { uid: 'dad' }, data: { familyId: '../other' } }), { code: 'invalid-argument' });
});

test('completion only updates authenticated member and matching task, once', async () => {
  const { api, records, carePath } = setup();
  const request = { auth: { uid: 'dad' }, data: { familyId: 'ABCDEFGH' } };
  await api.ensureDailyCare(request);
  const assigned = records.get(carePath);
  const wrongAction = ACTIONS.find(action => action !== assigned.dad.action);
  assert.equal((await api.completeDailyCare({ ...request, data: { ...request.data, action: wrongAction } })).completed, false);
  const complete = { ...request, data: { ...request.data, uid: 'mom', action: assigned.dad.action } };
  assert.equal((await api.completeDailyCare(complete)).completed, true);
  assert.equal(records.get(carePath).dad.completedAt, 'server-time');
  assert.equal(records.get(carePath).mom.completedAt, null);
  assert.equal((await api.completeDailyCare(complete)).completed, false);
});
