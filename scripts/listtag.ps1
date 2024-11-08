$repos = Get-ChildItem -Directory
$currentDir = Get-Location

foreach ($repo in $repos) {
  Set-Location $repo
  # git fetch --all *>$null
  git checkout main *>$null
  git pull *>$null
  $lastCommit = (git log -n1 --format="%h")
  $lastTag = (git describe --abbrev=0 --tags)
  $lastTagCommit = $lastCommit
  if ([bool]$lastTag) {
    $lastTagCommit = (git rev-list -n 1 --abbrev-commit --format="%h" $lastTag | Select-Object -Last 1)
  }

  $color = @("Red", "Green")[[byte]($lastCommit -eq $lastTagCommit)]

  Write-Host "$repo"  -ForegroundColor $color
  Write-Host "`tLast Commit: $lastCommit"
  Write-Host "`tLast Tag: "  -NoNewline
  Write-Host "$lastTag" -ForegroundColor Blue -NoNewline
  Write-Host " ($lastTagCommit)"
  Write-Host ""
  Set-Location $currentDir
}
