const test = require('node:test');
const assert = require('node:assert');
const http = require('http');
const { server } = require('../cockpit-server');

test('Server Health Tests', async (t) => {
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

  await t.test('GET /api/health should return 200 OK', async () => {
    const res = await makeRequest('/api/health');
    assert.strictEqual(res.statusCode, 200);
    const body = JSON.parse(res.data);
    assert.strictEqual(body.status, 'ok');
  });

  await t.test('stop server', () => {
    return new Promise(resolve => srv.close(resolve));
  });
});
