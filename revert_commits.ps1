# Script to revert all commits from 7bfe2aa onwards
# This uses git revert to create new commits that undo the changes (preserves history)

Write-Host "Reverting commits from 7bfe2aa28449e9a1411b3f444536db68bbac2a8a onwards..." -ForegroundColor Yellow

# First, let's check the current branch and status
Write-Host "`nCurrent branch:" -ForegroundColor Cyan
git branch --show-current

Write-Host "`nRecent commits:" -ForegroundColor Cyan
git log --oneline -10

# Get the commit hash before 7bfe2aa
$targetCommit = "7bfe2aa28449e9a1411b3f444536db68bbac2a8a"
$parentCommit = git rev-parse "$targetCommit^"

Write-Host "`nTarget commit to revert from: $targetCommit" -ForegroundColor Yellow
Write-Host "Parent commit (will revert to this state): $parentCommit" -ForegroundColor Yellow

# Get all commits from HEAD down to (but not including) the parent commit
Write-Host "`nGetting list of commits to revert..." -ForegroundColor Cyan
$commitsToRevert = git rev-list --reverse HEAD ^$parentCommit

if ($commitsToRevert.Count -eq 0) {
    Write-Host "No commits found to revert. The branch might already be at or before the target commit." -ForegroundColor Red
    exit 1
}

Write-Host "`nCommits that will be reverted:" -ForegroundColor Cyan
$commitsToRevert | ForEach-Object { Write-Host "  $_" }

# Confirm before proceeding
Write-Host "`nWARNING: This will create revert commits for all commits listed above." -ForegroundColor Red
$confirmation = Read-Host "Do you want to proceed? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit 0
}

# Revert commits in reverse order (newest to oldest)
# git revert works best when reverting newest to oldest
$commitsToRevertReverse = git rev-list HEAD ^$parentCommit

Write-Host "`nReverting commits (newest to oldest)..." -ForegroundColor Green

$revertCount = 0
$commitsToRevertReverse | ForEach-Object {
    $commitHash = $_
    $commitMessage = git log -1 --format="%s" $commitHash
    Write-Host "`nReverting commit: $commitHash" -ForegroundColor Cyan
    Write-Host "  Message: $commitMessage" -ForegroundColor Gray
    
    git revert --no-edit $commitHash
    if ($LASTEXITCODE -eq 0) {
        $revertCount++
        Write-Host "  ✓ Successfully reverted" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to revert commit $commitHash" -ForegroundColor Red
        Write-Host "`nYou may need to resolve conflicts manually." -ForegroundColor Yellow
        Write-Host "After resolving conflicts:" -ForegroundColor Yellow
        Write-Host "  1. git add <resolved-files>" -ForegroundColor White
        Write-Host "  2. git revert --continue" -ForegroundColor White
        Write-Host "  3. Or abort: git revert --abort" -ForegroundColor White
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Successfully reverted $revertCount commit(s)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCurrent status:" -ForegroundColor Cyan
git status

Write-Host "`nRecent commits (showing revert commits):" -ForegroundColor Cyan
git log --oneline -10

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review the changes with: git log --oneline -15" -ForegroundColor White
Write-Host "2. Test your application to ensure everything works" -ForegroundColor White
Write-Host "3. Push the revert commits: git push origin <branch-name>" -ForegroundColor White
Write-Host "   (Use --force-with-lease if you've already pushed the original commits)" -ForegroundColor White
