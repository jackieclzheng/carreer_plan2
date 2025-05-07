import { defineComponent, h } from 'vue'

// Select component
export const Select = defineComponent({
  name: 'Select',
  setup(_, { slots }) {
    return () => h('select', {
      class: "w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
    }, slots.default?.())
  }
})

// SelectContent component
export const SelectContent = defineComponent({
  name: 'SelectContent',
  setup(_, { slots }) {
    return () => h('div', {}, slots.default?.())
  }
})

// SelectItem component
export const SelectItem = defineComponent({
  name: 'SelectItem',
  props: {
    value: {
      type: [String, Number],
      required: true
    }
  },
  setup(props, { slots }) {
    return () => h('option', {
      value: props.value
    }, slots.default?.())
  }
})

// SelectTrigger component
export const SelectTrigger = defineComponent({
  name: 'SelectTrigger',
  setup(_, { slots }) {
    return () => h('div', {}, slots.default?.())
  }
})

// SelectValue component
export const SelectValue = defineComponent({
  name: 'SelectValue',
  props: {
    placeholder: {
      type: String,
      default: ''
    }
  },
  setup(props, { slots }) {
    return () => h('span', {}, slots.default?.() || props.placeholder)
  }
})

export default {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
}
