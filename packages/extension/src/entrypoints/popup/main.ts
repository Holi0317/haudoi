import { createApp } from "vue";
import { VueQueryPlugin } from "@tanstack/vue-query";
import ui from "@nuxt/ui/vue-plugin";
import App from "../../components/App.vue";
import { router } from "../../router";
import "./style.css";

const app = createApp(App);

app.use(VueQueryPlugin);
app.use(ui);
app.use(router);

app.mount("#app");
