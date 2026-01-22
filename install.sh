#!/bin/bash

# Git Worktree Helper Installer
# This script installs the git-worktree-helper tool
#
# Usage:
#   ./install.sh          # Symlink (default, changes picked up instantly)
#   ./install.sh --copy   # Copy file (traditional, requires reinstall for changes)

set -e

# Parse arguments
INSTALL_MODE="link"
SHOW_HELP=false
for arg in "$@"; do
    case $arg in
        --copy)
            INSTALL_MODE="copy"
            ;;
        --link)
            INSTALL_MODE="link"
            ;;
        --help|-h)
            SHOW_HELP=true
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to detect shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Main installation function
install_wt() {
    if [ "$INSTALL_MODE" = "link" ]; then
        print_info "Installing Git Worktree Helper (symlink mode)..."
    else
        print_info "Installing Git Worktree Helper (copy mode)..."
    fi
    echo ""

    # Check if we're in the git-worktree-helper directory
    if [ ! -f "bin/wt" ]; then
        print_error "bin/wt not found. Please run this script from the git-worktree-helper directory."
        exit 1
    fi

    # Get absolute path of source file for symlink
    local source_path="$(cd "$(dirname "bin/wt")" && pwd)/$(basename "bin/wt")"

    # Create installation directory
    local install_dir="/usr/local/bin"
    local install_path="$install_dir/wt"

    # Check if install directory exists and is writable
    if [ ! -d "$install_dir" ]; then
        print_info "Creating $install_dir directory..."
        sudo mkdir -p "$install_dir"
    fi

    # Remove existing installation (file or symlink)
    if [ -e "$install_path" ] || [ -L "$install_path" ]; then
        if [ ! -w "$install_dir" ]; then
            sudo rm -f "$install_path"
        else
            rm -f "$install_path"
        fi
    fi

    # Install based on mode
    if [ ! -w "$install_dir" ]; then
        print_info "Administrator privileges required for installation to $install_dir"
        print_info "You may be prompted for your password..."
        if [ "$INSTALL_MODE" = "link" ]; then
            sudo ln -sf "$source_path" "$install_path"
        else
            sudo cp bin/wt "$install_path"
            sudo chmod +x "$install_path"
        fi
    else
        if [ "$INSTALL_MODE" = "link" ]; then
            ln -sf "$source_path" "$install_path"
        else
            cp bin/wt "$install_path"
            chmod +x "$install_path"
        fi
    fi

    # Verify installation (check for file OR symlink, and executable)
    if [ -x "$install_path" ]; then
        print_success "Git Worktree Helper installed successfully!"
        echo ""
        if [ "$INSTALL_MODE" = "link" ]; then
            print_info "Installation: $install_path -> $source_path (symlink)"
            print_success "Changes to bin/wt will be picked up automatically!"
        else
            print_info "Installation path: $install_path (copy)"
            print_warning "Re-run ./install.sh after making changes to bin/wt"
        fi

        # Check if /usr/local/bin is in PATH
        if echo "$PATH" | grep -q "/usr/local/bin"; then
            print_success "/usr/local/bin is already in your PATH"
        else
            print_warning "/usr/local/bin is not in your PATH"
            echo ""
            print_info "To add it to your PATH, add this line to your shell configuration:"

            local shell=$(detect_shell)
            case $shell in
                "zsh")
                    echo "  echo 'export PATH=\"/usr/local/bin:\$PATH\"' >> ~/.zshrc"
                    echo "  source ~/.zshrc"
                    ;;
                "bash")
                    echo "  echo 'export PATH=\"/usr/local/bin:\$PATH\"' >> ~/.bashrc"
                    echo "  source ~/.bashrc"
                    ;;
                *)
                    echo "  export PATH=\"/usr/local/bin:\$PATH\""
                    ;;
            esac
        fi

        echo ""
        print_info "You can now use the 'wt' command from anywhere!"
        print_info "Try: wt --help"

        # Test if command is available
        if command -v wt >/dev/null 2>&1; then
            echo ""
            print_success "Installation verified - 'wt' command is available!"
            echo ""
            print_info "Quick start:"
            echo "  wt --help                    # Show help"
            echo "  wt my-feature               # Create a new worktree"
            echo "  wt list                     # List running servers"
            echo "  wt remove my-feature        # Remove a worktree"
        else
            echo ""
            print_warning "Command 'wt' not found in current PATH"
            print_info "You may need to restart your terminal or source your shell configuration"
        fi

    else
        print_error "Installation failed - could not create executable at $install_path"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --link    Install as symlink (default) - changes picked up instantly"
    echo "  --copy    Install as copy - requires reinstall for changes"
    echo ""
}

# Check if this is a GitHub Actions or automated environment
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    print_info "Detected automated environment, skipping interactive installation"
    exit 0
fi

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
    show_usage
    exit 0
fi

# Main execution
echo "======================================"
echo "    Git Worktree Helper Installer"
echo "    Mode: $INSTALL_MODE"
echo "======================================"
echo ""

install_wt

echo ""
echo "======================================"
print_success "Installation completed successfully!"
echo "======================================"