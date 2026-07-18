import { useQuery } from "@tanstack/vue-query";
import { browser } from "wxt/browser";

const keys = {
  root: () => [{ scope: "currentTab" }] as const,
};

export function useCurrentTab() {
  return useQuery({
    queryKey: keys.root(),
    async queryFn() {
      const tabs = await browser.tabs.query({
        active: true,
        currentWindow: true,
      });

      const tab = tabs[0];
      if (tab == null) {
        throw new Error("No active tab found");
      }

      return tab;
    },
  });
}
