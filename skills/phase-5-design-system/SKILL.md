---
name: phase-5-design-system
description: |
  Skill for building platform-independent design systems.
  Develops consistent component libraries for all UI frameworks.

  Triggers: design system, component library, design tokens, shadcn, 디자인 시스템, デザインシステム, 设计系统
agent: pipeline-guide
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Bash
user-invocable: false
---

# Phase 5: Design System

> Build platform-independent design system

## Purpose

Build a reusable UI component library. Enable consistent design and fast development.

## What is a Design System?

A design system is **a collection of reusable components and clear standards** that enables building consistent user experiences at scale.

### Why is it Needed?

| Problem | Design System Solution |
|---------|----------------------|
| Designer-developer mismatch | Single Source of Truth |
| Duplicate component development | Reusable component library |
| Inconsistent UI/UX | Unified design tokens and rules |

### 3 Layers of Design System

```
┌─────────────────────────────────────────────────────┐
│              Design Tokens                           │
│   Color, Typography, Spacing, Radius, Shadow        │
├─────────────────────────────────────────────────────┤
│              Core Components                         │
│   Button, Input, Card, Dialog, Avatar, Badge        │
├─────────────────────────────────────────────────────┤
│            Composite Components                      │
│   Form, DataTable, Navigation, SearchBar            │
└─────────────────────────────────────────────────────┘
```

### Platform-specific Tools

| Platform | Recommended Tools |
|----------|------------------|
| Web (React/Next.js) | shadcn/ui, Radix |
| Web (Vue) | Vuetify, PrimeVue |
| Flutter | Material 3, Custom Theme |
| React Native | NativeBase, Tamagui |

## What to Do in This Phase

1. **Install Base Components**: Button, Input, Card, etc.
2. **Customize**: Adjust to project style
3. **Composite Components**: Combine multiple base components
4. **Documentation**: Document component usage

## Deliverables

```
components/ui/              # shadcn/ui components
├── button.tsx
├── input.tsx
└── card.tsx

lib/utils.ts                # Utilities (cn function)
docs/02-design/design-system.md
```

## Level-wise Application

| Level | Application Method |
|-------|-------------------|
| Starter | Optional |
| Dynamic | Required |
| Enterprise | Required (including design tokens) |

## shadcn/ui Installation

```bash
npx shadcn@latest init
npx shadcn@latest add button input card
```

## Custom Theme Building

### Design Token Override

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --destructive: 0 84.2% 60.2%;
    --radius: 0.5rem;
    --spacing-xs: 0.25rem;
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 1.5rem;
  }
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
  }
}
```

### Tailwind Config Extension

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      spacing: {
        'xs': 'var(--spacing-xs)',
        'sm': 'var(--spacing-sm)',
      },
      borderRadius: {
        'DEFAULT': 'var(--radius)',
      },
    },
  },
}
```

## Component Customization

```tsx
const Button = React.forwardRef<
  HTMLButtonElement,
  ButtonProps & { isLoading?: boolean }
>(({ isLoading, children, ...props }, ref) => {
  return (
    <ButtonPrimitive ref={ref} {...props}>
      {isLoading ? <Spinner /> : children}
    </ButtonPrimitive>
  );
});
```

## Mobile App Design System (Flutter)

### Custom Theme Building

```dart
// lib/theme/app_theme.dart
class AppTheme {
  static const Color primary = Color(0xFF3B82F6);
  static const double spacingMd = 16.0;
  static const double radiusMd = 8.0;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
  );
}
```

### Reusable Components

```dart
// lib/components/app_button.dart
enum AppButtonVariant { primary, secondary, destructive, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? CircularProgressIndicator(strokeWidth: 2)
          : Text(label),
    );
  }
}
```

## Cross-Platform Design Token Sharing

### Design Token JSON

```json
// tokens/design-tokens.json
{
  "color": { "primary": { "value": "#3B82F6" } },
  "spacing": { "md": { "value": "16px" } },
  "radius": { "md": { "value": "8px" } }
}
```

## Design System Checklist

### Required Items
- [ ] **Design Tokens**: Colors, Typography, Spacing, Radius, Shadows
- [ ] **Core Components**: Button, Input, Card, Dialog, Avatar, Badge
- [ ] **Composite Components**: Form, Navigation, Data Display
- [ ] **Documentation**: Component catalog, usage guidelines

## Template

See `${CLAUDE_PLUGIN_ROOT}/templates/pipeline/phase-5-design-system.template.md`

## Next Phase

Phase 6: UI Implementation + API Integration → Components are ready, now implement actual screens
