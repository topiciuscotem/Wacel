-- =========================================================
-- Wacel.MA - قاعدة البيانات الشاملة - البوابة المغربية 2030
-- متوافق مع MySQL 8+ و Supabase/PostgreSQL و PlanetScale
-- يجعل الموقع تفاعلي 100% + نظام ربح ونقاط ومتجر
-- =========================================================

-- حذف الجداول القديمة إذا كاينة
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS ad_clicks, affiliate_clicks, page_views, newsletter_subscribers;
DROP TABLE IF EXISTS order_items, orders, products, sellers;
DROP TABLE IF EXISTS points_history, user_points;
DROP TABLE IF EXISTS comment_likes, forum_comments, forum_topics;
DROP TABLE IF EXISTS stars_interactions, entertainment, magazines, movies, documentaries, songs, videos, books;
DROP TABLE IF EXISTS ai_analysis, news, categories, users;
DROP TABLE IF EXISTS worldcup_matches, worldcup_stadiums;
SET FOREIGN_KEY_CHECKS=1;

-- =========================================================
-- 1. المستخدمين - أساس كلشي
-- =========================================================
CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  uid VARCHAR(100) UNIQUE NOT NULL COMMENT 'Firebase UID أو معرف',
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(20) COMMENT 'رقم واتساب - مهم للمغرب',
  city VARCHAR(50) DEFAULT 'الدار البيضاء',
  avatar_url VARCHAR(255),
  role ENUM('user','seller','moderator','admin') DEFAULT 'user',
  points INT DEFAULT 0 COMMENT 'نظام النقاط = خصم',
  subscription ENUM('free','pro') DEFAULT 'free',
  subscription_ends_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_points (points DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 2. التصنيفات
-- =========================================================
CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name_ar VARCHAR(100) NOT NULL,
  name_en VARCHAR(100),
  slug VARCHAR(100) UNIQUE NOT NULL,
  type ENUM('news','library','store','forum','entertainment') NOT NULL,
  icon VARCHAR(50)
);

INSERT INTO categories (name_ar, slug, type, icon) VALUES
('محلية', 'local', 'news', 'fa-map-pin'),
('إقليمية', 'regional', 'news', 'fa-globe-africa'),
('دولية', 'international', 'news', 'fa-earth'),
('مونديال 2030', 'worldcup2030', 'news', 'fa-futbol'),
('كتب', 'books', 'library', 'fa-book'),
('فيديوهات', 'videos', 'library', 'fa-video'),
('أغاني', 'songs', 'library', 'fa-music'),
('وثائقيات', 'docs', 'library', 'fa-film'),
('أفلام', 'movies', 'library', 'fa-clapperboard'),
('مجلات', 'magazines', 'library', 'fa-newspaper'),
('صناعة تقليدية', 'craft', 'store', 'fa-hands'),
('أركان وتجميل', 'argan', 'store', 'fa-leaf');

