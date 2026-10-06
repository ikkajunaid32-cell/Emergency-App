-- ==============================================================
-- DAILY TASKS PLATFORM - RELATIONAL SQL SCHEMA
-- Target: SQLite 3 / PostgreSQL Compatible
-- ==============================================================

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK(role IN ('user', 'admin')),
    points INTEGER NOT NULL DEFAULT 0 CHECK(points >= 0),
    avatar_url TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tasks Table
CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    detailed_instructions TEXT NOT NULL,
    banner_url TEXT,
    category TEXT NOT NULL,
    points_reward INTEGER NOT NULL DEFAULT 100 CHECK(points_reward >= 0),
    deadline TEXT NOT NULL DEFAULT '24 Hours',
    required_submissions TEXT NOT NULL DEFAULT '["text"]', -- JSON Array string
    status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'archived')),
    created_by TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Submissions Table
CREATE TABLE IF NOT EXISTS submissions (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    task_title TEXT NOT NULL,
    points_reward INTEGER NOT NULL,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    user_email TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'approved', 'rejected')),
    text_response TEXT,
    photo_urls TEXT DEFAULT '[]', -- JSON Array string
    video_url TEXT,
    file_urls TEXT DEFAULT '[]', -- JSON Array string
    location_address TEXT,
    location_lat REAL,
    location_lng REAL,
    rejection_reason TEXT,
    reviewed_by TEXT,
    reviewed_at DATETIME,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

-- 4. Rewards Table
CREATE TABLE IF NOT EXISTS rewards (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    points_cost INTEGER NOT NULL CHECK(points_cost > 0),
    image_url TEXT,
    category TEXT NOT NULL,
    stock INTEGER NOT NULL DEFAULT 50 CHECK(stock >= 0),
    is_available INTEGER NOT NULL DEFAULT 1 CHECK(is_available IN (0, 1)),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 5. Redemptions Table
CREATE TABLE IF NOT EXISTS redemptions (
    id TEXT PRIMARY KEY,
    reward_id TEXT NOT NULL,
    reward_title TEXT NOT NULL,
    reward_image_url TEXT,
    points_cost INTEGER NOT NULL,
    user_id TEXT NOT NULL,
    user_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'fulfilled' CHECK(status IN ('pending', 'fulfilled', 'cancelled')),
    redeemed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(reward_id) REFERENCES rewards(id) ON DELETE CASCADE
);

-- 6. Point Transactions Ledger
CREATE TABLE IF NOT EXISTS point_transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    amount INTEGER NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('earned', 'spent')),
    title TEXT NOT NULL,
    description TEXT,
    reference_id TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes for high-performance querying
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_task_id ON submissions(task_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON submissions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON point_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_rewards_available ON rewards(is_available);
