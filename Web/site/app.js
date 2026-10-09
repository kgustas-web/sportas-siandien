/* Sports Companion — the same model as the iPhone app:
   Source × Follow → Event, prominence by weight, nothing hidden.
   Data is baked at build time, so the page never talks to a feed. */

const CHEV = '›';
let DATA = { events: [], channels: {}, problems: [] };
let lens = 'all';
let sub = null;        // a second cut inside a lens: a sport, or a competition
const stack = document.getElementById('stack');

/* ── time ─────────────────────────────────────────────────────────────── */
const day0 = d => { const x = new Date(d); x.setHours(0,0,0,0); return x; };
const hhmm = d => d.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit', hour12:false});
// "Thu 17 September" — built by hand so the order never flips with locale.
const shortDate = d =>
  d.toLocaleDateString([], {weekday:'short'}).replace(',', '') + ' ' +
  d.getDate() + ' ' + d.toLocaleDateString([], {month:'long'});

function dayLabel(d) {
  const t = day0(new Date()), x = day0(d);
  const diff = Math.round((x - t) / 864e5);
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Tomorrow';
  if (diff === -1) return 'Yesterday';
  if (diff > 1 && diff < 7) return d.toLocaleDateString([], {weekday:'long'});
  return shortDate(d);
}

/* ── events ───────────────────────────────────────────────────────────── */
function hydrate(raw) {
  const start = new Date(raw.start);
  const end = new Date(start.getTime() + raw.minutes * 60000);
  const expires = new Date(end.getTime() + 7 * 864e5);
  return {...raw, start, end, expires};
}

function state(e, now) {
  if (now < e.start) return 'ahead';
  if (now < e.end) return 'live';
  if (now < e.expires) return 'sealed';
  return 'gone';
}

function availability(e, now) {
  if (state(e, now) !== 'sealed') return null;
  return (now - e.end) < 3.5 * 864e5 ? 'Full replay' : 'Highlights';
}

function expiryNote(e, now) {
  if (state(e, now) !== 'sealed') return null;
  const left = e.expires - now;
  if (left > 2 * 864e5) return null;
  return left < 12 * 36e5
    ? 'until ' + hhmm(e.expires)
    : 'until ' + e.expires.toLocaleDateString([], {weekday:'long'});
}

/* ── grouping ─────────────────────────────────────────────────────────── */
function forward(events, now, groupOccasions = true) {
  const today = day0(now);
  const live = events.filter(e => state(e, now) !== 'gone');
  const claimed = new Set();
  const items = [];

  // An occasion sits on the day of its first session that has not finished,
  // so a race weekend moves with you rather than vanishing on Friday night.
  const names = groupOccasions
    ? [...new Set(live.filter(e => e.occasion).map(e => e.occasion))]
    : [];
  for (const name of names) {
    const parts = live
      .filter(e => e.occasion === name && day0(e.start) >= today)
      .sort((a,b) => a.start - b.start);
    if (parts.length < 2) continue;
    parts.forEach(p => claimed.add(p));
    items.push({day: day0(parts[0].start), kind: 'occasion', name, sessions: parts});
  }
  for (const e of live) {
    if (claimed.has(e) || day0(e.start) < today) continue;
    items.push({day: day0(e.start), kind: 'event', event: e});
  }
  return group(items);
}

function earlier(events, now) {
  const today = day0(now);
  const past = events.filter(e => state(e, now) === 'sealed' && day0(e.start) < today);
  const days = group(past.map(e => ({day: day0(e.start), kind: 'event', event: e})));
  days.reverse();
  days.forEach(d => d.items.reverse());
  return days;
}

function group(items) {
  const by = new Map();
  for (const it of items) {
    const k = +it.day;
    if (!by.has(k)) by.set(k, {date: it.day, items: []});
    by.get(k).items.push(it);
  }
  const days = [...by.values()].sort((a,b) => a.date - b.date);
  days.forEach(d => d.items.sort((a,b) => sortDate(a) - sortDate(b)));
  return days;
}
const sortDate = it => it.kind === 'event' ? it.event.start : it.sessions[0].start;

