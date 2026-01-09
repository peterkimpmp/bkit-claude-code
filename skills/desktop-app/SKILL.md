---
name: desktop-app
description: |
  Desktop app development guide for cross-platform desktop applications.
  Covers Electron and Tauri frameworks.

  Triggers: desktop app, Electron, Tauri, mac app, windows app, 데스크톱 앱, デスクトップアプリ, 桌面应用
agent: pipeline-guide
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebSearch
user-invocable: false
---

# Desktop App Development Expertise

## Overview

Guide for developing desktop apps using web technologies (HTML, CSS, JavaScript).
Support Windows, macOS, and Linux simultaneously with a single codebase.

## Framework Selection Guide

| Framework | Recommended For | Advantages | Disadvantages |
|-----------|----------------|------------|---------------|
| **Electron** | Fast development | Easy start, many examples | Large bundle (~150MB) |
| **Tauri** | Lightweight apps | Small bundle (~10MB), fast | Requires Rust |

### Level-wise Recommendations

```
Starter → Electron + electron-vite (just web knowledge)
Dynamic → Electron + auto-update (server integration)
Enterprise → Tauri (performance and security)
```

## Electron Guide

### Project Creation

```bash
npm create @electron-vite/create my-electron-app
cd my-electron-app && npm install && npm run dev
```

### Folder Structure

```
my-electron-app/
├── src/
│   ├── main/               # Main process (Node.js)
│   ├── preload/            # Renderer↔Main bridge
│   └── renderer/           # Renderer process (Web)
├── resources/              # App icons, assets
└── electron-builder.yml    # Deployment configuration
```

### Core Concept: Process Separation

```
┌─────────────────────────────────────────────────────────┐
│  Main Process (Node.js)                                 │
│  - System API access, window management, menus          │
├─────────────────────────────────────────────────────────┤
│  Preload Script (Bridge)                                │
│  - Safe main↔renderer communication                     │
├─────────────────────────────────────────────────────────┤
│  Renderer Process (Chromium)                            │
│  - Web UI (React, Vue), no direct Node.js access        │
└─────────────────────────────────────────────────────────┘
```

### Main Process Example

```typescript
// src/main/index.ts
import { app, BrowserWindow, ipcMain } from 'electron';

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 1200, height: 800,
    webPreferences: { preload: join(__dirname, '../preload/index.js') },
  });

  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173');
  } else {
    mainWindow.loadFile(join(__dirname, '../renderer/index.html'));
  }
}

app.whenReady().then(createWindow);

ipcMain.handle('read-file', async (event, filePath) => {
  return require('fs/promises').readFile(filePath, 'utf-8');
});
```

### Preload Script

```typescript
// src/preload/index.ts
import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
  readFile: (path: string) => ipcRenderer.invoke('read-file', path),
  platform: process.platform,
});
```

### Renderer Process

```typescript
// src/renderer/src/App.tsx
function App() {
  const handleOpenFile = async () => {
    const result = await window.electronAPI.readFile('/path/to/file.txt');
    console.log(result);
  };

  return <button onClick={handleOpenFile}>Open File</button>;
}
```

## Tauri Guide

### Project Creation

```bash
# Prerequisite: Rust installation (https://rustup.rs)
npm create tauri-app my-tauri-app
cd my-tauri-app && npm install && npm run tauri dev
```

### Folder Structure

```
my-tauri-app/
├── src/                    # Frontend (React, Vue, etc.)
└── src-tauri/              # Tauri backend (Rust)
    ├── src/main.rs         # Main entry point
    └── tauri.conf.json     # Configuration
```

### Command Definition (Rust)

```rust
// src-tauri/src/lib.rs
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

pub fn run() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet])
        .run(tauri::generate_context!())
        .expect("error");
}
```

### Calling from Frontend

```typescript
import { invoke } from '@tauri-apps/api/core';

const result = await invoke('greet', { name: 'World' });
```

## Web vs Desktop Differences

| Feature | Web | Desktop |
|---------|-----|---------|
| File System | User must select | Free access |
| System Tray | Not possible | Supported |
| Global Shortcuts | Not possible | Supported |
| Offline | Service Worker | Works by default |

## Build & Deployment

### Electron Build

```yaml
# electron-builder.yml
appId: com.example.myapp
mac:
  target: [dmg, zip]
win:
  target: [nsis]
linux:
  target: [AppImage, deb]
```

### Auto-update

```typescript
import { autoUpdater } from 'electron-updater';
autoUpdater.checkForUpdatesAndNotify();
autoUpdater.on('update-downloaded', () => autoUpdater.quitAndInstall());
```

### Tauri Build

```bash
npm run tauri build
# Output: src-tauri/target/release/bundle/
```

## Desktop PDCA Checklist

### Phase 1: Schema
- [ ] Decide local data storage (SQLite, JSON)
- [ ] Decide if cloud sync is needed

### Phase 3: Mockup
- [ ] Consider platform-specific UI guidelines
- [ ] Plan keyboard shortcuts
- [ ] Design menu structure

### Phase 6: UI
- [ ] Support dark/light mode
- [ ] Handle window resizing
- [ ] Handle platform-specific UI differences

### Phase 7: Security
- [ ] Don't expose Node.js APIs directly
- [ ] Security handling for external URLs
- [ ] Encrypt sensitive data storage

### Phase 9: Deployment
- [ ] Code signing (macOS/Windows)
- [ ] Set up auto-update
- [ ] App Store submission (if needed)

## Useful Libraries

### Electron
- electron-store: Local settings storage
- electron-updater: Auto-update
- better-sqlite3: SQLite database

### Tauri
- tauri-plugin-store: Settings storage
- tauri-plugin-sql: SQLite support
- tauri-plugin-updater: Auto-update
