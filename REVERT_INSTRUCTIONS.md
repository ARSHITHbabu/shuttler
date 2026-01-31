# Reverting Commits from 7bfe2aa Onwards

This guide helps you revert all commits starting from `7bfe2aa28449e9a1411b3f444536db68bbac2a8a` using **Option 2: Git Revert** (preserves history).

## What This Does

- Creates new commits that undo the changes from commit `7bfe2aa` onwards
- Preserves the commit history (safer for shared branches)
- Allows you to push the revert commits to remote

## Prerequisites

1. Make sure you're on the correct branch (usually `main` or `master`)
2. Ensure your working directory is clean (no uncommitted changes)
3. Have the repository cloned locally

## Steps to Execute

### Step 1: Navigate to your repository
```powershell
cd "path\to\your\shuttler\repository"
```

### Step 2: Check current status
```powershell
git status
git log --oneline -10
```

### Step 3: Run the revert script
```powershell
.\revert_commits.ps1
```

The script will:
- Show you which commits will be reverted
- Ask for confirmation
- Revert each commit in reverse order (newest to oldest)
- Show the final status

### Step 4: Review the changes
```powershell
git log --oneline -15
git status
```

### Step 5: Push the revert commits

**If you haven't pushed the original commits yet:**
```powershell
git push origin main
```

**If you've already pushed the original commits:**
```powershell
# Option A: Force push with lease (safer)
git push --force-with-lease origin main

# Option B: Regular force push (use with caution)
git push --force origin main
```

## Manual Alternative

If you prefer to do it manually:

```powershell
# 1. Get the parent commit of 7bfe2aa
git rev-parse 7bfe2aa28449e9a1411b3f444536db68bbac2a8a^

# 2. Get list of commits to revert (newest to oldest)
git rev-list HEAD ^<parent-commit-hash>

# 3. Revert each commit individually (newest first)
git revert --no-edit <commit-hash-1>
git revert --no-edit <commit-hash-2>
# ... continue for all commits

# 4. Push the changes
git push origin main
```

## Troubleshooting

### Merge Conflicts
If you encounter merge conflicts during revert:
1. Resolve conflicts in the affected files
2. Stage resolved files: `git add <file>`
3. Continue: `git revert --continue`
4. Or abort: `git revert --abort`

### Wrong Branch
If you're on the wrong branch:
```powershell
git checkout main  # or your target branch
```

### Uncommitted Changes
If you have uncommitted changes:
```powershell
git stash  # Save changes temporarily
# Run revert script
git stash pop  # Restore changes after
```

## Alternative: Option 1 (Reset - Destructive)

If you want to completely remove the commits (destructive, use only if commits aren't pushed or you're okay rewriting history):

```powershell
# WARNING: This will delete commits permanently
git reset --hard 7bfe2aa28449e9a1411b3f444536db68bbac2a8a^
git push --force origin main
```

**Note:** Only use reset if:
- The commits haven't been pushed to remote, OR
- You're okay with rewriting history and have coordinated with your team

## Verification

After reverting, verify:
1. Your code is in the expected state
2. The application runs correctly
3. No important changes were lost
4. The commit history shows the revert commits
