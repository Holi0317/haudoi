<script setup lang="ts">
import { watch } from "vue";
import { useRouter } from "vue-router";
import { useConfigQuery } from "@/composables/queries/config";

const router = useRouter();
const config = useConfigQuery();

watch(
  config.data,
  (data) => {
    if (data == null) {
      return;
    }

    if (data.serverUrl) {
      // Server is configured. Saving the URL.
      router.push("/save");
    } else {
      // Server is not configured. Opening setup page.
      router.push("/setup");
    }
  },
  { immediate: true },
);
</script>

<template>
  <div>Loading...</div>
</template>
