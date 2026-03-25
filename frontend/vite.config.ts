import { defineConfig } from "vite";
import { moonbit } from "vite-plugin-moonbit";

export default defineConfig(({ command }) => ({
  plugins: [
    moonbit({
      target: "js",
      mode: command === "serve" ? "debug" : "release",
      watch: command === "serve",
    }),
  ],
  server: {
    proxy: {
      "/api": {
        target: "http://127.0.0.1:4000",
        changeOrigin: true,
      },
    },
  },
}));
