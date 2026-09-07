const { randomInt } = require('node:crypto');
const ACTIONS = ['🍚 밥 주기', '🛁 목욕', '🎾 놀기', '😴 재우기'];

// Care days start at 08:00 Asia/Seoul (UTC+9 minus 8 hours).
function careDate(now = new Date()) {
  return new Date(now.getTime() + 3600000).toISOString().slice(0, 10);
}

function assignMissing(members, existing = {}, pick = randomInt) {
  const result = { ...existing };
  const available = ACTIONS.filter(action =>
    !Object.values(existing).some(record => record.action === action));
  for (const uid of Object.keys(members).sort()) {
    if (result[uid]) continue;
    const pool = available.length ? available : [...ACTIONS];
    const [action] = pool.splice(pick(pool.length), 1);
    result[uid] = { action, completedAt: null };
  }
  return result;
}

module.exports = { ACTIONS, careDate, assignMissing };
