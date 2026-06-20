// @ts-check
import { defineConfig } from 'astro/config';
import { searchForWorkspaceRoot } from 'vite'
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';

// https://astro.build/config
export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
    server: {
      fs: {
        allow: [searchForWorkspaceRoot(process.cwd()), '../_base']
      }
    }
  },

  integrations: [react()]
});
