import { createMemoryHistory, createRouter } from "vue-router";
import { routes, handleHotUpdate } from "vue-router/auto-routes";

export const router = createRouter({
  history: createMemoryHistory(),
  routes,
});

if (import.meta.hot) {
  handleHotUpdate(router);
}
