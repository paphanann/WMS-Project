const https = require('https');

function buildPath(q) {
  let filter =
    "Items/ItemCode eq Items/ItemWarehouseInfoCollection/ItemCode" +
    " and Items/InventoryItem eq 'tYES'";

  if (q) {
    const term = q.replace(/'/g, "''");
    filter +=
      " and (contains(Items/ItemCode,'" +
      term +
      "') or contains(Items/ItemName,'" +
      term +
      "'))";
  }

  return (
    '$crossjoin(Items,Items/ItemWarehouseInfoCollection)' +
    '?$expand=Items($select=ItemCode,ItemName),' +
    'Items/ItemWarehouseInfoCollection($select=WarehouseCode)' +
    '&$filter=' +
    encodeURIComponent(filter)
  );
}

function sapGet(host, port, path, sessionId, routeId) {
  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: host,
        port: port || 50000,
        path: `/b1s/v1/${path}`,
        method: 'GET',
        agent: new https.Agent({ rejectUnauthorized: false }),
        headers: {
          Cookie: `B1SESSION=${sessionId}; ROUTEID=${routeId}`,
          Accept: 'application/json',
        },
      },
      (res) => {
        let body = '';
        res.on('data', (c) => (body += c));
        res.on('end', () => {
          if (res.statusCode !== 200) {
            reject(new Error(body || `SAP ${res.statusCode}`));
            return;
          }
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            reject(e);
          }
        });
      },
    );
    req.on('error', reject);
    req.end();
  });
}

function toProducts(payload) {
  const rows = payload.value || [];
  const out = [];
  const seen = {};

  for (let i = 0; i < rows.length; i++) {
    const item = rows[i].Items;
    if (!item || !item.ItemCode || seen[item.ItemCode]) continue;
    seen[item.ItemCode] = true;
    out.push({
      itemCode: item.ItemCode,
      itemName: item.ItemName || '',
    });
  }

  return out;
}

function registerProductRoutes(app, opts) {
  opts = opts || {};
  const host = opts.sapHost || process.env.SAP_HOST || 'localhost';
  const port = opts.sapPort || process.env.SAP_PORT || 50000;

  app.get('/api/products', async (req, res) => {
    const sessionId = req.get('X-Session-Id');
    const routeId = req.get('X-Route-Id');
    if (!sessionId || !routeId) {
      return res.status(401).json({ success: false, message: 'กรุณาเข้าสู่ระบบก่อน' });
    }

    try {
      const q = (req.query.q || '').trim();
      const payload = await sapGet(host, port, buildPath(q), sessionId, routeId);
      const data = toProducts(payload);
      res.json({ success: true, count: data.length, data });
    } catch (err) {
      console.error('products', err.message);
      res.status(500).json({ success: false, message: 'โหลดสินค้าไม่สำเร็จ' });
    }
  });
}

module.exports = { registerProductRoutes };
