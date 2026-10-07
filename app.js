/* ============================================================
   Brainy Basket — app.js
   Single-file web app (vanilla JS).

   Core system (unchanged concept):
     ESP32 → Inventory → AI → Recipes → Shopping

   Additive layer:
     Food Consumed → Person Profile → Nutrition Calculation
       → Daily Intake → AI Nutrition Insight

   Nutrition values are APPROXIMATE ESTIMATES — not a medical tool.
   ============================================================ */

'use strict';

const LS_KEY = 'brainy_basket_v2';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
let state = {
  version: 2,
  inventory: [],
  recipes: [],
  shopping: [],
  iot: { connected: true, device: 'ESP32-Shelf-01', lastEvent: 'No events yet' },
  nutrition: { profiles: [], logs: [], activeProfileId: null },
};

let view = 'dashboard';
let nutritionTab = 'today';
let summaryRange = 'daily';
let selectedDate = todayStr();
let editingProfileId = null;
let sidebarCollapsed = false;

// ---------------------------------------------------------------------------
// Toast notifications
// ---------------------------------------------------------------------------
function showToast(msg, type = 'success') {
  const c = document.getElementById('toast-container');
  if (!c) return;
  const t = document.createElement('div');
  t.className = 'toast ' + type;
  const icons = { success: '✅', error: '❌', warn: '⚠️' };
  t.innerHTML = '<span>' + (icons[type] || '✅') + '</span><span>' + msg + '</span>';
  c.appendChild(t);
  setTimeout(() => { t.style.opacity = '0'; t.style.transform = 'translateX(40px)'; t.style.transition = 'all 0.3s'; setTimeout(() => t.remove(), 320); }, 2800);
}

function toggleSidebar() {
  sidebarCollapsed = !sidebarCollapsed;
  const sb = document.getElementById('sidebar');
  const mw = document.getElementById('main-wrapper');
  if (sb) sb.classList.toggle('collapsed', sidebarCollapsed);
  if (mw) mw.style.marginLeft = sidebarCollapsed ? '72px' : '';
  if (mw) mw.style.width = sidebarCollapsed ? 'calc(100% - 72px)' : '';
}

function handleGlobalSearch(val) {
  let el = document.getElementById('search-results');
  if (!val.trim()) { if (el) el.classList.remove('open'); return; }
  const q = val.trim().toLowerCase();
  const hits = state.inventory.filter(i => i.name.toLowerCase().includes(q) || i.category.toLowerCase().includes(q));
  if (!el) {
    el = document.createElement('div');
    el.id = 'search-results';
    document.body.appendChild(el);
  }
  if (!hits.length) {
    el.innerHTML = '<div style="padding:16px;text-align:center;color:var(--muted);font-size:13px;">No commodities found</div>';
  } else {
    el.innerHTML = hits.map(i => {
      const status = i.qty <= 0 ? '🔴' : i.qty <= i.threshold ? '🟠' : '🟢';
      return '<div class="search-result-item" onclick="view=\'pantry\';render();document.getElementById(\'search-results\').classList.remove(\'open\');document.getElementById(\'global-search\').value=\'\';">' +
        '<span class="search-result-icon">' + status + '</span>' +
        '<div><div class="search-result-name">' + esc(i.name) + '</div>' +
        '<div class="search-result-meta">' + esc(i.category) + ' · ' + i.qty.toFixed(1) + ' ' + i.unit + '</div></div></div>';
    }).join('');
  }
  el.classList.add('open');
}

document.addEventListener('click', e => {
  const sr = document.getElementById('search-results');
  const si = document.getElementById('global-search');
  if (sr && si && !sr.contains(e.target) && e.target !== si) sr.classList.remove('open');
});

// ---------------------------------------------------------------------------
// Persistence
// ---------------------------------------------------------------------------
function save() { localStorage.setItem(LS_KEY, JSON.stringify(state)); }

function load() {
  try {
    const raw = localStorage.getItem(LS_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      state = Object.assign(state, parsed);
      if (!state.nutrition) state.nutrition = { profiles: [], logs: [], activeProfileId: null };
      if (!Array.isArray(state.nutrition.profiles)) state.nutrition.profiles = [];
      if (!Array.isArray(state.nutrition.logs)) state.nutrition.logs = [];
      if (!('activeProfileId' in state.nutrition)) state.nutrition.activeProfileId = null;
    }
  } catch (e) { console.warn('load failed', e); }
}

function uid(prefix) { return prefix + '_' + Date.now().toString(36) + Math.random().toString(36).slice(2, 7); }

// ---------------------------------------------------------------------------
// Seed data — REMOVED (manual configuration required)
// See /api/demo/load-sample-commodities for demo data
// ---------------------------------------------------------------------------
// The Brainy Basket system starts EMPTY by design.
// Users must manually register commodities and map hardware.
// There is NO automatic commodity creation from sensor data.
// 
// PRINCIPLE:
// 1. Admin manually registers commodities (name, category, minimum, unit, location)
// 2. Admin manually maps hardware (ESP32, RFID, RF tags)
// 3. ESP32 sends sensor data for already-registered commodities
// 4. Backend validates and updates live state
// 5. Dashboard reflects the database state
// ---------------------------------------------------------------------------

// No seed data — system starts empty by design.
// All commodities must be manually registered by the admin.

// ---------------------------------------------------------------------------
// Nutrition DB (per-100g approximate values, IFCT-style estimates)
// ---------------------------------------------------------------------------
const NUTRITION_DB = {
  'toor dal': { cal: 343, protein: 22.3, carbs: 57.6, fat: 1.7, fiber: 1.5 },
  'moong dal': { cal: 347, protein: 24.0, carbs: 56.8, fat: 1.2, fiber: 4.1 },
  'chickpeas': { cal: 364, protein: 19.0, carbs: 61.0, fat: 6.0, fiber: 17.0 },
  'rice': { cal: 345, protein: 6.8, carbs: 78.2, fat: 0.7, fiber: 0.3 },
  'ragi': { cal: 328, protein: 7.2, carbs: 66.8, fat: 1.9, fiber: 11.2 },
  'wheat flour': { cal: 341, protein: 12.1, carbs: 69.4, fat: 1.7, fiber: 11.0 },
  'milk': { cal: 65, protein: 3.3, carbs: 5.0, fat: 4.0, fiber: 0 },
  'curd': { cal: 98, protein: 3.5, carbs: 4.7, fat: 4.3, fiber: 0 },
  'tomato': { cal: 20, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2 },
  'onion': { cal: 44, protein: 1.1, carbs: 10.3, fat: 0.1, fiber: 1.7 },
  'potato': { cal: 97, protein: 2.0, carbs: 22.0, fat: 0.1, fiber: 2.1 },
  'ghee': { cal: 900, protein: 0, carbs: 0, fat: 100, fiber: 0 },
  'cooking oil': { cal: 884, protein: 0, carbs: 0, fat: 100, fiber: 0 },
  'egg': { cal: 155, protein: 13.0, carbs: 1.1, fat: 11.0, fiber: 0 },
  'paneer': { cal: 265, protein: 18.0, carbs: 1.2, fat: 21.0, fiber: 0 },
  'bread': { cal: 265, protein: 9.0, carbs: 49.0, fat: 3.2, fiber: 2.7 },
};

const SERVING_GRAMS = {
  'toor dal': 120, 'moong dal': 120, 'chickpeas': 150, 'rice': 150,
  'ragi': 100, 'wheat flour': 100, 'milk': 240, 'curd': 150,
  'tomato': 100, 'onion': 100, 'potato': 150, 'ghee': 10,
  'cooking oil': 10, 'egg': 50, 'paneer': 80, 'bread': 60,
};

function normKey(name) { return (name || '').trim().toLowerCase(); }

