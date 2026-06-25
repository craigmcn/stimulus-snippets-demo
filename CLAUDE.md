# stimulus-snippets-demo

A minimal Rails app demonstrating every Stimulus controller from
[stimulus-snippets](https://github.com/craigmcn/stimulus-snippets) on a real,
working page. Built to manually verify a controller's behavior in a real
browser before/after changes in the source repo — not a production app.

## What this is (and isn't)

- No database (`--skip-active-record`) — every controller here is stateless/client-side
- No JS bundler — Rails 8 importmap + Propshaft
- No test suite — this app exists to be looked at and clicked, not asserted against
- One route per component: `/demos/:id`, handled by `DemosController`

## Commands

```sh
bin/rails server -p 3140   # matches the port convention in ~/.claude active_projects.md
bin/rubocop                # Omakase Ruby style
bin/brakeman                # security static analysis
bin/bundler-audit            # gem vulnerability scan
bin/importmap audit          # JS dependency vulnerability scan
```

CI (`.github/workflows/ci.yml`, Rails 8 default) runs rubocop, brakeman,
bundler-audit, and importmap audit on push/PR to `main`.

## Project structure

```
app/javascript/controllers/   # straight copies of *_controller.js from stimulus-snippets/components/
app/controllers/demos_controller.rb   # DEMOS array drives routing, nav, and view lookup
app/views/demos/[id].html.erb         # one view per component, id matches the source repo's directory name
app/views/layouts/application.html.erb # sidebar nav built from DemosController::DEMOS
```

## Adding a demo for a new controller

1. Copy `[name]_controller.js` from `stimulus-snippets/components/[name]/` into
   `app/javascript/controllers/`.
2. Add an explicit `import`/`application.register` pair to
   `app/javascript/controllers/index.js` using a **bare specifier**:
   `import X from "controllers/[name]_controller"`. Relative specifiers
   (`"./[name]_controller"`) bypass the importmap's digested URLs and 404 —
   this bit twice already, see Key decisions below.
3. Add `{ id: "[name]", title: "[Title]" }` to `DemosController::DEMOS`.
4. Add `app/views/demos/[name].html.erb` with markup adapted from the
   component's README usage example.

## Key decisions

- **Relative imports break the importmap** — `bin/rails stimulus:manifest:update`
  regenerates `controllers/index.js` with relative imports
  (`"./accordion_controller"`). Propshaft serves controller files at
  digested, hashed filenames; a relative specifier resolves against the
  *importing module's URL* and skips importmap resolution entirely, so the
  browser requests the literal undigested path and gets a silent 404 — every
  controller fails to register with no visible error beyond a generic
  console message. Fixed by switching every import in `index.js` to the bare
  specifier form matching the importmap key (`"controllers/[name]_controller"`).
  Re-check this after running `stimulus:manifest:update` again.
- **No demo-box CSS framework, just enough custom CSS to make each control legible** —
  `app/assets/stylesheets/application.css` has one block per component family
  (accordion chevron, tablist underline, password-rules valid/invalid colors,
  etc.). Generic `.demo-box button` styling (background, color, border-radius)
  cascades into component-specific selectors of equal specificity; when adding
  a new component-specific button style, explicitly reset properties you don't
  want inherited (radius, color) rather than assuming an unset property means
  "default" — this is exactly how the tabs underline picked up an unwanted
  border-radius and the tab labels first rendered white-on-white.
- **Accordion chevron is CSS-only** — a `::after` pseudo-element border-corner
  rotated via `[aria-expanded="true"]`, no extra markup in the views.
- **Favicon matches the docs site's style** — same mustard rounded-square +
  monospace letter treatment as `stimulus-snippets/docs/public/favicon.svg`,
  with "D" (demo) instead of "S". `public/icon.png` is regenerated from
  `public/icon.svg` via `rsvg-convert` so the PNG fallback/apple-touch-icon
  stay visually consistent — re-run that conversion if the SVG changes.
- **`Intl.Collator({ numeric: true })` neutralizes string-vs-number sort type
  for purely numeric content** — table-sort's controller compares "string"
  type with a numeric-aware collator, so a column of pure digit strings
  sorts identically whether typed as `"string"` or `"number"`. A visible
  `data-table-sort-type` override demo only works with content that the
  browser's loose `Date.parse` misreads (e.g. `"3-15-24"`, a non-ISO,
  non-date batch code) — pure numbers can't show the distinction.
- **Sort affordance: text caption beats icon glyphs** — tried Unicode
  triangle-headed arrows (`⭡`/`⭣`) plus a muted `⭥` on unsorted columns to
  signal sortability; not obvious enough. Reverted to the simpler `▲`/`▼`
  (shown only once a column is actively sorted) and added a `<caption>`
  stating "Click a column header to sort by that column." instead — explicit
  text over icon-only affordance for a one-off demo page.
- **No Playwright install lives in this repo** (no JS test suite by design,
  see "What this is" above) — verification of JS-driven demos (table-sort's
  sort behavior, glyph states) is done with a throwaway
  `npm install playwright` in `/tmp` per session, screenshotted and diffed
  manually. Don't expect a persistent `node_modules` for this.

## Progress (as of 2026-06-25)

- **All 16 stimulus-snippets controllers from the previous batch have demos** — PRs #4–#7 added
  dependent-select, datetime-local, number-format, and table-sort.
- **table-sort demo (PR #7) has two tables**: a basic 3-column demo (string/
  number/date auto-detection) and an "advanced" table exercising
  `data-table-sort-type` (string override on date-shaped-but-not-dates batch
  codes) and `data-table-sort-value` (sorting displayed month names by a
  hidden numeric key). Both verified live via Playwright — actual row
  reordering and `aria-sort` state checked, not just rendered.
- **row-select demo (PR #8, merged)** — a 5-row table whose "Delete selected"
  button removes checked rows directly from the page (no DB to persist
  against). Verified live via Playwright: range select, delete, and a
  post-delete shift-click all behaved correctly with zero console errors.
- **unsaved-changes demo (PR #10, merged)** — a single-field form; the page
  text instructs clicking a sidebar link (a Turbo Drive visit) without
  saving first to trigger the confirmation prompt, and explains that the
  native `beforeunload` dialog can't be demonstrated from within the page
  itself (browsers only show it for a real, user-initiated navigation, not
  a script-triggered one). Verified live via Playwright with `page.on("dialog")`:
  declining the prompt keeps you on the page, accepting it navigates away,
  and clicking "Save" first clears the guard with no prompt at all — zero
  console errors in all three cases.
- **relative-time demo (this branch)** — four `<time>` elements covering a
  past timestamp, a future timestamp, the `numeric: "always"` override
  (forces "1 day ago" instead of "yesterday"), and a 5-second `interval`
  override for a live-feed-style re-render. All four datetimes are computed
  from `Time.now` in the view so the demo stays meaningful regardless of
  when it's loaded, rather than hardcoded ISO strings that would drift into
  nonsensical relative phrasing over time. Verified live via Playwright:
  text content, `aria-live="polite"`, and zero console errors checked across
  all four elements.
- **Next**: no outstanding TODOs — next work here only starts when a new
  controller is added to the source `stimulus-snippets` repo.
