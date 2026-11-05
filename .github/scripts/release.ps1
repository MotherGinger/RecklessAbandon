<#
.SYNOPSIS
Cuts a release: files the Unreleased changelog entries under the new version,
updates the TOC versions, commits "Bump to v<version>", and tags it.

.DESCRIPTION
Pushing the tag starts .github/workflows/release.yml, which builds the zip,
creates the GitHub release, and uploads to Wago.

.EXAMPLE
./.github/scripts/release.ps1 3.2.0

.EXAMPLE
./.github/scripts/release.ps1 3.2.0-beta.1 -Push
#>
param(
    [Parameter(Mandatory)]
    [string]$Version,

    # Push the commit and tag to origin, which starts the release workflow
    [switch]$Push
)

$ErrorActionPreference = 'Stop'

function Invoke-Git {
    $output = & git @args
    if ($LASTEXITCODE -ne 0) {
        throw "git $($args -join ' ') failed"
    }
    $output
}

# Rewrites a text file, keeping its line endings and BOM (or lack of one)
function Update-TextFile([string]$Path, [scriptblock]$Transform) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $text = [IO.File]::ReadAllText($Path)
    $newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

    $lines = & $Transform ($text -split "`r?`n")

    [IO.File]::WriteAllText($Path, ($lines -join $newline), [Text.UTF8Encoding]::new($hasBom))
}

$Version = $Version.TrimStart('v')
if ($Version -notmatch '^\d+\.\d+\.\d+(-(alpha|beta)\.\d+)?$') {
    throw "'$Version' is not a version like 3.2.0 or 3.2.0-beta.1"
}
$tag = "v$Version"

$root = Invoke-Git rev-parse --show-toplevel
Push-Location $root
try {
    if (Invoke-Git status --porcelain) {
        throw 'The working tree has uncommitted changes. Commit or stash them first.'
    }

    & git rev-parse --quiet --verify "refs/tags/$tag" *> $null
    if ($LASTEXITCODE -eq 0) {
        throw "Tag $tag already exists."
    }

    $branch = Invoke-Git branch --show-current
    if ($branch -ne 'main') {
        Write-Warning "Releasing from '$branch', not 'main'."
    }

    # Changelog: "- Unreleased" keeps its place and the entries under it move to "- v<version>".
    # Betas and alphas leave the entries under Unreleased so the full release still carries them.
    $prerelease = $Version -match '-(alpha|beta)\.'
    Update-TextFile (Join-Path $root 'CHANGELOG.txt') {
        param($lines)

        $start = [Array]::FindIndex([string[]]$lines, [Predicate[string]] { $args[0].TrimEnd() -eq '- Unreleased' })
        if ($start -lt 0) {
            throw "CHANGELOG.txt has no '- Unreleased' section."
        }

        $end = $start + 1
        while ($end -lt $lines.Count -and $lines[$end] -notmatch '^- ') {
            $end++
        }

        # PowerShell ranges count down when the end is below the start, so guard the empty case explicitly
        $entries = if ($end -gt $start + 1) { @($lines[($start + 1)..($end - 1)] | Where-Object { $_.Trim() }) } else { @() }
        if ($entries.Count -eq 0) {
            throw "The Unreleased section of CHANGELOG.txt is empty. Add the changes in $tag first."
        }

        if ($prerelease) {
            $lines
        } else {
            @($lines[0..$start]) + '' + "- $tag" + @($lines[($start + 1)..($lines.Count - 1)])
        }
    }

    # TOCs: every "## Version:" line
    $tocs = Get-ChildItem (Join-Path $root 'RecklessAbandon') -Filter '*.toc'
    foreach ($toc in $tocs) {
        Update-TextFile $toc.FullName {
            param($lines)
            $lines | ForEach-Object { if ($_ -match '^## Version:') { "## Version: $Version" } else { $_ } }
        }
    }

    $changed = @('CHANGELOG.txt') + @($tocs | ForEach-Object { $_.FullName })
    Invoke-Git add @changed | Out-Null
    Invoke-Git commit --quiet -m "Bump to $tag" | Out-Null
    Invoke-Git tag $tag | Out-Null
    Write-Host "Committed and tagged $tag."

    if ($Push) {
        Invoke-Git push origin HEAD | Out-Null
        Invoke-Git push origin $tag | Out-Null
        Write-Host "Pushed $tag. The release workflow will publish it to GitHub and Wago."
    } else {
        Write-Host "Push when ready to publish:"
        Write-Host "  git push origin HEAD"
        Write-Host "  git push origin $tag"
    }
} finally {
    Pop-Location
}