/* ── rows ─────────────────────────────────────────────────────────────── */
function eventRow(e, now, onTap) {
  const st = state(e, now);
  const weight = st === 'live' ? 2 : e.prominence;   // live always speaks up
  const el = document.createElement('button');
  el.className = 'row p' + weight;

  const avail = availability(e, now);
  const exp = expiryNote(e, now);
  const meta = [e.competition, avail ? (exp ? avail + ' · ' + exp : avail) : e.channel]
    .filter(Boolean).join(' · ');

  el.innerHTML =
    '<div class="body"><div class="t">' + hhmm(e.start) + '</div><div class="main">' +
      '<div class="ttlline"><span class="ttl"></span>' +
      (st === 'live' ? '<span class="live"><i></i>On now</span>' : '') + '</div>' +
      (e.reason ? '<div class="why"></div>' : '') +
      (e.note ? '<div class="n"></div>' : '') +
      '<div class="meta"></div>' +
    '</div></div><span class="chev">' + CHEV + '</span>';

  el.querySelector('.ttl').textContent = e.title;
  if (e.reason) el.querySelector('.why').textContent = e.reason;
  if (e.note) el.querySelector('.n').textContent = e.note;
  el.querySelector('.meta').textContent = meta;
  el.onclick = () => onTap(e);
  return el;
}

function sep() { const d = document.createElement('div'); d.className = 'sep'; return d; }

function utilRow(label, onTap, count, subtitle) {
  const b = document.createElement('button');
  b.className = 'util';
  b.innerHTML = '<span class="stack"><span class="l"></span>' +
    (subtitle ? '<span class="s"></span>' : '') + '</span>' +
    (count != null ? '<span class="count">' + count + '</span>' : '') +
    '<span class="chev">' + CHEV + '</span>';
  b.querySelector('.l').textContent = label;
  if (subtitle) b.querySelector('.s').textContent = subtitle;
  b.onclick = onTap;
  return b;
}

/* ── navigation ───────────────────────────────────────────────────────── */
function mount(build, animate) {
  const v = document.createElement('div');
  v.className = 'view';
  build(v);
  stack.appendChild(v);
  if (animate) {
    v.classList.add('push');
    const prev = stack.children[stack.children.length - 2];
    if (prev) prev.classList.add('under');
    v.addEventListener('animationend', () => v.classList.remove('push'), {once:true});
  }
  return v;
}

function pop() {
  const views = stack.children;
  if (views.length < 2) return;
  const top = views[views.length - 1], prev = views[views.length - 2];
  prev.classList.remove('under');
  prev.classList.add('back');
  prev.addEventListener('animationend', () => prev.classList.remove('back'), {once:true});
  top.classList.add('pop');
  top.addEventListener('animationend', () => top.remove(), {once:true});
}

/* Builds a nav bar. */
function chrome(v, {backLabel, title, links, brand} = {}) {
  const nav = document.createElement('div');
  nav.className = 'nav';
  nav.innerHTML = '<div class="navinner"><div class="bar">' +
    (backLabel
      ? '<button class="back"><svg viewBox="0 0 12 20" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M10 2 2 10l8 8"/></svg><span></span></button>'
      : '') +
    (brand ? '<span class="brand"></span>' : '') +
    '<div class="title"></div>' +
    '</div></div>';
  if (links) nav.classList.add('tall');
  if (backLabel) {
    nav.querySelector('.back span').textContent = backLabel;
    nav.querySelector('.back').onclick = pop;
  }
  const titleEl = nav.querySelector('.title');
  if (title) { titleEl.textContent = title; titleEl.classList.add('on'); }
  if (brand) nav.querySelector('.brand').textContent = brand;
  if (links) nav.querySelector('.navinner').appendChild(links);

  const sc = document.createElement('div');
  sc.className = 'scroll';
  const inner = document.createElement('div');
  inner.className = 'inner';
  sc.append(inner);
  v.append(nav, sc);

  sc.addEventListener('scroll', () => {
    nav.classList.toggle('edge', sc.scrollTop > 4);
  }, {passive:true});
  return inner;
}

