/* Sports Companion — the same model as the iPhone app:
   Source × Follow → Event, prominence by weight, nothing hidden.
   Data is baked at build time, so the page never talks to a feed. */

const CHEV = '›';
let DATA = { events: [], channels: {}, problems: [] };
let lens = 'all';
let subSport = null;   // a second cut, only inside Lithuania
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

/* Builds a nav bar. `track` turns on day-tracking against .daymark elements. */
function chrome(v, {backLabel, title, filter, track} = {}) {
  const nav = document.createElement('div');
  nav.className = 'nav';
  nav.innerHTML = '<div class="bar">' +
    (backLabel
      ? '<button class="back"><svg viewBox="0 0 12 20" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M10 2 2 10l8 8"/></svg><span></span></button>'
      : '') +
    '<div class="title"></div>' +
    (filter ? '<div class="trail"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M8 9.5h8M9.5 12h5M11 14.5h2"/></svg></div>' : '') +
    '</div>';
  if (backLabel) {
    nav.querySelector('.back span').textContent = backLabel;
    nav.querySelector('.back').onclick = pop;
  }
  const titleEl = nav.querySelector('.title');
  if (title) { titleEl.textContent = title; titleEl.classList.add('on'); }
  if (filter) nav.querySelector('.trail').appendChild(filter);

  const sc = document.createElement('div');
  sc.className = 'scroll';
  const inner = document.createElement('div');
  inner.className = 'inner';
  sc.append(inner);
  v.append(nav, sc);

  sc.addEventListener('scroll', () => {
    nav.classList.toggle('edge', sc.scrollTop > 4);
    if (!track) return;
    // The block straddling the top of the screen is the day you are reading.
    let label = null;
    for (const m of inner.querySelectorAll('.daymark')) {
      if (m.getBoundingClientRect().top < 60) label = m.dataset.label;
    }
    if (label) { titleEl.textContent = label; titleEl.classList.add('on'); }
    else titleEl.classList.remove('on');
  }, {passive:true});
  return inner;
}

function dayHeader(label, first) {
  const h = document.createElement('h1');
  h.className = 'day daymark' + (first ? ' first' : '');
  h.dataset.label = label;
  h.textContent = label;
  return h;
}

/* ── screens ──────────────────────────────────────────────────────────── */
function filterControl(onChange) {
  const sel = document.createElement('select');
  const now = new Date();
  const up = forward(DATA.events, now).flatMap(d =>
    d.items.flatMap(i => i.kind === 'event' ? [i.event] : i.sessions));
  const sports = [...new Set(up.map(e => e.sport))].sort();
  const opts = [['all','All']];
  if (up.some(e => e.lithuanian)) opts.push(['lithuania','Lithuania']);
  sports.forEach(s => opts.push(['sport:' + s, s]));
  sel.innerHTML = opts.map(([v,l]) => '<option value="' + v + '">' + l + '</option>').join('');
  sel.value = lens;
  sel.onchange = () => { lens = sel.value; subSport = null; onChange(); };
  return sel;
}

function visible() {
  if (lens === 'all') return DATA.events;
  if (lens === 'lithuania') {
    const lt = DATA.events.filter(e => e.lithuanian);
    return subSport ? lt.filter(e => e.sport === subSport) : lt;
  }
  const sport = lens.slice(6);
  return DATA.events.filter(e => e.sport === sport);
}

/// Sports present inside the current scope, so the chips never offer an
/// empty result.
function sportsWithin(events, now) {
  const up = forward(events, now).flatMap(d =>
    d.items.flatMap(i => i.kind === 'event' ? [i.event] : i.sessions));
  return [...new Set(up.map(e => e.sport))].sort();
}

function chipRow(onChange) {
  const now = new Date();
  const sports = sportsWithin(DATA.events.filter(e => e.lithuanian), now);
  if (sports.length < 2) return null;   // nothing to choose between

  const row = document.createElement('div');
  row.className = 'chips';
  const make = (label, value) => {
    const b = document.createElement('button');
    b.className = 'chip' + (subSport === value ? ' on' : '');
    b.textContent = label;
    b.onclick = () => { subSport = value; onChange(); };
    return b;
  };
  row.append(make('All sports', null));
  sports.forEach(s => row.append(make(s, s)));
  return row;
}

function today(v) {
  v.innerHTML = '';
  const now = new Date();
  const sc = chrome(v, {filter: filterControl(() => today(v)), track: true});

  if (lens === 'lithuania') {
    const chips = chipRow(() => today(v));
    if (chips) sc.append(chips);
  }

  const past = earlier(DATA.events, now);
  const pastCount = past.reduce((n,d) => n + d.items.length, 0);
  if (pastCount) {
    sc.append(utilRow(pastCount === 1 ? '1 from earlier' : pastCount + ' from earlier',
      () => mount(earlierScreen, true)), sep());
  }
  sc.append(utilRow('Browse', () => mount(browseScreen, true)), sep());

  const days = forward(visible(), now);
  if (!days.some(d => +d.date === +day0(now))) {
    const next = visible().filter(e => e.start > now).sort((a,b) => a.start - b.start)[0];
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

function earlierScreen(v) {
  const now = new Date();
  const sc = chrome(v, {backLabel: 'Today', title: 'Earlier'});
  earlier(DATA.events, now).forEach((d, di) => {
    sc.append(dayHeader(dayLabel(d.date), di === 0));
    d.items.forEach((it, i) => {
      sc.append(eventRow(it.event, now, openEvent));
      if (i < d.items.length - 1) sc.append(sep());
    });
  });
}

/* Browse: a different question from the timeline, so it gets its own place. */
function browseScreen(v) {
  const sc = chrome(v, {backLabel: 'Today', title: 'Browse'});
  const h = document.createElement('div'); h.className = 'large'; h.textContent = 'Browse';
  sc.append(h);
  const now = new Date();
  const up = DATA.events.filter(e => e.start >= day0(now));
  const bySport = {};
  up.forEach(e => (bySport[e.sport] ||= []).push(e));
  Object.keys(bySport).sort().forEach((sport, i, arr) => {
    sc.append(utilRow(sport, () => mount(w => competitions(w, sport, bySport[sport]), true),
                      bySport[sport].length));
    if (i < arr.length - 1) sc.append(sep());
  });
}

function competitions(v, sport, events) {
  const sc = chrome(v, {backLabel: 'Browse', title: sport});
  const h = document.createElement('div'); h.className = 'large'; h.textContent = sport;
  sc.append(h);
  const by = {};
  events.forEach(e => (by[e.competition] ||= []).push(e));
  const names = Object.keys(by).sort((a,b) =>
    Math.min(...by[a].map(e => e.start)) - Math.min(...by[b].map(e => e.start)));
  names.forEach((name, i) => {
    const next = new Date(Math.min(...by[name].map(e => +e.start)));
    sc.append(utilRow(name, () => mount(w => fixtures(w, name, by[name], sport), true),
                      by[name].length,
                      shortDate(next)));
    if (i < names.length - 1) sc.append(sep());
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
