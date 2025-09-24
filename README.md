# Git Worktree Helper

A powerful command-line tool that simplifies Git worktree management with automatic server setup for Rails and Node.js projects.

## Features

- 🚀 **One-command worktree creation** with automatic branch creation
- 📦 **Automatic dependency installation** (Ruby gems, Node.js packages)
- 🚂 **Rails server auto-start** with smart port allocation
- 📦 **Webpack dev server support** with compilation monitoring
- 🔐 **Credential copying** (.env, Rails credentials, master.key)
- 📁 **IDE configuration copying** (.idea, .vscode, etc.)
- 💻 **RubyMine integration** with automatic window management
- 🌐 **Auto browser opening** when Rails server is ready
- 📋 **Log management** with easy viewing commands
- 🧹 **Intelligent cleanup** with IDE window closing and server shutdown
- 📊 **Server monitoring** and listing capabilities

## Installation

### Quick Install

```bash
# Clone or download the git-worktree-helper
cd git-worktree-helper
./install.sh
```

### Manual Install

```bash
# Copy the script to your PATH
sudo cp bin/wt /usr/local/bin/wt
sudo chmod +x /usr/local/bin/wt

# Verify installation
wt --help
```

## Usage

### Create a New Worktree

```bash
# Create worktree for a new feature
wt my-feature

# This will:
# 1. Create a new branch 'my-feature'
# 2. Create worktree in ../project-name-worktrees/my-feature/
# 3. Copy .env, credentials, and IDE configs
# 4. Install dependencies (bundle install, yarn install)
# 5. Start Rails server on available port (3001+)
# 6. Start Webpack dev server if available
# 7. Open in RubyMine IDE
# 8. Open browser when Rails is ready
```

### Manage Worktrees

```bash
# List all running servers
wt list

# View Rails logs
wt logs my-feature

# View Webpack logs
wt webpack-logs my-feature

# Stop servers in current worktree
wt stop

# Remove worktree, stop servers, and close RubyMine window
wt remove my-feature

# Merge feature, cleanup, and close RubyMine window
wt merge my-feature main

# Or merge into main branch (default)
wt merge my-feature

# Remove ALL worktrees (careful!)
wt cleanup-all
```

### Get Help

```bash
# Show all commands
wt --help

# Show version
wt --version
```

## How It Works

### Directory Structure

When you run `wt my-feature` in a project located at `/path/to/myproject/`, it creates:

```
/path/to/
├── myproject/                 # Original project
└── myproject-worktrees/       # Worktrees directory
    └── my-feature/            # Your feature worktree
        ├── .env               # Copied from main
        ├── config/
        │   ├── credentials.yml.enc
        │   └── master.key
        ├── tmp/
        │   ├── .rails_pid
        │   ├── .rails_port
        │   ├── rails.log
        │   └── webpack.log
        └── ...                # Full project files
```

### Smart Port Allocation

- **Rails servers**: Start from port 3001, auto-increment if busy
- **Webpack servers**: Start from port 3036, auto-increment if busy
- **Main project**: Preserves ports 3000 (Rails) and 3035 (Webpack)

### Automatic File Copying

The tool automatically copies essential files from the main project:

- **Environment**: `.env`
- **Rails credentials**: `config/credentials.yml.enc`, `config/master.key`
- **IDE configs**: `.vscode/`, `.idea/`, etc.
- **GitHub**: `.github/`

## Requirements

- **Git** with worktree support
- **Ruby/Rails** projects: `bundle` command available
- **Node.js** projects: `yarn` command available
- **macOS/Linux**: Uses `lsof` for port detection
- **Optional**: RubyMine IDE for automatic window management

## Examples

### Basic Workflow

```bash
# Start working on a new feature
cd ~/projects/my-rails-app
wt user-authentication

# Your feature worktree is created and Rails starts on port 3001
# Browser opens to http://localhost:3001
# RubyMine IDE opens the worktree

# Work on your feature...

# When done, merge and cleanup (defaults to main branch)
wt merge user-authentication

# Or just remove without merging
wt remove user-authentication
```

### Multiple Features

```bash
# Work on multiple features simultaneously
wt feature-a    # Rails on port 3001
wt feature-b    # Rails on port 3002
wt feature-c    # Rails on port 3003

# List all running servers
wt list

# Switch between worktrees by cd'ing to them
cd ../my-rails-app-worktrees/feature-a/
cd ../my-rails-app-worktrees/feature-b/

# Clean up when done
wt remove feature-a
wt remove feature-b
wt remove feature-c
```

### Log Monitoring

```bash
# View Rails logs in real-time
wt logs my-feature

# View Webpack compilation logs
wt webpack-logs my-feature

# From within a worktree directory
cd ../my-project-worktrees/my-feature/
wt logs        # Auto-detects feature name
```

## Troubleshooting

### Command Not Found

If `wt` command is not found after installation:

```bash
# Check if /usr/local/bin is in PATH
echo $PATH

# Add to PATH if missing (choose your shell)
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc   # Zsh
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc  # Bash

# Reload shell configuration
source ~/.zshrc  # or ~/.bashrc
```

### Server Won't Start

If Rails/Webpack servers fail to start:

```bash
# Check logs
tail -f tmp/rails.log
tail -f tmp/webpack.log

# Check for port conflicts
lsof -i :3001

# Stop conflicting processes
wt list
wt stop
```

### Permission Issues

If you get permission errors during installation:

```bash
# Ensure you have write access to /usr/local/bin
ls -la /usr/local/bin/

# Or install to a different directory
cp bin/wt ~/bin/wt  # If ~/bin is in your PATH
```

## Updating After Local Changes

If you modify the script locally and want to apply the changes:

```bash
# Reinstall the updated script
./install.sh

# Reload your shell configuration to pick up any changes
source ~/.zshrc    # For Zsh users
# or
source ~/.bashrc   # For Bash users

# Verify the update worked
wt --version
```

### RubyMine Integration

The tool includes intelligent RubyMine integration:

- **Automatic window opening** when creating worktrees
- **Smart window closing** when removing/merging worktrees
- **IDE folder cleanup** (`.idea` folder) to prevent removal issues
- **Graceful fallbacks** if RubyMine isn't running or available

The window management works by:
1. Detecting RubyMine windows by name matching
2. Closing specific windows before worktree removal
3. Cleaning up IDE lock files that might prevent folder deletion
4. Providing clear feedback on window operations

## Uninstallation

```bash
# Run the uninstaller
./uninstall.sh

# Or remove manually
sudo rm /usr/local/bin/wt
```

## Development

### Project Structure

```
git-worktree-helper/
├── bin/
│   └── wt              # Main executable script
├── install.sh          # Installation script
├── uninstall.sh        # Uninstallation script
└── README.md           # This file
```

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b my-feature`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - feel free to use and modify as needed.

## Version History

- **v1.0.0** - Initial release with full worktree management capabilities