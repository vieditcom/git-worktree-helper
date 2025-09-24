#!/bin/bash

# Git Worktree Helper Installer
# This script installs the git-worktree-helper tool

set -e

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
    print_info "Installing Git Worktree Helper..."
    echo ""

    # Check if we're in the git-worktree-helper directory
    if [ ! -f "bin/wt" ]; then
        print_error "bin/wt not found. Please run this script from the git-worktree-helper directory."
        exit 1
    fi

    # Create installation directory
    local install_dir="/usr/local/bin"
    local install_path="$install_dir/wt"

    # Check if install directory exists and is writable
    if [ ! -d "$install_dir" ]; then
        print_info "Creating $install_dir directory..."
        sudo mkdir -p "$install_dir"
    fi

    # Check if we need sudo for installation
    if [ ! -w "$install_dir" ]; then
        print_info "Administrator privileges required for installation to $install_dir"
        print_info "You may be prompted for your password..."
        sudo cp bin/wt "$install_path"
        sudo chmod +x "$install_path"
    else
        cp bin/wt "$install_path"
        chmod +x "$install_path"
    fi

    # Verify installation
    if [ -f "$install_path" ] && [ -x "$install_path" ]; then
        print_success "Git Worktree Helper installed successfully!"
        echo ""
        print_info "Installation path: $install_path"

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

# Check if this is a GitHub Actions or automated environment
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    print_info "Detected automated environment, skipping interactive installation"
    exit 0
fi

# Main execution
echo "======================================"
echo "    Git Worktree Helper Installer"
echo "======================================"
echo ""

install_wt

echo ""
echo "======================================"
print_success "Installation completed successfully!"
echo "======================================"