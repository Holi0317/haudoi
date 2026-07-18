<script setup lang="ts">
import UInput from "@nuxt/ui/components/Input.vue";
import UButton from "@nuxt/ui/components/Button.vue";
import UAlert from "@nuxt/ui/components/Alert.vue";
import { useForm } from "@tanstack/vue-form";
import { computed, reactive } from "vue";
import { useServerSetup } from "@/composables/server";
import { useConfigQuery } from "@/composables/queries/config";

const config = useConfigQuery();
const setup = useServerSetup();

const url = computed(() => config.data.value?.serverUrl ?? "");

const defaultValues = reactive({
  url,
});

const form = useForm({
  defaultValues,
  async onSubmit({ value }) {
    setup.mutate(value.url);
  },
});

const validUrl = (url: string) => {
  try {
    const parsed = new URL(url);
    return parsed.protocol === "http:" || parsed.protocol === "https:";
  } catch {
    return false;
  }
};
</script>

<template>
  <p v-if="config.isLoading.value">Loading..</p>

  <form
    v-else
    class="flex justify-center flex-col gap-4"
    @submit.prevent.stop="form.handleSubmit"
  >
    <form.Field
      name="url"
      :validators="{
        onBlur: ({ value }) =>
          validUrl(value)
            ? null
            : 'Invalid URL. Please enter a valid http(s) URL.',
      }"
    >
      <template #default="{ field }">
        <div class="flex flex-col gap-2">
          <label for="url">Server URL</label>
          <UInput
            id="url"
            :value="field.state.value"
            :name="field.name"
            type="url"
            placeholder="https://your-server.worker.dev"
            :disabled="setup.isPending.value"
            @blur="field.handleBlur"
            @input="
              (e: Event) =>
                field.handleChange((e.target as HTMLInputElement).value)
            "
          />
          <UAlert
            color="neutral"
            variant="soft"
            description="Enter your haudoi server url. You can find that in server frontpage."
          />

          <UAlert
            v-if="!field.state.meta.isValid"
            color="error"
            :description="field.state.meta.errors.join(', ')"
          />
        </div>
      </template>
    </form.Field>

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
  </form>
</template>
