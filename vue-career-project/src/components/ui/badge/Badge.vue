<template>
  <span
    class="inline-flex items-center rounded-full px-2 py-1 text-xs font-medium"
    :class="variantClasses[variant]"
  >
    <slot></slot>
  </span>
</template>

<script setup lang="ts">
interface Props {
  variant?: 'default' | 'success' | 'warning' | 'destructive';
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default'
});

const variantClasses = {
  default: 'bg-gray-100 text-gray-800',
  success: 'bg-green-100 text-green-800',
  warning: 'bg-yellow-100 text-yellow-800',
  destructive: 'bg-red-100 text-red-800'
};
</script>