import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cn } from "@/lib/utils"

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  asChild?: boolean
  size?: 'sm' | 'md' | 'lg'
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, size = 'md', asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    const sizeClasses =
      size === 'sm' ? 'h-8 px-3 py-1.5 text-xs' : size === 'lg' ? 'h-12 px-6 py-3 text-base' : 'h-10 px-4 py-2 text-sm'
    return (
      <Comp
        className={cn(
          "inline-flex items-center justify-center whitespace-nowrap rounded-md font-medium",
          "ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2",
          "focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
          "bg-black text-white hover:bg-black/90",
          sizeClasses,
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button }
