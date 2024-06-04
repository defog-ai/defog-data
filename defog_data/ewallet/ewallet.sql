CREATE SCHEMA IF NOT EXISTS consumer_div;

CREATE TABLE consumer_div.users (
  uid BIGINT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20),
  created_at TIMESTAMP NOT NULL,
  last_login_at TIMESTAMP,
  user_type VARCHAR(20) NOT NULL, -- possible values: individual, business, admin
  status VARCHAR(20) NOT NULL, -- possible values: active, inactive, suspended, deleted
  country VARCHAR(2), -- 2-letter country code
  address_billing TEXT,
  address_delivery TEXT,
  kyc_status VARCHAR(20), -- possible values: pending, approved, rejected
  kyc_verified_at TIMESTAMP
);

CREATE TABLE consumer_div.merchants (
  mid BIGINT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  website_url VARCHAR(200),
  logo_url VARCHAR(200),
  created_at TIMESTAMP NOT NULL,
  country VARCHAR(2), -- 2-letter country code
  state VARCHAR(50),
  city VARCHAR(50),
  postal_code VARCHAR(20),
  address TEXT,
  status VARCHAR(20) NOT NULL, -- possible values: active, inactive, suspended
  category VARCHAR(50),
  sub_category VARCHAR(50),
  mcc INT, -- Merchant Category Code
  contact_name VARCHAR(100),
  contact_email VARCHAR(100),
  contact_phone VARCHAR(20)
);

CREATE TABLE consumer_div.coupons (
  cid BIGINT PRIMARY KEY,
  merchant_id BIGINT NOT NULL REFERENCES consumer_div.merchants(mid),
  code VARCHAR(20) NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  discount_type VARCHAR(20) NOT NULL, -- possible values: percentage, fixed_amount
  discount_value DECIMAL(10,2) NOT NULL,
  min_purchase_amount DECIMAL(10,2),
  max_discount_amount DECIMAL(10,2),
  redemption_limit INT,
  status VARCHAR(20) NOT NULL, -- possible values: active, inactive, expired
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP
);

-- Fact Tables --

CREATE TABLE consumer_div.wallet_transactions_daily (
  txid SERIAL PRIMARY KEY,
  sender_id BIGINT NOT NULL,
  sender_type INT NOT NULL, -- 0 for user, 1 for merchant
  receiver_id BIGINT NOT NULL,
  receiver_type INT NOT NULL, -- 0 for user, 1 for merchant
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL, -- possible values: pending, success, failed, refunded
  type VARCHAR(20) NOT NULL, -- possible values: credit, debit
  description TEXT,
  coupon_id BIGINT, -- NULL if transaction doesn't involve a coupon
  created_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP, -- NULL if failed
  transaction_ref VARCHAR(36) NOT NULL, -- randomly generated uuid4 for users' reference
  gateway_name VARCHAR(50),
  gateway_ref VARCHAR(50),
  device_id VARCHAR(50),
  ip_address VARCHAR(50),
  user_agent TEXT
);

