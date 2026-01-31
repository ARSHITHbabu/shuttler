"""
Setup script for automatic schema registry discovery.

This script sets up automatic discovery mechanisms:
1. Git pre-commit hook (runs before commits)
2. Instructions for file watcher (runs when files change)

Run this once to set up automatic discovery.
"""

import os
import stat
import sys
from pathlib import Path

def setup_git_hook():
    """Set up git pre-commit hook"""
    project_root = Path(__file__).parent.parent
    git_hooks_dir = project_root / ".git" / "hooks"
    pre_commit_hook = git_hooks_dir / "pre-commit"
    
    if not git_hooks_dir.exists():
        print("Error: .git/hooks directory not found. Are you in a git repository?")
        return False
    
    hook_content = '''#!/bin/sh
#
# Git pre-commit hook to automatically update database schema registry
# This runs automatically before every commit

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Check if main.py or any SQL migration files changed
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if echo "$CHANGED_FILES" | grep -qE "(Backend/main\\.py|Backend/.*\\.sql|Backend/generate_schema_registry\\.py)"; then
    echo "Detected database schema changes. Updating schema registry..."
    
    cd "$PROJECT_ROOT/Backend" || exit 1
    
    # Run the schema registry generator
    python generate_schema_registry.py
    
    # Check if registry was updated
    if git diff --quiet Backend/DATABASE_SCHEMA_REGISTRY.md; then
        echo "Schema registry is up to date."
    else
        echo "Schema registry updated. Adding to commit..."
        git add Backend/DATABASE_SCHEMA_REGISTRY.md
    fi
fi

exit 0
'''
    
    try:
        with open(pre_commit_hook, 'w') as f:
            f.write(hook_content)
        
        # Make executable (Unix/Linux/Mac)
        if sys.platform != 'win32':
            os.chmod(pre_commit_hook, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)
        
        print(f"Git pre-commit hook installed: {pre_commit_hook}")
        return True
    except Exception as e:
        print(f"Error setting up git hook: {e}")
        return False

def check_dependencies():
    """Check if required dependencies are installed"""
    try:
        import watchdog
        print("watchdog library installed")
        return True
    except ImportError:
        print("watchdog library not found")
        print("  Install it with: pip install watchdog")
        return False

def main():
    """Main setup function"""
    print("=" * 60)
    print("Setting up Automatic Schema Registry Discovery")
    print("=" * 60)
    print()
    
    # Setup git hook
    print("1. Setting up Git pre-commit hook...")
    git_hook_ok = setup_git_hook()
    print()
    
    # Check dependencies
    print("2. Checking dependencies...")
    deps_ok = check_dependencies()
    print()
    
    print("=" * 60)
    print("Setup Summary")
    print("=" * 60)
    
    if git_hook_ok:
        print("Git pre-commit hook: Will auto-update registry before commits")
    else:
        print("Git pre-commit hook: Setup failed (may need manual setup)")
    
    if deps_ok:
        print("File watcher: Ready (run 'python Backend/watch_schema_changes.py')")
    else:
        print("File watcher: Install watchdog first (pip install watchdog)")
    
    print()
    print("Automatic Discovery Options:")
    print("1. Git pre-commit hook: Runs automatically before commits (backup safety)")
    print("2. File watcher: Run 'python Backend/watch_schema_changes.py' for real-time feedback")
    print()
    print("Recommendation:")
    print("  - Use file watcher during development for real-time warnings")
    print("  - Git hook ensures registry is updated even if watcher wasn't running")

if __name__ == "__main__":
    main()
