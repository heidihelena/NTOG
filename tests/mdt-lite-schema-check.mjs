// Checks that the lite MDT form stays a subset of the v3.1 research form.
// Run from the repo root:  node tests/mdt-lite-schema-check.mjs
import fs from 'fs';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const lite = require('../js/mdt-lite.js');

const liteHtml = fs.readFileSync('mdt-structured-lite.html', 'utf8');
const fullHtml = fs.readFileSync('mdt-structured-v3_1.html', 'utf8');
const dict = fs.readFileSync('js/mdt-lite-i18n.js', 'utf8') + fs.readFileSync('js/mdt-i18n.js', 'utf8');
const logic = fs.readFileSync('js/mdt-lite.js', 'utf8');

let failures = 0;
const fail = msg => { failures++; console.log('FAIL  ' + msg); };

// field name -> set of option codes
function fields(html) {
  const map = new Map();
  const add = (name, value) => { if (!map.has(name)) map.set(name, new Set()); if (value) map.get(name).add(value); };
  for (const m of html.matchAll(/<select[^>]*\bname="([^"]+)"[^>]*>([\s\S]*?)<\/select>/g)) {
    add(m[1]);
    for (const o of m[2].matchAll(/<option[^>]*\bvalue="([^"]*)"/g)) add(m[1], o[1]);
  }
  for (const m of html.matchAll(/<input[^>]*>/g)) {
    const name = /\bname="([^"]+)"/.exec(m[0]); if (!name) continue;
    const value = /type="checkbox"/.test(m[0]) ? /\bvalue="([^"]+)"/.exec(m[0]) : null;
    add(name[1], value && value[1]);
  }
  return map;
}
const liteFields = fields(liteHtml), fullFields = fields(fullHtml);

// 1. every lite key and code exists in v3.1, except the declared lite-only keys
for (const [name, codes] of liteFields) {
  if (lite.LITE_ONLY_KEYS.includes(name)) continue;
  if (!fullFields.has(name)) { fail(`key "${name}" is not in v3.1 and not declared lite-only`); continue; }
  for (const c of codes) if (!fullFields.get(name).has(c)) fail(`code "${name}=${c}" is not in v3.1`);
}
// the surgery dropdown has no field name; its options must be v3.1 treatment codes
const surgery = /<select id="surgeryType">([\s\S]*?)<\/select>/.exec(liteHtml);
if (!surgery) fail('surgery dropdown not found');
else for (const o of surgery[1].matchAll(/value="([^"]+)"/g)) if (!fullFields.get('treatments').has(o[1])) fail(`surgery code "${o[1]}" is not a v3.1 treatment`);
for (const k of lite.LITE_ONLY_KEYS) if (!liteFields.has(k)) fail(`lite-only key "${k}" is declared but not in the form`);

// 2. driver mapping points at real v3.1 gene keys and codes, and covers the select
for (const [code, [key, value]] of Object.entries(lite.DRIVER_MAP)) {
  if (!fullFields.get(key)?.has(value)) fail(`driver map ${code} -> ${key}=${value} is not in v3.1`);
  if (!liteFields.get('driverAlteration').has(code)) fail(`driver map code ${code} is not an option in the form`);
}

// 3. T descriptors carry the same T category as v3.1
const tOf = html => new Map([...html.matchAll(/name="tFeatures" value="([^"]+)" data-t="([^"]+)"/g)].map(m => [m[1], m[2]]));
const liteT = tOf(liteHtml), fullT = tOf(fullHtml);
if (liteT.size !== fullT.size) fail(`tFeatures count differs: lite ${liteT.size}, v3.1 ${fullT.size}`);
for (const [k, t] of fullT) if (liteT.get(k) !== t) fail(`tFeatures ${k}: lite ${liteT.get(k)}, v3.1 ${t}`);