-- =========================================================
-- 3. الأخبار - محلية وإقليمية ودولية + مونديال 2030
-- =========================================================
CREATE TABLE news (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  excerpt VARCHAR(400),
  content TEXT NOT NULL,
  image_url VARCHAR(500),
  source_url VARCHAR(500),
  is_breaking BOOLEAN DEFAULT FALSE COMMENT 'عاجل؟',
  is_ai_analyzed BOOLEAN DEFAULT FALSE,
  views INT UNSIGNED DEFAULT 0,
  likes INT UNSIGNED DEFAULT 0,
  author_id BIGINT UNSIGNED,
  published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL,
  FULLTEXT idx_search (title, content),
  INDEX idx_category (category_id),
  INDEX idx_breaking (is_breaking, published_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- جدول خاص بمونديال 2030 - CPM عالي
CREATE TABLE worldcup_stadiums (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  city VARCHAR(50) NOT NULL,
  capacity INT,
  status ENUM('planned','building','ready') DEFAULT 'planned',
  image_url VARCHAR(500)
);

CREATE TABLE worldcup_matches (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  stadium_id INT UNSIGNED,
  team_a VARCHAR(50),
  team_b VARCHAR(50),
  match_date DATETIME,
  stage VARCHAR(50) COMMENT 'مجموعات، ثمن نهائي...',
  FOREIGN KEY (stadium_id) REFERENCES worldcup_stadiums(id)
);

INSERT INTO worldcup_stadiums (name, city, capacity, status) VALUES
('ملعب الحسن الثاني', 'الدار البيضاء', 115000, 'planned'),
('ملعب الأمير مولاي عبد الله', 'الرباط', 69000, 'building'),
('ملعب طنجة الكبير', 'طنجة', 75000, 'building'),
('ملعب مراكش', 'مراكش', 45000, 'ready');

-- =========================================================
-- 4. تحليل بالذكاء الاصطناعي - هذا كيخلي الناس تبقى بزاف = ربح
-- =========================================================
CREATE TABLE ai_analysis (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  news_id BIGINT UNSIGNED NULL,
  title VARCHAR(255) NOT NULL,
  prompt TEXT COMMENT 'السؤال اللي سولنا AI',
  ai_model VARCHAR(50) DEFAULT 'gpt-4o-mini',
  content TEXT NOT NULL COMMENT 'التحليل الكامل',
  summary VARCHAR(500),
  chart_data JSON COMMENT 'بيانات الرسم البياني',
  views INT UNSIGNED DEFAULT 0,
  reading_time INT DEFAULT 5 COMMENT 'دقائق',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (news_id) REFERENCES news(id) ON DELETE SET NULL,
  FULLTEXT idx_ai_search (title, content)
);

-- =========================================================
-- 5. المكتبة الشاملة
-- =========================================================
CREATE TABLE books (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(150),
  category_id INT UNSIGNED,
  description TEXT,
  cover_url VARCHAR(500),
  file_url VARCHAR(500) COMMENT 'PDF أو رابط',
  is_free BOOLEAN DEFAULT TRUE,
  price DECIMAL(8,2) DEFAULT 0,
  affiliate_url VARCHAR(500) COMMENT 'رابط Jumia/Amazon - تربح عمولة',
  downloads INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE videos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  youtube_id VARCHAR(20) COMMENT 'ID ديال يوتيوب',
  duration INT COMMENT 'بالثواني',
  category VARCHAR(50),
  views INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE songs ( id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), artist VARCHAR(150), audio_url VARCHAR(500), cover_url VARCHAR(500), plays INT UNSIGNED DEFAULT 0 );
CREATE TABLE documentaries ( id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), description TEXT, video_url VARCHAR(500), duration INT, views INT UNSIGNED DEFAULT 0 );
CREATE TABLE movies ( id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), year INT, poster_url VARCHAR(500), trailer_url VARCHAR(500), rating DECIMAL(3,1) );
CREATE TABLE magazines ( id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255), issue_date DATE, cover_url VARCHAR(500), pdf_url VARCHAR(500) );

-- =========================================================
-- 6. تفاعلات النجوم العالميين - روابط مباشرة
-- =========================================================
CREATE TABLE stars_interactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  star_name VARCHAR(100) NOT NULL,
  platform ENUM('instagram','tiktok','x','youtube','facebook') NOT NULL,
  handle VARCHAR(100) NOT NULL,
  profile_url VARCHAR(500) NOT NULL,
  last_post_url VARCHAR(500),
  followers BIGINT UNSIGNED,
  is_trending BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_trending (is_trending DESC, followers DESC)
);

INSERT INTO stars_interactions (star_name, platform, handle, profile_url, followers, is_trending) VALUES
('Cristiano Ronaldo', 'instagram', 'cristiano', 'https://instagram.com/cristiano', 620000000, TRUE),
('Khaby Lame', 'tiktok', 'khaby.lame', 'https://tiktok.com/@khaby.lame', 162000000, TRUE),
('Elon Musk', 'x', 'elonmusk', 'https://x.com/elonmusk', 180000000, TRUE),
('Achraf Hakimi', 'instagram', 'achrafhakimi', 'https://instagram.com/achrafhakimi', 25000000, TRUE);

-- =========================================================
-- 7. المنتدى التفاعلي - يزيد المحتوى مجاناً
-- =========================================================
CREATE TABLE forum_topics (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  category VARCHAR(50) DEFAULT 'نقاش عام',
  title VARCHAR(255) NOT NULL,
  content TEXT,
  likes INT UNSIGNED DEFAULT 0,
  comments_count INT UNSIGNED DEFAULT 0,
  views INT UNSIGNED DEFAULT 0,
  is_pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FULLTEXT idx_forum_search (title, content),
  INDEX idx_category (category)
);