function lookupFood(name) {
  const key = normKey(name);
  if (NUTRITION_DB[key]) return { per100g: NUTRITION_DB[key], gramsPerServing: SERVING_GRAMS[key] || 100 };
  for (const k of Object.keys(NUTRITION_DB)) {
    if (key.includes(k) || k.includes(key)) {
      return { per100g: NUTRITION_DB[k], gramsPerServing: SERVING_GRAMS[k] || 100 };
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Nutrition calculation — APPROXIMATE estimates
// ---------------------------------------------------------------------------
function foodNutrition(name, qtyServings) {
  const f = lookupFood(name);
  if (!f) return { cal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, known: false };
  const grams = f.gramsPerServing * qtyServings;
  const p = f.per100g;
  return {
    cal: Math.round(p.cal * grams / 100),
    protein: +(p.protein * grams / 100).toFixed(1),
    carbs: +(p.carbs * grams / 100).toFixed(1),
    fat: +(p.fat * grams / 100).toFixed(1),
    fiber: +(p.fiber * grams / 100).toFixed(1),
    known: true,
  };
}

function recipeNutritionPerServing(recipe) {
  const tot = { cal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 };
  for (const ing of recipe.ingredients) {
    const f = lookupFood(ing.name);
    if (!f) continue;
    const grams = f.gramsPerServing * (ing.qty || 1);
    const p = f.per100g;
    tot.cal += p.cal * grams / 100;
    tot.protein += p.protein * grams / 100;
    tot.carbs += p.carbs * grams / 100;
    tot.fat += p.fat * grams / 100;
    tot.fiber += p.fiber * grams / 100;
  }
  const servings = recipe.servings || 2;
  return {
    cal: Math.round(tot.cal / servings),
    protein: +(tot.protein / servings).toFixed(1),
    carbs: +(tot.carbs / servings).toFixed(1),
    fat: +(tot.fat / servings).toFixed(1),
    fiber: +(tot.fiber / servings).toFixed(1),
  };
}

// ---------------------------------------------------------------------------
// Person profile targets — Mifflin-St Jeor (per person, never global)
// ---------------------------------------------------------------------------
const ACTIVITY_FACTORS = { sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, very_active: 1.9 };

function calcTargets(p) {
  const s = p.gender === 'male' ? 5 : (p.gender === 'female' ? -161 : -78);
  const bmr = 10 * p.weightKg + 6.25 * p.heightCm - 5 * p.age + s;
  const factor = ACTIVITY_FACTORS[p.activityLevel] || 1.55;
  let cal = bmr * factor;
  if (p.goal === 'lose') cal -= 400;
  if (p.goal === 'gain') cal += 300;
  cal = Math.max(1200, Math.round(cal / 10) * 10);
  return {
    calories: cal,
    protein: Math.round(p.weightKg * 1.2),
    carbs: Math.round(cal * 0.5 / 4),
    fat: Math.round(cal * 0.25 / 9),
    fiber: p.age >= 12 ? 30 : 20,
  };
}

function activeProfile() {
  return state.nutrition.profiles.find(p => p.id === state.nutrition.activeProfileId) || state.nutrition.profiles[0] || null;
}

// ---------------------------------------------------------------------------
// Summaries
// ---------------------------------------------------------------------------
function todayStr() { const d = new Date(); return d.toISOString().slice(0, 10); }
function dateStr(d) { return d.toISOString().slice(0, 10); }

function logsFor(profileId, ds) {
  return state.nutrition.logs.filter(l => l.profileId === profileId && l.date === ds);
}

function dayTotals(profileId, ds) {
  const t = { cal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 };
  for (const l of logsFor(profileId, ds)) {
    const n = l.nutrition || {};
    t.cal += n.cal || 0; t.protein += n.protein || 0; t.carbs += n.carbs || 0;
    t.fat += n.fat || 0; t.fiber += n.fiber || 0;
  }
  return {
    cal: Math.round(t.cal), protein: Math.round(t.protein),
    carbs: Math.round(t.carbs), fat: Math.round(t.fat), fiber: Math.round(t.fiber),
  };
}

function addDays(ds, n) {
  const d = new Date(ds + 'T00:00:00');
  d.setDate(d.getDate() + n);
  return dateStr(d);
}

// ---------------------------------------------------------------------------
// AI Nutrition Insights — rule-based, pantry-aware (no medical claims)
// ---------------------------------------------------------------------------
function generateInsights(profileId) {
  const profile = state.nutrition.profiles.find(p => p.id === profileId);
  if (!profile) return [];
  const t = profile.targets;
  const today = dayTotals(profileId, todayStr());
  const out = [];

  if (today.protein < t.protein * 0.8) {
    const proteinFoods = state.inventory
      .filter(i => { const f = lookupFood(i.name); return f && f.per100g.protein >= 7; })
      .slice(0, 3).map(i => i.name);
    const proteinRecipes = state.recipes
      .filter(r => r.ingredients.some(i => { const f = lookupFood(i.name); return f && f.per100g.protein >= 7; }))
      .slice(0, 2).map(r => r.name);
    out.push({
      icon: '💪', title: 'Protein below target',
      text: "Today's protein intake is lower than your selected target." +
        (proteinFoods.length ? ' Consider a meal with ' + proteinFoods.join(', ') + ' — already in your pantry.' : '') +
        (proteinRecipes.length ? ' Try: ' + proteinRecipes.join(' or ') + '.' : ''),
    });
  }
  if (today.cal < t.calories * 0.6) {
    out.push({
      icon: '📉', title: 'Calories well below target',
      text: "You've recorded only " + today.cal + ' of ' + t.calories + ' kcal. Consider adding a balanced meal from your pantry staples.',
    });
  }
  if (today.cal > t.calories * 1.1) {
    out.push({
      icon: '⚠️', title: 'Calories above target',
      text: "Intake is above today's target. A lighter dinner from available veggies may help balance the day.",
    });
  }
  if (today.fiber < t.fiber * 0.7) {
    const fiberFoods = state.inventory
      .filter(i => { const f = lookupFood(i.name); return f && f.per100g.fiber >= 3; })
      .slice(0, 3).map(i => i.name);
    out.push({
      icon: '🌾', title: 'Fiber below target',
      text: 'Fiber intake is low. ' + (fiberFoods.length ? 'Pantry options: ' + fiberFoods.join(', ') + '.' : 'Consider whole grains and vegetables.'),
    });
  }
  if (today.carbs > t.carbs * 1.15) {
    out.push({
      icon: '🍞', title: 'Carbohydrates above target',
      text: 'Carb intake is above your target today. Try balancing with protein-rich options from your pantry.',
    });
  }
  if (out.length === 0) {
    out.push({ icon: '✅', title: 'On track', text: "Today's intake is within your selected targets. Keep it up!" });
  }
  return out;
}

// ---------------------------------------------------------------------------
// Recipe matching (AI recipe engine — existing core)
// ---------------------------------------------------------------------------
function recipeMatch(recipe) {
  const pantryNames = state.inventory.map(i => normKey(i.name));
  let have = 0, missing = [];
  for (const ing of recipe.ingredients) {
    const k = normKey(ing.name);
    if (pantryNames.some(pn => pn.includes(k) || k.includes(pn))) have++;
    else missing.push(ing.name);
  }
  const pct = Math.round(have / recipe.ingredients.length * 100);
  return { pct, missing };
}

// ---------------------------------------------------------------------------
// Core actions
// ---------------------------------------------------------------------------
function addInventoryItem(item) {
  state.inventory.push(Object.assign({ id: uid('i') }, item));
  save(); render();
  showToast('Commodity "' + item.name + '" registered successfully');
}
function deleteInventoryItem(id) {
  const it = state.inventory.find(i => i.id === id);
  state.inventory = state.inventory.filter(i => i.id !== id);
  save(); render();
  if (it) showToast('"' + it.name + '" removed', 'warn');
}
function adjustInventory(id, delta) {
  const it = state.inventory.find(i => i.id === id);
  if (it) {
    it.qty = Math.max(0, +(it.qty + delta).toFixed(2));
    state.iot.lastEvent = (delta > 0 ? 'Restocked ' : 'Consumed ') + it.name + (delta > 0 ? ' +' : ' ') + delta + it.unit;
    save(); render();
  }
}
function generateShoppingList() {
  for (const it of state.inventory) {
    if (it.qty <= it.threshold && !state.shopping.some(s => s.name === it.name && !s.done)) {
      state.shopping.push({ id: uid('s'), name: it.name, qty: Math.max(1, it.threshold * 2), unit: it.unit, priority: 'Medium', done: false });
    }
  }
  save(); render();
}
function addShoppingItem(item) {
  state.shopping.push(Object.assign({ id: uid('s'), done: false }, item));
  save(); render();
}
function toggleShopping(id) {
  const it = state.shopping.find(s => s.id === id);
  if (it) { it.done = !it.done; save(); render(); }
}
function deleteShopping(id) {
  state.shopping = state.shopping.filter(s => s.id !== id);
  save(); render();
}
function clearCompletedShopping() {
  state.shopping = state.shopping.filter(s => !s.done);
  save(); render();
}
function simulateIoT(type) {
  switch (type) {
    case 'disconnect':
      state.iot.connected = false;
      state.iot.lastEvent = 'Devices offline';
      break;
    case 'reconnect':
      state.iot.connected = true;
      state.iot.lastEvent = 'Devices back online';
      break;
    case 'sync':
      state.iot.connected = true;
      state.iot.lastEvent = 'Telemetry synced with backend';
      break;
  }
  save(); render();
}

function sendTestSignal() {
  const sel = document.getElementById('demo-commodity');
  const valEl = document.getElementById('demo-weight');
  if (!sel || !valEl) return;
  const id = sel.value;
  const val = parseFloat(valEl.value);
  if (!id) { alert('Select a registered commodity first.'); return; }
  if (isNaN(val) || val < 0) { alert('Enter a valid weight value.'); return; }
  const it = state.inventory.find(i => i.id === id);
  if (!it) { alert('Commodity not found.'); return; }
  if (!it.deviceId) { alert('This commodity has no ESP32 device mapped.\nPlease map a device to it first (Edit the commodity).'); return; }
  it.qty = val;
  state.iot.lastEvent = '[TEST SIGNAL] ' + it.deviceId + ' → ' + it.name + ' = ' + val + ' ' + it.unit;
  save(); render();
}

// ---------------------------------------------------------------------------
// Nutrition actions
// ---------------------------------------------------------------------------
function setActiveProfile(id) {
  state.nutrition.activeProfileId = id;
  save(); render();
}

function saveProfile(form) {
  const p = {
    id: editingProfileId || uid('p'),
    name: form.name.trim() || 'Person',
    age: +form.age || 30,
    gender: form.gender,
    heightCm: +form.heightCm || 170,
    weightKg: +form.weightKg || 65,
    activityLevel: form.activityLevel,
    goal: form.goal,
  };
  p.targets = calcTargets(p);
  const idx = state.nutrition.profiles.findIndex(x => x.id === p.id);
  if (idx >= 0) state.nutrition.profiles[idx] = p;
  else state.nutrition.profiles.push(p);
  state.nutrition.activeProfileId = p.id;
  editingProfileId = null;
  save(); closeModal(); render();
}

function deleteProfile(id) {
  state.nutrition.profiles = state.nutrition.profiles.filter(p => p.id !== id);
  state.nutrition.logs = state.nutrition.logs.filter(l => l.profileId !== id);
  if (state.nutrition.activeProfileId === id) state.nutrition.activeProfileId = state.nutrition.profiles[0]?.id || null;
  save(); render();
}

function addMealLog(form) {
  let nutrition, foodName = form.foodName.trim();
  let source = 'pantry';
  const recipe = state.recipes.find(r => r.id === form.foodId);
  if (recipe) {
    foodName = recipe.name;
    nutrition = recipeNutritionPerServing(recipe);
    source = 'recipe';
  } else {
    nutrition = foodNutrition(foodName, form.quantity);
    const inPantry = state.inventory.some(i => normKey(i.name).includes(normKey(foodName)));
    source = inPantry ? 'pantry' : 'custom';
  }
  state.nutrition.logs.push({
    id: uid('l'),
    profileId: form.profileId || state.nutrition.activeProfileId,
    meal: form.meal,
    foodId: form.foodId || null,
    foodName,
    quantity: form.quantity,
    unit: 'serving',
    date: form.date || todayStr(),
    nutrition,
  });
  save(); closeModal(); render();
}

function deleteMealLog(id) {
  state.nutrition.logs = state.nutrition.logs.filter(l => l.id !== id);
  save(); render();
}

// ---------------------------------------------------------------------------
// Rendering helpers
// ---------------------------------------------------------------------------
function esc(s) {
  return String(s == null ? '' : s)
    .replace(/&/g, '&').replace(/</g, '<').replace(/>/g, '>')
    .replace(/"/g, '"');
}
function pct(a, b) { return b > 0 ? Math.min(100, Math.round(a / b * 100)) : 0; }
function barClass(a, b) { return a > b * 1.1 ? 'over' : (a > b ? 'warn' : ''); }

function render() {
  renderNav();
  const v = document.getElementById('view');
  switch (view) {
    case 'dashboard': v.innerHTML = renderDashboard(); break;
    case 'pantry': v.innerHTML = renderPantry(); break;
    case 'recipes': v.innerHTML = renderRecipes(); break;
    case 'shopping': v.innerHTML = renderShopping(); break;
    case 'iot': v.innerHTML = renderIoT(); break;
    case 'nutrition': v.innerHTML = renderNutrition(); break;
  }
  if (view === 'nutrition') { drawCharts(); wireNutritionEvents(); }
  // Sync topbar
  const labels = { dashboard: 'Dashboard', pantry: 'Pantry Inventory', recipes: 'AI Recipes', shopping: 'Shopping List', iot: 'IoT Monitor', nutrition: 'My Nutrition' };
  const bc = document.getElementById('topbar-breadcrumb');
  if (bc) bc.textContent = labels[view] || 'Brainy Basket';
  // Alert badge
  const alertCount = state.inventory.filter(i => i.qty <= i.threshold).length;
  const badge = document.getElementById('alert-count-badge');
  if (badge) badge.textContent = alertCount;
  // IoT pill
  const pill = document.getElementById('sidebar-iot-pill');
  if (pill) {
    const dot = pill.querySelector('.iot-dot');
    const lbl = pill.querySelector('.iot-label');
    if (dot) dot.style.background = state.iot.connected ? 'var(--accent)' : 'var(--danger)';
    if (lbl) lbl.textContent = state.iot.connected ? 'IoT Connected' : 'IoT Offline';
    if (lbl) lbl.style.color = state.iot.connected ? 'var(--accent)' : 'var(--danger)';
  }
}

function renderNav() {
  const items = [
    ['dashboard', '🏠', 'Dashboard'],
    ['pantry', '🧂', 'Pantry'],
    ['recipes', '🍲', 'Recipes'],
    ['shopping', '🛒', 'Shopping'],
    ['iot', '📡', 'IoT'],
    ['nutrition', '🥗', 'My Nutrition'],
  ];
  const nav = document.getElementById('nav');
  nav.innerHTML = items.map(([id, icon, label]) =>
    '<button data-view="' + id + '" class="' + (view === id ? 'active' : '') + (id === 'nutrition' ? ' nutrition-link' : '') + '">' +
    '<span class="icon">' + icon + '</span><span class="label">' + label + '</span></button>'
  ).join('');
  nav.querySelectorAll('button[data-view]').forEach(b => {
    b.onclick = () => { view = b.dataset.view; render(); };
  });
}

// ---------------------------------------------------------------------------
// Views — CORE
// ---------------------------------------------------------------------------
function renderDashboard() {
  const total = state.inventory.length;
  const low = state.inventory.filter(i => i.qty <= i.threshold && i.qty > 0).length;
  const out = state.inventory.filter(i => i.qty <= 0).length;
  const ready = state.recipes.filter(r => recipeMatch(r).pct >= 90).length;
  const pending = state.shopping.filter(s => !s.done).length;
  const prof = activeProfile();

  if (total === 0) {
    return `
      <div class="page-head">
        <div>
          <div class="page-title">Welcome to Brainy Basket 🧠</div>
          <div class="page-sub">Your smart pantry starts empty — every commodity is manually registered by you</div>
        </div>
        <button class="btn btn-primary btn-lg" onclick="view='nutrition';render()">🥗 My Nutrition</button>
      </div>

      <div class="card" style="background:linear-gradient(135deg,#0b1120,#0f2318);border:1px solid rgba(0,200,150,0.2);">
        <div style="padding:40px 32px;text-align:center;">
          <div style="font-size:72px;margin-bottom:20px;">🧺</div>
          <h2 style="font-size:26px;font-weight:900;color:#fff;margin-bottom:10px;">Your Smart Pantry Awaits</h2>
          <p style="font-size:15px;color:#7a9aaa;max-width:480px;margin:0 auto 28px;line-height:1.7;">
            Brainy Basket is an <strong style="color:#00c896;">IoT-first intelligent system</strong>. Register your commodities, map your sensors, and get real-time AI insights.
          </p>
          <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">
            <button class="btn btn-primary btn-lg" onclick="view='pantry';render()">📦 Register First Item</button>
            <button class="btn btn-ghost btn-lg" style="color:#00c896;border-color:#00c896;" onclick="view='iot';render()">📡 IoT Monitor</button>
          </div>
        </div>
      </div>

      <div class="card mt-16">
        <div class="card-title">⚡ Quick Start Guide</div>
        <div class="onboard-steps">
          <div class="onboard-step">
            <div class="step-num">1</div>
            <div class="step-body"><strong>Register Commodities</strong><span>Go to Pantry → add each grocery item with name, category, minimum threshold, unit and storage location</span></div>
          </div>
          <div class="onboard-step">
            <div class="step-num warn">2</div>
            <div class="step-body"><strong>Map Hardware</strong><span>Assign ESP32 device IDs, RFID tags and RF tags to each commodity for automatic IoT tracking</span></div>
          </div>
          <div class="onboard-step">
            <div class="step-num blue">3</div>
            <div class="step-body"><strong>Enable Real-Time Monitoring</strong><span>Physical sensors measure quantities live. Only registered devices can update commodities</span></div>
          </div>
          <div class="onboard-step">
            <div class="step-num purple">4</div>
            <div class="step-body"><strong>Get AI Insights</strong><span>View recipe suggestions, shopping recommendations and personal nutrition insights</span></div>
          </div>
        </div>
      </div>
    `;
  }

  const attention = state.inventory.filter(i => i.qty <= i.threshold)
    .slice(0, 5)
    .map(i => `<div class="insight">
      <div class="insight-icon">${i.qty <= 0 ? '🔴' : '🟠'}</div>
      <div>
        <div class="insight-title">${esc(i.name)}</div>
        <div class="insight-text">${i.qty.toFixed(1)} ${i.unit} remaining · Minimum: ${i.threshold} ${i.unit}</div>
      </div>
      <div style="margin-left:auto;">${i.qty <= 0 ? '<span class="badge badge-red">Out of Stock</span>' : '<span class="badge badge-orange">Low Stock</span>'}</div>
    </div>`)
    .join('') || `<div class="empty-state" style="padding:24px;"><span class="big" style="font-size:36px;">✅</span><p style="margin:0;">All items are well stocked!</p></div>`;

  const suggestions = state.recipes
    .map(r => ({ r, m: recipeMatch(r) }))
    .sort((a, b) => b.m.pct - a.m.pct)
    .slice(0, 3)
    .map(({ r, m }) => `<div class="insight">
      <div class="insight-icon">${m.pct >= 90 ? '🟢' : m.pct >= 70 ? '🟠' : '🔴'}</div>
      <div style="flex:1">
        <div class="insight-title">${esc(r.name)}</div>
        <div class="insight-text"><strong>${m.pct}%</strong> ingredients available${m.missing.length ? ' · Missing: ' + esc(m.missing.join(', ')) : ' · ✨ Ready to cook!'}</div>
      </div>
      <span class="badge ${m.pct >= 90 ? 'badge-green' : m.pct >= 70 ? 'badge-orange' : 'badge-red'}">${m.pct}%</span>
    </div>`)
    .join('') || `<div class="empty-state" style="padding:24px;"><span class="big" style="font-size:36px;">🍳</span><p style="margin:0;">No recipes added yet</p></div>`;

  return `
    <div class="page-head">
      <div>
        <div class="page-title">Dashboard</div>
        <div class="page-sub">Smart Pantry Intelligence · IoT Monitoring + AI Recommendations + Nutrition Insights</div>
      </div>
      <button class="btn btn-primary" onclick="view='nutrition';render()">🥗 My Nutrition</button>
    </div>

    <div class="grid grid-4">
      <div class="stat green">
        <span class="stat-icon">📦</span>
        <div class="stat-label">Total Items</div>
        <div class="stat-value">${total}</div>
        <div class="stat-hint">Commodities registered</div>
      </div>
      <div class="stat orange">
        <span class="stat-icon">⚠️</span>
        <div class="stat-label">Low Stock</div>
        <div class="stat-value">${low}</div>
        <div class="stat-hint">Below threshold</div>
      </div>
      <div class="stat blue">
        <span class="stat-icon">✨</span>
        <div class="stat-label">Recipes Ready</div>
        <div class="stat-value">${ready}</div>
        <div class="stat-hint">Can cook now</div>
      </div>
      <div class="stat purple">
        <span class="stat-icon">🛍️</span>
        <div class="stat-label">Shopping</div>
        <div class="stat-value">${pending}</div>
        <div class="stat-hint">Pending items</div>
      </div>
    </div>

    <div class="grid grid-2 mt-16">
      <div class="card">
        <div class="card-title">📡 IoT Sensor Status <span class="spacer"></span>
          <button class="btn btn-ghost btn-sm" onclick="view='iot';render()">Monitor →</button>
        </div>
        <div class="device-row">
          <div class="device-icon">${state.iot.connected ? '🟢' : '🔴'}</div>
          <div class="device-info">
            <div class="device-name">${esc(state.iot.device)}</div>
            <div class="device-meta">${state.iot.connected ? 'Online · Receiving telemetry' : 'Offline · No signal'}</div>
          </div>
          <span class="chip ${state.iot.connected ? 'ok' : 'offline'}">${state.iot.connected ? 'Connected' : 'Offline'}</span>
        </div>
        <div class="small muted mt-8" style="padding:0 4px;">📊 Last event: <strong>${esc(state.iot.lastEvent)}</strong></div>
      </div>

      <div class="card">
        <div class="card-title">🥗 Nutrition Profile <span class="spacer"></span>
          <button class="btn btn-ghost btn-sm" onclick="view='nutrition';render()">Open →</button>
        </div>
        ${prof
          ? `<div class="insight" style="margin:0">
              <div class="insight-icon">👤</div>
              <div>
                <div class="insight-title">${esc(prof.name)}</div>
                <div class="insight-text"><strong>${esc(goalLabel(prof.goal))}</strong> · Target: ${prof.targets.calories} kcal/day · <em>Approximate values</em></div>
              </div>
            </div>`
          : `<div class="empty-state" style="padding:20px;">
              <span class="big" style="font-size:32px;">👤</span>
              <p style="margin:0 0 12px;">No profile yet</p>
              <button class="btn btn-primary btn-sm" onclick="view='nutrition';render()">Set up profile</button>
            </div>`
        }
      </div>
    </div>

    <div class="card mt-16">
      <div class="card-title">⚠️ Needs Attention <span class="spacer"></span>
        <button class="btn btn-ghost btn-sm" onclick="view='pantry';render()">View Pantry →</button>
      </div>
      ${attention}
    </div>

    <div class="card">
      <div class="card-title">🍲 AI Recipe Suggestions <span class="spacer"></span>
        <button class="btn btn-ghost btn-sm" onclick="view='recipes';render()">See All →</button>
      </div>
      ${suggestions}
    </div>
  `;
}
function renderPantry() {
  if (state.inventory.length === 0) {
    return `
      <div class="page-head">
        <div>
          <div class="page-title">Pantry Inventory</div>
          <div class="page-sub">No commodities registered yet — every item must be manually added</div>
        </div>
      </div>
      <div class="card">
        <div class="empty-state">
          <span class="big">📭</span>
          <h3>Your Pantry is Empty</h3>
          <p>Register your dry goods and bulk grocery items. Each item will be monitored in real-time by your IoT sensors.</p>
          <button class="btn btn-primary btn-lg" onclick="openAddCommodityModal()">+ Register First Item</button>
        </div>
      </div>
      <div class="card">
        <div class="card-title">📋 How the System Works</div>
        <div class="onboard-steps">
          <div class="onboard-step"><div class="step-num">1</div><div class="step-body"><strong>Register Commodities</strong><span>Add each item with name, category, minimum threshold, unit, storage location and optional hardware IDs</span></div></div>
          <div class="onboard-step"><div class="step-num warn">2</div><div class="step-body"><strong>Map Hardware</strong><span>Connect ESP32 sensors, RFID tags and RF tags to your commodities for automatic tracking</span></div></div>
          <div class="onboard-step"><div class="step-num blue">3</div><div class="step-body"><strong>IoT Monitoring</strong><span>Physical sensors measure quantities in real-time. Only registered devices can update commodities</span></div></div>
          <div class="onboard-step"><div class="step-num purple">4</div><div class="step-body"><strong>Get Insights</strong><span>Receive AI-powered recipe suggestions, shopping recommendations and nutrition insights</span></div></div>
        </div>
      </div>
    `;
  }

  const cards = state.inventory.map(i => {
    const statusBadge = i.qty <= 0
      ? '<span class="badge badge-red">Out of Stock</span>'
      : i.qty <= i.threshold
        ? '<span class="badge badge-orange">Low Stock</span>'
        : '<span class="badge badge-green">In Stock</span>';
    const fillPct = Math.min(100, i.threshold > 0 ? Math.round(i.qty / (i.threshold * 3) * 100) : (i.qty > 0 ? 100 : 0));
    const barCls = i.qty <= 0 ? 'over' : i.qty <= i.threshold ? 'warn' : '';
    const hwTags = [i.deviceId && '<span class="hw-tag">📡 ' + esc(i.deviceId) + '</span>',
      i.rfidTagId && '<span class="hw-tag">🏷️ ' + esc(i.rfidTagId) + '</span>',
      i.rfTagId && '<span class="hw-tag">📻 ' + esc(i.rfTagId) + '</span>']
      .filter(Boolean).join('');
    return `<div class="pantry-card">
      <div class="pantry-card-top">
        <div>
          <div class="pantry-card-name">${esc(i.name)}</div>
          <div class="pantry-card-cat">${esc(i.category)}${i.storageLocation && i.storageLocation !== 'Unspecified' ? ' · ' + esc(i.storageLocation) : ''}</div>
        </div>
        ${statusBadge}
      </div>
      <div class="pantry-qty">${i.qty.toFixed(1)}<span class="pantry-qty-unit"> ${i.unit}</span></div>
      <div class="small muted mt-4">Min: ${i.threshold} ${i.unit}</div>
      <div class="pantry-card-bar">
        <div class="bar-track"><div class="bar-fill ${barCls}" style="width:${fillPct}%"></div></div>
      </div>
      <div class="pantry-card-actions">
        <button class="btn btn-soft btn-sm" onclick="adjustInventory('${i.id}',0.5)" title="Add 0.5">＋ 0.5</button>
        <button class="btn btn-soft btn-sm" onclick="adjustInventory('${i.id}',-0.5)" title="Remove 0.5">－ 0.5</button>
        <button class="btn btn-danger btn-sm" onclick="deleteInventoryItem('${i.id}')" title="Delete">✕</button>
      </div>
      ${hwTags ? '<div class="pantry-card-hw">' + hwTags + '</div>' : ''}
    </div>`;
  }).join('');

  return `
    <div class="page-head">
      <div>
        <div class="page-title">Pantry Inventory</div>
        <div class="page-sub">${state.inventory.length} item${state.inventory.length !== 1 ? 's' : ''} registered · Real-time IoT monitoring</div>
      </div>
      <div class="date-nav">
        <button class="btn btn-soft" onclick="generateShoppingList()">🛒 Generate Shopping List</button>
        <button class="btn btn-primary" onclick="openAddCommodityModal()">+ Add Item</button>
      </div>
    </div>
    <div class="pantry-grid">${cards}</div>
  `;
}

function renderRecipes() {
  if (state.recipes.length === 0) {
    return `
      <div class="page-head">
        <div><div class="page-title">AI Recipes</div>
        <div class="page-sub">Matched to your pantry commodities — recipes feed the nutrition calculator</div></div>
      </div>
      <div class="card">
        <div class="empty-state">
          <span class="big">🍳</span>
          <h3>No Recipes Yet</h3>
          <p>Recipes are matched against your registered pantry commodities. Add recipes to get AI-powered cooking suggestions.</p>
        </div>
      </div>`;
  }
  const cards = state.recipes.map(r => {
    const m = recipeMatch(r);
    const n = recipeNutritionPerServing(r);
    const badge = m.pct >= 90 ? 'badge-green' : m.pct >= 70 ? 'badge-orange' : 'badge-red';
    return `<div class="card" style="margin-top:0">
      <div class="card-title">${esc(r.name)} <span class="badge ${badge}">${m.pct}% ready</span></div>
      <div class="small muted mb-8">⏱ ${r.time_min} min · ${r.servings} servings · ${esc(r.cuisine)}</div>
      <div class="small muted mb-8"><b>Approx. nutrition per serving:</b></div>
      <div class="summary-grid">
        <div class="summary-cell"><div class="s-label">Calories</div><div class="s-value">${n.cal}</div><div class="s-avg">kcal</div></div>
        <div class="summary-cell"><div class="s-label">Protein</div><div class="s-value">${n.protein}</div><div class="s-avg">g</div></div>
        <div class="summary-cell"><div class="s-label">Carbs</div><div class="s-value">${n.carbs}</div><div class="s-avg">g</div></div>
        <div class="summary-cell"><div class="s-label">Fat</div><div class="s-value">${n.fat}</div><div class="s-avg">g</div></div>
        <div class="summary-cell"><div class="s-label">Fiber</div><div class="s-value">${n.fiber}</div><div class="s-avg">g</div></div>
      </div>
      ${m.missing.length ? '<div class="small muted mt-8">❌ Missing: ' + esc(m.missing.join(', ')) + '</div>' : '<div class="chip ok mt-8" style="display:inline-block">✅ All ingredients available</div>'}
      <div class="small muted mt-8">⚠️ Approximate nutritional values — estimates only.</div>
    </div>`;
  }).join('');
  return `
    <div class="page-head">
      <div><div class="page-title">AI Recipes</div>
      <div class="page-sub">Matched to your pantry commodities — recipes feed the nutrition calculator</div></div>
    </div>
    <div class="grid grid-2">${cards}</div>`;
}

function renderShopping() {
  const pending = state.shopping.filter(s => !s.done).length;
  const done = state.shopping.filter(s => s.done).length;
  const rows = state.shopping.map(s => {
    const priColor = s.priority === 'High' ? 'badge-red' : s.priority === 'Low' ? 'badge-gray' : 'badge-orange';
    return `<div class="insight" style="${s.done ? 'opacity:0.55;' : ''}">
      <input type="checkbox" ${s.done ? 'checked' : ''} onchange="toggleShopping('${s.id}')" style="width:18px;height:18px;cursor:pointer;accent-color:var(--accent);flex-shrink:0">
      <div style="flex:1">
        <div class="insight-title" style="${s.done ? 'text-decoration:line-through;' : ''}">${esc(s.name)}</div>
        <div class="insight-text">${s.qty} ${s.unit} · <span class="badge ${priColor}" style="font-size:10.5px;padding:1px 7px;">${s.priority}</span></div>
      </div>
      <button class="btn btn-danger btn-sm" onclick="deleteShopping('${s.id}')">Remove</button>
    </div>`;
  }).join('') || '<div class="empty-state" style="padding:32px;"><span class="big">🛒</span><h3>Shopping list is empty</h3><p>Generate from low-stock items or add manually.</p></div>';

  return `
    <div class="page-head">
      <div><div class="page-title">Smart Shopping List</div>
      <div class="page-sub">${pending} pending · ${done} purchased · auto-suggested from low stock</div></div>
      <div class="date-nav">
        <button class="btn btn-soft" onclick="clearCompletedShopping()">Clear purchased</button>
        <button class="btn btn-ghost" onclick="generateShoppingList()">♻️ Auto-generate</button>
        <button class="btn btn-primary" onclick="openAddShoppingModal()">+ Add item</button>
      </div>
    </div>
    <div class="card">${rows}</div>`;
}

function renderIoT() {
  const mappedItems = state.inventory.filter(i => i.deviceId);
  const deviceOptions = mappedItems.length
    ? mappedItems.map(i => '<option value="' + i.id + '">' + esc(i.name) + ' (' + esc(i.deviceId) + ')</option>').join('')
    : '<option value="">— No commodities with mapped devices —</option>';

  const deviceRows = mappedItems.map(i =>
    '<tr><td><strong>' + esc(i.name) + '</strong></td><td>' + esc(i.deviceId) + '</td>' +
    '<td>' + (i.rfidTagId ? esc(i.rfidTagId) : '<span class="muted">—</span>') + '</td>' +
    '<td>' + (i.rfTagId ? esc(i.rfTagId) : '<span class="muted">—</span>') + '</td>' +
    '<td>' + i.qty.toFixed(2) + ' ' + i.unit + '</td></tr>'
  ).join('');

  return `
    <div class="page-head">
      <div><div class="page-title">IoT Monitor</div>
      <div class="page-sub">ESP32 smart-shelf → Firebase → inventory · Only registered commodities receive sensor data</div></div>
    </div>

    <div class="card">
      <div class="card-title">📡 Connection status</div>
      <div class="chip-row">
        <span class="chip ${state.iot.connected ? 'ok' : 'low'}">${state.iot.connected ? '● Connected' : '● Offline'}</span>
        <span class="chip">${esc(state.iot.device)}</span>
      </div>
      <div class="small muted mt-8">Last event: ${esc(state.iot.lastEvent)}</div>
      <div class="chip-row mt-8">
        <button class="btn btn-soft" onclick="simulateIoT('sync')">Simulate sync</button>
        <button class="btn btn-danger" onclick="simulateIoT('disconnect')">Disconnect</button>
        <button class="btn btn-primary" onclick="simulateIoT('reconnect')">Reconnect</button>
      </div>
    </div>

    <div class="card">
      <div class="card-title">🎮 Demo — Send Test Sensor Signal</div>
      ${mappedItems.length === 0
        ? '<div style="text-align:center;padding:30px 20px;"><div style="font-size:40px;margin-bottom:10px;">📭</div><strong>No commodities available.</strong><br><span class="muted" style="font-size:13px;">Please add a commodity and map an ESP32 device to it first.</span><br><br><button class="btn btn-primary" onclick="view=\'pantry\';render()">→ Go to Pantry</button></div>'
        : `<div style="display:grid;gap:14px;">
            <label class="field"><span class="field-label">Registered Commodity (with mapped ESP32)</span>
              <select id="demo-commodity">${deviceOptions}</select></label>
            <label class="field"><span class="field-label">Test Weight Value</span>
              <div style="display:flex;gap:8px;align-items:center;">
                <input id="demo-weight" type="number" min="0" step="0.01" value="1.00" style="flex:1">
                <span class="muted">kg</span>
              </div></label>
            <div class="small muted">This simulates an ESP32 sensor signal. Only commodities with a mapped device ID can receive signals.</div>
            <button class="btn btn-primary" onclick="sendTestSignal()">📡 Send Test Signal</button>
          </div>`
      }
    </div>

    <div class="card">
      <div class="card-title">🔗 Registered Hardware Mappings</div>
      ${mappedItems.length === 0
        ? '<div class="empty-state"><div class="big">🔌</div>No hardware mapped yet.<br><span class="muted" style="font-size:13px;">Add a commodity and assign an ESP32 device ID to it.</span></div>'
        : '<div style="overflow-x:auto"><table><thead><tr><th>Commodity</th><th>ESP32 Device</th><th>RFID Tag</th><th>RF Tag</th><th>Current Qty</th></tr></thead><tbody>' + deviceRows + '</tbody></table></div>'
      }
    </div>

    <div class="card">
      <div class="card-title">Core flow</div>
      <div class="flow-diagram">
        <span class="flow-node">Admin registers commodity</span><span class="flow-sep">→</span>
        <span class="flow-node">Maps ESP32 / RFID</span><span class="flow-sep">→</span>
        <span class="flow-node">ESP32 sends signal</span><span class="flow-sep">→</span>
        <span class="flow-node">Backend validates</span><span class="flow-sep">→</span>
        <span class="flow-node">Firebase</span><span class="flow-sep">→</span>
        <span class="flow-node">Dashboard</span>
      </div>
    </div>
  `;
}

// ---------------------------------------------------------------------------
// Views — MY NUTRITION (additive layer)
// ---------------------------------------------------------------------------
function goalLabel(g) {
  return { maintain: 'Maintain Weight', gain: 'Gain Weight', lose: 'Lose Weight' }[g] || g;
}
function goalEmoji(g) { return { maintain: '⚖️', gain: '📈', lose: '📉' }[g] || '⚖️'; }

function renderNutrition() {
  const profiles = state.nutrition.profiles;
  const prof = activeProfile();

  const chips = profiles.map(p =>
    '<button class="profile-chip ' + (prof && prof.id === p.id ? 'active' : '') + '" onclick="setActiveProfile(\'' + p.id + '\')">' +
    '<span class="avatar">' + goalEmoji(p.goal) + '</span>' +
    '<span><span class="p-name">' + esc(p.name) + '</span><br><span class="p-goal">' + esc(goalLabel(p.goal)) + '</span></span></button>'
  ).join('');

  const tabs = [
    ['today', 'Today'], ['history', 'Meal History'],
    ['trends', 'Trends & Summaries'], ['insights', 'AI Insights'],
  ].map(([id, label]) =>
    '<button class="tab ' + (nutritionTab === id ? 'active' : '') + '" onclick="nutritionTab=\'' + id + '\';render()">' + label + '</button>'
  ).join('');

  let body = '';
  if (!prof) {
    body = '<div class="card"><div class="empty-state"><div class="big">👤</div>' +
      'Create your first person profile to start tracking nutrition.' +
      '<br><br><button class="btn btn-primary" onclick="openProfileModal()">+ Add person profile</button></div></div>';
  } else {
    switch (nutritionTab) {
      case 'today': body = renderNutritionToday(prof); break;
      case 'history': body = renderNutritionHistory(prof); break;
      case 'trends': body = renderNutritionTrends(prof); break;
      case 'insights': body = renderNutritionInsights(prof); break;
    }
  }

  return `
    <div class="page-head">
      <div><div class="page-title">🥗 My Nutrition</div>
      <div class="page-sub">Personal nutrition tracking — an additive layer on Brainy Basket</div></div>
      <div class="date-nav">
        ${prof ? '<button class="btn btn-ghost" onclick="openProfileModal(\'' + prof.id + '\')">✎ Edit ' + esc(prof.name) + '</button>' : ''}
        <button class="btn btn-primary" onclick="openProfileModal()">+ Add profile</button>
      </div>
    </div>
    ${profiles.length ? '<div class="profile-chips mb-16">' + chips + '</div>' : ''}
    <div class="disclaimer-banner">⚠️ <b>Approximate nutritional values.</b> All figures are estimates based on public food-composition data. Brainy Basket nutrition tracking is <b>not</b> a medical or clinical nutrition tool and does not provide medical diagnosis or treatment advice.</div>
    <div class="tabs">${tabs}</div>
    ${body}
  `;
}

function nutritionBar(label, val, target, unit) {
  const p = pct(val, target);
  return '<div class="bar-row"><div class="bar-head"><b>' + label + '</b>' +
    '<span class="bar-val">' + val + ' / ' + target + ' ' + unit + ' (' + p + '%)</span></div>' +
    '<div class="bar-track"><div class="bar-fill ' + barClass(val, target) + '" style="width:' + p + '%"></div></div></div>';
}

function renderNutritionToday(prof) {
  const totals = dayTotals(prof.id, selectedDate);
  const t = prof.targets;

  const meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  const mealBlocks = meals.map(meal => {
    const logs = logsFor(prof.id, selectedDate).filter(l => l.meal.toLowerCase() === meal.toLowerCase());
    let inner;
    if (logs.length === 0) {
      inner = '<div class="meal-empty">Nothing recorded for ' + meal.toLowerCase() + ' yet.</div>';
    } else {
      inner = '<div class="log-row head"><span>Food</span><span class="num">Qty</span><span class="num">Cal</span><span class="num">Protein</span><span class="num">Carbs</span><span class="num">Fat</span><span class="num">Fiber</span><span></span></div>' +
        logs.map(l =>
          '<div class="log-row"><span><span class="food-name">' + esc(l.foodName) + '</span><br><span class="food-src">' + l.sourceLabel + '</span></span>' +
          '<span class="num">' + l.quantity + ' serving' + (l.quantity > 1 ? 's' : '') + '</span>' +
          '<span class="num">' + l.nutrition.cal + '</span><span class="num">' + l.nutrition.protein + 'g</span>' +
          '<span class="num">' + l.nutrition.carbs + 'g</span><span class="num">' + l.nutrition.fat + 'g</span>' +
          '<span class="num">' + l.nutrition.fiber + 'g</span>' +
          '<span><button class="btn btn-danger btn-sm" onclick="deleteMealLog(\'' + l.id + '\')">✕</button></span></div>'
        ).join('');
    }
    return '<div class="meal-block"><div class="meal-head">' +
      '<span>' + ({ Breakfast: '🌅', Lunch: '☀️', Dinner: '🌙', Snacks: '🍿' }[meal]) + ' ' + meal + '</span>' +
      '<span class="spacer"></span>' +
      '<button class="btn btn-soft btn-sm" onclick="openMealLogModal(\'' + meal + '\')">+ Add</button></div>' + inner + '</div>';
  }).join('');

  const dateLabel = selectedDate === todayStr() ? 'Today' : selectedDate;

  return `
    <div class="grid grid-2">
      <div class="card" style="margin-top:0">
        <div class="card-title">TODAY — ${esc(prof.name.toUpperCase())} <span class="spacer"></span>
          <input type="date" value="${selectedDate}" onchange="selectedDate=this.value;render()"></div>
        <div class="ring-wrap">
          <div>
            <canvas id="cal-ring" width="130" height="130"></canvas>
          </div>
          <div class="ring-center-text">
            <div class="big">${totals.cal} / ${t.calories}</div>
            <div class="small">kcal recorded of target</div>
          </div>
        </div>
        <div class="mt-16">
          ${nutritionBar('Protein', totals.protein, t.protein, 'g')}
          ${nutritionBar('Carbohydrates', totals.carbs, t.carbs, 'g')}
          ${nutritionBar('Fat', totals.fat, t.fat, 'g')}
          ${nutritionBar('Fiber', totals.fiber, t.fiber, 'g')}
        </div>
        <div class="small muted mt-8">Targets are personalized for ${esc(prof.name)} (Mifflin-St Jeor estimate · goal: ${esc(goalLabel(prof.goal))}). Approximate nutritional values.</div>
      </div>
      <div class="card" style="margin-top:0">
        <div class="card-title">👤 Profile — ${esc(prof.name)}</div>
        <table>
          <tr><td class="muted">Age</td><td>${prof.age} yrs</td></tr>
          <tr><td class="muted">Gender</td><td>${esc(prof.gender)}</td></tr>
          <tr><td class="muted">Height</td><td>${prof.heightCm} cm</td></tr>
          <tr><td class="muted">Weight</td><td>${prof.weightKg} kg</td></tr>
          <tr><td class="muted">Activity</td><td>${esc(prof.activityLevel.replace('_', ' '))}</td></tr>
          <tr><td class="muted">Goal</td><td>${goalEmoji(prof.goal)} ${esc(goalLabel(prof.goal))}</td></tr>
        </table>
        <div class="small muted mt-8">Estimated daily targets (approx.): ${t.calories} kcal · ${t.protein}g protein · ${t.carbs}g carbs · ${t.fat}g fat · ${t.fiber}g fiber</div>
        <button class="btn btn-danger btn-sm mt-16" onclick="deleteProfile('${prof.id}')">Delete profile</button>
      </div>
    </div>
    <div class="mt-16">
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px">
        <b>${dateLabel} — meal history</b>
        <span class="spacer" style="flex:1"></span>
        <button class="btn btn-primary" onclick="openMealLogModal('Lunch')">+ Log food</button>
      </div>
      ${mealBlocks}
    </div>
  `;
}

function renderNutritionHistory(prof) {
  const dates = [...new Set(state.nutrition.logs.filter(l => l.profileId === prof.id).map(l => l.date))].sort().reverse();
  if (dates.length === 0) {
    return '<div class="card"><div class="empty-state"><div class="big">🍽️</div>No meal history yet. Log foods from the Today tab.</div></div>';
  }
  const blocks = dates.slice(0, 14).map(ds => {
    const logs = logsFor(prof.id, ds);
    const tot = dayTotals(prof.id, ds);
    const meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map(meal => {
      const ml = logs.filter(l => l.meal.toLowerCase() === meal.toLowerCase());
      if (ml.length === 0) return '';
      return '<div class="small mt-8"><b>' + meal + ':</b> ' + ml.map(l =>
        esc(l.foodName) + ' (' + l.quantity + ' serv · ' + l.nutrition.cal + ' kcal · ' + l.nutrition.protein + 'g P · ' +
        l.nutrition.carbs + 'g C · ' + l.nutrition.fat + 'g F · ' + l.nutrition.fiber + 'g fiber)'
      ).join(' · ') + '</div>';
    }).join('');
    return '<div class="card" style="margin-top:0"><div class="card-title">📅 ' + ds +
      '<span class="badge badge-green">' + tot.cal + ' kcal</span>' +
      '<span class="badge badge-blue">' + tot.protein + 'g protein</span></div>' + meals + '</div><div style="height:12px"></div>';
  }).join('');

  return `
    <div class="page-sub mb-16">Recent meal history for ${esc(prof.name)} — per-food approximate nutrition.</div>
    ${blocks}
  `;
}

function renderNutritionTrends(prof) {
  const t = prof.targets;
  const ranges = [
    ['daily', 'Daily', todayStr(), todayStr()],
    ['weekly', 'Weekly (last 7 days)', addDays(todayStr(), -6), todayStr()],
    ['monthly', 'Monthly (last 30 days)', addDays(todayStr(), -29), todayStr()],
  ];
  const rangeBtns = ranges.map(([id, label]) =>
    '<button class="tab ' + (summaryRange === id ? 'active' : '') + '" onclick="summaryRange=\'' + id + '\';render()">' + label + '</button>'
  ).join('');

  let days = 1, from = todayStr();
  if (summaryRange === 'weekly') { days = 7; from = addDays(todayStr(), -6); }
  if (summaryRange === 'monthly') { days = 30; from = addDays(todayStr(), -29); }

  const totals = { cal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0 };
  let logged = 0;
  for (let i = 0; i < days; i++) {
    const ds = addDays(from, i);
    const dt = dayTotals(prof.id, ds);
    if (dt.cal > 0) logged++;
    totals.cal += dt.cal; totals.protein += dt.protein; totals.carbs += dt.carbs;
    totals.fat += dt.fat; totals.fiber += dt.fiber;
  }
  const avg = k => logged ? Math.round(totals[k] / logged) : 0;

  return `
    <div class="card" style="margin-top:0">
      <div class="card-title">Summary range <span class="spacer"></span></div>
      <div class="tabs" style="margin-bottom:0">${rangeBtns}</div>
      <div class="summary-grid mt-16">
        <div class="summary-cell"><div class="s-label">Calories (avg/day)</div><div class="s-value">${avg('cal')}</div><div class="s-avg">target ${t.calories} kcal</div></div>
        <div class="summary-cell"><div class="s-label">Protein (avg/day)</div><div class="s-value">${avg('protein')}g</div><div class="s-avg">target ${t.protein}g</div></div>
        <div class="summary-cell"><div class="s-label">Carbs (avg/day)</div><div class="s-value">${avg('carbs')}g</div><div class="s-avg">target ${t.carbs}g</div></div>
        <div class="summary-cell"><div class="s-label">Fat (avg/day)</div><div class="s-value">${avg('fat')}g</div><div class="s-avg">target ${t.fat}g</div></div>
        <div class="summary-cell"><div class="s-label">Fiber (avg/day)</div><div class="s-value">${avg('fiber')}g</div><div class="s-avg">target ${t.fiber}g</div></div>
      </div>
      <div class="small muted mt-8">${logged} of ${days} day(s) have recorded intake. Approximate values.</div>
    </div>

    <div class="grid grid-2 mt-16">
      <div class="card" style="margin-top:0"><div class="card-title">📈 Calorie trend (last 14 days)</div><canvas id="chart-cal" class="chart-canvas"></canvas></div>
      <div class="card" style="margin-top:0"><div class="card-title">💪 Protein trend (last 14 days)</div><canvas id="chart-protein" class="chart-canvas"></canvas></div>
      <div class="card" style="margin-top:0"><div class="card-title">🌾 Fiber trend (last 14 days)</div><canvas id="chart-fiber" class="chart-canvas"></canvas></div>
      <div class="card" style="margin-top:0"><div class="card-title">🍞 Carbohydrate trend (last 14 days)</div><canvas id="chart-carbs" class="chart-canvas"></canvas></div>
    </div>
  `;
}

function renderNutritionInsights(prof) {
  const insights = generateInsights(prof.id);
  const pantryAvailable = state.inventory.filter(i => i.qty > 0).slice(0, 8).map(i => esc(i.name));

  return `
    <div class="card" style="margin-top:0">
      <div class="card-title">🤖 AI nutrition insights — ${esc(prof.name)} (${todayStr()})</div>
      ${insights.map(i =>
        '<div class="insight"><div class="insight-icon">' + i.icon + '</div>' +
        '<div><div class="insight-title">' + esc(i.title) + '</div><div class="insight-text">' + esc(i.text) + '</div></div></div>'
      ).join('')}
      <div class="small muted mt-8">Insights are generated from your recorded consumption and your <b>own selected targets</b>, using Brainy Basket's pantry commodities and recipes. These are simple observations, not medical advice.</div>
    </div>
    <div class="card">
      <div class="card-title">🧂 Pantry → Recipe Engine → Nutrition → Dashboard</div>
      <div class="flow-diagram">
        <span class="flow-node">Available: ${pantryAvailable.slice(0, 4).join(', ') || '—'}</span>
        <span class="flow-sep">→</span><span class="flow-node">Recipe Engine</span>
        <span class="flow-sep">→</span><span class="flow-node nutrition">Nutrition Info</span>
        <span class="flow-sep">→</span><span class="flow-node nutrition">Personal Dashboard</span>
      </div>
    </div>
  `;
}

// ---------------------------------------------------------------------------
// Charts (vanilla canvas)
// ---------------------------------------------------------------------------
function drawCharts() {
  const prof = activeProfile();
  if (!prof) return;

  // Calorie ring
  const ring = document.getElementById('cal-ring');
  if (ring) {
    const ctx = ring.getContext('2d');
    const totals = dayTotals(prof.id, selectedDate);
    const p = Math.min(1, totals.cal / Math.max(1, prof.targets.calories));
    ctx.clearRect(0, 0, 130, 130);
    ctx.lineWidth = 14;
    ctx.strokeStyle = '#e9efe6';
    ctx.beginPath(); ctx.arc(65, 65, 52, 0, Math.PI * 2); ctx.stroke();
    ctx.strokeStyle = p > 1 ? '#c62828' : '#2e7d32';
    ctx.beginPath(); ctx.arc(65, 65, 52, -Math.PI / 2, -Math.PI / 2 + p * Math.PI * 2); ctx.stroke();
    ctx.fillStyle = '#1d2a1f'; ctx.font = 'bold 20px Segoe UI'; ctx.textAlign = 'center';
    ctx.fillText(Math.round(p * 100) + '%', 65, 71);
  }

  // Trend line charts
  const series = [
    ['chart-cal', 'cal', '#2e7d32', prof.targets.calories],
    ['chart-protein', 'protein', '#1565c0', prof.targets.protein],
    ['chart-fiber', 'fiber', '#ef6c00', prof.targets.fiber],
    ['chart-carbs', 'carbs', '#7b1fa2', prof.targets.carbs],
  ];
  for (const [id, key, color, target] of series) {
    const cv = document.getElementById(id);
    if (!cv) continue;
    const ctx = cv.getContext('2d');
    const W = cv.width = cv.clientWidth || 400;
    const H = cv.height = 220;
    const data = [];
    for (let i = 13; i >= 0; i--) data.push({ d: addDays(todayStr(), -i), v: dayTotals(prof.id, addDays(todayStr(), -i))[key] });
    const maxV = Math.max(target * 1.2, ...data.map(x => x.v), 1);
    ctx.clearRect(0, 0, W, H);

    // target line
    ctx.strokeStyle = '#bbb'; ctx.setLineDash([5, 4]); ctx.beginPath();
    const ty = H - 30 - (target / maxV) * (H - 50);
    ctx.moveTo(34, ty); ctx.lineTo(W - 8, ty); ctx.stroke(); ctx.setLineDash([]);
    ctx.fillStyle = '#888'; ctx.font = '10px Segoe UI'; ctx.textAlign = 'left';
    ctx.fillText('target ' + target, 36, ty - 4);

    // bars
    const bw = (W - 42) / 14;
    data.forEach((x, i) => {
      const bh = (x.v / maxV) * (H - 50);
      ctx.fillStyle = x.v > target * 1.1 ? '#c62828' : color;
      ctx.fillRect(36 + i * bw, H - 30 - bh, Math.max(6, bw - 4), bh);
    });
    // baseline + labels
    ctx.strokeStyle = '#dfe6da'; ctx.beginPath(); ctx.moveTo(34, H - 30); ctx.lineTo(W - 8, H - 30); ctx.stroke();
    ctx.fillStyle = '#888'; ctx.font = '9px Segoe UI'; ctx.textAlign = 'center';
    [0, 6, 13].forEach(i => {
      const d = data[i].d.slice(5);
      ctx.fillText(d, 36 + i * bw + bw / 2, H - 14);
    });
  }
}

// ---------------------------------------------------------------------------
// Modals
// ---------------------------------------------------------------------------
function closeModal() { document.getElementById('modal-root').innerHTML = ''; }

function openProfileModal(editId) {
  editingProfileId = editId || null;
  const p = editId ? state.nutrition.profiles.find(x => x.id === editId) : null;
  document.getElementById('modal-root').innerHTML = `
    <div class="modal-backdrop" onclick="if(event.target===this)closeModal()">
      <div class="modal">
        <div class="modal-head"><h3>${p ? 'Edit' : 'New'} person profile</h3><span class="spacer"></span>
          <button class="modal-close" onclick="closeModal()">✕</button></div>
        <div class="modal-body">
          <label class="field"><span class="field-label">Name</span>
            <input id="pf-name" value="${p ? esc(p.name) : ''}" placeholder="e.g. Ajay"></label>
          <div class="form-row">
            <label class="field"><span class="field-label">Age</span>
              <input id="pf-age" type="number" min="1" max="120" value="${p ? p.age : 30}"></label>
            <label class="field"><span class="field-label">Gender</span>
              <select id="pf-gender">
                <option value="male" ${p && p.gender === 'male' ? 'selected' : ''}>Male</option>
                <option value="female" ${p && p.gender === 'female' ? 'selected' : ''}>Female</option>
                <option value="other" ${!p || p.gender === 'other' ? 'selected' : ''}>Other</option>
              </select></label>
          </div>
          <div class="form-row">
            <label class="field"><span class="field-label">Height (cm)</span>
              <input id="pf-height" type="number" min="50" max="250" value="${p ? p.heightCm : 170}"></label>
            <label class="field"><span class="field-label">Weight (kg)</span>
              <input id="pf-weight" type="number" min="10" max="300" step="0.1" value="${p ? p.weightKg : 65}"></label>
          </div>
          <label class="field"><span class="field-label">Activity Level</span>
            <select id="pf-activity">
              ${['sedentary', 'light', 'moderate', 'active', 'very_active'].map(a =>
                '<option value="' + a + '" ' + (p && p.activityLevel === a ? 'selected' : '') + '>' + a.replace('_', ' ') + '</option>').join('')}
            </select></label>
          <label class="field"><span class="field-label">Nutrition Goal</span>
            <select id="pf-goal">
              <option value="maintain" ${!p || p.goal === 'maintain' ? 'selected' : ''}>Maintain Weight</option>
              <option value="gain" ${p && p.goal === 'gain' ? 'selected' : ''}>Gain Weight</option>
              <option value="lose" ${p && p.goal === 'lose' ? 'selected' : ''}>Lose Weight</option>
            </select></label>
          <div class="small muted">Daily targets are estimated per person (Mifflin-St Jeor) from the details above. Approximate values — not medical guidance.</div>
        </div>
        <div class="modal-foot">
          <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
          <button class="btn btn-primary" onclick="submitProfileModal()">Save profile</button>
        </div>
      </div>
    </div>`;
}

function submitProfileModal() {
  saveProfile({
    name: document.getElementById('pf-name').value,
    age: document.getElementById('pf-age').value,
    gender: document.getElementById('pf-gender').value,
    heightCm: document.getElementById('pf-height').value,
    weightKg: document.getElementById('pf-weight').value,
    activityLevel: document.getElementById('pf-activity').value,
    goal: document.getElementById('pf-goal').value,
  });
}

function openMealLogModal(meal) {
  const prof = activeProfile();
  if (!prof) return;
  const options = state.recipes.map(r =>
    '<option value="recipe:' + r.id + '">' + esc(r.name) + ' (recipe)</option>'
  ).join('') + state.inventory.map(i =>
    '<option value="pantry:' + esc(i.name) + '">' + esc(i.name) + ' (pantry)</option>'
  ).join('');

  document.getElementById('modal-root').innerHTML = `
    <div class="modal-backdrop" onclick="if(event.target===this)closeModal()">
      <div class="modal">
        <div class="modal-head"><h3>Log food — ${esc(prof.name)}</h3><span class="spacer"></span>
          <button class="modal-close" onclick="closeModal()">✕</button></div>
        <div class="modal-body">
          <label class="field"><span class="field-label">Meal</span>
            <select id="ml-meal">
              ${['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map(m =>
                '<option ' + (m === meal ? 'selected' : '') + '>' + m + '</option>').join('')}
            </select></label>
          <label class="field"><span class="field-label">Food / recipe (from your pantry & recipe engine)</span>
            <select id="ml-food">${options}
              <option value="custom:Custom food">Custom food…</option></select></label>
          <label class="field" id="ml-custom-wrap" style="display:none"><span class="field-label">Custom food name</span>
            <input id="ml-custom" placeholder="e.g. Dal Rice"></label>
          <div class="form-row">
            <label class="field"><span class="field-label">Quantity (servings)</span>
              <input id="ml-qty" type="number" min="0.25" step="0.25" value="1"></label>
            <label class="field"><span class="field-label">Date</span>
              <input id="ml-date" type="date" value="${selectedDate}"></label>
          </div>
          <div class="small muted">Nutrition is calculated from the recipe engine / per-100g food estimates. Approximate values only.</div>
        </div>
        <div class="modal-foot">
          <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
          <button class="btn btn-primary" onclick="submitMealLogModal()">Log meal</button>
        </div>
      </div>
    </div>`;

  document.getElementById('ml-food').addEventListener('change', function () {
    document.getElementById('ml-custom-wrap').style.display = this.value === 'custom:Custom food' ? 'block' : 'none';
  });
}

function submitMealLogModal() {
  const val = document.getElementById('ml-food').value;
  const [src, key] = val.split(':');
  let foodId = null, foodName = '';
  if (src === 'recipe') foodId = key;
  else if (src === 'pantry') foodName = key;
  else foodName = document.getElementById('ml-custom').value || 'Unknown food';

  addMealLog({
    profileId: state.nutrition.activeProfileId,
    meal: document.getElementById('ml-meal').value,
    foodId,
    foodName,
    quantity: +document.getElementById('ml-qty').value || 1,
    date: document.getElementById('ml-date').value || todayStr(),
  });
}

function openAddCommodityModal() {
  document.getElementById('modal-root').innerHTML = `
    <div class="modal-backdrop" onclick="if(event.target===this)closeModal()">
      <div class="modal">
        <div class="modal-head"><h3>Register new commodity</h3><span class="spacer"></span>
          <button class="modal-close" onclick="closeModal()">✕</button></div>
        <div class="modal-body">
          <p class="small muted" style="margin-bottom:16px"><b>Manual commodity registration:</b> Enter the commodity details. Hardware mapping (ESP32, RFID) comes next.</p>
          <label class="field"><span class="field-label">Commodity name *</span><input id="cm-name" placeholder="e.g. Toor Dal" autofocus></label>
          <label class="field"><span class="field-label">Category *</span><input id="cm-cat" placeholder="e.g. Pulses"></label>
          <label class="field"><span class="field-label">Storage location</span><input id="cm-loc" placeholder="e.g. Container A"></label>
          <div class="form-row">
            <label class="field"><span class="field-label">Minimum quantity *</span><input id="cm-min" type="number" min="0" step="0.1" value="1" placeholder="1"></label>
            <label class="field"><span class="field-label">Unit *</span>
              <select id="cm-unit"><option>kg</option><option>g</option><option>L</option><option>ml</option><option>piece</option><option>dozen</option></select></label>
          </div>
          <hr style="margin:16px 0;border:none;border-top:1px solid var(--line)">
          <p class="small muted" style="margin-bottom:12px"><b>Hardware IDs (optional for now):</b> You can add these later when mapping hardware.</p>
          <div class="form-row">
            <label class="field"><span class="field-label">ESP32 device ID</span><input id="cm-esp" placeholder="e.g. ESP32_001"></label>
            <label class="field"><span class="field-label">RFID tag ID</span><input id="cm-rfid" placeholder="e.g. RFID001"></label>
          </div>
          <label class="field"><span class="field-label">RF tag ID</span><input id="cm-rf" placeholder="e.g. RF001"></label>
        </div>
        <div class="modal-foot">
          <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
          <button class="btn btn-primary" onclick="submitAddCommodityModal()">Register commodity</button>
        </div>
      </div>
    </div>`;
}

function submitAddCommodityModal() {
  const name = document.getElementById('cm-name').value.trim();
  const category = document.getElementById('cm-cat').value.trim();
  const minQty = parseFloat(document.getElementById('cm-min').value) || 1;
  
  if (!name || !category) {
    alert('Name and category are required');
    return;
  }
  
  addInventoryItem({
    name,
    category,
    qty: 0, // Always start at 0
    unit: document.getElementById('cm-unit').value,
    threshold: minQty,
    storageLocation: document.getElementById('cm-loc').value.trim() || 'Unspecified',
    deviceId: document.getElementById('cm-esp').value.trim() || null,
    rfidTagId: document.getElementById('cm-rfid').value.trim() || null,
    rfTagId: document.getElementById('cm-rf').value.trim() || null,
  });
  closeModal();
}



function openAddShoppingModal() {
  document.getElementById('modal-root').innerHTML = `
    <div class="modal-backdrop" onclick="if(event.target===this)closeModal()">
      <div class="modal">
        <div class="modal-head"><h3>Add shopping item</h3><span class="spacer"></span>
          <button class="modal-close" onclick="closeModal()">✕</button></div>
        <div class="modal-body">
          <label class="field"><span class="field-label">Name</span><input id="sh-name" placeholder="e.g. Olive Oil"></label>
          <div class="form-row">
            <label class="field"><span class="field-label">Quantity</span><input id="sh-qty" type="number" min="0" step="0.1" value="1"></label>
            <label class="field"><span class="field-label">Unit</span>
              <select id="sh-unit"><option>kg</option><option>g</option><option>L</option><option>pcs</option></select></label>
          </div>
          <label class="field"><span class="field-label">Priority</span>
            <select id="sh-pri"><option>High</option><option selected>Medium</option><option>Low</option></select></label>
        </div>
        <div class="modal-foot">
          <button class="btn btn-ghost" onclick="closeModal()">Cancel</button>
          <button class="btn btn-primary" onclick="submitAddShoppingModal()">Add</button>
        </div>
      </div>
    </div>`;
}

function submitAddShoppingModal() {
  addShoppingItem({
    name: document.getElementById('sh-name').value.trim(),
    qty: +document.getElementById('sh-qty').value || 1,
    unit: document.getElementById('sh-unit').value,
    priority: document.getElementById('sh-pri').value,
  });
  closeModal();
}

function wireNutritionEvents() { /* date inputs handled inline */ }

// ---------------------------------------------------------------------------
// Init
// ---------------------------------------------------------------------------
function init() {
  load();
  render();
}

document.addEventListener('DOMContentLoaded', init);