# Starter Level Guide

## Target Audience

- Programming beginners
- Static website creation
- Simple portfolios, landing pages

## Tech Stack

```
Frontend:
- HTML / CSS / JavaScript (basics)
- Next.js (recommended, static generation)
- Tailwind CSS

Deployment:
- Vercel / Netlify
- GitHub Pages

Backend:
- None (static site)
- If needed → Upgrade to Dynamic level
```

## Project Structure

```
project/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── page.tsx           # Homepage
│   │   ├── about/
│   │   └── contact/
│   │
│   ├── components/             # Reusable components
│   │   └── Header.tsx
│   │
│   └── styles/                 # Styles
│
├── public/                     # Static files
│   └── images/
│
├── docs/                       # PDCA documents
│   ├── 01-plan/
│   │   ├── _INDEX.md
│   │   └── features/
│   ├── 02-design/
│   │   ├── _INDEX.md
│   │   └── features/
│   ├── 03-analysis/
│   │   └── _INDEX.md
│   └── 04-report/
│       └── _INDEX.md
│
└── README.md
```

## PDCA Application

### Simplified Documents

At the Starter level, simple documents are sufficient.

```markdown
# Contact Page Plan

## Goal
- A page where visitors can make inquiries

## Include
- Name, email, message form
- Submit button

## Exclude
- Actual email sending (later)
```

### Automatic Application

You don't need to know commands:

```
User: "Create a contact page"

Claude:
1. Check/create docs/01-plan/features/contact.plan.md
2. Check/create design document
3. Implement
4. Suggest analysis after completion
```

## Common Patterns

### 1. Component Structure

```tsx
// components/Header.tsx
export function Header() {
  return (
    <header className="p-4 bg-white shadow">
      <nav className="max-w-4xl mx-auto flex justify-between">
        <a href="/" className="font-bold">My Site</a>
        <div className="space-x-4">
          <a href="/about">About</a>
          <a href="/contact">Contact</a>
        </div>
      </nav>
    </header>
  );
}
```

### 2. Page Structure

```tsx
// app/page.tsx
import { Header } from '@/components/Header';

export default function Home() {
  return (
    <main>
      <Header />
      <section className="max-w-4xl mx-auto p-4">
        <h1 className="text-3xl font-bold">Welcome</h1>
        <p>My portfolio site</p>
      </section>
    </main>
  );
}
```

### 3. Form (Client Side)

```tsx
'use client';

import { useState } from 'react';

export function ContactForm() {
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Just show success without actual sending here
    setSubmitted(true);
  };

  if (submitted) {
    return <p>Thank you! We will contact you soon.</p>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <input name="name" placeholder="Name" required />
      <input name="email" type="email" placeholder="Email" required />
      <textarea name="message" placeholder="Message" required />
      <button type="submit">Send</button>
    </form>
  );
}
```

## When to Upgrade

Upgrade to **Dynamic level** if you need:

```
→ "I need login/signup"
→ "I want to save data"
→ "I want to show different screens per user"
→ "I need API integration"
```

Upgrade: `/upgrade-level dynamic`

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Next.js page not showing | Check `app/` folder structure |
| Styles not applying | Check Tailwind config, use `className` |
| Image not showing | Place in `public/` folder, use `/images/...` path |
| Deployment error | Run `npm run build` locally first |

## Getting Started

```bash
# Initialize
/init-starter

# Or request directly
"Create a portfolio site for me"
```

## Related Documents

- [Starter Skill](../../skills/starter/SKILL.md)
- [Dynamic Level Guide](./dynamic-guide.md) (when upgrading)