function dayHeader(label, first) {
  const h = document.createElement('h1');
  h.className = 'day' + (first ? ' first' : '');
  h.textContent = label;
  return h;
}

/* ── screens ──────────────────────────────────────────────────────────── */
/* Top level is only the sports followed in their own right. Gymnastics and
   weightlifting are in the app because Lithuanians turn up there, so they
   belong under Lithuania, not beside Basketball. */
function lensOptions() {
  const up = upcoming(DATA.events, new Date());
  const core = new Set(DATA.coreSports || []);
  const opts = [['all', 'All']];
  if (up.some(inLithuania)) opts.push(['lithuania', 'Lithuania']);
  [...new Set(up.map(e => e.sport))].sort()
    .filter(s => core.has(s))
    .forEach(s => opts.push(['sport:' + s, s]));
  return opts;
}

/// Everything the timeline still has to show: today onwards, not expired.
function upcoming(events, now) {
  const today = day0(now);
  return events.filter(e => state(e, now) !== 'gone' && day0(e.start) >= today);
}

function pickLens(value, onChange) {
  lens = value;
  sub = null;
  onChange();
}

/* One control, both sizes: words in the bar on a phone, header links on a
   wide screen. */
function filterLinks(onChange) {
  const nav = document.createElement('nav');
  nav.className = 'links';
  for (const [value, label] of lensOptions()) {
    const b = document.createElement('button');
    b.className = lens === value ? 'on' : '';
    b.textContent = label;
    b.onclick = () => pickLens(value, onChange);
    nav.append(b);
  }
  return nav;
}

/* Two different things, kept apart.

   `lithuanian` on an event is evidence: a named Lithuanian, a Lithuanian
   club, the country. It drives prominence and must stay honest.

   The Lithuania *lens* is a scope, and it is wider. Any sport beyond the
   ones followed in their own right is in the app only because Lithuanians
   compete there, so the whole sport belongs in this view — even a biathlon
   round whose Lithuanian entry has not been announced yet. */
function inLithuania(e) {
  const core = new Set(DATA.coreSports || []);
  return e.lithuanian || !core.has(e.sport);
}

/* The lens on its own, before the second cut. */
function scope() {
  if (lens === 'all') return DATA.events;
  if (lens === 'lithuania') return DATA.events.filter(inLithuania);
  const sport = lens.slice(6);
  return DATA.events.filter(e => e.sport === sport);
}

/* What a lens divides into, one level down: Lithuania by sport, a sport by
   competition. All has nothing under it — its parts are the bar above. */
function subKey() {
  if (lens === 'lithuania') return e => e.sport;
  if (lens.startsWith('sport:')) return e => e.competition;
  return null;
}

function visible() {
  const key = subKey();
  return sub && key ? scope().filter(e => key(e) === sub) : scope();
}

/* The parts of the current lens. This replaced Browse, which answered the
   same question three screens away. Only parts with something ahead are
   offered, so no pill leads nowhere.

   Counts appear inside Lithuania only. There "Gymnastics 1" says something:
   one thing, do not miss it. On a sport the number is the size of a feed —
   373 EuroLeague games — which is not a judgement about any evening. */
function chipRow(onChange) {
  const key = subKey();
  if (!key) return null;
  const up = upcoming(scope(), new Date());
  const counts = new Map();
  up.forEach(e => counts.set(key(e), (counts.get(key(e)) || 0) + 1));
  if (counts.size < 2) return null;   // nothing to choose between
  // A race weekend is already one row in the timeline. Eight pills naming
  // the same eight rows would be a second copy of the list, not a filter.
  if (up.every(e => e.occasion === key(e))) return null;

  const counted = lens === 'lithuania';
  const row = document.createElement('div');
  row.className = 'chips';
  const make = (label, value, n) => {
    const b = document.createElement('button');
    b.className = 'chip' + (sub === value ? ' on' : '');
    b.innerHTML = '<span></span>' + (counted ? '<span class="c"></span>' : '');
    b.firstChild.textContent = label;
    if (counted) b.lastChild.textContent = n;
    b.onclick = () => { sub = value; onChange(); };
    return b;
  };
  row.append(make(lens === 'lithuania' ? 'All sports' : 'All ' + lens.slice(6).toLowerCase(),
                  null, up.length));
  [...counts.keys()].sort().forEach(k => row.append(make(k, k, counts.get(k))));
  return row;
}

