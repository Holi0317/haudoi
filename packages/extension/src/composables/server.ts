import { useMutation } from "@tanstack/vue-query";
import { computed } from "vue";
import { useConfigMutation, useConfigQuery } from "./queries/config";
import { createClient } from "@haudoi/worker/client";
import { useRouter } from "vue-router";
import { browser } from "#imports";

export function useServerSetup() {
  const config = useConfigMutation();
  const { login } = useServerLogin();
  const router = useRouter();

  return useMutation({
    async mutationFn(url: string) {
      const parsedUrl = new URL(url);
      const normalizedUrl = parsedUrl.origin;

      console.info("Requesting permission for origin:", normalizedUrl);

      // Request permission for this origin. This will show up in browser permission prompt.
      // Seems if we already have the permission, this promise will resolve immediately without prompting again.
      const granted = await browser.permissions.request({
        origins: [`${normalizedUrl}/*`],
        // Not sure if we need cookies here. We just want to make fetch to include session cookies in requests.
        permissions: ["cookies"],
      });

      if (!granted) {
        console.warn("Permission denied for origin:", normalizedUrl);
        throw new Error("Permission denied for this server");
      }

      // Check if the server is valid, reachable and has been authenticated before saving
      console.info(
        "Permission granted for origin. Validating server:",
        normalizedUrl,
      );

      const client = createClient(normalizedUrl, {
        init: { credentials: "include" },
      });

      const response = await client.api.$get();

      if (!response.ok) {
        throw new Error(
          `Server validation failed with status ${response.status}: ${await response.text()}`,
        );
      }

      const info = await response.json();

      if (info.name !== "haudoi") {
        throw new Error("The server is not a valid haudoi server");
      }

      await config.mutateAsync({ serverUrl: normalizedUrl });

      if (info.session == null) {
        console.info("User is not authenticated. Opening login page.");
        login();
      } else {
        console.info("User is already authenticated. Redirecting to main app.");
        router.push("/");
      }
    },
  });
}

/**
 * Get hono client for configured server URL.
 *
 * If server URL is not configured, computes to null.
 *
 * This isn't using tanstack query. For whatever reason, if we `select` a client from
 * a query, the client ends up being broken with incorrect call paths and generating wrong request URLs.
 * Probably something to do with Proxy and structured sharing, or vue's reactivity system.
 */
export function useServerClient() {
  const { data } = useConfigQuery();

  return computed(() => {
    const url = data.value?.serverUrl;
    if (!url) {
      return null;
    }

    return createClient(url, {
      init: { credentials: "include" },
    });
  });
}

export function useServerLogin() {
  const client = useServerClient();

  const login = () => {
    if (client.value == null) {
      throw new Error("Server URL is not configured");
    }

    const loginUrl = client.value.auth.google.login.$url();

    browser.tabs.create({
      url: loginUrl.toString(),
    });

    // Close popup - user will come back after login
    window.close();
  };

  return {
    login,
  };
}
