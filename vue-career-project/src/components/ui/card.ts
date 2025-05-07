import { defineComponent, h } from 'vue'

// Card component
export const Card = defineComponent({
  name: 'Card',
  setup(_, { slots }) {
    return () => h('div', { class: 'bg-white rounded-lg shadow-md overflow-hidden' }, slots.default?.())
  }
})

// CardHeader component
export const CardHeader = defineComponent({
  name: 'CardHeader',
  setup(_, { slots }) {
    return () => h('div', { class: 'p-4 border-b' }, slots.default?.())
  }
})

// CardTitle component
export const CardTitle = defineComponent({
  name: 'CardTitle',
  setup(_, { slots }) {
    return () => h('h3', { class: 'text-lg font-semibold' }, slots.default?.())
  }
})

// CardContent component
export const CardContent = defineComponent({
  name: 'CardContent',
  setup(_, { slots }) {
    return () => h('div', { class: 'p-4' }, slots.default?.())
  }
})

export default {
  Card,
  CardHeader,
  CardTitle,
  CardContent
}
