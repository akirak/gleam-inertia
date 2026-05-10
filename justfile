[parallel]
dev: gleam_dev pnpm_dev

pnpm_dev:
    pnpm dev

gleam_dev:
    DEMO_WEB_ENV=development gleam run -m main
