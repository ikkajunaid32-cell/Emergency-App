// ==============================================================
// DAILY TASKS PLATFORM - ZERO-DEPENDENCY SQL BACKEND SERVER
// Built with native Node.js (v22+) node:sqlite module
// Runs immediately with: node backend_sql/server.js
// ==============================================================

const http = require('http');
const fs = require('fs');
const path = require('path');
const { DatabaseSync } = require('node:sqlite');
const crypto = require('crypto');

const PORT = process.env.PORT || 5000;
const DB_PATH = path.join(__dirname, 'tasks_app.sqlite');
const UPLOAD_DIR = path.join(__dirname, 'uploads');
const ADMIN_DIR = path.join(__dirname, '..', 'admin_dashboard');

// Ensure uploads folder exists
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

// Initialize SQLite Database
console.log(`[SQL Database] Connecting to SQLite at ${DB_PATH}...`);
const db = new DatabaseSync(DB_PATH);

// Run initial schema & seed
function initDatabase() {
  try {
    const schemaSql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
    db.exec(schemaSql);
    console.log('[SQL Database] Relational Schema verified / migrated successfully.');

    // Check if tasks table is populated
    const countStmt = db.prepare('SELECT COUNT(*) as count FROM tasks');
    const result = countStmt.get();
    if (result.count === 0) {
      console.log('[SQL Database] Seeding initial data from seed.sql...');
      const seedSql = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf8');
      db.exec(seedSql);
      console.log('[SQL Database] Seed data loaded successfully.');
    }
  } catch (err) {
    console.error('[SQL Database] Error during initialization:', err);
  }
}
initDatabase();

// CORS Headers Helper
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

// JSON Response Helper
function sendJson(res, statusCode, data) {
  setCorsHeaders(res);
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

// Request Body Parser
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
    });
    req.on('end', () => {
      try {
        if (!body) {
          resolve({});
        } else {
          resolve(JSON.parse(body));
        }
      } catch {
        resolve({ raw: body });
      }
    });
    req.on('error', reject);
  });
}

