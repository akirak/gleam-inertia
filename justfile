[parallel]
dev: gleam_dev pnpm_dev

pnpm_dev:
    pnpm --dir examples/mist dev

gleam_dev:
    cd examples/mist && DEMO_WEB_ENV=development gleam run -m demo_web

install:
    gleam deps download
    (cd examples/mist && gleam deps download)
    pnpm --dir examples/mist install
