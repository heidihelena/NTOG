#!/usr/bin/env python3
"""Single source of truth for the NTOG primary navbar.

The same navbar lives in every page. To change the menu, edit the CANON
string below and run, from the repo root:

    python3 build-nav.py

It replaces the <nav class="navbar ...>...</nav> block in every page that
has one (idempotent / re-runnable). Active-state highlighting and the red
2027 theme are handled at runtime (js/scripts.js + body.ntog2027), so the
stamped markup is byte-identical on every page.
"""
import re, glob, sys

CANON = '''  <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
    <div class="container">
      <a class="navbar-brand d-flex align-items-center gap-2" href="/">
        <img src="/ntog-logo.svg" alt="" width="34" height="34" aria-hidden="true">
        <span>NTOG</span>
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item dropdown">
            <a class="nav-link" href="/about.html">About Us</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" aria-label="About Us submenu"></button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="/about.html">About Us</a></li>
              <li><a class="dropdown-item" href="/mission.html">Mission</a></li>
              <li><a class="dropdown-item" href="/history.html">History</a></li>
              <li><a class="dropdown-item" href="/steering-committee.html">Steering Committee</a></li>
            </ul>
          </li>

          <li class="nav-item dropdown">
            <a class="nav-link" href="/research.html">Research</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Research submenu"></button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="/research.html">Research Overview</a></li>
              <li><a class="dropdown-item" href="/ongoing-projects.html">Ongoing Projects</a></li>
              <li><a class="dropdown-item" href="/publications.html">Publications</a></li>
              <li><a class="dropdown-item" href="/collaborations.html">Research Collaborations</a></li>
            </ul>
          </li>

          <li class="nav-item dropdown">
            <a class="nav-link" href="/upcoming-events.html">Events</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Events submenu"></button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="/ntog2027/">Nordic Lung Cancer Symposium 2027</a></li>
              <li><a class="dropdown-item" href="/ntog2027/programme.html">Programme</a></li>
              <li><a class="dropdown-item" href="/ntog2027/call-for-abstracts.html">Call for Abstracts</a></li>
              <li><a class="dropdown-item" href="/ntog2027/sponsors.html">Sponsorship &amp; Exhibition</a></li>
              <li><a class="dropdown-item" href="/upcoming-events.html">Upcoming Events</a></li>
              <li><a class="dropdown-item" href="/past-events.html">Past Events</a></li>
            </ul>
          </li>

          <li class="nav-item dropdown">
            <a class="nav-link" href="/guidelines.html">Clinical Resources</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Clinical Resources submenu"></button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="/guidelines.html">Clinical Guidelines</a></li>
              <li><a class="dropdown-item" href="/guidelines/nodule-management.html">Nodule Management</a></li>
              <li><a class="dropdown-item" href="/protocols.html">Protocols</a></li>
            </ul>
          </li>

          <li class="nav-item dropdown">
            <a class="nav-link" href="/tools.html">Tools</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" data-bs-display="static" aria-expanded="false" aria-label="Tools submenu"></button>
            <div class="dropdown-menu dropdown-menu-end mega-menu">
              <div class="mega-grid">
                <div class="mega-col">
                  <h6 class="mega-head">MDT &amp; pathway</h6>
                  <a class="dropdown-item" href="/mdt-structured-v3_1.html">MDT structured form (v3.1)</a>
                  <a class="dropdown-item" href="/mdt-structured-mini.html">MDT structured (mini)</a>
                  <a class="dropdown-item" href="/mdt.html">MDT free-text form</a>
                </div>
                <div class="mega-col">
                  <h6 class="mega-head">Screening &amp; nodule risk</h6>
                  <a class="dropdown-item" href="/ntog_lungrisk_static_tools_v3.html">LungRisk hub</a>
                  <a class="dropdown-item" href="/nordic-nodule-pathway-sandbox-v3.html">Nodule pathway sandbox</a>
                  <a class="dropdown-item" href="/screening-risk-explained.html">Screening risk explained</a>
                </div>
                <div class="mega-col">
                  <h6 class="mega-head">Treatment value &amp; follow-up</h6>
                  <a class="dropdown-item" href="/decision-tools.html">Understanding treatment value</a>
                  <a class="dropdown-item" href="/decision-tool-v2.html">Treatment value discussion compass</a>
                  <a class="dropdown-item" href="/decision-tool-structured.html">Structured treatment value profile</a>
                  <a class="dropdown-item" href="/surveillance-yield-calculator.html">Surveillance yield (NNS)</a>
                </div>
                <div class="mega-col">
                  <h6 class="mega-head">Research builders</h6>
                  <a class="dropdown-item" href="/study-builder.html">Study design builder</a>
                  <a class="dropdown-item" href="/federated-dataset-builder.html">Federated dataset builder</a>
                </div>
              </div>
              <div class="mega-foot"><a href="/tools.html">View all tools &rarr;</a></div>
            </div>
          </li>

          <li class="nav-item dropdown">
            <a class="nav-link" href="/volunteer.html">Get Involved</a>
            <button type="button" class="nav-link nav-caret dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Get Involved submenu"></button>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="/expert.html">Expert Network</a></li>
              <li><a class="dropdown-item" href="/collaboration.html">Collaboration Opportunities</a></li>
              <li><a class="dropdown-item" href="/volunteer.html">Volunteer</a></li>
            </ul>
          </li>

          <li class="nav-item">
            <a class="nav-link" href="/news.html">Research News</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>'''

NAV_RE = re.compile(r'[ \t]*<nav class="navbar.*?</nav>', re.DOTALL)

def main():
    files = []
    for pat in ['*.html', 'ntog2027/*.html', 'research-news/*.html', 'guidelines/*.html']:
        files += glob.glob(pat)
    files = sorted(set(files))
    changed, skipped = [], []
    for f in files:
        src = open(f, encoding='utf-8').read()
        navs = NAV_RE.findall(src)
        if 'navbarNav' not in src or not navs:
            continue
        navbar_count = src.count('<nav class="navbar')
        if navbar_count > 1:
            print("!! %s: %d navbars — SKIPPED for safety" % (f, navbar_count))
            skipped.append(f)
            continue
        new = NAV_RE.sub(lambda m: CANON, src, count=1)
        if new != src:
            open(f, 'w', encoding='utf-8').write(new)
            changed.append(f)
    print(f"\nstamped {len(changed)} files; skipped {len(skipped)}")

if __name__ == '__main__':
    main()
