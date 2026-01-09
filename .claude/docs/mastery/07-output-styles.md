# 7. Output Styles

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 7.1 What are Output Styles?

**Output Styles** customize the format of Claude Code's responses. You can use built-in styles or define custom styles.

---

## 7.2 Built-in Styles

| Style | Description | Use Case |
|-------|-------------|----------|
| **Default** | Standard output | General conversation |
| **Explanatory** | Includes detailed explanations | Learning, understanding needed |
| **Learning** | Educational explanations | Learning new concepts |
| **Concise** | Brief responses | Quick tasks, experienced users |
| **Verbose** | Maximum detail | Complex debugging |

**Applying Styles**:

```bash
# Specify style at session start
claude --output-style concise

# Change during session
/style concise
```

---

## 7.3 Defining Custom Styles

**Location**: `.claude/styles/{style-name}.md`

**Template**:

```markdown
---
name: my-style
description: My custom output style
---

# Output Style Instructions

## Tone and Format
- Answer concisely and directly
- Skip unnecessary introductions
- Prioritize code examples

## Structure
- Core content first
- Use collapse for additional explanations
- Always show related file paths

## Formatting
- Use markdown
- Specify language in code blocks
- Use tables for comparisons
```

---

## 7.4 Style Usage Examples

**Concise Code Review Style**:

```markdown
---
name: brief-review
description: Code review focusing on essentials only
---

# Brief Review Style

## Format
- List only issues (skip what's good)
- Present fix code directly
- 1-2 line explanations

## Example Output
❌ Using `any` type → Change to `string | number`
❌ Unused variable `temp` should be deleted
⚠️ Error handling recommended
```

**Educational Style**:

```markdown
---
name: teaching
description: Concept explanation focused
---

# Teaching Style

## Format
- Explain concepts before code
- Always explain why (Why)
- Progress step by step
- Highlight common mistakes

## Structure
1. Introduce concept
2. Simple example
3. Real-world application
4. Cautions
```
