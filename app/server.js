const express = require('express');
const app = express();
app.get('/', (_, res) => res.json({ ok: true, service: 'harsh-app', ts: Date.now() }));
app.listen(8080, () => console.log('harsh-app on :8080'));
