---
name: phase-6-ui-integration
description: |
  Skill for implementing actual UI and integrating with APIs.
  Covers frontend-backend integration, state management, and API client architecture.

  Triggers: UI implementation, API integration, state management, UI 구현, API連携, 状态管理
agent: pipeline-guide
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
user-invocable: false
---

# Phase 6: UI Implementation + API Integration

> Actual UI implementation and API integration

## Purpose

Implement actual screens using design system components and integrate with APIs.

## What to Do in This Phase

1. **Page Implementation**: Develop each screen
2. **State Management**: Handle client state
3. **API Integration**: Call backend APIs
4. **Error Handling**: Handle loading and error states

## Deliverables

```
src/
├── pages/              # Page components
├── features/           # Feature-specific components
│   ├── auth/
│   └── product/
└── hooks/              # API call hooks
    └── useProducts.ts

docs/03-analysis/
└── ui-qa.md            # QA results
```

## PDCA Application

- **Plan**: Define screens/features to implement
- **Design**: Component structure, state management design
- **Do**: UI implementation + API integration
- **Check**: Zero Script QA
- **Act**: Fix bugs and proceed to Phase 7

## Level-wise Application

| Level | Application Method |
|-------|-------------------|
| Starter | Static UI only (no API integration) |
| Dynamic | Full integration |
| Enterprise | Full integration + optimization |

## API Client Architecture

### 3-Layer API Client Structure

```
┌─────────────────────────────────────────────────────────┐
│                    UI Components                         │
│              (pages, features, hooks)                    │
├─────────────────────────────────────────────────────────┤
│                    Service Layer                         │
│         (Domain-specific API call functions)             │
│    authService, productService, orderService, ...        │
├─────────────────────────────────────────────────────────┤
│                    API Client Layer                      │
│         (Common settings, interceptors, error handling)  │
│              apiClient (axios/fetch wrapper)             │
└─────────────────────────────────────────────────────────┘
```

### Folder Structure

```
src/
├── lib/api/
│   ├── client.ts           # API client wrapper
│   └── error-handler.ts    # Error handling logic
├── services/
│   ├── auth.service.ts     # Auth-related APIs
│   └── product.service.ts  # Product-related APIs
├── types/
│   ├── api.types.ts        # Common API types
│   └── auth.types.ts       # Auth domain types
└── hooks/
    └── useProducts.ts      # Hooks using Service
```

## API Client Implementation

### Basic API Client (lib/api/client.ts)

```typescript
const BASE_URL = process.env.NEXT_PUBLIC_API_URL || '/api';

class ApiClient {
  private baseUrl: string;
  constructor(baseUrl: string) { this.baseUrl = baseUrl; }

  private async request<T>(endpoint: string, config: RequestInit = {}): Promise<T> {
    const headers = new Headers(config.headers);
    headers.set('Content-Type', 'application/json');

    const token = localStorage.getItem('auth_token');
    if (token) headers.set('Authorization', `Bearer ${token}`);

    const response = await fetch(`${this.baseUrl}${endpoint}`, { ...config, headers });
    if (!response.ok) throw new ApiError(response);
    return response.json();
  }

  get<T>(endpoint: string) { return this.request<T>(endpoint, { method: 'GET' }); }
  post<T>(endpoint: string, body?: unknown) {
    return this.request<T>(endpoint, { method: 'POST', body: JSON.stringify(body) });
  }
  put<T>(endpoint: string, body?: unknown) {
    return this.request<T>(endpoint, { method: 'PUT', body: JSON.stringify(body) });
  }
  delete<T>(endpoint: string) { return this.request<T>(endpoint, { method: 'DELETE' }); }
}

export const apiClient = new ApiClient(BASE_URL);
```

### Common Type Definitions

```typescript
// types/api.types.ts
export interface ApiResponse<T> {
  data: T;
  meta?: { timestamp: string; requestId?: string; };
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: { page: number; limit: number; total: number; totalPages: number; };
}

export class ApiError extends Error {
  constructor(
    public code: string,
    message: string,
    public status: number,
    public details?: Array<{ field: string; message: string }>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const ERROR_CODES = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  NOT_FOUND: 'NOT_FOUND',
  NETWORK_ERROR: 'NETWORK_ERROR',
} as const;
```

## Service Layer Pattern

```typescript
// services/auth.service.ts
import { apiClient } from '@/lib/api/client';

export const authService = {
  login(credentials: LoginRequest) { return apiClient.post<LoginResponse>('/auth/login', credentials); },
  logout() { return apiClient.post<void>('/auth/logout'); },
  getMe() { return apiClient.get<User>('/auth/me'); },
};

// services/product.service.ts
export const productService = {
  getList(filter?: ProductFilter) { return apiClient.get<PaginatedResponse<Product>>('/products', filter); },
  getById(id: string) { return apiClient.get<Product>(`/products/${id}`); },
  create(data: CreateProductRequest) { return apiClient.post<Product>('/products', data); },
  delete(id: string) { return apiClient.delete<void>(`/products/${id}`); },
};
```

## Error Handling Pattern

```typescript
// lib/api/error-handler.ts
export function handleApiError(error: unknown, options = {}) {
  if (!(error instanceof ApiError)) {
    toast.error('An unknown error occurred.');
    return;
  }

  switch (error.code) {
    case ERROR_CODES.UNAUTHORIZED:
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
      break;
    case ERROR_CODES.FORBIDDEN:
      toast.error('You do not have permission.');
      break;
    case ERROR_CODES.NETWORK_ERROR:
      toast.error('Please check your network connection.');
      break;
    default:
      toast.error(error.message);
  }
}
```

## API Integration Patterns

```typescript
// React Query Pattern
function useProducts(filter?: ProductFilter) {
  return useQuery({
    queryKey: ['products', filter],
    queryFn: () => productService.getList(filter),
  });
}

// SWR Pattern
function useProducts() {
  return useSWR('/api/products', fetcher);
}
```

## State Management Guide

```
Server state (API data) → React Query / SWR
Client state (UI state) → useState / useReducer
Global state (auth, etc.) → Context / Zustand
Form state → React Hook Form
```

## Zero Script QA Application

```
Validate UI behavior with logs:
[UI] Login button clicked
[STATE] isLoading: true
[API] POST /api/auth/login
[RESPONSE] { token: "...", user: {...} }
[STATE] isLoading: false, isLoggedIn: true
[RESULT] ✅ Login successful
```

## API Integration Checklist

### Architecture
- [ ] Build API client layer (lib/api/client.ts)
- [ ] Automatic auth token injection
- [ ] Service Layer separation by domain
- [ ] Type consistency (ApiResponse, ApiError)

### Error Handling
- [ ] Error codes matching Phase 4 API spec
- [ ] Global error handler with toast notifications
- [ ] Form validation error handling
- [ ] Auth error redirect

### Coding Conventions
- [ ] No direct fetch in components
- [ ] Follow hooks → services → apiClient order
- [ ] Services: `{domain}.service.ts`
- [ ] Hooks: `use{Domain}{Action}.ts`
- [ ] Types: `{domain}.types.ts`

## Template

See `${CLAUDE_PLUGIN_ROOT}/templates/pipeline/phase-6-ui.template.md`

## Next Phase

Phase 7: SEO/Security → Features are complete, now optimize and strengthen security
