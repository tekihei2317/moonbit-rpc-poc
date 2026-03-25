import { defineConfig } from "vite";
import { moonbit } from "vite-plugin-moonbit";

export default defineConfig(({ command }) => ({
  plugins: [
    {
      name: "moonbit-full-reload",
      configureServer(server) {
        const watchTargets = [
          "main.mbt",
          "app/**/*.mbt",
          "rpc/**/*.mbt",
          "../shared/**/*.mbt",
        ];
        let reloadTimer: ReturnType<typeof setTimeout> | undefined;

        server.watcher.add(watchTargets);
        server.watcher.on("change", file => {
          if (!file.endsWith(".mbt")) {
            return;
          }
          if (reloadTimer) {
            clearTimeout(reloadTimer);
          }
          reloadTimer = setTimeout(() => {
            server.ws.send({ type: "full-reload" });
          }, 150);
        });
      },
    },
    moonbit({
      target: "js",
      mode: command === "serve" ? "debug" : "release",
      watch: false,
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