// HTTP Server Request Handler
const server = http.createServer(async (req, res) => {
  setCorsHeaders(res);

  // Handle OPTIONS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  try {
    // ==========================================
    // HEALTH CHECK
    // ==========================================
    if (pathname === '/api/health' && method === 'GET') {
      return sendJson(res, 200, {
        status: 'online',
        database: 'sqlite',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
      });
    }

    // ==========================================
    // AUTHENTICATION & USERS
    // ==========================================
    // Register
    if (pathname === '/api/auth/register' && method === 'POST') {
      const { name, email, phone, password, role } = await parseBody(req);
      if (!name || !email || !password) {
        return sendJson(res, 400, { error: 'Name, email, and password are required' });
      }

      // Check if user exists
      const checkStmt = db.prepare('SELECT id FROM users WHERE email = ?');
      const existing = checkStmt.get(email.trim().toLowerCase());
      if (existing) {
        return sendJson(res, 409, { error: 'Email already registered' });
      }

      const id = 'usr_' + crypto.randomUUID().substring(0, 8);
      const userRole = (role === 'admin') ? 'admin' : 'user';
      const initialPoints = userRole === 'admin' ? 9999 : 0;
      const passHash = crypto.createHash('sha256').update(password).digest('hex');

      const insertStmt = db.prepare(`
        INSERT INTO users (id, name, email, phone, password_hash, role, points, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
      `);
      insertStmt.run(id, name.trim(), email.trim().toLowerCase(), phone || '', passHash, userRole, initialPoints);

      const user = db.prepare('SELECT id, name, email, phone, role, points, avatar_url, created_at FROM users WHERE id = ?').get(id);
      return sendJson(res, 201, { user });
    }

    // Login
    if (pathname === '/api/auth/login' && method === 'POST') {
      const { email, password } = await parseBody(req);
      if (!email || !password) {
        return sendJson(res, 400, { error: 'Email and password required' });
      }

      const stmt = db.prepare('SELECT id, name, email, phone, password_hash, role, points, avatar_url, created_at FROM users WHERE email = ?');
      const user = stmt.get(email.trim().toLowerCase());

      if (!user) {
        return sendJson(res, 401, { error: 'Invalid email or password' });
      }

      // Check hash or demo bypass
      const passHash = crypto.createHash('sha256').update(password).digest('hex');
      if (user.password_hash !== passHash && !user.password_hash.startsWith('demo_hash') && password !== 'password123') {
        return sendJson(res, 401, { error: 'Invalid credentials' });
      }

      delete user.password_hash;
      return sendJson(res, 200, { user });
    }

    // Get all users (Admin view)
    if (pathname === '/api/auth/users' && method === 'GET') {
      const users = db.prepare('SELECT id, name, email, phone, role, points, avatar_url, created_at FROM users ORDER BY points DESC').all();
      return sendJson(res, 200, { users });
    }

    // Update profile
    if (pathname.startsWith('/api/auth/users/') && method === 'PATCH') {
      const id = pathname.split('/').pop();
      const { name, phone } = await parseBody(req);
      db.prepare('UPDATE users SET name = COALESCE(?, name), phone = COALESCE(?, phone) WHERE id = ?').run(name, phone, id);
      const user = db.prepare('SELECT id, name, email, phone, role, points, avatar_url, created_at FROM users WHERE id = ?').get(id);
      return sendJson(res, 200, { user });
    }

    // ==========================================
    // TASKS (EXPLORE & ADMIN)
    // ==========================================
    // List Tasks
    if (pathname === '/api/tasks' && method === 'GET') {
      const status = parsedUrl.searchParams.get('status') || 'active';
      const category = parsedUrl.searchParams.get('category');
      
      let query = 'SELECT * FROM tasks WHERE status = ?';
      const params = [status];
      if (category && category !== 'All') {
        query += ' AND category = ?';
        params.push(category);
      }
      query += ' ORDER BY created_at DESC';

      const rows = db.prepare(query).all(...params);
      const tasks = rows.map(r => ({
        ...r,
        required_submissions: JSON.parse(r.required_submissions || '["text"]')
      }));
      return sendJson(res, 200, { tasks });
    }

    // Create Task (Admin)
    if (pathname === '/api/tasks' && method === 'POST') {
      const body = await parseBody(req);
      const id = body.id || 'task_' + crypto.randomUUID().substring(0, 8);
      const reqSubmissions = JSON.stringify(body.required_submissions || ['text']);

      const stmt = db.prepare(`
        INSERT INTO tasks (id, title, description, detailed_instructions, banner_url, category, points_reward, deadline, required_submissions, status, created_by, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
      `);
      stmt.run(
        id,
        body.title || 'Untitled Task',
        body.description || '',
        body.detailed_instructions || '',
        body.banner_url || 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
        body.category || 'Community',
        parseInt(body.points_reward) || 100,
        body.deadline || '24 Hours',
        reqSubmissions,
        body.status || 'active',
        body.created_by || 'admin'
      );

      const task = db.prepare('SELECT * FROM tasks WHERE id = ?').get(id);
      task.required_submissions = JSON.parse(task.required_submissions);
      return sendJson(res, 201, { task });
    }

    // Delete Task
    if (pathname.startsWith('/api/tasks/') && method === 'DELETE') {
      const id = pathname.split('/').pop();
      db.prepare('DELETE FROM tasks WHERE id = ?').run(id);
      return sendJson(res, 200, { message: 'Task deleted successfully', id });
    }

    // ==========================================
    // SUBMISSIONS & EVIDENCE VERIFICATION
    // ==========================================
    // List submissions
    if (pathname === '/api/submissions' && method === 'GET') {
      const userId = parsedUrl.searchParams.get('userId');
      const status = parsedUrl.searchParams.get('status');

      let query = 'SELECT * FROM submissions WHERE 1=1';
      const params = [];
      if (userId) {
        query += ' AND user_id = ?';
        params.push(userId);
      }
      if (status) {
        query += ' AND status = ?';
        params.push(status);
      }
      query += ' ORDER BY submitted_at DESC';

      const rows = db.prepare(query).all(...params);
      const submissions = rows.map(s => ({
        ...s,
        photo_urls: JSON.parse(s.photo_urls || '[]'),
        file_urls: JSON.parse(s.file_urls || '[]')
      }));
      return sendJson(res, 200, { submissions });
    }

    // Submit proof (Citizen)
    if (pathname === '/api/submissions' && method === 'POST') {
      const body = await parseBody(req);
      const id = body.id || 'sub_' + crypto.randomUUID().substring(0, 8);
      const photoUrls = JSON.stringify(body.photo_urls || []);
      const fileUrls = JSON.stringify(body.file_urls || []);

      const stmt = db.prepare(`
        INSERT INTO submissions (id, task_id, task_title, points_reward, user_id, user_name, user_email, status, text_response, photo_urls, video_url, file_urls, location_address, location_lat, location_lng, submitted_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?, ?, ?, datetime('now'))
      `);
      stmt.run(
        id,
        body.task_id,
        body.task_title || '',
        parseInt(body.points_reward) || 0,
        body.user_id,
        body.user_name || 'Anonymous',
        body.user_email || '',
        body.text_response || '',
        photoUrls,
        body.video_url || null,
        fileUrls,
        body.location_address || null,
        body.location_lat || null,
        body.location_lng || null
      );

      const sub = db.prepare('SELECT * FROM submissions WHERE id = ?').get(id);
      sub.photo_urls = JSON.parse(sub.photo_urls);
      sub.file_urls = JSON.parse(sub.file_urls);
      return sendJson(res, 201, { submission: sub });
    }

    // Review Submission (Admin approve / reject with atomic points award)
    if (pathname.startsWith('/api/submissions/') && pathname.endsWith('/review') && (method === 'PATCH' || method === 'POST')) {
      const parts = pathname.split('/');
      const id = parts[3];
      const { approve, rejection_reason, reviewed_by } = await parseBody(req);

      const sub = db.prepare('SELECT * FROM submissions WHERE id = ?').get(id);
      if (!sub) {
        return sendJson(res, 404, { error: 'Submission not found' });
      }

      const newStatus = approve ? 'approved' : 'rejected';
      const reviewer = reviewed_by || 'System Administrator';
      const reason = approve ? null : (rejection_reason || 'Did not meet requirements');

      // ATOMIC TRANSACTION: update submission & credit points
      db.exec('BEGIN TRANSACTION');
      try {
        db.prepare(`
          UPDATE submissions 
          SET status = ?, rejection_reason = ?, reviewed_by = ?, reviewed_at = datetime('now')
          WHERE id = ?
        `).run(newStatus, reason, reviewer, id);

        if (approve && sub.status !== 'approved') {
          // Add points to user in SQL database
          db.prepare('UPDATE users SET points = points + ? WHERE id = ?').run(sub.points_reward, sub.user_id);

          // Record in point ledger
          const txId = 'tx_' + crypto.randomUUID().substring(0, 8);
          db.prepare(`
            INSERT INTO point_transactions (id, user_id, amount, type, title, description, timestamp)
            VALUES (?, ?, ?, 'earned', ?, 'Task approved by Administrator', datetime('now'))
          `).run(txId, sub.user_id, sub.points_reward, sub.task_title);
        }

        db.exec('COMMIT');
      } catch (txErr) {
        db.exec('ROLLBACK');
        throw txErr;
      }

      const updatedSub = db.prepare('SELECT * FROM submissions WHERE id = ?').get(id);
      updatedSub.photo_urls = JSON.parse(updatedSub.photo_urls);
      updatedSub.file_urls = JSON.parse(updatedSub.file_urls);
      return sendJson(res, 200, { submission: updatedSub });
    }

    // ==========================================
    // REWARDS & POINT REDEMPTIONS
    // ==========================================
    // List rewards
    if (pathname === '/api/rewards' && method === 'GET') {
      const rewards = db.prepare('SELECT * FROM rewards WHERE is_available = 1 ORDER BY points_cost ASC').all();
      return sendJson(res, 200, { rewards });
    }

    // Create reward (Admin)
    if (pathname === '/api/rewards' && method === 'POST') {
      const body = await parseBody(req);
      const id = body.id || 'rew_' + crypto.randomUUID().substring(0, 8);
      db.prepare(`
        INSERT INTO rewards (id, title, description, points_cost, image_url, category, stock, is_available, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, datetime('now'))
      `).run(
        id,
        body.title,
        body.description || '',
        parseInt(body.points_cost) || 100,
        body.image_url || 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
        body.category || 'General',
        parseInt(body.stock) || 50
      );
      const reward = db.prepare('SELECT * FROM rewards WHERE id = ?').get(id);
      return sendJson(res, 201, { reward });
    }

    // Redeem reward (Atomic points deduction & stock decrement)
    if (pathname === '/api/rewards/redeem' && method === 'POST') {
      const { user_id, reward_id } = await parseBody(req);

      const user = db.prepare('SELECT * FROM users WHERE id = ?').get(user_id);
      const reward = db.prepare('SELECT * FROM rewards WHERE id = ?').get(reward_id);

      if (!user || !reward) {
        return sendJson(res, 404, { error: 'User or reward not found' });
      }

      if (user.points < reward.points_cost) {
        return sendJson(res, 400, { error: 'Insufficient points balance' });
      }

      const redemptionId = 'red_' + crypto.randomUUID().substring(0, 8);
      const txId = 'tx_' + crypto.randomUUID().substring(0, 8);

      db.exec('BEGIN TRANSACTION');
      try {
        // Deduct points
        db.prepare('UPDATE users SET points = points - ? WHERE id = ?').run(reward.points_cost, user.id);

        // Record redemption
        db.prepare(`
          INSERT INTO redemptions (id, reward_id, reward_title, reward_image_url, points_cost, user_id, user_name, status, redeemed_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, 'fulfilled', datetime('now'))
        `).run(redemptionId, reward.id, reward.title, reward.image_url, reward.points_cost, user.id, user.name);

        // Record ledger transaction
        db.prepare(`
          INSERT INTO point_transactions (id, user_id, amount, type, title, description, reference_id, timestamp)
          VALUES (?, ?, ?, 'spent', ?, 'Redeemed in Rewards Store', ?, datetime('now'))
        `).run(txId, user.id, reward.points_cost, reward.title, redemptionId);

        // Decrement stock if greater than 0
        if (reward.stock > 0) {
          db.prepare('UPDATE rewards SET stock = stock - 1 WHERE id = ?').run(reward.id);
        }

        db.exec('COMMIT');
      } catch (e) {
        db.exec('ROLLBACK');
        throw e;
      }

      const updatedUser = db.prepare('SELECT id, name, email, points FROM users WHERE id = ?').get(user.id);
      return sendJson(res, 200, {
        message: 'Redeemed successfully',
        redemption_id: redemptionId,
        user: updatedUser,
      });
    }

    // Redemptions history
    if (pathname === '/api/redemptions' && method === 'GET') {
      const userId = parsedUrl.searchParams.get('userId');
      let query = 'SELECT * FROM redemptions';
      const params = [];
      if (userId) {
        query += ' WHERE user_id = ?';
        params.push(userId);
      }
      query += ' ORDER BY redeemed_at DESC';
      const redemptions = db.prepare(query).all(...params);
      return sendJson(res, 200, { redemptions });
    }

    // Ledger transactions
    if (pathname === '/api/transactions' && method === 'GET') {
      const userId = parsedUrl.searchParams.get('userId');
      let query = 'SELECT * FROM point_transactions';
      const params = [];
      if (userId) {
        query += ' WHERE user_id = ?';
        params.push(userId);
      }
      query += ' ORDER BY timestamp DESC';
      const transactions = db.prepare(query).all(...params);
      return sendJson(res, 200, { transactions });
    }

    // ==========================================
    // MULTI-MODAL UPLOADS (Base64 / Binary)
    // ==========================================
    if (pathname === '/api/upload' && method === 'POST') {
      const body = await parseBody(req);
      if (!body.data) {
        return sendJson(res, 400, { error: 'No upload data provided' });
      }

      const fileExt = body.extension || 'jpg';
      const fileName = `proof_${Date.now()}_${crypto.randomUUID().substring(0, 6)}.${fileExt}`;
      const filePath = path.join(UPLOAD_DIR, fileName);

      // Clean base64 header if present
      const base64Data = body.data.replace(/^data:([A-Za-z-+/]+);base64,/, '');
      fs.writeFileSync(filePath, Buffer.from(base64Data, 'base64'));

      const publicUrl = `http://localhost:${PORT}/uploads/${fileName}`;
      return sendJson(res, 201, { url: publicUrl, filename: fileName });
    }

    // Serve uploaded files statically
    if (pathname.startsWith('/uploads/') && method === 'GET') {
      const filename = path.basename(pathname);
      const filePath = path.join(UPLOAD_DIR, filename);
      if (fs.existsSync(filePath)) {
        res.writeHead(200);
        return fs.createReadStream(filePath).pipe(res);
      } else {
        res.writeHead(404);
        return res.end('File not found');
      }
    }

    // ==========================================
    // STATIC ADMIN DASHBOARD WEB PORTAL
    // ==========================================
    if (pathname === '/' || pathname === '/index.html' || pathname.startsWith('/admin')) {
      const fileToServe = pathname === '/app.js' 
        ? path.join(ADMIN_DIR, 'app.js') 
        : path.join(ADMIN_DIR, 'index.html');

      if (fs.existsSync(fileToServe)) {
        const ext = path.extname(fileToServe);
        const contentType = ext === '.js' ? 'application/javascript' : 'text/html';
        res.writeHead(200, { 'Content-Type': contentType });
        return fs.createReadStream(fileToServe).pipe(res);
      }
    }

    if (pathname === '/app.js') {
      const fileToServe = path.join(ADMIN_DIR, 'app.js');
      if (fs.existsSync(fileToServe)) {
        res.writeHead(200, { 'Content-Type': 'application/javascript' });
        return fs.createReadStream(fileToServe).pipe(res);
      }
    }

    // Default 404 for unknown endpoints
    return sendJson(res, 404, { error: 'Endpoint not found', path: pathname });

  } catch (error) {
    console.error(`[SQL Server Error] ${method} ${pathname}:`, error);
    return sendJson(res, 500, { error: error.message || 'Internal Server Error' });
  }
});

server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 DAILY TASKS SQL SERVER RUNNING ON PORT ${PORT}`);
  console.log(`📁 SQLite Database: ${DB_PATH}`);
  console.log(`🌐 Web Admin Dashboard: http://localhost:${PORT}`);
  console.log(`📡 REST API Health:     http://localhost:${PORT}/api/health`);
  console.log(`📋 API Tasks:           http://localhost:${PORT}/api/tasks`);
  console.log(`=======================================================`);
});
