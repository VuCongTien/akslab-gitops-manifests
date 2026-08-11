const express = require('express');
const { Pool } = require('pg');
const fs = require('fs');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

function getSecret(secretName, envVarName, defaultValue) {
  const mountPath = `/mnt/secrets-store/${secretName}`;
  if (fs.existsSync(mountPath)) {
    try {
      return fs.readFileSync(mountPath, 'utf8').trim();
    } catch (err) {
      console.warn(`Warning: Could not read secret from ${mountPath}, using fallback.`);
    }
  }
  return process.env[envVarName] || defaultValue;
}

const dbHost = getSecret('db-host', 'DB_HOST', 'localhost');
const dbUser = getSecret('db-username', 'DB_USER', 'dbadmin');
const dbPassword = getSecret('db-password', 'DB_PASSWORD', 'P@ssw0rd2026!Lab');
const dbName = process.env.DB_NAME || 'backenddb';

console.log(`[Config] Connecting to Database Host: ${dbHost}, User: ${dbUser}, DB: ${dbName}`);

const pool = new Pool({
  host: dbHost,
  user: dbUser,
  password: dbPassword,
  database: dbName,
  port: 5432,
  ssl: { rejectUnauthorized: false },
  connectionTimeoutMillis: 5000
});

async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        category VARCHAR(50) NOT NULL DEFAULT 'General',
        price NUMERIC(10,2) NOT NULL,
        stock INT NOT NULL DEFAULT 10,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    const checkRes = await pool.query('SELECT COUNT(*) FROM products');
    if (parseInt(checkRes.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO products (name, category, price, stock) VALUES 
        ('Azure AKS Enterprise Node', 'Infrastructure', 199.99, 15),
        ('ArgoCD GitOps Sync Engine', 'DevOps Tools', 49.99, 25),
        ('Key Vault Secrets CSI Driver', 'Security', 29.99, 50);
      `);
      console.log('[DB Init] Sample CRUD products inserted successfully.');
    }
  } catch (err) {
    console.error('[DB Init Error]:', err.message);
  }
}
initDatabase();


app.get('/api/health', async (req, res) => {
  try {
    const dbRes = await pool.query('SELECT NOW() as db_time');
    res.json({
      status: 'UP',
      service: 'Backend CRUD API',
      database: 'Connected (PostgreSQL Flexible Server)',
      dbTime: dbRes.rows[0].db_time,
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({
      status: 'DEGRADED',
      service: 'Backend CRUD API',
      database: 'Disconnected',
      error: err.message,
      timestamp: new Date().toISOString()
    });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id DESC');
    res.json({ success: true, data: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/api/products', async (req, res) => {
  const { name, category, price, stock } = req.body;
  if (!name || !price) {
    return res.status(400).json({ success: false, error: 'Name and price are required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO products (name, category, price, stock) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, category || 'General', parseFloat(price), parseInt(stock) || 10]
    );
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.put('/api/products/:id', async (req, res) => {
  const { id } = req.params;
  const { name, category, price, stock } = req.body;

  try {
    const result = await pool.query(
      `UPDATE products 
       SET name = COALESCE($1, name), 
           category = COALESCE($2, category), 
           price = COALESCE($3, price), 
           stock = COALESCE($4, stock),
           updated_at = CURRENT_TIMESTAMP 
       WHERE id = $5 RETURNING *`,
      [name, category, price, stock, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.delete('/api/products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM products WHERE id = $1 RETURNING *', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }
    res.json({ success: true, message: `Product ID ${id} deleted successfully.` });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`Backend CRUD API listening on port ${PORT}`);
});
