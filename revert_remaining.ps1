cd "d:\laptop new\f\Personal Projects\badminton\abhi_colab\Cursor1\shuttler"

$commits = @(
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

$count = 2
$total = 15

foreach ($c in $commits) {
    $count++
    $msg = git log -1 --format="%s" $c
    $parents = git show --format="%P" -s $c
    
    Write-Host "[$count/$total] Processing: $msg" -ForegroundColor Cyan
    
    if ($parents.Split(' ').Count -gt 1) {
        Write-Host "  (merge commit, using -m 1)" -ForegroundColor Gray
        git revert --no-edit -m 1 $c 2>&1 | Out-Null
    } else {
        git revert --no-edit $c 2>&1 | Out-Null
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Successfully reverted" -ForegroundColor Green
    } else {
        $output = git revert --no-edit $c 2>&1
        if ($output -match "nothing to commit") {
            Write-Host "  Skipped (already reverted)" -ForegroundColor Yellow
        } else {
            Write-Host "  Error: $output" -ForegroundColor Red
            break
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Revert operation completed" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
git log --oneline -10
