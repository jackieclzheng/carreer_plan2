import { defineComponent, h } from 'vue'

// Label component
export const Label = defineComponent({
  name: 'Label',
  props: {
    for: {
      type: String,
      default: ''
    }
  },
  setup(props, { slots }) {
    return () => h('label', {
      for: props.for,
      class: "block text-sm font-medium text-gray-700 mb-1"
    }, slots.default?.())
  }
})

export default Label
