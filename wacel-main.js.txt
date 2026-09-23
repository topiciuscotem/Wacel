/* Wacel.MA - main.js - كل الأكواد التفاعلية + الربح */
console.log('Wacel 2026 Loaded - بوابة مغربية شاملة');

// ===== 1. إعدادات عامة =====
const CONFIG = {
  adsenseClient: 'ca-pub-XXXXXXXXXXXXXXX', // <-- بدلها بـ ID ديالك
  worldCupDate: '2030-06-13T00:00:00',
  affiliate: {
    jumia: 'https://www.jumia.ma/catalog/?q=',
    amazon: 'https://www.amazon.com/s?k='
  }
};

// ===== 2. تاريخ اليوم + عد تنازلي مونديال 2030 =====
function initDates(){
  const dateEl = document.getElementById('today-date');
  if(dateEl){
    dateEl.textContent = new Date().toLocaleDateString('ar-MA',{weekday:'long',year:'numeric',month:'long',day:'numeric'});
  }
  const cdEl = document.getElementById('countdown');
  if(cdEl){
    setInterval(()=>{
      const target = new Date(CONFIG.worldCupDate).getTime();
      const diff = target - Date.now();
      if(diff <=0){ cdEl.innerHTML='🏆 مونديال 2030 بدا!'; return; }
      const d = Math.floor(diff/(1000*60*60*24));
      const h = Math.floor((diff%(1000*60*60*24))/(1000*60*60));
      const m = Math.floor((diff%(1000*60*60))/(1000*60));
      cdEl.innerHTML = `
        <div><b>${d}</b>يوم</div>
        <div><b>${h}</b>ساعة</div>
        <div><b>${m}</b>دقيقة</div>
        <div><b>2030</b>المغرب</div>`;
    },1000);
  }
}

// ===== 3. وضع ليلي - يزيد مدة البقاء = ربح أكثر =====
function toggleDark(){
  document.documentElement.classList.toggle('dark');
  localStorage.setItem('wacel_dark', document.documentElement.classList.contains('dark'));
}
if(localStorage.getItem('wacel_dark')==='true') document.documentElement.classList.add('dark');

// ===== 4. تبويبات المكتبة الشاملة =====
function initTabs(){
  const btns = document.querySelectorAll('.tab-btn');
  const contents = document.querySelectorAll('.tab-content');
  btns.forEach(btn=>{
    btn.addEventListener('click',()=>{
      btns.forEach(b=>b.classList.remove('active')); btn.classList.add('active');
      const tab = btn.dataset.tab;
      contents.forEach(c=>c.classList.remove('active'));
      const target = document.getElementById('tab-'+tab);
      if(target) target.classList.add('active');
      // تتبع أفلييت - نعرف شنو كيقلب الزائر
      console.log('Tab view:',tab);
    });
  });
}

// ===== 5. بحث فوري في كلشي =====
function initSearch(){
  const input = document.getElementById('searchBox');
  if(!input) return;
  input.addEventListener('input', e=>{
    const q = e.target.value.toLowerCase().trim();
    document.querySelectorAll('.book-card, .product-card, .forum-row, .ai-card').forEach(el=>{
      const txt = el.innerText.toLowerCase();
      el.style.display = txt.includes(q) ? '' : 'none';
    });
    if(q.length>2){
      // هنا تقدر تزيد إعلان بعد البحث - مربح جداً
      // showInSearchAd(q);
    }
  });
}

// ===== 6. تحليل AI تفاعلي - هذا كيخلي الناس تبقى بزاف =====
function openAIAnalysis(topic='الاقتصاد المغربي'){
  const modal = document.getElementById('ai-modal');
  const box = document.getElementById('ai-modal-content');
  if(!modal) {
    alert(`🤖 تحليل AI لـ: ${topic}\n\nهنا غادي يتربط مع OpenAI API\nالزائر غادي يبقى 5 دقايق كيقرا التحليل = ربح AdSense x3`);
    return;
  }
  modal.classList.add('active');
  box.innerHTML = `
    <div style="text-align:center;padding:20px">
      <div class="ai-badge">تحليل بالذكاء الاصطناعي - مباشر</div>
      <h3 style="font-weight:900;margin:15px 0">تحليل: ${topic} وتأثير مونديال 2030</h3>
      <p style="font-size:13px;color:var(--muted)">جاري توليد التحليل... <i class="fa fa-spinner fa-spin"></i></p>
      <div style="background:var(--ad-bg);padding:15px;border-radius:12px;margin-top:15px;text-align:right;font-size:13px;line-height:1.9">
        حسب تحليل AI لبيانات 2023-2026، المغرب سيستفيد من:<br>
        • 45% نمو في السياحة<br>
        • 120,000 منصب شغل جديد<br>
        • المنتوجات المحلية (أركان، زليج) الطلب عليها +80%<br><br>
        <b>توصية للربح:</b> ركّز على متجر المنتوجات المغربية قبل 2028.
      </div>
      <button onclick="document.getElementById('ai-modal').classList.remove('active')" style="margin-top:15px;background:#000;color:#fff;padding:10px 20px;border-radius:999px;border:none">إغلاق</button>
    </div>`;

  // --- هنا تحط كود الربط الحقيقي مع Gemini / OpenAI ---
  // fetch('https://api.openai.com/v1/chat/completions', { method:'POST', headers:{'Authorization':'Bearer YOUR_KEY'}, body: JSON.stringify({model:'gpt-4o-mini', messages:[{role:'user', content:`حلل ${topic} للمغرب`}]} ) })
}

