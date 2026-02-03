# To run alive.app in development mode
SITE=alive.app pnpm dev

Run:
docker-compose -f docker-compose.dev.yml pull && docker-compose -f docker-compose.dev.yml up

# To build alive.app
SITE=alive.app pnpm build```
***Why this is better:*** This provides a clean, consistent, and scalable way to run commands for any website in your `websites/` directory without needing to `cd` into it. It relies on the `name` field in each site's `package.json`.

### Step 3: Clean Up the `alive.app` Website

The `alive.app` site has several configuration issues and a very confused `index.astro` file that mixes Astro and Next.js/React syntax.

#### A. Fix the Astro Config

**File to Edit:** `websites/alive.app/astro.config.ts`

**Correction:**
The `outDir` should be specific to the site being built.

```typescript
import { defineConfig } from 'astro/config'
import acmePreset from '../../packages/astro-preset/src/index'

export default defineConfig({
  site: 'https://alive.app',
  outDir: '../../dist/alive.app', // Correct output directory
  integrations: [acmePreset()],
})

# Base Static Site

pnpm dev to dev
pnpm build to build
then docker something...