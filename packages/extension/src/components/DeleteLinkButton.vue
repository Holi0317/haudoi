<script setup lang="ts">
import UButton from "@nuxt/ui/components/Button.vue";
import { useDeleteMutation } from "@/composables/queries/server";

const props = defineProps<{
  id: number;
}>();

const mutation = useDeleteMutation();

const click = () => {
  mutation.mutate(props.id);
};
</script>

<template>
  <template v-if="mutation.isError.value">
    <UButton
      label="Delete link"
      icon="i-material-symbols:error"
      color="warning"
      :disabled="true"
    />

    <p>Error deleting link. {{ mutation.failureReason.value }}</p>

    <UButton
      label="Retry"
      icon="i-material-symbols:refresh"
      color="info"
      @click="click"
    />
  </template>

  <UButton
    v-else-if="mutation.isSuccess.value"
    label="Link deleted"
    icon="i-material-symbols:check"
    color="success"
    :disabled="true"
  />

  <UButton
    v-else
    label="Delete link"
    icon="i-material-symbols:delete"
    color="error"
    :loading="mutation.isPending.value"
    @click="click"
  />
</template>