CREATE TABLE consumer_div.wallet_user_balance_daily (
  user_id BIGINT,
  balance DECIMAL(10,2) NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE consumer_div.wallet_merchant_balance_daily (
  merchant_id BIGINT,
  balance DECIMAL(10,2) NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE TABLE consumer_div.notifications (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES consumer_div.users(uid),
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL, -- possible values: transaction, promotion, security, general 
  status VARCHAR(20) NOT NULL, -- possible values: unread, read, archived
  created_at TIMESTAMP NOT NULL,
  read_at TIMESTAMP, -- NULL if not read
  device_type VARCHAR(10), -- possible values: mobile_app, web_app, email, sms
  device_id VARCHAR(36),
  action_url TEXT -- can be external https or deeplink url within the app
);  

CREATE TABLE consumer_div.user_sessions (
  user_id BIGINT NOT NULL,
  session_start_ts TIMESTAMP NOT NULL,
  session_end_ts TIMESTAMP,
  device_type VARCHAR(10), -- possible values: mobile_app, web_app, email, sms
  device_id VARCHAR(36)
);

CREATE TABLE consumer_div.user_setting_snapshot (
  user_id BIGINT NOT NULL,
  snapshot_date DATE NOT NULL,
  tx_limit_daily DECIMAL(10,2),
  tx_limit_monthly DECIMAL(10,2),
  membership_status INTEGER, -- 0 for bronze, 1 for silver, 2 for gold, 3 for platinum, 4 for VIP
  password_hash VARCHAR(255),
  api_key VARCHAR(255),
  verified_devices TEXT, -- comma separated list of device ids
  verified_ips TEXT, -- comma separated list of IP addresses
  mfa_enabled BOOLEAN,
  marketing_opt_in BOOLEAN,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, snapshot_date)
);

-- users
INSERT INTO consumer_div.users (uid, username, email, phone_number, created_at, user_type, status, country, address_billing, address_delivery, kyc_status) 
VALUES 
  (1, 'john_doe', 'john.doe@email.com', '+1234567890', DATE_TRUNC('month', CURRENT_TIMESTAMP) - INTERVAL '1 month', 'individual', 'active', 'US', '123 Main St, Anytown US 12345', '123 Main St, Anytown US 12345', 'approved'),
  (2, 'jane_smith', 'jane.smith@email.com', '+9876543210', DATE_TRUNC('month', CURRENT_TIMESTAMP) - INTERVAL '2 months', 'individual', 'active', 'CA', '456 Oak Rd, Toronto ON M1M2M2', '456 Oak Rd, Toronto ON M1M2M2', 'approved'), 
  (3, 'bizuser', 'contact@business.co', '+1234509876', '2021-06-01 09:15:00', 'business', 'active', 'FR', '12 Rue Baptiste, Paris 75001', NULL, 'approved'),
  (4, 'david_miller', 'dave@personal.email', '+4477788899', '2023-03-20 18:45:00', 'individual', 'inactive', 'GB', '25 London Road, Manchester M12 4XY', '25 London Road, Manchester M12 4XY', 'pending'),
  (5, 'emily_wilson', 'emily.w@gmail.com', '+8091017161', '2021-11-03 22:10:00', 'individual', 'suspended', 'AU', '72 Collins St, Melbourne VIC 3000', '19 Smith St, Brunswick VIC 3056', 'rejected'),
  (6, 'techcorp', 'orders@techcorp.com', '+14165558888', '2018-05-20 11:35:00', 'business', 'active', 'US', '33 Technology Dr, Silicon Valley CA 94301', NULL, 'approved'),
  (7, 'shopsmart', 'customerserv@shopsmart.biz', '+6585771234', '2020-09-15 06:25:00', 'business', 'inactive', 'SG', '888 Orchard Rd, #05-000, Singapore 238801', NULL, 'approved'),
  (8, 'michael_brown', 'mike.brown@outlook.com', '+3912378624', '2019-07-22 16:40:00', 'individual', 'active', 'DE', 'Heidestr 17, Berlin 10557', 'Heidestr 17, Berlin 10557', 'approved'),
  (9, 'alex_taylor', 'ataylo@university.edu', NULL, '2022-08-30 09:15:00', 'individual', 'active', 'NZ', '12 Mardon Rd, Wellington 6012', '5 Boulcott St, Wellington 6011', 'approved'),
  (10, 'huang2143', 'huang2143@example.com', '+8612345678901', '2023-12-10 08:00:00', 'individual', 'active', 'CN', '123 Nanjing Road, Shanghai 200000', '123 Nanjing Road, Shanghai 200000', 'approved'),
  (11, 'lisa_jones', 'lisa.jones@email.com', '+6123456789', '2023-09-05 15:20:00', 'individual', 'active', 'AU', '789 George St, Sydney NSW 2000', '789 George St, Sydney NSW 2000', 'approved');

-- merchants 
INSERT INTO consumer_div.merchants (mid, name, description, website_url, logo_url, created_at, country, state, city, postal_code, address, status, category, sub_category, mcc, contact_name, contact_email, contact_phone)
VALUES
  (1, 'TechMart', 'Leading electronics retailer', 'https://www.techmart.com', 'https://www.techmart.com/logo.png', '2015-01-15 00:00:00', 'US', 'California', 'Los Angeles', '90011', '645 Wilshire Blvd, Los Angeles CA 90011', 'active', 'retail (hardware)', 'Electronics', 5732, 'John Jacobs', 'jjacobs@techmart.com', '+15551234567'),
  (2, 'FitLifeGear', 'Fitness equipment and activewear', 'https://fitlifegear.com', 'https://fitlifegear.com/brand.jpg', '2018-07-01 00:00:00', 'CA', 'Ontario', 'Toronto', 'M5V2J2', '421 Richmond St W, Toronto ON M5V2J2', 'active', 'retail (hardware)', 'Sporting Goods', 5655, 'Jane McDonald', 'jmcdonald@fitlifegear.com', '+14165559876'),
  (3, 'UrbanDining', 'Local restaurants and cafes', 'https://www.urbandining.co', 'https://www.urbandining.co/logo.png', '2020-03-10 00:00:00', 'FR', NULL, 'Paris', '75011', '35 Rue du Faubourg Saint-Antoine, 75011 Paris', 'active', 'Food & Dining', 'Restaurants', 5812, 'Pierre Gagnon', 'pgagnon@urbandining.co', '+33612345678'),
  (4, 'LuxStays', 'Boutique vacation rentals', 'https://luxstays.com', 'https://luxstays.com/branding.jpg', '2016-11-01 00:00:00', 'IT', NULL, 'Rome', '00187', 'Via della Conciliazione 15, Roma 00187', 'inactive', 'Travel & Hospitality', 'Accommodation', 7011, 'Marco Rossi', 'mrossi@luxstays.com', '+39061234567'),
  (5, 'HandyCraft', 'Handmade arts and crafts supplies', 'https://handycraft.store', 'https://handycraft.store/hc-logo.png', '2022-06-20 00:00:00', 'ES', 'Catalonia', 'Barcelona', '08003', 'Passeig de Gracia 35, Barcelona 08003', 'active', 'Retail', 'Crafts & Hobbies', 5949, 'Ana Garcia', 'agarcia@handycraft.store', '+34612345678'),
  (6, 'CodeSuite', 'SaaS productivity tools for developers', 'https://codesuite.io', 'https://codesuite.io/logo.svg', '2019-02-01 00:00:00', 'DE', NULL, 'Berlin', '10119', 'Dessauer Str 28, 10119 Berlin', 'active', 'Business Services', 'Software', 5734, 'Michael Schmidt', 'mschmidt@codesuite.io', '+49301234567'),
  (7, 'ZenHomeGoods', 'Housewares and home decor items', 'https://www.zenhomegoods.com', 'https://www.zenhomegoods.com/branding.jpg', '2014-09-15 00:00:00', 'AU', 'Victoria', 'Melbourne', '3004', '159 Franklin St, Melbourne VIC 3004', 'active', 'Retail', 'Home & Garden', 5719, 'Emily Watson', 'ewatson@zenhomegoods.com', '+61312345678'),
  (8, 'KidzPlayhouse', 'Children''s toys and games', 'https://kidzplayhouse.com', 'https://kidzplayhouse.com/logo.png', '2017-04-01 00:00:00', 'GB', NULL, 'London', 'WC2N 5DU', '119 Charing Cross Rd, London WC2N 5DU', 'suspended', 'Retail', 'Toys & Games', 5945, 'David Thompson', 'dthompson@kidzplayhouse.com', '+442071234567'),
  (9, 'BeautyTrending', 'Cosmetics and beauty supplies', 'https://beautytrending.com', 'https://beautytrending.com/bt-logo.svg', '2021-10-15 00:00:00', 'NZ', NULL, 'Auckland', '1010', '129 Queen St, Auckland 1010', 'active', 'Retail', 'Health & Beauty', 5977, 'Sophie Wilson', 'swilson@beautytrending.com', '+6493012345'),
  (10, 'GameRush', 'Video games and gaming accessories', 'https://gamerush.co', 'https://gamerush.co/gr-logo.png', '2023-02-01 00:00:00', 'US', 'New York', 'New York', '10001', '303 Park Ave S, New York NY 10001', 'active', 'Retail', 'Electronics', 5735, 'Michael Davis', 'mdavis@gamerush.co', '+16463012345'),
  (11, 'FashionTrend', 'Trendy clothing and accessories', 'https://www.fashiontrend.com', 'https://www.fashiontrend.com/logo.png', '2019-08-10 00:00:00', 'UK', NULL, 'Manchester', 'M2 4WU', '87 Deansgate, Manchester M2 4WU', 'active', 'Retail', 'Apparel', 5651, 'Emma Thompson', 'ethompson@fashiontrend.com', '+441612345678'),
  (12, 'GreenGourmet', 'Organic foods and natural products', 'https://www.greengourmet.com', 'https://www.greengourmet.com/logo.jpg', '2020-12-05 00:00:00', 'CA', 'British Columbia', 'Vancouver', 'V6B 6B1', '850 W Hastings St, Vancouver BC V6B 6B1', 'active', 'Food & Dining', 'Groceries', 5411, 'Daniel Lee', 'dlee@greengourmet.com', '+16041234567'),
  (13, 'PetParadise', 'Pet supplies and accessories', 'https://petparadise.com', 'https://petparadise.com/logo.png', '2018-03-20 00:00:00', 'AU', 'New South Wales', 'Sydney', '2000', '275 Pitt St, Sydney NSW 2000', 'active', 'Retail', 'Pets', 5995, 'Olivia Johnson', 'ojohnson@petparadise.com', '+61298765432'),
  (14, 'HomeTechSolutions', 'Smart home devices and gadgets', 'https://hometechsolutions.net', 'https://hometechsolutions.net/logo.png', '2022-04-15 00:00:00', 'US', 'California', 'San Francisco', '94105', '350 Mission St, San Francisco CA 94105', 'active', 'Retail', 'Home Appliances', 5734, 'Ethan Brown', 'ebrown@hometechsolutions.net', '+14159876543'),
  (15, 'BookWorms', 'Books and reading accessories', 'https://bookworms.co.uk', 'https://bookworms.co.uk/logo.png', '2017-06-30 00:00:00', 'UK', NULL, 'London', 'WC2H 9JA', '66-67 Tottenham Court Rd, London WC2H 9JA', 'active', 'Retail', 'Books', 5942, 'Sophia Turner', 'sturner@bookworms.co.uk', '+442078912345');

-- coupons
INSERT INTO consumer_div.coupons (cid, merchant_id, code, description, start_date, end_date, discount_type, discount_value, min_purchase_amount, max_discount_amount, redemption_limit, status, created_at, updated_at)
VALUES
  (1, 1, 'TECH20', '20% off tech and electronics', '2023-05-01', '2023-05-31', 'percentage', 20.00, 100.00, NULL, 500, 'active', '2023-04-01 09:00:00', '2023-04-15 11:30:00'),
  (2, 2, 'NEWYEAR30', '30% off workout gear', '2023-01-01', '2023-01-15', 'percentage', 30.00, NULL, NULL, 1000, 'expired', '2022-12-01 12:00:00', '2023-01-16 18:45:00'),
  (3, 3, 'DINEDISCOUNT', 'Get $10 off $50 order', '2023-06-01', '2023-06-30', 'fixed_amount', 10.00, 50.00, 10.00, NULL, 'active', '2023-05-15 15:30:00', NULL), 
  (4, 4, 'HOME15', '15% off weekly rental', '2023-07-01', '2023-08-31', 'percentage', 15.00, 1000.00, 300.00, 200, 'active', '2023-05-01 09:15:00', NULL),
  (5, 5, 'HOME10', '$10 off $75+ purchase', '2023-04-01', '2023-04-30', 'fixed_amount', 10.00, 75.00, 10.00, 300, 'inactive', '2023-03-01 14:00:00', '2023-05-05 10:30:00'),
  (6, 6, 'CODENEW25', '25% off new subscriptions', '2023-03-01', '2023-03-31', 'percentage', 25.00, NULL, NULL, NULL, 'expired', '2023-02-15 11:00:00', '2023-04-01 09:30:00'),
  (7, 7, 'ZENHOME', 'Get 20% off home items', '2023-09-01', '2023-09-30', 'percentage', 20.00, 50.00, NULL, 1500, 'active', '2023-08-15 16:45:00', NULL),
  (8, 8, 'GAMEKIDS', '$15 off $100+ purchase', '2022-12-01', '2022-12-31', 'fixed_amount', 15.00, 100.00, 15.00, 800, 'expired', '2022-11-01 10:30:00', '2023-01-02 13:15:00'), 
  (9, 9, 'GLOWUP', 'Buy 2 get 1 free on cosmetics', '2023-10-15', '2023-10-31', 'fixed_amount', 50.00, 150.00, 50.00, 300, 'active', '2023-10-01 08:00:00', NULL),
  (10, 10, 'GAMERALERT', 'Get 25% off accessories', '2023-03-01', '2023-03-15', 'percentage', 25.00, NULL, 50.00, 750, 'expired', '2023-02-15 14:30:00', '2023-03-16 12:00:00');


-- wallet_transactions_daily
INSERT INTO consumer_div.wallet_transactions_daily (txid, sender_id, sender_type, receiver_id, receiver_type, amount, status, type, description, coupon_id, created_at, completed_at, transaction_ref, gateway_name, gateway_ref, device_id, ip_address, user_agent)
VALUES
  (1, 1, 0, 1, 0, 99.99, 'success', 'debit', 'Online purchase', NULL, '2023-06-01 10:15:30', '2023-06-01 10:15:45', 'ad154bf7-8185-4230-a8d8-3ef59b4e0012', 'Stripe', 'tx_123abc456def', 'mobile_8fh2k1', '192.168.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) ...'),
  (2, 1, 0, 1, 1, 20.00, 'success', 'credit', 'Coupon discount', 1, '2023-06-01 10:15:30', '2023-06-01 10:15:45', 'ad154bf7-8185-4230-a8d8-3ef59b4e0012', 'Stripe', 'tx_123abc456def', 'mobile_8fh2k1', '192.168.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_3_1 like Mac OS X) ...'),
  (3, 2, 0, 1, 1, 16.00, 'success', 'credit', 'Coupon discount', 1, '2023-07-01 10:18:30', '2023-06-01 10:18:45', 'kd454bf7-428d-eig2-a8d8-3ef59b4e0012', 'Stripe', 'tx_123abc789gas', 'mobile_yjp08q', '198.51.100.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) ...'),
  (4, 3, 1, 9, 0, 125.50, 'success', 'debit', 'Product purchase', NULL, '2023-06-01 13:22:18', '2023-06-01 13:22:45', 'e6f510e9-ff7d-4914-81c2-f8e56bae4012', 'PayPal', 'ppx_192ks8hl', 'web_k29qjd', '216.58.195.68', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...'),
  (5, 9, 0, 3, 1, 42.75, 'pending', 'debit', 'Order #438721', 3, '2023-06-01 18:45:02', '2023-06-01 18:45:13', 'b2ca190e-a42f-4f5e-8318-f82bcc6ae64e', 'Stripe', 'tx_987zyx654wvu', 'mobile_q3mz8n', '68.85.32.201', 'Mozilla/5.0 (Linux; Android 13) ...'),
  (6, 9, 0, 3, 1, 10.00, 'success', 'credit', 'Coupon discount', 3, '2023-06-01 18:45:02', '2023-06-01 18:45:13', 'b2ca190e-a42f-4f5e-8318-f82bcc6ae64e', 'Stripe', 'tx_987zyx654wvu', 'mobile_q3mz8n', '68.85.32.201', 'Mozilla/5.0 (Linux; Android 13) ...'),
  (7, 2, 0, 7, 1, 89.99, 'pending', 'debit', 'Home furnishings', NULL, '2023-06-02 09:30:25', '2023-06-02 09:30:40', 'c51e10d1-db34-4d9f-b55f-43a05a5481c8', 'Checkout.com', 'ord_kzhg123', 'mobile_yjp08q', '198.51.100.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) ...'),
  (8, 2, 0, 7, 1, 17.99, 'success', 'credit', 'Coupon discount', 7, '2023-06-02 09:30:25', '2023-06-02 09:30:40', 'c51e10d1-db34-4d9f-b55f-43a05a5481c8', 'Checkout.com', 'ord_kzhg123', 'mobile_yjp08q', '198.51.100.233', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) ...'),  
  (9, 6, 1, 1, 0, 29.95, 'success', 'debit', 'Software subscription', NULL, '2023-06-02 14:15:00', '2023-06-02 14:15:05', '25cd48e5-08c3-4d1c-b7a4-26485ea646eb', 'Braintree', 'sub_mnb456', 'web_zz91p44l', '4.14.15.90', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...'),
  (10, 4, 0, 4, 1, 2500.00, 'pending', 'debit', 'Villa rental deposit', NULL, '2023-06-02 20:45:36', NULL, 'a7659c81-0cd0-4635-af6c-cf68d2c15ab2', 'PayPal', NULL, 'mobile_34jdkl', '143.92.64.138', 'Mozilla/5.0 (Linux; Android 11; Pixel 5) ...'),
  (11, 5, 0, 5, 1, 55.99, 'success', 'debit', 'Craft supplies order', NULL, '2023-06-03 11:12:20', '2023-06-03 11:12:35', 'ec74cb3b-8272-4175-a5d0-f03c2e781593', 'Adyen', 'ord_tkjs87', 'web_8902wknz', '192.64.112.188', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...'),
  (12, 9, 0, 9, 1, 75.00, 'success', 'debit', 'Beauty products', 9, '2023-06-04 08:00:00', '2023-06-04 08:00:25', '840a9854-1b07-422b-853c-636b289222a9', 'Checkout.com', 'ord_kio645', 'mobile_g3mjfz', '203.96.81.36', 'Mozilla/5.0 (Linux; Android 12; SM-S906N Build/QP1A.190711.020) ...'),
  (13, 9, 0, 9, 1, 50.00, 'success', 'credit', 'Coupon discount', 9, '2023-06-04 08:00:00', '2023-06-04 08:00:25', '840a9854-1b07-422b-853c-636b289222a9', 'Checkout.com', 'ord_kio645', 'mobile_g3mjfz', '203.96.81.36', 'Mozilla/5.0 (Linux; Android 12; SM-S906N Build/QP1A.190711.020) ...'),
  (14, 8, 0, 10, 1, 119.99, 'failed', 'debit', 'New game purchase', NULL, '2023-06-04 19:30:45', NULL, '32e2b29c-5c7f-4906-98c5-e8abdcbfd69a', 'Braintree', 'ord_mjs337', 'web_d8180kaf', '8.26.53.165', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...'),
  (15, 8, 0, 10, 1, 29.99, 'success', 'credit', 'Coupon discount', 10, '2023-06-04 19:30:45', '2023-06-04 19:31:10', '32e2b29c-5c7f-4906-98c5-e8abdcbfd69a', 'Braintree', 'ord_mjs337', 'web_d8180kaf', '8.26.53.165', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ...'),
  (16, 10, 1, 3, 0, 87.50, 'failed', 'debit', 'Restaurant order', NULL, '2023-06-05 12:05:21', NULL, '37cf052d-0475-4ecc-bda7-73ee904bf65c', 'Checkout.com', NULL, 'mobile_x28qlj', '92.110.51.150', 'Mozilla/5.0 (Linux; Android 13; SM-S901B) ...'),
  (17, 1, 0, 1, 0, 175.00, 'success', 'debit', 'Refund on order #1234', NULL, '2023-06-06 14:20:00', '2023-06-06 14:20:05', 'a331232e-a3f6-4e7f-b49f-3588bc5ff985', 'Stripe', 'rfnd_xkt521', 'web_33lq1dh', '38.75.197.8', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...'),
  (18, 7, 1, 2, 0, 599.99, 'success', 'debit', 'Yearly subscription', NULL, '2023-06-06 16:55:10', '2023-06-06 16:55:15', 'ed6f46ab-9617-4d11-9aa9-60d24bdf9bc0', 'PayPal', 'sub_pjj908', 'web_zld22f', '199.59.148.201', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 ...'),
  (19, 2, 0, 2, 1, 22.99, 'refunded', 'debit', 'Product return', NULL, '2023-06-07 10:10:30', '2023-06-07 10:11:05', '6c97a87d-610f-4705-ae97-55071127d9ad', 'Adyen', 'tx_zcx258', 'mobile_1av8p0', '70.121.39.25', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) ...'),
  (20, 2, 0, 2, 1, 22.99, 'success', 'credit', 'Refund on return', NULL, '2023-06-07 10:10:30', '2023-06-07 10:11:05', '6c97a87d-610f-4705-ae97-55071127d9ad', 'Adyen', 'tx_zcx258', 'mobile_1av8p0', '70.121.39.25', 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_4 like Mac OS X) ...'),
  (21, 1, 0, 2, 1, 49.99, 'success', 'debit', 'Product purchase', NULL, NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months', 'tx_ref_11_1', 'Stripe', 'stripe_ref_11_1', 'device_11_1', '192.168.1.11', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36'),
  (22, 4, 0, 3, 1, 99.99, 'success', 'debit', 'Service purchase', NULL, NOW() - INTERVAL '4 months', NOW() - INTERVAL '4 months', 'tx_ref_12_1', 'PayPal', 'paypal_ref_12_1', 'device_12_1', '192.168.1.12', 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1'),
  (23, 4, 0, 1, 1, 149.99, 'success', 'debit', 'Subscription purchase', NULL, NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months', 'tx_ref_13_1', 'Stripe', 'stripe_ref_13_1', 'device_13_1', '192.168.1.13', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36'),
  (24, 2, 0, 5, 1, 199.99, 'pending', 'debit', 'Product purchase', NULL, NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months', 'tx_ref_14_1', 'PayPal', 'paypal_ref_14_1', 'device_14_1', '192.168.1.14', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:91.0) Gecko/20100101 Firefox/91.0'),
  (25, 2, 0, 1, 1, 249.99, 'success', 'debit', 'Service purchase', NULL, NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month', 'tx_ref_15_1', 'Stripe', 'stripe_ref_15_1', 'device_15_1', '192.168.1.15', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36'),
  (26, 7, 1, 2, 0, 299.99, 'success', 'debit', 'Renew subscription', NULL, NOW() - INTERVAL '3 weeks', NOW() - INTERVAL '3 weeks', 'ed6f46ab-9617-4d11-9aa9-55071127d9ad', 'PayPal', 'sub_pjk832', 'web_zld22f', '199.59.148.201', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 ...');

  
-- wallet_user_balance_daily
INSERT INTO consumer_div.wallet_user_balance_daily (user_id, balance, updated_at)
VALUES
  (1, 525.80, '2023-06-07 23:59:59'),
  (2, 429.76, '2023-06-07 23:59:59'),
  (3, -725.55, '2023-06-07 23:59:59'),
  (4, -2500.00, '2023-06-07 23:59:59'),
  (5, -55.99, '2023-06-07 23:59:59'), 
  (6, 0.00, '2023-06-07 23:59:59'),
  (7, 0.00, '2023-06-07 23:59:59'),
  (8, -599.98, '2023-06-07 23:59:59'),
  (9, -183.25, '2023-06-07 23:59:59'),
  (10, 0.00, '2023-06-07 23:59:59'),
  (1, 2739.10, NOW() - INTERVAL '8 days'),
  (1, 2738.12, NOW() - INTERVAL '6 days'),
  (1, 2733.92, NOW() - INTERVAL '3 days'),
  (2, 155.24, NOW() - INTERVAL '7 days'),
  (3, 2775.25, NOW() - INTERVAL '6 days'),
  (4, 2500.00, NOW() - INTERVAL '5 days'),
  (5, 155.99, NOW() - INTERVAL '4 days'),
  (6, 29.95, NOW() - INTERVAL '3 days'),
  (7, 172.98, NOW() - INTERVAL '2 days'),
  (8, 0.00, NOW() - INTERVAL '7 days'),
  (9, 125.00, NOW() - INTERVAL '3 days'),
  (10, 219.98, NOW() - INTERVAL '1 days');
  
-- wallet_merchant_balance_daily  
INSERT INTO consumer_div.wallet_merchant_balance_daily (merchant_id, balance, updated_at)
VALUES
  (1, 3897.99, '2023-06-07 23:59:59'),
  (2, 155.24, '2023-06-07 23:59:59'), 
  (3, 2775.25, '2023-06-07 23:59:59'),
  (4, 2500.00, '2023-06-07 23:59:59'),
  (5, 155.99, '2023-06-07 23:59:59'),
  (6, 29.95, '2023-06-07 23:59:59'),
  (7, 172.98, '2023-06-07 23:59:59'), 
  (8, 0.00, '2023-06-07 23:59:59'),
  (9, 125.00, '2023-06-07 23:59:59'),
  (10, 219.98, '2023-06-07 23:59:59');

-- notifications
INSERT INTO consumer_div.notifications (id, user_id, message, type, status, created_at, device_type, device_id, action_url)
VALUES
(1, 1, 'Your order #123abc has been shipped!', 'transaction', 'unread', '2023-06-01 10:16:00', 'mobile_app', 'mobile_8fh2k1', 'app://orders/123abc'),
(2, 1, 'Get 20% off your next purchase! Limited time offer.', 'promotion', 'unread', '2023-06-02 09:00:00', 'email', NULL, 'https://techmart.com/promo/TECH20'),
(3, 2, 'A package is being returned to you. Refund processing...', 'transaction', 'read', '2023-06-07 10:12:00', 'mobile_app', 'mobile_1av8p0', 'app://orders?status=returned'),
(4, 2, 'Your FitLife membership is up for renewal on 7/1', 'general', 'unread', '2023-06-05 15:30:00', 'email', NULL, 'https://fitlifegear.com/renew'),
(5, 3, 'An order from UrbanDining was unsuccessful', 'transaction', 'read', '2023-06-05 12:06:00', 'sms', NULL, 'https://urbandining.co/orders/37cf052d'),
(6, 4, 'Your rental request is pending approval', 'transaction', 'unread', '2023-06-02 20:46:00', 'mobile_app', 'mobile_34jdkl', 'app://bookings/a7659c81'),
(7, 5, 'Claim your 25% discount on craft supplies!', 'promotion', 'archived', '2023-06-01 08:00:00', 'email', NULL, 'https://handycraft.store/CRAFTY10'),
(8, 6, 'Your CodeSuite subscription will renew on 7/1', 'general', 'unread', '2023-06-01 12:00:00', 'email', NULL, 'https://codesuite.io/subscriptions'),
(9, 7, 'Thanks for shopping at ZenHomeGoods! How did we do?', 'general', 'read', '2023-06-02 09:31:00', 'mobile_app', 'mobile_yjp08q', 'https://zenhomesurvey.com/order/c51e10d1'),
(10, 8, 'Playtime! New games and toys have arrived', 'promotion', 'archived', '2023-06-01 18:00:00', 'email', NULL, 'https://kidzplayhouse.com/new-arrivals'),
(11, 9, 'Here''s $10 to start your glow up!', 'promotion', 'unread', '2023-06-01 10:15:00', 'email', NULL, 'https://beautytrending.com/new-customer'),
(12, 10, 'Your order #ord_mjs337 is being processed', 'transaction', 'read', '2023-06-04 19:31:30', 'web_app', 'web_d8180kaf', 'https://gamerush.co/orders/32e2b29c'),
(13, 1, 'New promotion: Get 10% off your next order!', 'promotion', 'unread', DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '1 week', 'email', NULL, 'https://techmart.com/promo/TECH10'),
(14, 1, 'Your order #456def has been delivered', 'transaction', 'unread', DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '2 weeks', 'mobile_app', 'mobile_8fh2k1', 'app://orders/456def'),  
(15, 2, 'Reminder: Your FitLife membership expires in 7 days', 'general', 'unread', DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '3 weeks', 'email', NULL, 'https://fitlifegear.com/renew'),
(16, 2, 'Weekend Flash Sale: 25% off all activewear!', 'promotion', 'unread', DATE_TRUNC('week', CURRENT_TIMESTAMP) - INTERVAL '1 week' + INTERVAL '2 days', 'mobile_app', 'mobile_yjp08q', 'app://shop/activewear');

-- user_sessions
INSERT INTO consumer_div.user_sessions (user_id, session_start_ts, session_end_ts, device_type, device_id)
VALUES
(1, '2023-06-01 09:45:22', '2023-06-01 10:20:35', 'mobile_app', 'mobile_8fh2k1'),
(1, '2023-06-02 13:30:00', '2023-06-02 14:15:15', 'web_app', 'web_33lq1dh'),
(1, '2023-06-06 14:19:00', '2023-06-06 14:22:10', 'web_app', 'web_33lq1dh'),
(1, '2023-06-07 23:49:12', '2023-06-08 00:00:00', 'web_app', 'web_33lq1dh'),
(2, '2023-06-02 08:55:08', '2023-06-02 09:45:42', 'mobile_app', 'mobile_yjp08q'),
(2, '2023-06-07 10:09:15', '2023-06-07 10:12:25', 'mobile_app', 'mobile_1av8p0'),
(3, '2023-06-01 13:15:33', '2023-06-01 13:28:01', 'web_app', 'web_k29qjd'),
(3, '2023-06-05 12:00:00', '2023-06-05 12:10:22', 'mobile_app', 'mobile_x28qlj'),
(4, '2023-06-02 20:30:12', '2023-06-02 21:15:48', 'mobile_app', 'mobile_34jdkl'),
(5, '2023-06-03 10:45:30', '2023-06-03 11:20:28', 'web_app', 'web_8902wknz'),
(6, '2023-06-02 14:00:00', '2023-06-02 15:10:05', 'web_app', 'web_zz91p44l'),
(7, '2023-06-06 16:45:22', '2023-06-06 17:10:40', 'web_app', 'web_zld22f'),
(8, '2023-06-04 19:25:15', '2023-06-04 19:40:20', 'web_app', 'web_d8180kaf'),
(8, '2023-06-01 17:30:00', '2023-06-01 18:15:35', 'mobile_app', 'mobile_q3mz8n'),
(9, '2023-06-04 07:45:30', '2023-06-04 08:15:27', 'mobile_app', 'mobile_g3mjfz'),
(10, '2023-06-02 14:10:15', '2023-06-02 14:40:58', 'web_app', 'web_zz91p44l'),
(5, CURRENT_TIMESTAMP - INTERVAL '31 days', CURRENT_TIMESTAMP - INTERVAL '31 days' + INTERVAL '15 min', 'web_app', 'web_8902wknz'),
(6, CURRENT_TIMESTAMP - INTERVAL '8 days', CURRENT_TIMESTAMP - INTERVAL '8 days' + INTERVAL '15 min', 'web_app', 'web_zz91p44l'),
(7, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '15 min', 'web_app', 'web_zz91p44l'),
(8, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 min', 'web_app', 'web_d8180kaf'),
(9, CURRENT_TIMESTAMP - INTERVAL '1 days', CURRENT_TIMESTAMP - INTERVAL '1 days' + INTERVAL '15 min', 'mobile_app', 'mobile_g3mjfz'),
(10, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '15 min', 'web_app', 'web_zz91p44l'),
(5, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '15 min', 'web_app', 'web_8902wknz')
;

-- user_setting_snapshot
INSERT INTO consumer_div.user_setting_snapshot (user_id, snapshot_date, tx_limit_daily, tx_limit_monthly, membership_status, password_hash, api_key, verified_devices, verified_ips, mfa_enabled, marketing_opt_in, created_at)
VALUES
(1, '2023-06-07', 1000.00, 5000.00, 2, 'bcryptHash($2yz9!&ka1)', '9d61c49b-8977-4914-a36b-80d1445e38fa', 'mobile_8fh2k1', '192.168.0.1', true, false, '2023-06-07 00:00:00'),
(2, '2023-06-07', 500.00, 2500.00, 1, 'bcryptHash(qpwo9874zyGk!)', NULL, 'mobile_yjp08q, mobile_1av8p0', '198.51.100.233, 70.121.39.25', false, true, '2023-06-07 00:00:00'),
(3, '2023-06-07', 2000.00, 10000.00, 3, 'bcryptHash(Fr3nchPa1n!@98zy)', 'e785f611-fdd8-4c2d-a870-e104358712e5', 'web_k29qjd, mobile_x28qlj', '216.58.195.68, 92.110.51.150', true, false, '2023-06-07 00:00:00'),
(4, '2023-06-07', 5000.00, 20000.00, 4, 'bcryptHash(Vacay2023*&!Rm)', NULL, 'mobile_34jdkl', '143.92.64.138', false, true, '2023-06-07 00:00:00'),
(5, '2023-06-07', 100.00, 500.00, 0, 'bcryptHash(cRaf7yCr8zy)', NULL, 'web_8902wknz', '192.64.112.188', false, false, '2023-06-07 00:00:00'),
(6, '2023-06-07', 50.00, 500.00, 1, 'bcryptHash(C0d3Rul3z!99)', '6c03c175-9ac9-4854-b064-a3fff2c62e31', 'web_zz91p44l', '4.14.15.90', true, true, '2023-06-07 00:00:00'),
(7, '2023-06-07', 250.00, 1000.00, 2, 'bcryptHash(zEnH0me&Pw7)', NULL, NULL, NULL, false, true, '2023-06-07 00:00:00'),
(8, '2023-06-07', 200.00, 1000.00, 0, 'bcryptHash(K1dzPlay!&Rt8)', NULL, 'web_d8180kaf, mobile_q3mz8n', '8.26.53.165, 68.85.32.201', false, false, '2023-06-07 00:00:00'),
(9, '2023-06-07', 150.00, 1000.00, 2, 'bcryptHash(Gl0wUp7!9zy)', NULL, 'mobile_g3mjfz', '203.96.81.36', true, true, '2023-06-07 00:00:00'),
(10, '2023-06-07', 300.00, 2000.00, 1, 'bcryptHash(GamzRu1ez*&99!)', NULL, 'web_d8180kaf', '8.26.53.165', false, true, '2023-06-07 00:00:00'),
(1, '2023-06-01', 500.00, 1000.00, 2, 'bcryptHash($2yz9!&ka1)', '9d61c49b-8977-4914-a36b-80d1445e38fa', 'mobile_8fh2k1', '192.168.0.1', false, true, '2023-06-01 06:00:00'),
(2, '2023-06-01', 500.00, 2500.00, 1, 'bcryptHash(qpwo9874zyGk!)', NULL, 'mobile_yjp08q', '198.51.100.233, 70.121.39.25', true, false, '2023-06-01 09:00:00');
