-- Insert Initial Data
INSERT INTO user_details_login (id, password, username, userrole)
SELECT 1, '$2a$10$abcdefghijklmnopqrstuu2njjerFUdKeNqVoGia/slSqhJQ.vuAy', 'username1', 'ADMIN'
WHERE NOT EXISTS (SELECT 1 FROM user_details_login WHERE id = 1);

-- Sync Sequence for UserLogin
-- COALESCE ensures that if the table is empty, it defaults to 1 instead of NULL
SELECT setval('sequence_user', (SELECT COALESCE(MAX(id), 1) FROM user_details_login));