CREATE TABLE forum_comments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  topic_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  content TEXT NOT NULL,
  likes INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (topic_id) REFERENCES forum_topics(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================================================
-- 8. نظام النقاط - سر الرجوع اليومي
-- =========================================================
CREATE TABLE user_points (
  user_id BIGINT UNSIGNED PRIMARY KEY,
  total_points INT DEFAULT 0,
  level INT DEFAULT 1,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE points_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  action ENUM('read','comment','topic','like','share','purchase','daily_login','referral') NOT NULL,
  points INT NOT NULL,
  reference_id BIGINT UNSIGNED COMMENT 'ID ديال الموضوع أو المنتج',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_date (user_id, created_at DESC)
);

-- Trigger: ملي كيزيدو النقاط كيتحدّث level تلقائياً
DELIMITER //
CREATE TRIGGER after_points_insert AFTER INSERT ON points_history
FOR EACH ROW
BEGIN
  INSERT INTO user_points (user_id, total_points) VALUES (NEW.user_id, NEW.points)
  ON DUPLICATE KEY UPDATE total_points = total_points + NEW.points, level = FLOOR((total_points+NEW.points)/100)+1;
  UPDATE users SET points = points + NEW.points WHERE id = NEW.user_id;
END//
DELIMITER ;

-- =========================================================
-- 9. المتجر المغربي - الدفع عند الاستلام
-- =========================================================
CREATE TABLE sellers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  store_name VARCHAR(100) NOT NULL,
  city VARCHAR(50),
  whatsapp VARCHAR(20),
  commission_rate DECIMAL(4,2) DEFAULT 15.00 COMMENT 'نسبة عمولة Wacel',
  is_verified BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE products (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  seller_id BIGINT UNSIGNED NULL,
  category_id INT UNSIGNED,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  old_price DECIMAL(10,2) NULL,
  cost DECIMAL(10,2) COMMENT 'ثمن الشراء - باش تحسب الربح',
  stock INT DEFAULT 100,
  image_url VARCHAR(500),
  images JSON COMMENT 'صور إضافية',
  city VARCHAR(50) DEFAULT 'الدار البيضاء' COMMENT 'مدينة المنتج',
  is_affiliate BOOLEAN DEFAULT FALSE COMMENT 'منتج Jumia؟',
  affiliate_url VARCHAR(500),
  profit_per_sale DECIMAL(10,2) GENERATED ALWAYS AS (price - IFNULL(cost, price*0.7)) STORED,
  views INT UNSIGNED DEFAULT 0,
  sales INT UNSIGNED DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_city (city),
  INDEX idx_affiliate (is_affiliate)
);

CREATE TABLE orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'WAC-2026-XXXX',
  user_id BIGINT UNSIGNED NULL,
  customer_name VARCHAR(100) NOT NULL,
  customer_phone VARCHAR(20) NOT NULL,
  customer_city VARCHAR(50) NOT NULL,
  customer_address VARCHAR(255) NOT NULL,
  customer_note TEXT,
  total_amount DECIMAL(10,2) NOT NULL,
  delivery_fee DECIMAL(6,2) DEFAULT 0,
  status ENUM('new','confirmed','shipped','delivered','cancelled') DEFAULT 'new',
  payment_method ENUM('cod','mopay','wafacash') DEFAULT 'cod',
  whatsapp_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_status (status, created_at DESC),
  INDEX idx_city (customer_city),
  INDEX idx_phone (customer_phone)
);

CREATE TABLE order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  quantity INT UNSIGNED DEFAULT 1,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- =========================================================
-- 10. الربح والتتبع - مهم بزاف
-- =========================================================
CREATE TABLE ad_clicks (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  ad_slot VARCHAR(50) COMMENT 'top, sidebar, infeed',
  page_url VARCHAR(500),
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_slot_date (ad_slot, created_at)
);

