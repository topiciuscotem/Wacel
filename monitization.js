/* Wacel.MA - ads-monetization.js - أكواد الربح المتقدمة */
 // ضع هذا الملف بعد main.js

// ===== 1. إعدادات الربح - بدلها بمعلوماتك =====
const MONETIZATION = {
  adsense: 'ca-pub-XXXXXXXXXXXX', // AdSense ID
  jumiaAffiliateId: 'wacel-xxx', // Jumia KOL ID
  amazonTag: 'wacel-20',
  buyMeACoffee: 'https://www.buymeacoffee.com/wacel',
  mopayLink: 'https://mopay.ma/wacel' // للدفع المغربي
};

// ===== 2. إعلانات تظهر بعد تفاعل الزائر - ممنوع تظهر مباشرة (سياسة AdSense) =====
let adShown = false;
function showStickyAdOnScroll(){
  if(adShown) return;
  if(window.scrollY > 800){
    const ad = document.getElementById('sticky-ad-container');
    if(ad){ ad.style.display='block'; adShown=true; }
  }
}
window.addEventListener('scroll', showStickyAdOnScroll);

// ===== 3. تتبع عمق القراءة - كيزيد سعر النقرة =====
let maxScroll = 0;
window.addEventListener('scroll', ()=>{
  const scrolled = Math.round((window.scrollY / (document.body.scrollHeight - window.innerHeight))*100);
  if(scrolled > maxScroll){
    maxScroll = scrolled;
    if(maxScroll % 25 === 0){ // 25%, 50%, 75%, 100%
      console.log(`قراءة ${maxScroll}%`);
      // gtag('event','scroll_depth',{percent:maxScroll});
    }
  }
});

// ===== 4. منع AdBlock - رسالة لطيفة =====
function detectAdBlock(){
  const test = document.createElement('div');
  test.innerHTML='&nbsp;'; test.className='adsbox';
  document.body.appendChild(test);
  setTimeout(()=>{
    if(test.offsetHeight===0){
      const msg = document.getElementById('adblock-msg');
      if(msg) msg.style.display='block';
    }
    document.body.removeChild(test);
  },100);
}
detectAdBlock();

// ===== 5. روابط أفلييت مغربية - تربح تلقائياً =====
function convertToAffiliateLinks(){
  document.querySelectorAll('a[data-jumia]').forEach(a=>{
    const q = a.dataset.jumia;
    a.href = `https://www.jumia.ma/catalog/?q=${encodeURIComponent(q)}&tag=${MONETIZATION.jumiaAffiliateId}`;
    a.target='_blank'; a.rel='nofollow sponsored';
    a.addEventListener('click', ()=>{ console.log('Jumia click',q); });
  });
}
document.addEventListener('DOMContentLoaded', convertToAffiliateLinks);

// ===== 6. نظام نقاط - كيخلي الناس ترجع = ترافيك مجاني =====
function addPoints(action){
  let points = parseInt(localStorage.getItem('wacel_points')||'0');
  const map = {read:5, comment:10, share:15, purchase:50, daily:20};
  points += map[action]||5;
  localStorage.setItem('wacel_points', points);
  const el = document.getElementById('points-badge');
  if(el) el.textContent = points + ' نقطة';
  if(points >= 100){
    alert('🎉 عندك 100 نقطة = خصم 20 MAD فالمتجر المغربي!');
  }
  return points;
}

// تمنح نقاط يومية
if(!localStorage.getItem('wacel_daily_'+new Date().toDateString())){
  addPoints('daily');
  localStorage.setItem('wacel_daily_'+new Date().toDateString(), '1');
}

// ===== 7. إعلان بيني (Interstitial) للمونديال - CPM عالي بزاف =====
function showWorldCupInterstitial(){
  // يظهر مرة واحدة فالنهار فقط
  if(localStorage.getItem('wc_ad_'+new Date().toDateString())) return;
  setTimeout(()=>{
    const modal = document.createElement('div');
    modal.style.cssText='position:fixed;inset:0;background:rgba(0,0,0,0.85);z-index:9999;display:flex;align-items:center;justify-content:center;padding:20px';
    modal.innerHTML=`
      <div style="background:#fff;border-radius:20px;padding:25px;max-width:360px;text-align:center">
        <h3 style="font-weight:900">🇲🇦 عرض مونديال 2030</h3>
        <p style="font-size:13px;margin:10px 0">اشتر تيشيرت المنتخب المغربي الأصلي - توصيل مجاني</p>
        <div style="background:#f1f5f9;height:150px;border-radius:12px;display:flex;align-items:center;justify-content:center;margin:10px 0">مساحة إعلان 300x250 - CPM 5$</div>
        <button onclick="this.closest('div').parentElement.remove()" style="background:#000;color:#fff;border:none;padding:10px 20px;border-radius:999px;width:100%">متابعة للموقع</button>
        <p style="font-size:10px;color:#888;margin-top:8px">إعلان - يدعم استمرار Wacel مجاناً</p>
      </div>`;
    document.body.appendChild(modal);
    localStorage.setItem('wc_ad_'+new Date().toDateString(),'1');
  }, 15000); // بعد 15 ثانية
}
// showWorldCupInterstitial(); // فعلها إلا بغيتي

console.log('Monetization JS Loaded - 7 مصادر دخل جاهزة');
