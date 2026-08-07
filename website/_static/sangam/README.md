# Sangam 2027 — site source

Served at **<https://akriti.io/sangam/>**.

This page is plain hand-written HTML and CSS. It is **not** a Quarto document
and shares nothing with the rest of akriti.io — no stylesheet, no navigation,
no theme. Quarto has no say over it; `website/post-render.sh` rsyncs this
directory into `docs/sangam/` after every render.

```
website/_static/sangam/     ← edit here
  index.html
  assets/style.css          "Dawn over the range"
  assets/favicon.svg
  README.md                 excluded from the published output
        │  post-render.sh
        ▼
docs/  ← committed build output, served by GitHub Pages (main:/docs)
```

Preview locally with `python3 -m http.server` from this directory; there is no
build step. Running `quarto render` from `website/` is only needed to refresh
`docs/`.

## Conventions

These have each been broken at least once. Please keep them.

- **No name appears until that person has agreed.** Speakers, committee members
  and lecturers read *To be announced* until they accept. A public page listing
  someone who has not said yes is the fastest way to lose them. One commit had
  to walk four names back to placeholders; a later rewrite nearly deleted four
  confirmed ones.
- **Pull before editing.** Several people and sessions edit this file. At least
  one merge has already been needed, and one near-miss avoided only by rebasing.
- **Nothing internal goes in the source.** HTML comments ship to the browser.
  The publication checklist, funding, budget, speaker tiers and rejected
  alternatives all live in the private planning repo, never here.
- **`noindex` stays** until the meeting is announced. Two changes lift it:
  remove the `robots` meta tag from `index.html`, and drop `sangam` from
  `NOINDEX_PAGES` in `website/post-render.sh`. Don't do one without the other.
- **`tbc` chips mark anything unsettled.** Remove a chip only when the thing it
  marks is actually decided.

## The banner

An original SVG, drawn inline in `index.html` — five ranges in atmospheric
perspective, snow on the summits that earn it, mist in the valley folds. No
stock photography, so there is nothing to license or attribute, and it stays
crisp at any width.

To swap in a photograph later, replace the `<div class="banner-art">` block
with a background image on `.banner`. Nothing else depends on it.

## Why it lives here rather than in its own repo

GitHub Pages allows one custom domain per repository, and `akriti.io` is bound
to this one. A separate repo could only be served from a subdomain such as
`sangam.akriti.io`, which would need a DNS record. Keeping the source under
`_static/` is what lets the page stay standalone in character while sitting at
`akriti.io/sangam`.

## Planning notes

The organising plan — dates, budget, funding, speaker tiers, open questions —
is private, in `sushovan4/jobs` at `service/sangam-2027.md`. Its §15 tracks what
this page and that plan must agree on.
