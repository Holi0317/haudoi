// @ts-check

import { defineConfig } from "eslint/config";
import js from "@eslint/js";
import globals from "globals";
import tseslint from "typescript-eslint";
import pluginVue from "eslint-plugin-vue";
import eslintConfigPrettier from "eslint-config-prettier";
import stylistic from "@stylistic/eslint-plugin";
import importX, { createNodeResolver } from "eslint-plugin-import-x";
import { createTypeScriptImportResolver } from "eslint-import-resolver-typescript";

export default defineConfig(
  {
    name: "Files and globbing",
    files: ["**/*.{js,jsx,mjs,ts,tsx,vue}"],
  },
  {
    name: "Global ignores",
    ignores: [
      "packages/worker/dist/",
      "node_modules/",
      "packages/worker/.wrangler/",
      "packages/worker/worker-configuration.d.ts",
      "packages/worker/src/client/build/",
      "packages/extension/.wxt/",
      "packages/extension/.output/",
    ],
  },

  {
    name: "Base configurations",
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommended,
      ...pluginVue.configs["flat/recommended"],
    ],
    files: ["**/*.{js,jsx,mjs,ts,tsx,vue}"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parserOptions: {
        parser: tseslint.parser,
      },
    },
  },

  {
    name: "Language options (worker)",
    files: ["packages/worker/**/*.{js,jsx,mjs,ts,tsx}"],
    languageOptions: {
      globals: {
        ...globals.worker,
      },
    },
  },
  {
    name: "Language options (extension)",
    files: ["packages/extension/**/*.{js,jsx,mjs,ts,tsx,vue}"],
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.webextensions,
      },
    },
  },

  {
    name: "import-x/typescript",
    plugins: {
      "import-x": importX,
    },
    settings: {
      "import-x/extensions": [
        ".ts",
        ".tsx",
        ".cts",
        ".mts",
        ".js",
        ".jsx",
        ".cjs",
        ".mjs",
      ],
      "import-x/external-module-folders": [
        "node_modules",
        "node_modules/@types",
      ],
      "import-x/parsers": {
        "@typescript-eslint/parser": [".ts", ".tsx", ".cts", ".mts"],
      },
      "import-x/resolver-next": [
        createTypeScriptImportResolver(),
        createNodeResolver(),
      ],
    },
  },

  eslintConfigPrettier,

  {
    name: "Styling rules",
    plugins: {
      "@stylistic": stylistic,
    },
    rules: {
      curly: ["error", "all"],
      "@stylistic/spaced-comment": ["error", "always", { markers: ["/"] }],
      "@typescript-eslint/array-type": ["error", { default: "array-simple" }],
    },
  },

  {
    name: "Strict rules",
    rules: {
      eqeqeq: ["error", "smart"],
      "@typescript-eslint/ban-ts-comment": [
        "error",
        {
          "ts-expect-error": "allow-with-description",
          "ts-ignore": false,
          "ts-nocheck": false,
          "ts-check": false,
          minimumDescriptionLength: 3,
        },
      ],
      "@typescript-eslint/no-unused-vars": [
        "error",
        { argsIgnorePattern: "^_.+", ignoreRestSiblings: true },
      ],
      "import-x/no-duplicates": "error",
      "@typescript-eslint/consistent-type-imports": "error",
      "@typescript-eslint/no-import-type-side-effects": "error",
      "import-x/no-nodejs-modules": "warn",
      "import-x/order": [
        "error",
        {
          groups: [
            ["builtin", "external", "parent", "sibling", "index", "type"],
          ],
        },
      ],
    },
  },
);
