#!/bin/bash

# Git Worktree Helper Uninstaller
# This script removes the git-worktree-helper tool

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

# Main uninstallation function
uninstall_wt() {
    print_info "Uninstalling Git Worktree Helper..."
    echo ""

    local install_path="/usr/local/bin/wt"

    # Check if the tool is installed
    if [ ! -f "$install_path" ]; then
        print_warning "Git Worktree Helper not found at $install_path"
        print_info "It may have been installed elsewhere or already removed"

        # Check if it's available in PATH but not at the expected location
        if command -v wt >/dev/null 2>&1; then
            local wt_location=$(which wt)
            print_info "Found 'wt' command at: $wt_location"
            echo -n "Remove this installation? (y/N): "
            read -r REPLY
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -w "$(dirname "$wt_location")" ]; then
                    rm "$wt_location"
                    print_success "Removed $wt_location"
                else
                    print_info "Administrator privileges required..."
                    sudo rm "$wt_location"
                    print_success "Removed $wt_location"
                fi
            else
                print_info "Uninstallation cancelled"
                exit 0
            fi
        else
            print_info "No 'wt' command found in PATH"
            exit 0
        fi
    else
        # Remove the standard installation
        print_info "Found Git Worktree Helper at: $install_path"

        # Check if we need sudo for removal
        if [ -w "/usr/local/bin" ]; then
            rm "$install_path"
        else
            print_info "Administrator privileges required for removal..."
            sudo rm "$install_path"
        fi

        print_success "Git Worktree Helper removed successfully!"
    fi

    # Verify removal
    if command -v wt >/dev/null 2>&1; then
        local remaining_location=$(which wt)
        print_warning "Another 'wt' command found at: $remaining_location"
        print_info "This may be a different installation or tool"
    else
        print_success "Removal verified - 'wt' command no longer available"
    fi

    echo ""
    print_info "Note: This uninstaller only removes the 'wt' executable"
    print_info "Any existing worktrees created with the tool remain untouched"
    print_info "To clean up worktrees, use 'wt cleanup-all' before uninstalling"
}

# Confirmation prompt
confirm_uninstall() {
    echo "======================================"
    echo "   Git Worktree Helper Uninstaller"
    echo "======================================"
    echo ""
    print_warning "This will remove the Git Worktree Helper tool from your system"
    print_info "Any existing worktrees will remain untouched"
    echo ""
    echo -n "Continue with uninstallation? (y/N): "
    read -r REPLY

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        uninstall_wt
    else
        print_info "Uninstallation cancelled"
        exit 0
    fi
}

# Check if this is a GitHub Actions or automated environment
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    print_info "Detected automated environment, performing silent uninstall"
    uninstall_wt
else
    # Interactive uninstallation
    confirm_uninstall
fi

echo ""
echo "======================================"
print_success "Uninstallation completed!"
echo "======================================"