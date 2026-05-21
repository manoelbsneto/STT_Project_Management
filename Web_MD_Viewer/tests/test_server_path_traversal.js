const test = require('node:test');
const assert = require('node:assert');
const http = require('http');
const { server } = require('../cockpit-server');

test('Server Security Tests', async (t) => {
  let srv;
  let port;
  
  await t.test('start server', () => {
    return new Promise(resolve => {
      srv = server.listen(0, '127.0.0.1', () => {
        port = srv.address().port;
        resolve();
      });
    });
  });

  const makeRequest = (path) => {
    return new Promise((resolve, reject) => {
      http.get(`http://127.0.0.1:${port}${path}`, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => resolve({ statusCode: res.statusCode, data }));
      }).on('error', reject);
    });
  };

  await t.test('Prevent path traversal with dot dot slash', async () => {
    const res = await makeRequest('/api/prompts/..%2f..%2f/content');
    assert.strictEqual(res.statusCode, 404);
  });
  
  await t.test('Prevent path traversal with special characters', async () => {
    const res = await makeRequest('/api/prompts/some_file!/content');
    assert.strictEqual(res.statusCode, 404);
  });
  
  await t.test('Prevent path traversal directly accessing root', async () => {
    const res = await makeRequest('/api/prompts/../../../../Windows/System32/cmd.exe/content');
    assert.strictEqual(res.statusCode, 404);
  });

  await t.test('stop server', () => {
    return new Promise(resolve => srv.close(resolve));
  });
});