/* A redraw rebuilds the rows, which would throw a scrolled row back to its
   start and can leave the thing just picked off-screen. */
function settle(row, left) {
  if (!row) return;
  row.scrollLeft = left || 0;
  const on = row.querySelector('.on');
  if (!on) return;
  const r = row.getBoundingClientRect(), o = on.getBoundingClientRect();
  if (o.left < r.left + 20) row.scrollLeft += o.left - r.left - 20;
  else if (o.right > r.right - 28) row.scrollLeft += o.right - r.right + 28;
}

function today(v) {
  const was = sel => v.querySelector(sel)?.scrollLeft;
  const kept = {links: was('.links'), chips: was('.chips')};
  v.innerHTML = '';
  const now = new Date();
  const redraw = () => today(v);
  const sc = chrome(v, {
    brand: 'Sportas šiandien',
    links: filterLinks(redraw),
  });

  const chips = chipRow(redraw);
  if (chips) sc.append(chips);
  requestAnimationFrame(() => {
    settle(v.querySelector('.links'), kept.links);
    settle(chips, kept.chips);
  });

  // Earlier follows the lens: inside Lithuania it counts Lithuania.
  const shown = visible();
  const pastCount = earlier(shown, now).reduce((n,d) => n + d.items.length, 0);
  if (pastCount) {
    const b = utilRow(pastCount + ' from earlier',
      () => mount(w => earlierScreen(w, shown), true));
    b.classList.add('quiet');
    sc.append(b);
  }

  const days = forward(shown, now);
  if (!days.some(d => +d.date === +day0(now))) {
    const next = shown.filter(e => e.start > now).sort((a,b) => a.start - b.start)[0];
    const box = document.createElement('div');
    box.className = 'verdict';
    box.innerHTML = '<div class="a"></div>' + (next ? '<div class="b"></div>' : '');
    box.querySelector('.a').textContent = now.getHours() < 12 ? 'Nothing today.' : 'Nothing tonight.';
    if (next) box.querySelector('.b').textContent =
      'Next: ' + next.title + ', ' + dayLabel(next.start) + ' ' + hhmm(next.start) + '.';
    sc.append(box);
  }

  renderDays(sc, days, now, !pastCount);

  if (!DATA.events.length) {
    const n = document.createElement('div');
    n.className = 'note';
    n.textContent = DATA.problems.length
      ? 'Could not load the schedule. Showing nothing rather than guessing.'
      : 'No schedule loaded yet.';
    sc.append(n);
  }
}

function renderDays(sc, days, now, tightFirst) {
  days.forEach((d, di) => {
    sc.append(dayHeader(dayLabel(d.date), di === 0 && tightFirst));
    d.items.forEach((it, i) => {
      sc.append(it.kind === 'occasion' ? occasionRow(it, now) : eventRow(it.event, now, openEvent));
      if (i < d.items.length - 1) sc.append(sep());
    });
  });
}

function occasionRow(it, now) {
  const b = document.createElement('button');
  b.className = 'row p2';
  const a = it.sessions[0].start.toLocaleDateString([], {weekday:'short'});
  const z = it.sessions[it.sessions.length-1].start.toLocaleDateString([], {weekday:'short'});
  const span = (a === z ? '' : a + '–' + z + ' · ') + it.sessions.length + ' sessions';
  b.innerHTML = '<div class="body"><div class="t"></div><div class="main">' +
    '<div class="ttl"></div><div class="meta"></div></div></div>' +
    '<span class="chev">' + CHEV + '</span>';
  b.querySelector('.ttl').textContent = it.name;
  b.querySelector('.meta').textContent = span;
  b.onclick = () => mount(v => fixtures(v, it.name, it.sessions, 'Today'), true);
  return b;
}

