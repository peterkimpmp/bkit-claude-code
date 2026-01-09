# Environment Setup Guide for Non-Developers

> **Purpose**: Guide anyone to start developing with Claude Code, even without programming experience.
> **Estimated Time**: 30 minutes ~ 1 hour

---

## Before You Start

### Who This Guide is For
- Those new to programming
- Those who have never used terminal/commands
- Those using Claude Code for the first time

### What You'll Need
- A computer (Mac or Windows)
- Internet connection
- Anthropic account (for using Claude)

---

## Step 1: Getting Familiar with Terminal

### What is Terminal?
```
Terminal = A window to communicate with your computer via text

Normal way: Click icon → Program runs
Terminal way: Type command → Program runs

Example: Instead of "open notepad", you type "notepad"
```

### Opening Terminal on Mac
```
1. Press Command + Space (Spotlight search opens)
2. Type "Terminal"
3. Press Enter
4. If a black or white window opens, success!
```

### Opening Terminal on Windows
```
1. Press Windows key
2. Type "PowerShell"
3. Click "Windows PowerShell"
4. If a blue window opens, success!
```

### First Command Practice
Type this command in terminal and press Enter:

```bash
echo "Hello!"
```

If "Hello!" is printed, success!

**✅ Checkpoint**: Can you open terminal and run the echo command?

---

## Step 2: Installing Node.js

### What is Node.js?
```
Node.js = An engine that runs JavaScript

It's a basic tool needed to create websites or apps.
Claude Code also runs on Node.js.
```

### Installation Method

#### Mac
```bash
# 1. Install Homebrew (Mac app installation tool)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Node.js
brew install node
```

#### Windows
```
1. Go to https://nodejs.org
2. Download "LTS" version (stable version)
3. Run downloaded file
4. Click "Next" → "Next" → "Install"
5. Installation complete!
```

### Verify Installation
Run this command in terminal:

```bash
node --version
```

If you see a version number like `v20.x.x`, success!

```bash
npm --version
```

If you see a version number like `10.x.x`, success!

**✅ Checkpoint**: Do `node --version` and `npm --version` output normally?

---

## Step 3: Installing Git

### What is Git?
```
Git = A repository for storing file change history

You know how you sometimes create "final.docx", "final_really.docx", "final_really_final.docx"
when working on documents?

Git does this version management automatically.
You can go back to past versions anytime.
```

### Installation Method

#### Mac
```bash
# Install with Homebrew
brew install git
```

#### Windows
```
1. Go to https://git-scm.com/download/win
2. Run downloaded file
3. Keep clicking "Next" with default options
4. Installation complete!
```

### Verify Installation
```bash
git --version
```

If you see output like `git version 2.x.x`, success!

### Git Initial Setup
Run these commands with **your own** name and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

**✅ Checkpoint**: Does `git --version` output normally?

---

## Step 4: Installing VS Code or Cursor

### What is a Code Editor?
```
Code editor = A notepad for programming

Much more convenient features than regular notepad:
- Code syntax highlighting (improved readability)
- Auto-completion (less typing)
- Error indication (mistake prevention)
```

### Installing VS Code (Free, Recommended)
```
1. Go to https://code.visualstudio.com
2. Download version for your OS
3. Run installation file
4. Run after installation complete
```

### Installing Cursor (Built-in AI features, Recommended)
```
1. Go to https://cursor.sh
2. Click "Download"
3. Run installation file
4. Run after installation complete
```

### Language Settings (VS Code)
```
1. Run VS Code
2. Click the 4 squares icon (Extensions) in left menu
3. Type "Korean" in search (or your preferred language)
4. Install "Korean Language Pack"
5. Restart VS Code
```

**✅ Checkpoint**: Does VS Code or Cursor run?

---

## Step 5: Installing Claude Code

### What is Claude Code?
```
Claude Code = AI programming partner

Converse with Claude in terminal while writing code.
Say "Create a login feature" and it creates the code.
```

### Installation Method
Run this command in terminal:

```bash
npm install -g @anthropic-ai/claude-code
```

### Verify Installation
```bash
claude --version
```

If you see a version number, installation successful!

### API Key Setup
```
1. Go to https://console.anthropic.com
2. Log in (sign up if no account)
3. Click "API Keys" menu
4. Click "Create Key"
5. Copy generated key (sk-ant-... format)
```

Set API key in terminal:

```bash
# Mac/Linux
export ANTHROPIC_API_KEY="sk-ant-paste-your-copied-key-here"

# Windows PowerShell
$env:ANTHROPIC_API_KEY="sk-ant-paste-your-copied-key-here"
```

**⚠️ Important**: Treat your API key like a password! Don't share it with others.

**✅ Checkpoint**: Does `claude --version` output normally?

---

## Step 6: Starting a Project

### Create Project Folder
```bash
# Go to home directory
cd ~

# Create project folder
mkdir my-first-project

# Move to folder
cd my-first-project
```

### Start Claude Code
```bash
claude
```

When Claude Code starts, a welcome message will appear!

### First Conversation
Try saying this in Claude Code:

```
Hi! I'm a programming beginner. I want to create a simple webpage.
```

Claude will guide you kindly!

**✅ Checkpoint**: Can you chat with Claude Code?

---

## Troubleshooting Guide

### "command not found" Error
```
Cause: The program is not installed or path is not set

Solution:
1. Completely close terminal and reopen
2. Redo the installation process for that step
```

### "permission denied" Error
```
Cause: Administrator privileges needed

Solution (Mac/Linux):
Add sudo before the command
Example: sudo npm install -g @anthropic-ai/claude-code

Solution (Windows):
Run PowerShell as "Administrator"
```

### API Key Error
```
Cause: API key is wrong or not set

Solution:
1. Copy API key again
2. Check there are no spaces before/after the key
3. Paste exactly inside the quotes
```

### When It Still Doesn't Work
```
1. Copy the entire error message
2. Paste it to Claude Code and ask "Help me resolve this error"
3. Claude will tell you the solution!
```

---

## Next Steps

Environment setup is complete! Now you can proceed with:

### Recommended Learning Path
```
1. Run /learn-claude-code → Learn Claude Code basics
2. Run /init-starter → Start first project
3. Try creating a simple webpage!
```

### When You Need Help
```
- Type "help" or "/help" in Claude Code
- Show error messages to Claude when errors occur
- Ask "What is XXX?" when unknown terms appear
```

---

## Glossary

| Term | Simple Explanation |
|------|-------------------|
| Terminal | A window to communicate with computer via text |
| Command | Instructions given to the computer |
| Node.js | JavaScript execution engine |
| npm | App installation tool for Node.js |
| Git | File version management tool |
| API Key | Like a password for using a service |
| Project | A working folder for creating an app/website |
| Directory | Another name for folder |
| Path | Location address of file/folder |

---

## Comprehensive Checklist

Check all items before starting:

- [ ] Can open terminal
- [ ] `node --version` output confirmed
- [ ] `npm --version` output confirmed
- [ ] `git --version` output confirmed
- [ ] VS Code or Cursor can run
- [ ] `claude --version` output confirmed
- [ ] API key setup complete
- [ ] Can chat with Claude Code

**If all items are checked, you're ready to start developing!** 🎉
