[parallel]
dev: gleam_dev pnpm_dev

pnpm_dev:
    pnpm dev

gleam_dev:
    DEMO_WEB_ENV=development gleam run -m demo_web

install:
    gleam deps download
    (cd packages/inertia && gleam deps download)
    pnpm install
