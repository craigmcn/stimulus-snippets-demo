# Stimulus Snippets Demo

A minimal Rails app demonstrating each Stimulus controller from
[stimulus-snippets](https://github.com/craigmcn/stimulus-snippets) on a real,
working page.

No database, no JS bundler — Rails 8 + importmap + Propshaft. Each controller
file in `app/javascript/controllers/` is a straight copy from the source repo;
the demo markup in `app/views/demos/*.html.erb` matches each component's
README usage example.

## Run

```sh
bin/rails server -p 3140
```

Visit `http://localhost:3140`.

## Adding a demo for a new controller

1. Copy `[name]_controller.js` from `stimulus-snippets/components/[name]/` into
   `app/javascript/controllers/`.
2. Add an explicit `import`/`application.register` pair to
   `app/javascript/controllers/index.js` (bare specifier `"controllers/[name]_controller"`
   — relative specifiers like `"./[name]_controller"` bypass the importmap's
   digested URLs and 404).
3. Add `{ id: "[name]", title: "[Title]" }` to `DemosController::DEMOS`.
4. Add `app/views/demos/[name].html.erb` with markup from the component's README.
