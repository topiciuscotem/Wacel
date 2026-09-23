const WACEL_CONFIG = {
  supabaseUrl: 'https://YOUR_PROJECT_ID.supabase.co', // من supabase.com
  supabaseKey: 'YOUR_ANON_KEY_HERE', // anon public key
  whatsappNumber: '212600000000', // نمرة واتساب ديالك للطلبات
  useFirebaseFallback: true // إلا Supabase ما خدمش، يخدم بـ Firebase
};

// تحميل Supabase من CDN تلقائياً
let supabaseClient = null;
async function initSupabase() {
  if (WACEL_CONFIG.supabaseUrl.includes('YOUR_PROJECT')) {
    console.warn('⚠️ بدل supabaseUrl و supabaseKey فـ wacel-api.js باش يخدم SQL');
    return null;
  }
  try {
    const { createClient } = await import('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm');
    supabaseClient = createClient(WACEL_CONFIG.supabaseUrl, WACEL_CONFIG.supabaseKey);
    console.log('✅ Supabase connected - SQL خدام');
    return supabaseClient;
  } catch (e) {
    console.error('Supabase error:', e);
    return null;
  }
}

// تهيئة عند تحميل الصفحة
let dbReady = initSupabase();

// ===== 2. دوال الأخبار - محلية/إقليمية/دولية/مونديال 2030 =====
const NewsAPI = {
  // جيب أخبار حسب التصنيف
  async getByCategory(slug, limit = 10) {
    const db = await dbReady;
    if (!db) return this.getMockNews(slug);
    const { data: cat } = await db.from('categories').select('id').eq('slug', slug).single();
    if (!cat) return [];
    const { data, error } = await db.from('news').select('*').eq('category_id', cat.id).order('published_at', {ascending: false}).limit(limit);
    if (error) { console.error(error); return []; }
    return data;
  },
  async getBreaking() {
    const db = await dbReady;
    if (!db) return [{title: 'المغرب يستعد لمونديال 2030 - ملعب الحسن الثاني', is_breaking: true}];
    const { data } = await db.from('news').select('*').eq('is_breaking', true).order('published_at', {descending: true}).limit(5);
    return data || [];
  },
  async getWorldCup() { return this.getByCategory('worldcup2030', 8); },
  async getLocal() { return this.getByCategory('local', 6); },

  // بحث ذكي - FULLTEXT
  async search(query) {
    const db = await dbReady;
    if (!db) return [];
    const { data } = await db.from('news').select('*').ilike('title', `%${query}%`).limit(10);
    return data || [];
  },

  // زيادة المشاهدات - مهم لـ AdSense
  async addView(newsId) {
    const db = await dbReady;
    if (!db) return;
    await db.rpc('increment_views', { row_id: newsId }); // تقدر تدير function فـ Supabase
    // أو ببساطة:
    const { data: current } = await db.from('news').select('views').eq('id', newsId).single();
    if (current) await db.from('news').update({views: current.views + 1}).eq('id', newsId);
  },

  getMockNews(slug) {
    const mocks = {
      worldcup2030: [
        {title: 'ملعب الحسن الثاني - 115 ألف متفرج - الأكبر في العالم', excerpt: 'الدار البيضاء', views: 1250, is_breaking: true},
        {title: 'الفيفا تشيد بملاعب المغرب', excerpt: 'الرباط', views: 890}
      ],
      local: [
        {title: 'ترامواي جديد يربط مطار كازا بالملعب', views: 450},
        {title: 'أسواق المنتوجات المغربية تنتعش قبل 2030', views: 320}
      ]
    };
    return mocks[slug] || [];
  }
};

// ===== 3. تحليل AI - كيخلي الناس تبقى بزاف =====
const AI_API = {
  async getAll(limit=4) {
    const db = await dbReady;
    if (!db) return [{title: 'تحليل AI: هل سيرفع المونديال الناتج الداخلي 40%؟', summary: 'تحليل تفاعلي', reading_time: 5}];
    const { data } = await db.from('ai_analysis').select('*').order('created_at', {descending: true}).limit(limit);
    return data || [];
  },
  // توليد تحليل جديد بـ OpenAI (اختياري)
  async generate(topic) {
    // هنا تحط مفتاح OpenAI ديالك - اختياري
    // const res = await fetch('https://api.openai.com/v1/chat/completions', {...})
    // بعد التوليد، خزنو فـ SQL:
    // await supabaseClient.from('ai_analysis').insert({title: `تحليل: ${topic}`, content: aiContent, prompt: topic})
    alert(`🤖 تحليل AI لـ: ${topic}\nغادي يتولد ويتخزن فـ جدول ai_analysis\nالزائر غادي يبقى 5 دقايق = ربح x3`);
    return {title: `تحليل: ${topic}`, content: 'محتوى تجريبي...'};
  }
};

