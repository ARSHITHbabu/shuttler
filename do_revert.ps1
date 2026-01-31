cd "d:\laptop new\f\Personal Projects\badminton\abhi_colab\Cursor1\shuttler"

$commits = @(
    "556d2525d8147ab041c073726fd3f03dde0f9585",
    "39a7d9fe86865143bfe071ac4146c3d98caaff5a",
    "f2989bc60a0123f0b0a337db05d2eab926b94002",
    "b42638cc3c15b06f196259cf2cce2d84f03d7cad",
    "d24582744dde551007ab6bf2b7f23afc5d14f1cf",
    "7cb0287c33c1635d05a837c51a26d09513f039cf",
    "b38e1020f626e0a1d32463bbaf6c98fd41211537",
    "16373cded091488159a78a2174c00cf018e42898",
    "7f7a52362d645c764f4f54cf69bbc05d0642f108",
    "457d5507c1122589ed7b6a9418fed62feaec23c2",
    "4d58efb31454d7665d3fbcea62c102c4559d44c6",
    "c68a7674f758ca9587a5e5e76ad323103fb61896",
    "288d9cef8b7af886cbc6b0e85795b19e2ca88b36",
    "e2019ed0aedd752a984799cf7455a3b90d44e68a",
    "7bfe2aa28449e9a1411b3f444536db68bbac2a8a"
)

$count = 0
$total = $commits.Count

Write-Host "Starting revert of $total commits..." -ForegroundColor Green
Write-Host ""

foreach ($commit in $commits) {
    $count++
    $msg = git log -1 --format="%s" $commit
    Write-Host "[$count/$total] Reverting: $msg" -ForegroundColor Cyan
    Write-Host "  Commit: $commit" -ForegroundColor Gray
    
    git revert --no-edit $commit
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Failed to revert commit $commit" -ForegroundColor Red
        Write-Host "You may need to resolve conflicts manually." -ForegroundColor Yellow
        Write-Host "After resolving conflicts:" -ForegroundColor Yellow
        Write-Host "  1. git add <resolved-files>" -ForegroundColor White
        Write-Host "  2. git revert --continue" -ForegroundColor White
        Write-Host "  3. Or abort: git revert --abort" -ForegroundColor White
        exit 1
    } else {
        Write-Host "  ✓ Successfully reverted" -ForegroundColor Green
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Successfully reverted $total commit(s)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Current status:" -ForegroundColor Cyan
git status
Write-Host ""
Write-Host "Recent commits:" -ForegroundColor Cyan
git log --oneline -10
