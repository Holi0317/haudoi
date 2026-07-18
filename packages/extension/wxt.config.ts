import ui from "@nuxt/ui/vite";
import { defineConfig } from "wxt";

// See https://wxt.dev/api/config.html
export default defineConfig({
  modules: ["@wxt-dev/module-vue"],
  srcDir: "src",
  imports: false,
  vite: () => ({
    plugins: [
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