// ===== 4. المكتبة - كتب/فيديو/أغاني =====
const LibraryAPI = {
  async getBooks(limit=8) {
    const db = await dbReady;
    if (!db) return [];
    const { data } = await db.from('books').select('*').order('created_at', {descending: true}).limit(limit);
    return data || [];
  },
  async getVideos() {
    const db = await dbReady;
    if (!db) return [{title: 'وثائقي المغرب 2030', youtube_id: 'dQw4w9WgXcQ'}];
    const { data } = await db.from('videos').select('*').limit(6);
    return data || [];
  }
};

// ===== 5. النجوم - تفاعلات مباشرة =====
const StarsAPI = {
  async getTrending() {
    const db = await dbReady;
    if (!db) return [
      {star_name: 'Cristiano', platform: 'instagram', profile_url: 'https://instagram.com/cristiano', followers: 620000000, is_trending: true},
      {star_name: 'Achraf Hakimi', platform: 'instagram', profile_url: 'https://instagram.com/achrafhakimi', is_trending: true}
    ];
    const { data } = await db.from('stars_interactions').select('*').eq('is_trending', true).order('followers', {descending: true}).limit(6);
    return data || [];
  }
};

// ===== 6. المنتدى - topics + comments =====
const ForumAPI = {
  async getTopics(limit=10) {
    const db = await dbReady;
    if (!db) return JSON.parse(localStorage.getItem('wacel_forum_mock')||'[]');
    const { data } = await db.from('forum_topics').select('*, users(username)').order('created_at', {descending: true}).limit(limit);
    return data || [];
  },
  async createTopic(title, content, category='نقاش عام') {
    const db = await dbReady;
    const user = JSON.parse(localStorage.getItem('wacel_user')||'{"id":1}');
    if (!db) {
      const mock = JSON.parse(localStorage.getItem('wacel_forum_mock')||'[]');
      mock.unshift({id: Date.now(), title, content, category, likes:0, comments_count:0, created_at: new Date()});
      localStorage.setItem('wacel_forum_mock', JSON.stringify(mock));
      return {success: true};
    }
    const { data, error } = await db.from('forum_topics').insert({user_id: user.id, title, content, category}).select();
    if (!error) await PointsAPI.add(user.id, 'topic', 10);
    return {success: !error, data};
  },
  async getComments(topicId) {
    const db = await dbReady;
    if (!db) return [];
    const { data } = await db.from('forum_comments').select('*, users(username)').eq('topic_id', topicId).order('created_at', {ascending: true});
    return data || [];
  }
};

// ===== 7. المتجر المغربي - الدفع عند الاستلام =====
const StoreAPI = {
  async getProducts(city=null, category=null) {
    const db = await dbReady;
    if (!db) return [
      {id:1, name:'زيت أركان 100ml', price:149, city:'أكادير', profit_per_sale:35, image_url:'https://images.unsplash.com/photo-1608571423902-eed4a94d8108'},
      {id:2, name:'جلابة فاس', price:399, city:'فاس', profit_per_sale:80}
    ];
    let query = db.from('products').select('*').gt('stock', 0);
    if (city) query = query.eq('city', city);
    if (category) query = query.eq('category_id', category);
    const { data } = await query.order('sales', {descending: true}).limit(20);
    return data || [];
  },
  async createOrder(orderData) {
    // orderData = {customer_name, phone, city, address, items, total}
    const db = await dbReady;
    const orderCode = 'WAC-' + new Date().getFullYear() + '-' + Math.floor(Math.random()*9000+1000);
    const order = {
      order_code: orderCode,
      customer_name: orderData.name,
      customer_phone: orderData.phone,
      customer_city: orderData.city,
      customer_address: orderData.address,
      customer_note: orderData.note || '',
      total_amount: orderData.total,
      status: 'new',
      payment_method: 'cod'
    };
    
    if (db) {
      const { data, error } = await db.from('orders').insert(order).select().single();
      if (!error && orderData.items) {
        // حفظ المنتجات
        for (const item of orderData.items) {
          await db.from('order_items').insert({order_id: data.id, product_id: item.id, quantity: 1, price: item.price});
        }
      }
      if (error) console.error(error);
    } else {
      // حفظ محلي إلا ما كاينش SQL
      const orders = JSON.parse(localStorage.getItem('wacel_orders')||'[]');
      orders.push({...order, items: orderData.items, id: Date.now()});
      localStorage.setItem('wacel_orders', JSON.stringify(orders));
    }

    // إرسال واتساب تلقائي - أهم حاجة فالمغرب
    const msg = `طلب جديد ${orderCode}%0Aالاسم: ${order.customer_name}%0Aالهاتف: ${order.customer_phone}%0Aالمدينة: ${order.customer_city}%0Aالعنوان: ${order.customer_address}%0Aالمنتجات: ${orderData.items.map(i=>i.name).join(', ')}%0Aالمجموع: ${order.total_amount} MAD%0Aالدفع عند الاستلام`;
    window.open(`https://wa.me/${WACEL_CONFIG.whatsappNumber}?text=${msg}`, '_blank');

    // نقاط
    await PointsAPI.add(null, 'purchase', 50);

    return {success: true, orderCode};
  },
  async getEarnings() {
    const db = await dbReady;
    if (!db) return {revenue: 1250, profit: 320, orders: 8};
    const { data } = await db.from('v_daily_earnings').select('*').limit(7);
    return data || [];
  }
};

