# 2. Language/Framework Templates

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 2.1 Language Detection Methods

Files Claude Code checks when analyzing projects:

| Language | Detection Files |
|----------|-----------------|
| TypeScript/JavaScript | `package.json`, `tsconfig.json` |
| Python | `pyproject.toml`, `requirements.txt`, `setup.py` |
| Go | `go.mod`, `go.sum` |
| Rust | `Cargo.toml` |
| Java | `pom.xml`, `build.gradle` |
| C# | `*.csproj`, `*.sln` |
| Ruby | `Gemfile` |
| PHP | `composer.json` |
| **Flutter/Dart** | `pubspec.yaml`, `.fvmrc` |
| Swift | `Package.swift`, `*.xcodeproj` |
| Kotlin | `build.gradle.kts` |

---

## 2.2 TypeScript/JavaScript

### npm

```json
// settings.local.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "npm run format || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(npm run build:*)",
      "Bash(npm run test:*)",
      "Bash(npm run lint:*)",
      "Bash(npx:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Package Management
- Use **npm**

## Development Order
npm run typecheck    # Type check
npm run test         # Test
npm run lint         # Lint
npm run build        # Build

## Coding Conventions
- Prefer `type`, avoid `interface`
- **No `enum`** → Use string literal unions
```

### pnpm (Monorepo)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "pnpm format || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(pnpm:*)",
      "Bash(pnpm -r:*)",
      "Bash(pnpm --filter:*)"
    ]
  }
}
```

### Bun

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "bun run format || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(bun:*)",
      "Bash(bun run:*)",
      "Bash(bun test:*)"
    ]
  }
}
```

### Deno

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "deno fmt || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(deno:*)",
      "Bash(deno run:*)",
      "Bash(deno test:*)",
      "Bash(deno lint:*)"
    ]
  }
}
```

---

## 2.3 Python

### Poetry

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "poetry run black . && poetry run isort . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(poetry:*)",
      "Bash(poetry run:*)",
      "Bash(pytest:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Package Management
- Use **Poetry**
- `poetry add {package}` / `poetry add -D {dev-package}`

## Development Order
poetry run mypy .        # Type check
poetry run pytest        # Test
poetry run black .       # Format
poetry run ruff check .  # Lint

## Coding Conventions
- Type hints required
- Docstrings in Google style
- Use f-strings (no format())

## Forbidden Practices
- ❌ print() → Use logging
- ❌ Global variables
- ❌ * imports
```

### pip + venv

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "black . && isort . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(pip:*)",
      "Bash(python:*)",
      "Bash(pytest:*)"
    ]
  }
}
```

### uv (Latest)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "uv run ruff format . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(uv:*)",
      "Bash(uv run:*)"
    ]
  }
}
```

---

## 2.4 Go

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "gofmt -w . && goimports -w . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(go:*)",
      "Bash(go build:*)",
      "Bash(go test:*)",
      "Bash(go mod:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Package Management
- Use Go Modules
- Clean dependencies with `go mod tidy`

## Development Order
go build ./...     # Build
go test ./...      # Test
go vet ./...       # Static analysis
golangci-lint run  # Lint

## Coding Conventions
- Follow Effective Go style guide
- Always handle errors
- Define interfaces at the point of use

## Forbidden Practices
- ❌ panic() (allowed only in main)
- ❌ Overuse of init()
- ❌ Global variables
```

---

## 2.5 Rust

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "cargo fmt || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(cargo:*)",
      "Bash(cargo build:*)",
      "Bash(cargo test:*)",
      "Bash(cargo clippy:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Package Management
- Use Cargo
- `cargo add {crate}` / `cargo add --dev {crate}`

## Development Order
cargo check        # Quick check
cargo build        # Build
cargo test         # Test
cargo clippy       # Lint
cargo fmt          # Format

## Coding Conventions
- Resolve all Clippy warnings
- Use ? operator or expect() instead of unwrap()
- Actively use derive macros

## Forbidden Practices
- ❌ unsafe blocks (unless necessary)
- ❌ unwrap() (except in tests)
- ❌ Global mutable statics
```

---

## 2.6 Java

### Maven

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "mvn spotless:apply || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(mvn:*)",
      "Bash(mvn clean:*)",
      "Bash(mvn test:*)",
      "Bash(mvn package:*)"
    ]
  }
}
```

### Gradle

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "./gradlew spotlessApply || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(./gradlew:*)",
      "Bash(gradle:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Package Management
- Use Gradle/Maven

## Development Order
./gradlew build          # Build
./gradlew test           # Test
./gradlew spotlessCheck  # Format check
./gradlew spotlessApply  # Apply format

## Coding Conventions
- Follow Google Java Style Guide
- Actively use Optional<T>
- Use Stream API

## Forbidden Practices
- ❌ Return null (use Optional)
- ❌ Raw type collections
- ❌ System.out.println (use Logger)
```

---

## 2.7 C# / .NET

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "dotnet format || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(dotnet:*)",
      "Bash(dotnet build:*)",
      "Bash(dotnet test:*)",
      "Bash(dotnet run:*)"
    ]
  }
}
```

---

## 2.8 Ruby

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "bundle exec rubocop -A || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(bundle:*)",
      "Bash(rails:*)",
      "Bash(rake:*)",
      "Bash(rspec:*)"
    ]
  }
}
```

---

## 2.9 PHP

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "composer run format || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(composer:*)",
      "Bash(php:*)",
      "Bash(phpunit:*)",
      "Bash(artisan:*)"
    ]
  }
}
```

---

## 2.10 Flutter/Dart

### Single App (Using FVM)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "fvm dart format . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(fvm flutter:*)",
      "Bash(fvm dart:*)",
      "Bash(dart run build_runner:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Flutter Version Management
- Use **FVM** (Flutter Version Management)
- Version pinned with `.fvmrc` file

## Development Order
fvm flutter analyze       # Static analysis
fvm flutter test          # Test
fvm dart format .         # Format
fvm flutter build         # Build

## Code Generation
dart run build_runner build --delete-conflicting-outputs

## Coding Conventions
- **freezed** pattern for immutable models
- **Riverpod** state management
- **auto_route** routing

## Forbidden Practices
- ❌ StatefulWidget (use Riverpod)
- ❌ GlobalKey overuse
- ❌ Hardcoded strings (use i18n)
```

### Monorepo (Melos)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "melos exec -- fvm dart format . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(melos:*)",
      "Bash(melos exec:*)",
      "Bash(fvm flutter:*)",
      "Bash(fvm dart:*)"
    ]
  }
}
```

```markdown
<!-- CLAUDE.md (Melos Monorepo) -->
# Development Workflow

## Monorepo Management
- Use **Melos**
- Link dependencies with `melos bootstrap`

## Development Order
melos analyze             # Analyze all
melos test                # Test all
melos exec -- fvm dart format .  # Format all

## Package Structure
packages/
├── {project}_ui/         # UI components
├── {project}_utils/      # Utilities
└── app/                  # Main app (depends on above)
```

---

## 2.11 Swift (iOS/macOS)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "swiftformat . || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(swift:*)",
      "Bash(xcodebuild:*)",
      "Bash(swiftformat:*)",
      "Bash(swiftlint:*)"
    ]
  }
}
```

---

## 2.12 Kotlin (Android/Multiplatform)

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "./gradlew ktlintFormat || true"
      }]
    }]
  },
  "permissions": {
    "allow": [
      "Bash(./gradlew:*)",
      "Bash(gradle:*)"
    ]
  }
}
```