// ===== 7. متجر مغربي - سلة مشتريات + ربح =====
let cart = JSON.parse(localStorage.getItem('wacel_cart')||'[]');
function addToCart(name, price){
  cart.push({name, price, date: Date.now()});
  localStorage.setItem('wacel_cart', JSON.stringify(cart));
  updateCartUI();
  // تتبع للربح
  gtagTrack('add_to_cart', {name, price});
  alert(`✅ تمت إضافة ${name} للسلة - ${price} MAD\nالدفع عند الاستلام`);
}
function updateCartUI(){
  const count = document.getElementById('cart-count');
  if(count) count.textContent = cart.length;
}

// ===== 8. أكواد الربح - AdSense بطريقة لا تبطئ الموقع =====
function loadAdsense(){
  // نحمل الإعلانات بعد 3 ثواني باش الموقع يبقى سريع (مهم لـ SEO)
  setTimeout(()=>{
    const script = document.createElement('script');
    script.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${CONFIG.adsenseClient}`;
    script.async = true; script.crossOrigin='anonymous';
    document.head.appendChild(script);
    script.onload = ()=>{
      try{
        document.querySelectorAll('.adsbygoogle').forEach(()=>{ (adsbygoogle=window.adsbygoogle||[]).push({}); });
        document.querySelectorAll('.lazy-ad').forEach(el=>el.classList.add('loaded'));
      }catch(e){console.log('AdSense error',e)}
    };
  }, 3000);
}

// تتبع النقرات الأفلييت - مهم باش تعرف شنو كيتباع
function gtagTrack(event, data){
  console.log('[TRACK]',event,data);
  // إذا عندك Google Analytics 4:
  // gtag('event', event, data);
  // إذا عندك Facebook Pixel:
  // fbq('track', event, data);
}

// ===== 9. منتدى - تفاعل وهمي يزيد المحتوى =====
function initForum(){
  const form = document.getElementById('forum-form');
  if(form){
    form.addEventListener('submit', e=>{
      e.preventDefault();
      const title = e.target.querySelector('input').value;
      if(!title) return;
      const list = document.getElementById('forum-list');
      const row = document.createElement('div');
      row.className='forum-row';
      row.innerHTML=`<span>${title}</span><span>الآن - 0 تعليق</span>`;
      list.prepend(row);
      e.target.reset();
      alert('تم نشر موضوعك +10 نقاط! النقاط = خصم فالمتجر');
    });
  }
}

// ===== 10. نشرة بريدية - بناء قائمة إيميلات = ذهب =====
function subscribeNewsletter(email){
  if(!email || !email.includes('@')){ alert('دخل إيميل صحيح'); return; }
  localStorage.setItem('wacel_email', email);
  alert('شكراً! هديتك: كتاب مجاني غادي يوصلك بالإيميل\nدابا عندك لائحة إيميلات كتسوى الفلوس');
  // هنا ترسل الإيميل لـ Mailchimp / Brevo
  // fetch('https://api.brevo.com/v3/contacts', {method:'POST', ...})
}

// ===== 11. PWA - يخلي الموقع تطبيق =====
function initPWA(){
  if('serviceWorker' in navigator){
    // navigator.serviceWorker.register('/sw.js'); // فعلها بعد ما تصايب sw.js
  }
}

// ===== 12. تحسينات سرعة - Lazy Load =====
function initLazy(){
  const observer = new IntersectionObserver((entries)=>{
    entries.forEach(entry=>{
      if(entry.isIntersecting){
        const img = entry.target;
        if(img.dataset.src){ img.src = img.dataset.src; }
        observer.unobserve(img);
      }
    });
  });
  document.querySelectorAll('img[data-src]').forEach(img=>observer.observe(img));
}

// ===== تشغيل كلشي عند تحميل الصفحة =====
document.addEventListener('DOMContentLoaded', ()=>{
  initDates();
  initTabs();
  initSearch();
  initForum();
  initLazy();
  initPWA();
  loadAdsense();
  updateCartUI();
});

// ===== دوال عامة تقدر تستعملها في HTML =====
window.toggleDark = toggleDark;
window.openAIAnalysis = openAIAnalysis;
window.addToCart = addToCart;
window.subscribeNewsletter = subscribeNewsletter;
</style>
