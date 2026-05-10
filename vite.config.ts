import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import inertia from "@inertiajs/vite";

export default defineConfig({
  resolve: {
    tsconfigPaths: true,
  },
  base: "/static/",
  plugins: [inertia({ ssr: false }), react()],
  build: {
    outDir: "priv/static",
    emptyOutDir: false,
    rollupOptions: {
      input: {
        app: "src-inertia/app.tsx",
      },
      output: {
        entryFileNames: "js/[name].js",
        chunkFileNames: "js/[name]-[hash].js",
        assetFileNames: "assets/[name].[ext]",
      },
    },
  },
});
