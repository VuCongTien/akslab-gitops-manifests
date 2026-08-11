const express = require('express');
const axios = require('axios');
const path = require('path');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const backendUrl = process.env.BACKEND_URL || 'http://localhost:8080';

console.log(`[Frontend Service] Proxying requests to Backend: ${backendUrl}`);

app.get('/api/proxy/health', async (req, res) => {
  try {
    const response = await axios.get(`${backendUrl}/api/health`, { timeout: 4000 });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ status: 'DEGRADED', error: err.message });
  }
});

app.get('/api/proxy/products', async (req, res) => {
  try {
    const response = await axios.get(`${backendUrl}/api/products`, { timeout: 4000 });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/api/proxy/products', async (req, res) => {
  try {
    const response = await axios.post(`${backendUrl}/api/products`, req.body, { timeout: 4000 });
    res.status(201).json(response.data);
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.put('/api/proxy/products/:id', async (req, res) => {
  try {
    const response = await axios.put(`${backendUrl}/api/products/${req.params.id}`, req.body, { timeout: 4000 });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.delete('/api/proxy/products/:id', async (req, res) => {
  try {
    const response = await axios.delete(`${backendUrl}/api/products/${req.params.id}`, { timeout: 4000 });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 80;
app.listen(PORT, () => {
  console.log(`Frontend Application listening on port ${PORT}`);
});
