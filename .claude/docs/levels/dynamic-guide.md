# Dynamic Level Guide

## Target Audience

- Frontend developers
- Solo entrepreneurs
- Those who want to quickly build fullstack services

## Tech Stack

```
Frontend:
- React / Next.js 14+
- TypeScript
- Tailwind CSS
- TanStack Query (data fetching)
- Zustand (state management)

Backend (BaaS):
- bkend.ai
  - Automatic REST API
  - MongoDB database
  - Built-in authentication (JWT)
  - Real-time features

Deployment:
- Vercel (frontend)
- bkend.ai (backend)
```

## Project Structure

```
project/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Auth-related routes
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── (main)/            # Main routes (protected)
│   │   │   ├── dashboard/
│   │   │   └── settings/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   │
│   ├── components/
│   │   ├── ui/                # Basic UI components
│   │   └── features/          # Feature-specific components
│   │
│   ├── hooks/                  # Custom hooks
│   │   ├── useAuth.ts
│   │   └── useQuery.ts
│   │
│   ├── lib/
│   │   ├── bkend.ts           # bkend.ai client
│   │   └── utils.ts
│   │
│   ├── stores/                 # Zustand stores
│   │   └── auth-store.ts
│   │
│   └── types/
│       └── index.ts
│
├── docs/                       # PDCA documents
│   ├── 01-plan/
│   ├── 02-design/
│   │   ├── data-model.md      # Data model ⭐
│   │   └── api-spec.md        # API specification ⭐
│   ├── 03-analysis/
│   └── 04-report/
│
├── .mcp.json                   # bkend.ai MCP configuration
└── .env.local
```

## Core Patterns

### 1. bkend.ai Client

```typescript
// lib/bkend.ts
import { createClient } from '@bkend/client';

export const bkend = createClient({
  apiKey: process.env.NEXT_PUBLIC_BKEND_API_KEY!,
  projectId: process.env.NEXT_PUBLIC_BKEND_PROJECT_ID!,
});
```

### 2. Authentication Hook (Zustand)

```typescript
// hooks/useAuth.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { bkend } from '@/lib/bkend';

interface AuthState {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useAuth = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isLoading: false,

      login: async (email, password) => {
        set({ isLoading: true });
        const { user, token } = await bkend.auth.login({ email, password });
        set({ user, isLoading: false });
      },

      logout: () => {
        bkend.auth.logout();
        set({ user: null });
      },
    }),
    { name: 'auth-storage' }
  )
);
```

### 3. Data Fetching (TanStack Query)

```typescript
// List query
const { data, isLoading } = useQuery({
  queryKey: ['posts'],
  queryFn: () => bkend.collection('posts').find(),
});

// Create mutation
const mutation = useMutation({
  mutationFn: (newPost) => bkend.collection('posts').create(newPost),
  onSuccess: () => {
    queryClient.invalidateQueries(['posts']);
  },
});
```

### 4. Protected Route

```typescript
// components/ProtectedRoute.tsx
'use client';

import { useAuth } from '@/hooks/useAuth';
import { redirect } from 'next/navigation';

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();

  if (isLoading) return <LoadingSpinner />;
  if (!user) redirect('/login');

  return <>{children}</>;
}
```

## Data Model Design

### Document Location
`docs/02-design/data-model.md`

### Example

```markdown
# Data Model

## Collections

### users (auto-generated)
Uses bkend.ai built-in authentication

### posts
| Field | Type | Description |
|-------|------|-------------|
| _id | string | Auto-generated |
| userId | string | Author reference |
| title | string | Title |
| content | string | Content |
| tags | string[] | Tags |
| createdAt | Date | Auto |
| updatedAt | Date | Auto |

### comments
| Field | Type | Description |
|-------|------|-------------|
| _id | string | Auto-generated |
| postId | string | Post reference |
| userId | string | Author reference |
| content | string | Comment content |
```

## PDCA Application

### Required Documents for Dynamic Level

1. **data-model.md**: bkend.ai collection structure
2. **api-spec.md**: API endpoints to use
3. Feature-specific plan/design documents

### Gap Analysis Points

- Designed collection structure vs. actual created structure
- Designed fields vs. actually used fields
- API call pattern consistency

## When to Upgrade

Upgrade to **Enterprise level** if you need:

```
→ "Traffic is expected to increase significantly"
→ "I need my own server"
→ "I want to split into microservices"
→ "I need complex backend logic"
→ "I want to use Kubernetes"
```

Upgrade: `/upgrade-level enterprise`

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| CORS error | Register domain in bkend.ai console |
| 401 Unauthorized | Token expired, re-login or refresh |
| Data not visible | Check collection name, query conditions |
| Type error | Sync TypeScript types with schema |
| Real-time not working | Check WebSocket connection status |

## Getting Started

```bash
# Initialize
/init-dynamic

# Or request directly
"Create a blog with login functionality"
```

## MCP Configuration

```json
// .mcp.json
{
  "mcpServers": {
    "bkend": {
      "command": "npx",
      "args": ["@bkend/mcp-server"],
      "env": {
        "BKEND_API_KEY": "${BKEND_API_KEY}",
        "BKEND_PROJECT_ID": "${BKEND_PROJECT_ID}"
      }
    }
  }
}
```

## Related Documents

- [Dynamic Skill](../../skills/dynamic/SKILL.md)
- [Starter Level Guide](./starter-guide.md) (previous level)
- [Enterprise Level Guide](./enterprise-guide.md) (next level)
