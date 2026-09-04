<script setup lang="ts">
import UInput from "@nuxt/ui/components/Input.vue";
import UButton from "@nuxt/ui/components/Button.vue";
import UAlert from "@nuxt/ui/components/Alert.vue";
import UForm from "@nuxt/ui/components/Form.vue";
import UFormField from "@nuxt/ui/components/FormField.vue";
import * as z from "zod";
import type { FormSubmitEvent } from "@nuxt/ui";
import { reactive, watch } from "vue";
import { useServerSetup } from "@/composables/server";
import { useConfigQuery } from "@/composables/queries/config";

const config = useConfigQuery();
const setup = useServerSetup();

const schema = z.object({
  url: z.url("Invalid URL. Please enter a valid http(s) URL."),
});

type Schema = z.output<typeof schema>;

const state = reactive<Partial<Schema>>({
  url: undefined,
});

// Pre-fill URL from config when it loads
watch(
  () => config.data.value?.serverUrl,
  (serverUrl) => {
    if (serverUrl) {
      state.url = serverUrl;
    }
  },
  { immediate: true },
);

function onSubmit(event: FormSubmitEvent<Schema>) {
  setup.mutate(event.data.url);
}
</script>

<template>
  <p v-if="config.isLoading.value">Loading..</p>

  <UForm
    v-else
    :schema="schema"
    :state="state"
    class="flex justify-center flex-col gap-4"
    :disabled="setup.isPending.value"
    @submit="onSubmit"
  >
    <UFormField label="Server URL" name="url">
      <UInput
        v-model="state.url"
        type="url"
        placeholder="https://your-server.worker.dev"
      />
    </UFormField>

    <UAlert
      color="neutral"
      variant="soft"
      description="Enter your haudoi server url. You can find that in server frontpage."
    />

    <UButton
      label="Connect"
      icon="i-material-symbols:login"
      type="submit"
      :loading="setup.isPending.value"
    />

    <UAlert
      v-if="setup.isPending.value"
      color="info"
      icon="i-material-symbols:info"
      description='Press "allow" in the permission prompt to continue.'
    />

    <UAlert
      v-if="setup.error.value"
      color="error"
      icon="i-material-symbols:cancel"
      :description="setup.error.value.message"
    />
  </UForm>
</template>
