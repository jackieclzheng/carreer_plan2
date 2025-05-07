import { defineComponent, h } from 'vue'

// Progress component
export const Progress = defineComponent({
  name: 'Progress',
  props: {
    value: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    }
  },
  setup(props) {
    return () => h('div', { 
      class: "w-full bg-gray-200 rounded-full h-2.5 dark:bg-gray-700" 
    }, [
      h('div', { 
        class: "bg-blue-600 h-2.5 rounded-full",
        style: `width: ${(props.value / props.max) * 100}%`
      })
    ])
  }
})

export default Progress
