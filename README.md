# Sites

This repo contains static sites in `static/` and Astro-based sites in `astro/`.

## Astro Development

```sh
./dev.sh alive_app
```

## Astro Build

```sh
./build.sh alive_app
```

The build output is written to `astro/<site>/dist`.

## Cloudflare Pages

Use these settings for each Astro-based site, replacing `alive_app` with the site directory you are deploying:

| Setting | Value |
| --- | --- |
| Framework preset | Astro |
| Root directory | `astro/alive_app` |
| Build command | `pnpm pages:build` |
| Build output directory | `dist` |
| Node.js version | `26` |

For a custom domain, attach the matching production domain in Cloudflare Pages after the first deploy.
