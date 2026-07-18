<script setup lang="ts">
import { computed, watch } from "vue";
import DeleteLinkButton from "./DeleteLinkButton.vue";
import SettingCog from "./SettingCog.vue";
import { useCurrentTab } from "@/composables/queries/tab";
import { useSaveMutation } from "@/composables/queries/server";

const tabQuery = useCurrentTab();
const mutation = useSaveMutation();

const validUrl = computed(() => {
  const tab = tabQuery.data.value;
  if (tab == null) {
    return false;
  }

  try {
    const url = new URL(tab.url || "");
    return url.protocol === "http:" || url.protocol === "https:";
  } catch {
    return false;
  }
});

watch(
  [validUrl],
  () => {
    if (validUrl.value) {
      const tab = tabQuery.data.value;
      mutation.mutate({
        url: tab!.url!,
        title: tab!.title,
      });
    }
  },
  { immediate: true },
);

const retry = () => {
  const tab = tabQuery.data.value;
  if (tab == null) {
    return;
  }

  if (!validUrl.value) {
    return;
  }

  mutation.mutate({
    url: tab.url!,
    title: tab.title,
  });
};
</script>

<template>
  <SettingCog />

  <div v-if="tabQuery.isLoading.value">Loading...</div>

  <div v-else-if="mutation.error.value != null">
    <p>Error saving link: {{ mutation.error.value.message }}</p>
    <p>Maybe the server is not reachable or you are not authenticated.</p>

    <button class="primary" @click="retry">Retry</button>
    <router-link to="/setup">
      <button class="secondary">Setup Server</button>
    </router-link>
  </div>

  <div v-else-if="mutation.isPending.value">Saving link...</div>

  <div v-else-if="mutation.isSuccess.value && mutation.data.value != null">
    <p>
      <i class="pi pi-check text-green-500"></i>
      Link saved successfully!
    </p>

    <DeleteLinkButton :id="mutation.data.value" />
  </div>

  <div v-else>
    <p>Cannot save this URL: {{ tabQuery.data.value?.url }}</p>
  </div>
</template>