CREATE TABLE affiliate_clicks (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  product_id BIGINT UNSIGNED NULL,
  affiliate_network ENUM('jumia','amazon','other') NOT NULL,
  clicked_url VARCHAR(500),
  converted BOOLEAN DEFAULT FALSE COMMENT 'واش شرا؟',
  commission DECIMAL(8,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE page_views (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  page_url VARCHAR(500) NOT NULL,
  page_type VARCHAR(50) COMMENT 'news, product, forum',
  duration_seconds INT DEFAULT 0 COMMENT 'مدة البقاء - مهم لـ AdSense',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_page_type (page_type, created_at DESC)
);

CREATE TABLE newsletter_subscribers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(150) UNIQUE NOT NULL,
  city VARCHAR(50),
  is_active BOOLEAN DEFAULT TRUE,
  source VARCHAR(50) COMMENT 'منين جا؟ popup, footer',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================
-- 11. Views جاهزة للربح - Dashboard
-- =========================================================

-- لوحة تحكم الربح اليومي
CREATE VIEW v_daily_earnings AS
SELECT 
  DATE(created_at) as day,
  COUNT(*) as orders_count,
  SUM(total_amount) as revenue,
  SUM(total_amount * 0.15) as estimated_profit
FROM orders WHERE status != 'cancelled'
GROUP BY DATE(created_at) ORDER BY day DESC;

-- أكثر المنتجات ربحاً
CREATE VIEW v_top_products AS
SELECT p.name, p.city, p.sales, p.views, p.profit_per_sale, (p.sales * p.profit_per_sale) as total_profit
FROM products p ORDER BY total_profit DESC LIMIT 20;

-- أكثر المستخدمين تفاعلاً
CREATE VIEW v_top_users AS
SELECT u.username, u.city, u.points, COUNT(ft.id) as topics, COUNT(fc.id) as comments
FROM users u
LEFT JOIN forum_topics ft ON ft.user_id = u.id
LEFT JOIN forum_comments fc ON fc.user_id = u.id
GROUP BY u.id ORDER BY u.points DESC LIMIT 20;

-- =========================================================
-- 12. بيانات تجريبية - منتجات مغربية
-- =========================================================
INSERT INTO products (name, description, price, old_price, cost, category_id, city, image_url, stock) VALUES
('زيت أركان أصلي 100ml - نساء أركانة', 'معصور على البارد - تعاونية نسائية', 149.00, 199.00, 80.00, 12, 'أكادير', 'https://images.unsplash.com/photo-1608571423902-eed4a94d8108', 200),
('جلابة مغربية رجال - صوف فاس', 'صناعة يدوية فاسية', 399.00, 550.00, 250.00, 11, 'فاس', 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c', 50),
('بلغة جلد طبيعي - صفراء', 'بلغة مغربية أصيلة', 129.00, 180.00, 70.00, 11, 'مراكش', 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2', 120),
('عسل حر جبال الأطلس 500g', 'عسل حر بدون سكر', 180.00, 220.00, 110.00, 12, 'أزيلال', 'https://images.unsplash.com/photo-1587049352846-4a222e784d38', 80),
('طاجين فخار ناظور', 'طاجين تقليدي', 89.00, 120.00, 40.00, 11, 'الناظور', 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6', 300);

-- أخبار مونديال 2030 تجريبية
INSERT INTO news (category_id, title, slug, excerpt, content, is_breaking, views) VALUES
(4, 'المغرب يبني أكبر ملعب في العالم بالدار البيضاء', 'morocco-biggest-stadium-casablanca', 'ملعب الحسن الثاني بسعة 115 ألف متفرج', 'تفاصيل المشروع الضخم استعدادا لمونديال 2030...', TRUE, 1250),
(1, 'ترامواي جديد في الدار البيضاء قبل المونديال', 'tram-casablanca-2026', 'خطوط جديدة تربط الملعب بالمطار', 'المشروع سينتهي في 2028...', FALSE, 890);

-- =========================================================
-- 13. استعلامات تفاعلية جاهزة - كوبي كولي
-- =========================================================

-- 1. البحث الذكي في كلشي
-- SELECT * FROM news WHERE MATCH(title, content) AGAINST('مونديال 2030' IN BOOLEAN MODE) LIMIT 10;

-- 2. المنتجات حسب المدينة - مهم للـ COD
-- SELECT * FROM products WHERE city = 'الدار البيضاء' AND stock > 0 ORDER BY sales DESC;

-- 3. منتدى مع عدد التعليقات
-- SELECT ft.*, u.username, COUNT(fc.id) as real_comments FROM forum_topics ft JOIN users u ON ft.user_id=u.id LEFT JOIN forum_comments fc ON fc.topic_id=ft.id GROUP BY ft.id ORDER BY ft.created_at DESC;

-- 4. نقاط المستخدم + خصم
-- SELECT total_points, FLOOR(total_points/10) as discount_mad FROM user_points WHERE user_id = 1;

-- 5. الربح الشهري
-- SELECT * FROM v_daily_earnings WHERE day >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- =========================================================
-- انتهى - دابا الموقع ديالك تفاعلي 100%
-- =========================================================
