const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();

const candidates = [
  path.join(__dirname, 'dist', 'frontend', 'browser'),
  path.join(__dirname, 'dist', 'kit-monitor', 'browser')
];
const distPath = candidates.find(p => fs.existsSync(p)) || candidates[0];

app.use(express.static(distPath));
app.get('*', (_req, res) => res.sendFile(path.join(distPath, 'index.html')));

const port = process.env.PORT || 8080;
app.listen(port, '0.0.0.0', () => console.log(`Frontend listening on :${port} -> ${distPath}`));
