const test = require('node:test');
const assert = require('node:assert');
const { parseCheckinBoard, parseActivityLog, parseFileLocks, parseHandoffs } = require('../cockpit-server');

test('Parsers Unit Tests', async (t) => {
  await t.test('parseCheckinBoard should parse active agents and phases', async () => {
    const res = await parseCheckinBoard();
    assert.ok(res, 'Result should not be null');
    assert.ok(Array.isArray(res.active_agents_table), 'Should parse active agents table');
    assert.ok(Array.isArray(res.phase_tracker), 'Should parse phase tracker');
    assert.ok(res.stats.total_agents_in_fleet === 13, 'Total agents should be 13');
  });

  await t.test('parseActivityLog should parse recent activity', async () => {
    const res = await parseActivityLog(null, 50);
    assert.ok(res, 'Result should not be null');
    assert.ok(Array.isArray(res.entries), 'Should have entries array');
  });

  await t.test('parseFileLocks should parse lock history', async () => {
    const res = await parseFileLocks();
    assert.ok(res, 'Result should not be null');
    assert.ok(Array.isArray(res.active_locks), 'Should have active_locks array');
  });

  await t.test('parseHandoffs should parse handoff relationships', async () => {
    const res = await parseHandoffs();
    assert.ok(res, 'Result should not be null');
    assert.ok(Array.isArray(res.active_handoffs_pending), 'Should have pending handoffs array');
    assert.ok(Array.isArray(res.handoff_history), 'Should have handoff history array');
    assert.ok(res.graph, 'Should have graph object');
  });
});
