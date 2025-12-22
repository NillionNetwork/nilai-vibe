#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_REMOTE="upstream"
ORIGIN_REMOTE="origin"
UPSTREAM_BRANCH="upstream-main"
MAIN_BRANCH="main"

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo -e "\n${GREEN}=== $1 ===${NC}\n"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Update upstream mirror
update_mirror() {
    print_header "Updating Upstream Mirror"

    print_warning "This will FORCE-UPDATE upstream-main to match upstream/main"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted"
        exit 1
    fi

    git checkout $UPSTREAM_BRANCH
    print_success "Switched to $UPSTREAM_BRANCH"

    git fetch $UPSTREAM_REMOTE
    print_success "Fetched from $UPSTREAM_REMOTE"

    git reset --hard $UPSTREAM_REMOTE/$MAIN_BRANCH
    print_success "Reset to $UPSTREAM_REMOTE/$MAIN_BRANCH"

    git push $ORIGIN_REMOTE $UPSTREAM_BRANCH --force
    print_success "Force-pushed to $ORIGIN_REMOTE/$UPSTREAM_BRANCH"

    print_success "Mirror update complete!"
}

# Rebase main onto upstream
rebase_main() {
    print_header "Rebasing Main onto Upstream"

    git checkout $MAIN_BRANCH
    print_success "Switched to $MAIN_BRANCH"

    print_warning "Starting rebase... If conflicts occur:"
    echo "  1. Fix conflicts in flagged files"
    echo "  2. Run: git add -A"
    echo "  3. Run: git rebase --continue"
    echo ""

    if git rebase $UPSTREAM_BRANCH; then
        print_success "Rebase completed successfully!"

        print_warning "Ready to force-push to origin/main"
        read -p "Push now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push $ORIGIN_REMOTE $MAIN_BRANCH --force-with-lease
            print_success "Pushed to $ORIGIN_REMOTE/$MAIN_BRANCH"
        else
            print_warning "Skipped push. Run manually: git push origin main --force-with-lease"
        fi
    else
        print_error "Rebase encountered conflicts. Resolve them and run:"
        echo "  git add -A"
        echo "  git rebase --continue"
        exit 1
    fi
}

# Full sync workflow
full_sync() {
    print_header "Full Upstream Sync"
    update_mirror
    rebase_main
    print_success "Complete sync finished!"
}

# Create feature branch
create_feature() {
    local feature_name=$1

    if [ -z "$feature_name" ]; then
        print_error "Feature name required"
        echo "Usage: $0 feature <feature-name>"
        exit 1
    fi

    print_header "Creating Feature Branch"

    git checkout $MAIN_BRANCH
    git pull $ORIGIN_REMOTE $MAIN_BRANCH
    print_success "Updated $MAIN_BRANCH"

    git checkout -b "feature/$feature_name"
    print_success "Created and switched to feature/$feature_name"

    echo ""
    print_success "Ready to develop! When done:"
    echo "  git add -A"
    echo "  git commit -m 'feat: your change'"
    echo "  git push -u origin feature/$feature_name"
}

# Show custom changes
show_custom_changes() {
    print_header "Custom Changes (not in upstream)"
    git log $UPSTREAM_BRANCH..$MAIN_BRANCH --oneline --decorate
}

# Show branch status
show_status() {
    print_header "Branch Status"
    git branch -vv
    echo ""
    print_header "Current Branch"
    git status -sb
}

# Help message
show_help() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
    mirror              Update upstream-main mirror
    rebase              Rebase main onto upstream-main
    sync                Full sync (mirror + rebase)
    feature <name>      Create new feature branch
    changes             Show custom changes vs upstream
    status              Show branch status
    help                Show this help message

Examples:
    $0 sync                    # Full upstream sync
    $0 feature my-change       # Create feature/my-change branch
    $0 changes                 # See what we've customized

EOF
}

# Main script logic
check_git_repo

case "${1:-help}" in
    mirror)
        update_mirror
        ;;
    rebase)
        rebase_main
        ;;
    sync)
        full_sync
        ;;
    feature)
        create_feature "$2"
        ;;
    changes)
        show_custom_changes
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
