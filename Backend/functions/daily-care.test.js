const test = require('node:test');
const assert = require('node:assert/strict');
const { ACTIONS, careDate, assignMissing } = require('./daily-care');

test('care day changes at 08:00 KST, including month/year rollover', () => {
  assert.equal(careDate(new Date('2026-01-01T07:59:59+09:00')), '2025-12-31');
  assert.equal(careDate(new Date('2026-01-01T08:00:00+09:00')), '2026-01-01');
});

test('four members receive distinct tasks', () => {
  const assigned = assignMissing({ a: '아빠', b: '엄마', c: '딸', d: '아들' });
  assert.deepEqual(Object.values(assigned).map(x => x.action).sort(), [...ACTIONS].sort());
  assert.ok(Object.values(assigned).every(x => x.completedAt === null));
});

test('retries preserve assignment and completion; late join only adds missing member', () => {
  const completed = { a: { action: ACTIONS[0], completedAt: 'saved timestamp' } };
  const assigned = assignMissing({ a: '아빠', b: '엄마' }, completed, () => 0);
  assert.deepEqual(assigned.a, completed.a);
  assert.notEqual(assigned.b.action, completed.a.action);
  assert.deepEqual(assignMissing({ a: '아빠', b: '엄마' }, assigned), assigned);
});

test('small and empty families are supported', () => {
  assert.deepEqual(assignMissing({}), {});
  assert.equal(Object.keys(assignMissing({ a: '아빠' })).length, 1);
});