// ===== 8. نظام النقاط والربح =====
const PointsAPI = {
  async add(userId, action, points) {
    const db = await dbReady;
    const uid = userId || JSON.parse(localStorage.getItem('wacel_user')||'{"id":1}').id;
    if (db) {
      await db.from('points_history').insert({user_id: uid, action, points});
    }
    // محلي
    let total = parseInt(localStorage.getItem('wacel_points')||'0') + points;
    localStorage.setItem('wacel_points', total);
    const badge = document.getElementById('points-badge');
    if (badge) badge.textContent = total + ' نقطة';
    return total;
  },
  async getBalance(userId) {
    const db = await dbReady;
    if (!db) return parseInt(localStorage.getItem('wacel_points')||'0');
    const { data } = await db.from('user_points').select('total_points').eq('user_id', userId).single();
    return data?.total_points || 0;
  }
};

// ===== 9. التتبع والربح - AdSense + Affiliate =====
const TrackingAPI = {
  async trackView(pageUrl, pageType, duration=0) {
    const db = await dbReady;
    if (!db) return;
    await db.from('page_views').insert({page_url: pageUrl, page_type: pageType, duration_seconds: duration});
  },
  async trackAdClick(slot) {
    const db = await dbReady;
    if (!db) return;
    await db.from('ad_clicks').insert({ad_slot: slot, page_url: window.location.href});
    console.log('Ad click tracked:', slot);
  },
  async trackAffiliate(productId, network, url) {
    const db = await dbReady;
    if (!db) return;
    await db.from('affiliate_clicks').insert({product_id: productId, affiliate_network: network, clicked_url: url});
  },
  async subscribeNewsletter(email, city='') {
    const db = await dbReady;
    if (!db) {
      let list = JSON.parse(localStorage.getItem('wacel_newsletter')||'[]');
      list.push(email); localStorage.setItem('wacel_newsletter', JSON.stringify(list));
      return true;
    }
    const { error } = await db.from('newsletter_subscribers').insert({email, city, source: 'api'});
    return !error;
  }
};

// ===== 10. بحث شامل في كلشي =====
async function searchAll(query) {
  const results = {
    news: await NewsAPI.search(query),
    products: (await StoreAPI.getProducts()).filter(p=>p.name.includes(query)),
    topics: (await ForumAPI.getTopics(20)).filter(t=>t.title.includes(query))
  };
  return results;
}

// تصدير عام - تقدر تستعملهم فـ أي صفحة
window.WacelAPI = {
  init: initSupabase,
  news: NewsAPI,
  ai: AI_API,
  library: LibraryAPI,
  stars: StarsAPI,
  forum: ForumAPI,
  store: StoreAPI,
  points: PointsAPI,
  track: TrackingAPI,
  search: searchAll,
  config: WACEL_CONFIG
};

// تشغيل تلقائي
document.addEventListener('DOMContentLoaded', async () => {
  await initSupabase();
  // مثال: عمر الأخبار العاجلة تلقائياً
  const breaking = await NewsAPI.getBreaking();
  const ticker = document.querySelector('.ticker-track');
  if (ticker && breaking.length) {
    ticker.textContent = breaking.map(n=>n.title).join(' | ') + ' | ';
  }
  console.log('Wacel API Ready - SQL خدام ✅');
});
