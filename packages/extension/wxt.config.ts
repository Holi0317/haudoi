import { defineConfig } from "wxt";
import VueRouter from "vue-router/vite";
import vue from "@vitejs/plugin-vue";
import ui from "@nuxt/ui/vite";

// See https://wxt.dev/api/config.html
export default defineConfig({
  srcDir: "src",
  imports: false,
  vite: () => ({
    plugins: [
      VueRouter(),
      vue({
        features: {
          optionsAPI: false,
        },
      }),
      ui({
        autoImport: false,
        components: false,
        icon: {
          clientBundle: {
            scan: true,
          },
        },
      }),
    ],
  }),
  manifest: ({ manifestVersion }) => ({
    name: "Haudoi",
    description: "Save links to your Haudoi server",
    permissions: ["storage", "activeTab", "tabs"],

    // WXT cannot transpile optional_permissions for MV2/MV3 differences.
    // Ref: https://wxt.dev/guide/essentials/config/manifest#host-permissions
    // Ref: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/optional_permissions
    optional_permissions:
      manifestVersion === 2 ? ["*://*/*", "cookies"] : ["cookies"],
  }),
});
