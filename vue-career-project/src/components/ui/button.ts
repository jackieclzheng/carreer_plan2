import { defineComponent, h } from 'vue'

// Button component
export const Button = defineComponent({
  name: 'Button',
  props: {
    variant: {
      type: String,
      default: 'primary'
    },
    size: {
      type: String,
      default: 'md'
    }
  },
  setup(props, { slots }) {
    return () => {
      const variantClasses = {
        primary: 'bg-blue-500 hover:bg-blue-600 text-white',
        secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-800',
        ghost: 'bg-transparent hover:bg-gray-100 text-gray-800'
      }[props.variant] || 'bg-blue-500 hover:bg-blue-600 text-white'
      
      const sizeClasses = {
        sm: 'py-1 px-2 text-sm',
        md: 'py-2 px-4',
        lg: 'py-3 px-6 text-lg'
      }[props.size] || 'py-2 px-4'
      
      return h('button', { 
        class: `rounded font-medium ${variantClasses} ${sizeClasses}` 
      }, slots.default?.())
    }
  }
})

export default Button