// 4. staging logic gives the same result as the v3.1 functions
const grab = (name) => { const m = new RegExp(`function ${name}\\([^)]*\\) \\{[\\s\\S]*?\\n\\}`).exec(fullHtml); if (!m) throw new Error('v3.1 function not found: ' + name); return m[0]; };
const fullStage = new Function(grab('calcStageGroup') + '; return calcStageGroup;')();
const Ts = ['Tx', 'T0', 'Tis', 'T1mi', 'T1a', 'T1b', 'T1c', 'T2a', 'T2b', 'T3', 'T4'];
const Ns = ['NX', 'N0', 'N1', 'N2a', 'N2b', 'N3'];
const Ms = ['Mx', 'M0', 'M1a', 'M1b', 'M1c1', 'M1c2', ''];
let stageCases = 0;
for (const t of Ts) for (const n of Ns) for (const m of Ms) {
  stageCases++;
  if (lite.calcStageGroup(t, n, m) !== fullStage(t, n, m)) fail(`stage ${t}${n}${m}: lite ${lite.calcStageGroup(t, n, m)}, v3.1 ${fullStage(t, n, m)}`);
}
const tRank = { Tx: 0, T0: 1, Tis: 2, T1mi: 3, T1a: 4, T1b: 5, T1c: 6, T2a: 7, T2b: 8, T3: 9, T4: 10 };
function fullTFor(size, special, features, nodule) {
  const env = {
    valueOf: n => ({ tSpecial: special, separateNodulePattern: nodule }[n] || ''),
    numValue: () => size,
    checkedValues: () => features,
    formEl: () => ({ querySelector: sel => { const v = /value="([^"]+)"/.exec(sel)[1]; return { dataset: { t: fullT.get(v) } }; } }),
    maxCategory: (c, x, r) => (r[x] || 0) > (r[c] || 0) ? x : c,
    tRank
  };
  return new Function(...Object.keys(env), grab('calcTCategory') + '; return calcTCategory();')(...Object.values(env));
}
const sizes = [null, 0, 5, 10, 10.1, 20, 20.5, 30, 31, 40, 41, 50, 51, 70, 70.1, 120];
const specials = ['', 'Tx', 'T0', 'Tis', 'T1mi'];
const featureSets = [[], ['visceral_pleura'], ['pericardium'], ['trachea_or_carina'], ['visceral_pleura', 'heart_or_great_vessels']];
const nodules = ['none', 'same_lobe', 'different_ipsilateral_lobe', 'contralateral_lobe', 'synchronous_primary_suspected', 'multifocal_ground_glass', 'diffuse_pneumonic_type'];
let tCases = 0;
for (const s of sizes) for (const sp of specials) for (const fs_ of featureSets) for (const nd of nodules) {
  tCases++;
  const a = lite.calcTCategory(s, sp, fs_.map(x => liteT.get(x)), nd), b = fullTFor(s, sp, fs_, nd);
  if (a !== b) fail(`T for size=${s} special=${sp} features=${fs_} nodule=${nd}: lite ${a}, v3.1 ${b}`);
}

// 5. every string key used by the page or the logic is in the dictionary
const used = new Set([...liteHtml.matchAll(/data-i18n="([^"]+)"/g)].map(m => m[1]));
for (const m of logic.matchAll(/(?:L|add|pair)\("(lt\.[a-zA-Z0-9_.]+)"/g)) if (!m[1].endsWith('.')) used.add(m[1]);
for (const r of lite.REQUIRED) used.add('lt.req.' + r);
for (const k of used) if (!dict.includes(JSON.stringify(k) + ':')) fail(`string key "${k}" is not in the dictionary`);

console.log(`${liteFields.size} lite fields, ${lite.LITE_ONLY_KEYS.length} lite-only; ${stageCases} stage and ${tCases} T cases compared with v3.1; ${used.size} string keys.`);
console.log(failures ? `${failures} FAILED` : 'All checks passed');
process.exit(failures ? 1 : 0);
