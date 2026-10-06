-- ==============================================================
-- DAILY TASKS PLATFORM - INITIAL SEED DATA
-- ==============================================================

-- Demo Users (passwords are simple demo hashes: 'password123')
INSERT OR IGNORE INTO users (id, name, email, phone, password_hash, role, points, avatar_url, created_at)
VALUES 
('usr_admin_1', 'System Administrator', 'admin@eatclubtasks.com', '+1 555-0100', 'demo_hash_admin', 'admin', 9999, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', datetime('now', '-30 days')),
('usr_user_1', 'Jordan Lee', 'citizen@eatclubtasks.com', '0412 345 678', 'demo_hash_user', 'user', 420, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400', datetime('now', '-15 days')),
('usr_user_2', 'Alex Johnson', 'alex@example.com', '0423 456 789', 'demo_hash_alex', 'user', 150, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', datetime('now', '-10 days')),
('usr_user_3', 'Sarah Miller', 'sarah@example.com', '0434 567 890', 'demo_hash_sarah', 'user', 380, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', datetime('now', '-5 days'));

-- Daily Tasks
INSERT OR IGNORE INTO tasks (id, title, description, detailed_instructions, banner_url, category, points_reward, deadline, required_submissions, status, created_by, created_at)
VALUES
('task_1', 'Morning Park & Trail Cleanup', 
 'Collect at least one bag of litter from your local neighborhood park or hiking trail.', 
 '1. Grab a recyclable trash bag and gloves.\n2. Spend 20-30 minutes collecting litter along walking trails, picnic areas, or sports fields.\n3. Take a clear photo of the filled bag disposed in a designated public bin.\n4. Enable GPS verification to confirm you completed the task at a public reserve.',
 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
 'Eco & Green', 250, '24 Hours', '["text","photo","location"]', 'active', 'usr_admin_1', datetime('now', '-1 day')),

('task_2', '5,000 Morning Steps Challenge', 
 'Complete a brisk morning walk of 5,000+ steps to energize your day.', 
 '1. Put on your walking/running shoes and track your walk on Apple Health, Google Fit, or your smartwatch.\n2. Take a screenshot showing your step count exceeding 5,000 steps today.\n3. Write a short note describing your walking route.',
 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
 'Fitness & Health', 150, '12 Hours', '["text","photo"]', 'active', 'usr_admin_1', datetime('now', '-1 day')),

('task_3', 'Support a Local Coffee Shop', 
 'Order from a neighborhood small business coffee shop and leave a thoughtful review.', 
 '1. Visit an independent local coffee shop or bakery.\n2. Snap a photo of your cup/pastry with the storefront or counter visible.\n3. Write a 2-sentence note about why supporting small business matters to you.',
 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800',
 'Community', 180, '18 Hours', '["text","photo","location"]', 'active', 'usr_admin_1', datetime('now', '-2 days')),

('task_4', 'Home Fire Alarm Safety Check', 
 'Test smoke detectors in your home and verify batteries are charged.', 
 '1. Press the "Test" button on your ceiling smoke detector until the siren beeps.\n2. Take a clear photo or short 3-second video showing you testing the unit.\n3. Note down the replacement expiry date printed on the device.',
 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800',
 'Safety & Preparedness', 200, '36 Hours', '["text","photo"]', 'active', 'usr_admin_1', datetime('now', '-3 days')),

('task_5', 'Public Transit Commuter Ride', 
 'Choose bus, tram, or train over a solo car drive for your daily trip.', 
 '1. Take public transit for your commute or weekend trip.\n2. Take a photo of your transit card, ticket receipt, or the station platform.\n3. Share which route you rode.',
 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
 'Eco & Green', 120, '48 Hours', '["text","photo"]', 'active', 'usr_admin_1', datetime('now', '-4 days'));

-- Rewards Catalog
INSERT OR IGNORE INTO rewards (id, title, description, points_cost, image_url, category, stock, is_available, created_at)
VALUES
('rew_1', '$10 Artisan Coffee Voucher', 'Redeem for any barista-made beverage at participating local cafes.', 350, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600', 'Dining & Drinks', 25, 1, datetime('now', '-10 days')),
('rew_2', '1-Day Premium Fitness Pass', 'Full access to gym facilities, heated pool, and group fitness classes.', 500, 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600', 'Health & Fitness', 15, 1, datetime('now', '-10 days')),
('rew_3', '$25 Eco-Store Gift Card', 'Zero-waste groceries, sustainable goods, and organic home essentials.', 800, 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600', 'Shopping', 10, 1, datetime('now', '-10 days')),
('rew_4', 'Movie Night Double Pass', 'Two standard general admission cinema tickets for any session.', 950, 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600', 'Entertainment', 8, 1, datetime('now', '-10 days')),
('rew_5', 'Tree Planting Certificate', 'Fund the planting of 5 native trees in protected wildlife corridors.', 400, 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=600', 'Eco Impact', 99, 1, datetime('now', '-10 days'));

-- Submissions
INSERT OR IGNORE INTO submissions (id, task_id, task_title, points_reward, user_id, user_name, user_email, status, text_response, photo_urls, location_address, location_lat, location_lng, submitted_at)
VALUES
('sub_1', 'task_2', '5,000 Morning Steps Challenge', 150, 'usr_user_2', 'Alex Johnson', 'alex@example.com', 'pending', 
 'Walked through the botanical garden loop early this morning. Total 6,240 steps recorded on my Fitbit!', 
 '["https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800"]', 
 'Botanical Gardens Loop, Brisbane', -27.4748, 153.0298, datetime('now', '-45 minutes')),

('sub_2', 'task_1', 'Morning Park & Trail Cleanup', 250, 'usr_user_3', 'Sarah Miller', 'sarah@example.com', 'approved', 
 'Cleaned up plastic bottles and snack wrappers near the children playground.', 
 '["https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800"]', 
 'Victoria Park, Central Lawn, Brisbane', -27.4520, 153.0210, datetime('now', '-3 hours')),

('sub_3', 'task_3', 'Support a Local Coffee Shop', 180, 'usr_user_1', 'Jordan Lee', 'citizen@eatclubtasks.com', 'pending', 
 'Tried the flat white at Bean & Leaf. Left a 5-star Google review praising the barista!', 
 '["https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800"]', 
 'Bean & Leaf Roasters, 42 Main St', -27.4698, 153.0251, datetime('now', '-15 minutes'));

-- Point Transactions
INSERT OR IGNORE INTO point_transactions (id, user_id, amount, type, title, description, timestamp)
VALUES
('tx_1', 'usr_user_1', 250, 'earned', 'Morning Park & Trail Cleanup', 'Task approved by Administrator', datetime('now', '-2 days')),
('tx_2', 'usr_user_1', 170, 'earned', 'Local Community Survey', 'Task approved by Administrator', datetime('now', '-5 days')),
('tx_3', 'usr_user_3', 250, 'earned', 'Morning Park & Trail Cleanup', 'Task approved by Administrator', datetime('now', '-3 hours'));
