/*
 * NTOG lung cancer MDT — structured (lite).
 *
 * Field names and option codes are a subset of mdt-structured-v3_1.html so a
 * lite export can be read next to a v3.1 export. The two keys in DERIVED_IN_V31
 * are entered directly here and derived from detailed fields in v3.1. T is calculated from size and descriptors with the same
 * rules as v3.1; N is entered directly (nCategorySource: "direct_entry").
 *
 * The staging functions are pure and exported for Node so they can be
 * compared with v3.1 (tests/mdt-lite-schema-check.mjs).
 */
(function (global) {
  "use strict";

  var SCHEMA_VERSION = "ntog_lung_mdt_structured_lite_v1";
  var PARENT_SCHEMA = "ntog_lung_mdt_structured_v3_1";
  var DERIVED_IN_V31 = ["nCategory", "driverAlteration"];

  var T_RANK = { Tx: 0, T0: 1, Tis: 2, T1mi: 3, T1a: 4, T1b: 5, T1c: 6, T2a: 7, T2b: 8, T3: 9, T4: 10 };
  var M_RANK = { Mx: 0, M0: 1, M1a: 2, M1b: 3, M1c1: 4, M1c2: 5 };

  // driverAlteration (lite) -> per-gene status key and code in v3.1
  var DRIVER_MAP = {
    egfr_exon_19_del: ["egfrStatus", "exon_19_del"],
    egfr_l858r: ["egfrStatus", "l858r"],
    egfr_exon_20_insertion: ["egfrStatus", "exon_20_insertion"],
    egfr_other_positive: ["egfrStatus", "other_positive"],
    alk_positive: ["alkStatus", "positive"],
    ros1_positive: ["ros1Status", "positive"],
    braf_v600e: ["brafStatus", "v600e"],
    kras_g12c: ["krasStatus", "g12c"],
    met_exon_14_skipping: ["metStatus", "exon_14_skipping"],
    ret_positive: ["retStatus", "positive"],
    ntrk_positive: ["ntrkStatus", "positive"]
  };

  var REQUIRED = [
    "meetingDate", "mdtPurpose", "age", "sex", "ecog", "smokingStatus", "histology",
    "tnmSizeDescriptor", "nCategory", "metastasisPattern",
    "mdtDecisionStatus", "treatmentIntent", "decisionRationale", "attendingSpecialist", "nextActionDue"
  ];

  var SURGERY = ["surgery_lobectomy", "surgery_segmentectomy", "surgery_wedge", "surgery_pneumonectomy"];
  var RADICAL_LOCAL = SURGERY.concat(["definitive_chemoradiotherapy", "sabr_sbrt"]);

  // ---------- pure staging logic (same rules as v3.1) ----------

  function maxCategory(current, candidate, rank) {
    return (rank[candidate] || 0) > (rank[current] || 0) ? candidate : current;
  }

  // sizeMm: number or null; special: "", Tx, T0, Tis, T1mi; featureTs: e.g. ["T2a","T4"]
  function calcTCategory(sizeMm, special, featureTs, nodule) {
    var t = special || "Tx";
    if (!special && sizeMm !== null && sizeMm > 0) {
      if (sizeMm <= 10) t = "T1a";
      else if (sizeMm <= 20) t = "T1b";
      else if (sizeMm <= 30) t = "T1c";
      else if (sizeMm <= 40) t = "T2a";
      else if (sizeMm <= 50) t = "T2b";
      else if (sizeMm <= 70) t = "T3";
      else t = "T4";
    }
    (featureTs || []).forEach(function (ft) { t = maxCategory(t, ft, T_RANK); });
    if (nodule === "same_lobe") t = maxCategory(t, "T3", T_RANK);
    if (nodule === "different_ipsilateral_lobe") t = maxCategory(t, "T4", T_RANK);
    if (nodule === "diffuse_pneumonic_type") t = maxCategory(t, "T4", T_RANK);
    return t;
  }

  function calcMCategory(selected, nodule) {
    var m = selected || "Mx";
    if (nodule === "contralateral_lobe") m = maxCategory(m, "M1a", M_RANK);
    return m;
  }

  function calcStageGroup(t, n, m) {
    if (m === "M1c1" || m === "M1c2") return "IVB";
    if (m === "M1a" || m === "M1b") return "IVA";
    if (m === "Mx") return "Staging incomplete";
    if (m !== "M0") return "Not assigned";
    if (t === "Tis" && n === "N0") return "0";
    if ((t === "Tx" || t === "T0") && n === "N0") return "Occult carcinoma";
    if (t === "Tx" || t === "T0" || n === "NX") return "Manual review";
    var rowKey = (t === "T1mi") ? "T1a" : t;
    var table = {
      T1a: { N0: "IA1", N1: "IIA", N2a: "IIB", N2b: "IIIA", N3: "IIIB" },
      T1b: { N0: "IA2", N1: "IIA", N2a: "IIB", N2b: "IIIA", N3: "IIIB" },
      T1c: { N0: "IA3", N1: "IIA", N2a: "IIB", N2b: "IIIA", N3: "IIIB" },
      T2a: { N0: "IB", N1: "IIB", N2a: "IIIA", N2b: "IIIB", N3: "IIIB" },
      T2b: { N0: "IIA", N1: "IIB", N2a: "IIIA", N2b: "IIIB", N3: "IIIB" },
      T3: { N0: "IIB", N1: "IIIA", N2a: "IIIA", N2b: "IIIB", N3: "IIIC" },
      T4: { N0: "IIIA", N1: "IIIA", N2a: "IIIB", N2b: "IIIB", N3: "IIIC" }
    };
    return (table[rowKey] && table[rowKey][n]) || "Not assigned";
  }

  var api = {
    SCHEMA_VERSION: SCHEMA_VERSION, PARENT_SCHEMA: PARENT_SCHEMA, DERIVED_IN_V31: DERIVED_IN_V31,
    DRIVER_MAP: DRIVER_MAP, REQUIRED: REQUIRED,
    calcTCategory: calcTCategory, calcMCategory: calcMCategory, calcStageGroup: calcStageGroup
  };
  if (typeof module !== "undefined" && module.exports) { module.exports = api; }
  global.MDTLite = api;
  if (typeof document === "undefined") return;

  // ---------- page ----------

  // Languages this form is translated into. Other languages saved by the
  // sibling MDT forms fall back to English here.
  var LITE_LANGS = ["en", "fi", "sv", "no", "da"];
  var LANG = "en";
  var I18N = global.MDTI18N;
  function L(key) { return I18N ? I18N.t(key, LANG) : key; }

  var f = document.getElementById("mdtForm");
  var latest = { derived: {}, warnings: [] };

  function el(name) { return f.elements[name]; }
  function v(name) { var e = el(name); return e && typeof e.value === "string" ? e.value.trim() : ""; }
  function num(name) { var n = parseFloat(v(name)); return isFinite(n) ? n : null; }
  function checked(name) {
    return Array.prototype.slice.call(f.querySelectorAll('input[name="' + name + '"]:checked'));
  }
  function checkedValues(name) { return checked(name).map(function (c) { return c.value; }); }
  function checkedLabels(name) {
    return checked(name).map(function (c) { return c.parentNode.textContent.trim(); });
  }
  function selLabel(name) {
    var e = el(name);
    if (!e || !e.value) return "";
    return e.options[e.selectedIndex].textContent.trim();
  }
  // surgery is one dropdown in the form; it is exported as a v3.1 "treatments" code
  function treatmentValues() {
    var s = document.getElementById("surgeryType").value;
    return (s ? [s] : []).concat(checkedValues("treatments"));
  }
  function treatmentLabels() {
    var s = document.getElementById("surgeryType");
    return (s.value ? [s.options[s.selectedIndex].textContent.trim()] : []).concat(checkedLabels("treatments"));
  }
  // short wording for the report; falls back to the option label
  function short(name) {
    var val = v(name);
    if (!val) return "";
    var key = "lt.s." + name + "." + val, text = L(key);
    return text === key ? selLabel(name) : text;
  }
  function any(list, values) { return list.some(function (x) { return values.indexOf(x) >= 0; }); }

  function show(id, visible, namesToClear) {
    var wrap = document.getElementById(id);
    if (wrap.hidden === !visible) return;
    wrap.hidden = !visible;
    if (!visible) (namesToClear || []).forEach(function (n) {
      var boxes = f.querySelectorAll('input[type="checkbox"][name="' + n + '"]');
      if (boxes.length) Array.prototype.forEach.call(boxes, function (b) { b.checked = false; });
      else el(n).value = "";
    });
  }

  function requiredFilled(name) {
    if (name === "tnmSizeDescriptor") { var s = num("tumourTSizeMm"); return Boolean((s !== null && s > 0) || v("tSpecial")); }
    if (name === "age") { var a = num("age"); return a !== null && a > 0; }
    return Boolean(v(name));
  }

  function validate(t, n, m, stage) {
    var w = [], flagged = [];
    function add(key, fields) { w.push(L(key)); (fields || []).forEach(function (x) { flagged.push(x); }); }

    var size = num("tumourTSizeMm");
    var treatments = treatmentValues();
    var invest = checkedValues("furtherInvestigations");
    var intent = v("treatmentIntent");
    var status = v("mdtDecisionStatus");
    var hasSurgery = any(treatments, SURGERY);

    if (!v("tSpecial") && size === 0) add("lt.v.sizeZero", ["tumourTSizeMm"]);
    if (v("tSpecial") && size !== null && size > 0) add("lt.v.sizeAndSpecial", ["tumourTSizeMm", "tSpecial"]);
    if (v("metastasisPattern") && v("metastasisPattern") !== m) add("lt.v.mEscalated", ["metastasisPattern"]);
    if (intent === "curative" && (m === "M1c1" || m === "M1c2")) add("lt.v.curativeM1c", ["treatmentIntent", "metastasisPattern"]);
    if (hasSurgery && n === "N3") add("lt.v.surgeryN3", ["nCategory"]);
    if (hasSurgery && n === "N2b") add("lt.v.surgeryN2b", ["nCategory"]);
    if (hasSurgery && v("n2Bulky") === "yes") add("lt.v.surgeryBulkyN2", ["n2Bulky"]);
    if ((n === "N2a" || n === "N2b") && hasSurgery && !v("n2Bulky")) add("lt.v.bulkyMissing", ["n2Bulky"]);
    if (any(treatments, RADICAL_LOCAL) && (m === "Mx" || n === "NX")) add("lt.v.radicalStagingIncomplete", ["nCategory", "metastasisPattern"]);
    if (status === "decision_made" && treatments.length === 0) add("lt.v.decisionNoTreatment", ["mdtDecisionStatus"]);
    if (status === "conditional_on_tests" && invest.length === 0) add("lt.v.conditionalNoTests", ["mdtDecisionStatus"]);
    if (v("decisionRationale") === "other" && !v("decisionRationaleNote")) add("lt.v.otherNeedsNote", ["decisionRationaleNote"]);
    if (v("nextActionDue") && v("meetingDate") && v("nextActionDue") < v("meetingDate")) add("lt.v.dueBeforeMeeting", ["nextActionDue", "meetingDate"]);
    var drivers = checkedValues("driverAlteration");
    if (drivers.indexOf("none_detected") >= 0 && drivers.length > 1) add("lt.v.noneWithDriver");
    if (drivers.filter(function (x) { return x.indexOf("egfr_") === 0; }).length > 1) add("lt.v.twoEgfr");
    if (stage === "Manual review") add("lt.v.manualReview");

    Array.prototype.forEach.call(f.querySelectorAll(".field-warning"), function (x) { x.classList.remove("field-warning"); });
    flagged.forEach(function (name) { var e = el(name); if (e && e.classList) e.classList.add("field-warning"); });
    return w;
  }

  function update() {
    var nSel = v("nCategory");
    var treatments = treatmentValues();
    show("n2BulkyWrap", nSel === "N2a" || nSel === "N2b", ["n2Bulky"]);
    show("driverWrap", v("molecularStatus") === "complete", ["driverAlteration"]);
    show("lungFnWrap", any(treatments, RADICAL_LOCAL), ["fev1Percent", "dlcoPercent"]);

    var featureTs = checked("tFeatures").map(function (c) { return c.getAttribute("data-t"); });
    var nodule = v("separateNodulePattern");
    var t = calcTCategory(num("tumourTSizeMm"), v("tSpecial"), featureTs, nodule);
    var n = nSel || "NX";
    var m = calcMCategory(v("metastasisPattern"), nodule);
    show("oligoWrap", m === "M1a" || m === "M1b" || m === "M1c1", ["oligometastaticStatus"]);

    var stage = calcStageGroup(t, n, m);
    var missing = REQUIRED.filter(function (r) { return !requiredFilled(r); });
    var done = REQUIRED.length - missing.length;
    var started = Boolean(num("tumourTSizeMm") || v("tSpecial") || nSel || v("metastasisPattern"));
    var warnings = validate(t, n, m, stage);

    latest.derived = {
      cT: t, cN: n, cM: m, cTNM: "c" + t + n + m,
      stageGroup: stage,
      stageDetail: "IASLC / AJCC v9 support",
      completenessPercent: Math.round(100 * done / REQUIRED.length),
      missingRequiredFields: missing,
      validationWarnings: warnings
    };
    latest.warnings = warnings;

    document.getElementById("tnmDisplay").textContent = started ? latest.derived.cTNM : "—";
    document.getElementById("stageDisplay").textContent = started ? L("lt.stage." + stage) : "—";
    document.getElementById("completeDisplay").textContent = done + " / " + REQUIRED.length;

    var box = document.getElementById("warnings");
    box.textContent = "";
    if (warnings.length) {
      var head = document.createElement("span"); head.textContent = L("lt.msg.flags");
      var ul = document.createElement("ul");
      warnings.forEach(function (x) { var li = document.createElement("li"); li.textContent = x; ul.appendChild(li); });
      box.appendChild(head); box.appendChild(ul);
    }
  }

  function collectData() {
    update();
    var data = {};
    Array.prototype.forEach.call(f.querySelectorAll("input, select, textarea"), function (e) {
      if (!e.name) return;
      if (e.type === "checkbox") {
        if (!data[e.name]) data[e.name] = [];
        if (e.checked) data[e.name].push(e.value);
      } else {
        data[e.name] = e.value;
      }
    });
    data.treatments = treatmentValues();
    // one status per gene in v3.1: the first listed subtype of a gene is exported
    (data.driverAlteration || []).forEach(function (code) {
      var map = DRIVER_MAP[code];
      if (map && !data[map[0]]) data[map[0]] = map[1];
    });
    data.nCategorySource = "direct_entry";
    data.derived = latest.derived;
    data.exportedAt = new Date().toISOString();
    data.schemaVersion = SCHEMA_VERSION;
    data.parentSchema = PARENT_SCHEMA;
    return data;
  }

  function buildSummary() {
    update();
    var d = latest.derived;
    function join(parts, sep) { return parts.filter(Boolean).join(sep || ", "); }
    var nr = L("lt.sum.notRecorded");
    var drivers = checkedLabels("driverAlteration");
    var driverCodes = checkedValues("driverAlteration");
    var driverText = !drivers.length ? short("molecularStatus")
      : (driverCodes.length === 1 && driverCodes[0] === "none_detected") ? L("lt.sum.noDriver") : join(drivers);

    var lines = [join([L("lt.sum.title"), join([v("meetingDate"), v("hospitalCentre")])], " ")];
    if (v("mdtPurpose")) lines.push(L("lt.f.mdtPurpose") + ": " + selLabel("mdtPurpose"));
    lines.push("",
      L("lt.sum.patient") + ": " + (join([
        join([v("age") ? v("age") + " " + L("lt.sum.y") : "", short("sex")], " "),
        v("ecog") ? "ECOG " + v("ecog") : "",
        short("smokingStatus")
      ]) || nr),
      L("lt.sum.diagnosis") + ": " + join([
        join([selLabel("histology"), d.cTNM], " "),
        (/^(0|I)/.test(d.stageGroup) ? L("lt.sum.stage") + " " : "") + L("lt.stage." + d.stageGroup) + " (" + L("lt.sum.edition") + ")"
      ]));
    [
      join([v("tumourTSizeMm") ? v("tumourTSizeMm") + " mm" : "", short("n2Bulky"), short("oligometastaticStatus")]),
      join([v("pdl1Tps") ? "PD-L1 " + v("pdl1Tps") + " %" : "", driverText]),
      join([v("fev1Percent") ? "FEV1 " + v("fev1Percent") + " %" : "", v("dlcoPercent") ? "DLCO " + v("dlcoPercent") + " %" : ""])
    ].forEach(function (x) { if (x) lines.push("  " + x); });

    lines.push("",
      L("lt.sum.decision") + ": " + (join([short("treatmentIntent"), short("mdtDecisionStatus")]) || nr),
      L("lt.sum.plan") + ": " + (join(treatmentLabels()) || nr),
      L("lt.sum.before") + ": " + (join(checkedLabels("furtherInvestigations")) || L("lt.sum.none")),
      L("lt.sum.reason") + ": " + (join([selLabel("decisionRationale"), v("decisionRationaleNote")], " — ") || nr),
      L("lt.sum.responsible") + ": " + (selLabel("attendingSpecialist") || nr),
      L("lt.sum.nextBy") + ": " + (v("nextActionDue") || nr));
    if (v("patientPreferenceStatus")) lines.push(L("lt.f.patientPreferenceStatus") + ": " + selLabel("patientPreferenceStatus"));
    if (checked("participants").length) lines.push(L("lt.sum.present") + ": " + join(checkedLabels("participants")));

    if (d.missingRequiredFields.length) {
      lines.push("", L("lt.msg.missing") + " " + d.missingRequiredFields.map(function (k) { return L("lt.req." + k); }).join(", "));
    }
    if (latest.warnings.length) {
      lines.push("", L("lt.msg.flags"));
      latest.warnings.forEach(function (x) { lines.push("  - " + x); });
    }
    lines.push("", L("lt.sum.note"));
    return lines.join("\n");
  }

  function flatten(prefix, obj, out) {
    Object.keys(obj || {}).forEach(function (key) {
      var value = obj[key], newKey = prefix ? prefix + "." + key : key;
      if (Array.isArray(value)) out[newKey] = value.join(";");
      else if (value && typeof value === "object") flatten(newKey, value, out);
      else out[newKey] = (value === null || value === undefined) ? "" : value;
    });
  }
  function csvEscape(value) {
    var s = String(value === null || value === undefined ? "" : value);
    if (/^[=+\-@\t\r]/.test(s)) s = "'" + s;
    if (/[",\n;]/.test(s)) return '"' + s.replace(/"/g, '""') + '"';
    return s;
  }
  function download(text, type, filename) {
    var url = URL.createObjectURL(new Blob([text], { type: type }));
    var a = document.createElement("a");
    a.href = url; a.download = filename;
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }
  function toCsv(data) {
    var flat = {}; flatten("", data, flat);
    var keys = Object.keys(flat);
    return keys.join(",") + "\n" + keys.map(function (k) { return csvEscape(flat[k]); }).join(",") + "\n";
  }

  function showSummary() { document.getElementById("summary").textContent = buildSummary(); }
  function status(msg) { document.getElementById("status").textContent = msg; }

  document.getElementById("btnSummary").addEventListener("click", showSummary);
  document.getElementById("btnCopy").addEventListener("click", function () {
    showSummary();
    var text = document.getElementById("summary").textContent;
    if (navigator.clipboard && global.isSecureContext) {
      navigator.clipboard.writeText(text).then(function () { status(L("lt.msg.copied")); }, function () { status(L("lt.msg.copyFailed")); });
    } else {
      status(L("lt.msg.copyFailed"));
    }
  });
  document.getElementById("btnJson").addEventListener("click", function () {
    download(JSON.stringify(collectData(), null, 2), "application/json", "lung_mdt_lite_extract.json");
  });
  document.getElementById("btnCsv").addEventListener("click", function () {
    download(toCsv(collectData()), "text/csv", "lung_mdt_lite_extract.csv");
  });
  document.getElementById("btnPrint").addEventListener("click", function () { showSummary(); global.print(); });
  document.getElementById("btnClear").addEventListener("click", function () {
    f.reset();
    document.getElementById("summary").textContent = "";
    status("");
    setToday();
    update();
  });

  function setToday() {
    var now = new Date();
    var iso = now.getFullYear() + "-" + String(now.getMonth() + 1).padStart(2, "0") + "-" + String(now.getDate()).padStart(2, "0");
    el("meetingDate").value = iso;
  }

  f.addEventListener("input", update);
  f.addEventListener("change", update);
  global.addEventListener("mdt:langchange", function () {
    applyLangUi();
    update();
    if (document.getElementById("summary").textContent) showSummary();
  });

  // language: the shared engine translates every [data-i18n] element
  function applyLangUi() {
    document.documentElement.lang = LANG;
    document.getElementById("provisional").hidden = LANG === "en"; // English is the source text
  }
  var langSelect = document.getElementById("langSelect");
  if (I18N) {
    I18N.init(null);
    if (LITE_LANGS.indexOf(I18N.current) >= 0) LANG = I18N.current;
    LITE_LANGS.forEach(function (code) {
      var o = document.createElement("option");
      o.value = code; o.textContent = I18N.names[code] || code;
      langSelect.appendChild(o);
    });
    langSelect.value = LANG;
    langSelect.addEventListener("change", function () { LANG = langSelect.value; I18N.apply(LANG); });
  }
  applyLangUi();

  api.collectData = collectData;
  api.buildSummary = buildSummary;
  api.toCsv = toCsv;

  setToday();
  update();
})(typeof window !== "undefined" ? window : globalThis);
