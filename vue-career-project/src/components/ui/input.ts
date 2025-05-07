import { defineComponent, h } from 'vue'

// Input component
export const Input = defineComponent({
  name: 'Input',
  props: {
    type: {
      type: String,
      default: 'text'
    },
    placeholder: {
      type: String,
      default: ''
    }
  },
  setup(props) {
    return () => h('input', {
      type: props.type,
      placeholder: props.placeholder,
      class: "w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
    })
  }
})

export default Input
