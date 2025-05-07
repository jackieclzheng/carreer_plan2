import { defineComponent, h } from 'vue'

// AlertDialog components
export const AlertDialog = defineComponent({
  name: 'AlertDialog',
  setup(_, { slots }) {
    return () => h('div', {}, slots.default?.())
  }
})

export const AlertDialogTrigger = defineComponent({
  name: 'AlertDialogTrigger',
  props: {
    'as-child': {
      type: Boolean,
      default: false
    }
  },
  setup(_, { slots }) {
    return () => h('div', {}, slots.default?.())
  }
})

export const AlertDialogContent = defineComponent({
  name: 'AlertDialogContent',
  setup(_, { slots }) {
    return () => h('div', { 
      class: "fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50" 
    }, [
      h('div', { 
        class: "bg-white rounded-lg shadow-lg p-6 max-w-md w-full" 
      }, slots.default?.())
    ])
  }
})

export const AlertDialogHeader = defineComponent({
  name: 'AlertDialogHeader',
  setup(_, { slots }) {
    return () => h('div', { class: "mb-4" }, slots.default?.())
  }
})

export const AlertDialogTitle = defineComponent({
  name: 'AlertDialogTitle',
  setup(_, { slots }) {
    return () => h('h2', { class: "text-xl font-semibold" }, slots.default?.())
  }
})

export const AlertDialogDescription = defineComponent({
  name: 'AlertDialogDescription',
  setup(_, { slots }) {
    return () => h('p', { class: "text-gray-600 mt-2" }, slots.default?.())
  }
})

export const AlertDialogFooter = defineComponent({
  name: 'AlertDialogFooter',
  setup(_, { slots }) {
    return () => h('div', { class: "flex justify-end space-x-2 mt-6" }, slots.default?.())
  }
})

export const AlertDialogAction = defineComponent({
  name: 'AlertDialogAction',
  setup(_, { slots }) {
    return () => h('button', { 
      class: "px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600" 
    }, slots.default?.())
  }
})

export const AlertDialogCancel = defineComponent({
  name: 'AlertDialogCancel',
  setup(_, { slots }) {
    return () => h('button', { 
      class: "px-4 py-2 bg-gray-200 text-gray-800 rounded hover:bg-gray-300" 
    }, slots.default?.())
  }
})

export default {
  AlertDialog,
  AlertDialogTrigger,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogAction,
  AlertDialogCancel
}
