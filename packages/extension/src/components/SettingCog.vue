<script setup lang="ts">
import UButton from "@nuxt/ui/components/Button.vue";
</script>

<template>
  <div class="flex justify-end">
    <UButton
      to="/setup"
      icon="i-material-symbols:settings"
      variant="ghost"
      color="neutral"
      aria-label="Settings"
    >
    </UButton>
  </div>
</template>