function earlierScreen(v, events) {
  const now = new Date();
  const sc = chrome(v, {backLabel: 'Today', title: 'Earlier'});
  earlier(events, now).forEach((d, di) => {
    sc.append(dayHeader(dayLabel(d.date), di === 0));
    d.items.forEach((it, i) => {
      sc.append(eventRow(it.event, now, openEvent));
      if (i < d.items.length - 1) sc.append(sep());
    });
  });
}

function fixtures(v, title, events, backLabel) {
  const now = new Date();
  const sc = chrome(v, {backLabel, title});
  // Flat: you are already inside the occasion, so its sessions are the content.
  renderDays(sc, forward(events, now, false), now, true);
}

function openEvent(e) {
  mount(v => {
    const now = new Date();
    const st = state(e, now);
    const sc = chrome(v, {backLabel: 'Back'});
    const url = DATA.channels[e.channel];
    const box = document.createElement('div');
    box.className = 'detail';

    let when = dayLabel(e.start) + ' at ' + hhmm(e.start) + ' · ' + e.competition;
    let acts = '';
    if (st === 'live' && url) acts = '<a class="btn" href="' + url + '" target="_blank" rel="noopener">Watch on ' + e.channel + '</a>';
    else if (st === 'sealed' && url) {
      const full = availability(e, now) === 'Full replay';
      acts = '<a class="btn" href="' + url + '" target="_blank" rel="noopener">' + (full ? 'Watch full replay' : 'Extended highlights') + '</a>' +
             (full ? '<a class="btn sec" href="' + url + '" target="_blank" rel="noopener">Extended highlights</a>' : '');
    } else if (st === 'ahead' && url) {
      acts = '<a class="btn sec" href="' + url + '" target="_blank" rel="noopener">Open ' + e.channel + '</a>';
    }

    box.innerHTML =
      '<h2></h2><div class="when"></div>' +
      (st === 'live' ? '<div class="live"><i></i>On now</div>' : '') +
      (e.reason ? '<div class="why"></div>' : '') +
      (e.note ? '<div class="notehint"></div>' : '') +
      (acts ? '<div class="acts">' + acts + '</div>' : '') +
      (st === 'ahead' ? '<div class="hint"></div>' : '') +
      (expiryNote(e, now) ? '<div class="hint">Available ' + expiryNote(e, now) + '.</div>' : '') +
      (st === 'sealed'
        ? '<div class="reveal"><a target="_blank" rel="noopener" href="https://duckduckgo.com/?q=' +
          encodeURIComponent(e.title + ' ' + e.competition + ' result') + '">Show result</a></div>'
        : '');

    box.querySelector('h2').textContent = e.title;
    box.querySelector('.when').textContent = when;
    if (e.reason) box.querySelector('.why').textContent = e.reason;
    if (e.note) box.querySelector('.notehint').textContent = e.note;
    if (st === 'ahead') {
      const mins = Math.round((e.start - now) / 60000);
      box.querySelector('.hint').textContent = 'Starts in ' +
        (mins < 60 ? Math.max(mins,1) + ' minutes'
         : mins < 1440 ? Math.round(mins/60) + ' hours'
         : Math.round(mins/1440) + ' days') + '.';
    }
    sc.append(box);
  }, true);
}

/* ── boot ─────────────────────────────────────────────────────────────── */
async function boot() {
  try {
    const r = await fetch('events.json?v=' + Date.now());
    const j = await r.json();
    DATA = {...j, events: j.events.map(hydrate)};
  } catch (err) {
    DATA = { events: [], channels: {}, problems: ['offline'] };
  }
  mount(today, false);
}
boot();

/* The first service worker shipped was cache-first, and a browser that
   installed it kept serving the old build no matter how many times the page
   was reloaded. Network-first fixed the rule; this makes the switch happen
   without anyone having to know about it: check for a new worker on every
   load, and reload once when one takes over. */
if ('serviceWorker' in navigator) {
  let reloading = false;
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (reloading) return;
    reloading = true;
    location.reload();
  });
  navigator.serviceWorker.register('sw.js')
    .then(reg => reg.update())
    .catch(() => {});
}
