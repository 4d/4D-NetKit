param([string]$File = '')
$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$docDir = Join-Path $PSScriptRoot 'Documentation/Classes'
$excluded = @('Google','JWT','OAuth2Provider','Office365')
$nonFuncSections = @('Overview','Table of Contents','Properties','See also')

function Get-Key([string]$Line) {
    if ($Line -match '^\*\s*\[\.?([A-Za-z0-9_]+)') { return $Matches[1].ToLower() }
    if ($Line -match '^###\s+\.?([A-Za-z0-9_]+)') { return $Matches[1].ToLower() }
    return $Line.ToLower()
}

function Process-File([string]$path) {
    $lines = [System.IO.File]::ReadAllLines($path, [System.Text.Encoding]::UTF8)
    $n = $lines.Length
    $out = New-Object 'System.Collections.Generic.List[string]'
    $i = 0
    while ($i -lt $n) {
        $line = $lines[$i]

        if ($line -match '^##\s+Table of Contents\s*$') {
            $out.Add($line); $i++
            while ($i -lt $n -and -not ($lines[$i] -match '^##\s')) {
                if ($lines[$i] -match '^###\s') {
                    $out.Add($lines[$i]); $i++
                    $lead = New-Object 'System.Collections.Generic.List[string]'
                    $bullets = New-Object 'System.Collections.Generic.List[string]'
                    $tail = New-Object 'System.Collections.Generic.List[string]'
                    while ($i -lt $n -and -not ($lines[$i] -match '^###\s') -and -not ($lines[$i] -match '^##\s')) {
                        if ($lines[$i] -match '^\*\s*\[') { $bullets.Add($lines[$i]) }
                        elseif ($bullets.Count -eq 0) { $lead.Add($lines[$i]) }
                        else { $tail.Add($lines[$i]) }
                        $i++
                    }
                    $sorted = $bullets.ToArray() | Sort-Object -Property @{ Expression = { Get-Key $_ } }
                    foreach ($l in $lead) { $out.Add($l) }
                    foreach ($b in $sorted) { $out.Add($b) }
                    foreach ($t in $tail) { $out.Add($t) }
                } else {
                    $out.Add($lines[$i]); $i++
                }
            }
            continue
        }

        if ($line -match '^##\s+(.+?)\s*$' -and ($Matches[1].Trim() -notin $nonFuncSections)) {
            $out.Add($line); $i++
            $intro = New-Object 'System.Collections.Generic.List[string]'
            $blocks = New-Object 'System.Collections.Generic.List[object]'
            $cur = $null
            while ($i -lt $n -and -not ($lines[$i] -match '^##\s')) {
                if ($lines[$i] -match '^###\s') {
                    if ($null -ne $cur) { $blocks.Add($cur) }
                    $cur = New-Object 'System.Collections.Generic.List[string]'
                    $cur.Add($lines[$i])
                } elseif ($null -eq $cur) {
                    $intro.Add($lines[$i])
                } else {
                    $cur.Add($lines[$i])
                }
                $i++
            }
            if ($null -ne $cur) { $blocks.Add($cur) }

            foreach ($x in $intro) { $out.Add($x) }
            if ($blocks.Count -gt 0) {
                $keyed = foreach ($b in $blocks) { [pscustomobject]@{ Key = (Get-Key $b[0]); Block = $b } }
                $sorted = $keyed | Sort-Object -Property Key
                foreach ($item in $sorted) {
                    $blk = $item.Block
                    $end = $blk.Count - 1
                    while ($end -ge 0 -and $blk[$end].Trim() -eq '') { $end-- }
                    for ($k = 0; $k -le $end; $k++) { $out.Add($blk[$k]) }
                    $out.Add('')
                }
            }
            continue
        }

        $out.Add($line); $i++
    }

    $text = ($out.ToArray() -join "`r`n")
    $text = [System.Text.RegularExpressions.Regex]::Replace($text, '(\r\n){3,}', "`r`n`r`n")
    $text = $text.TrimEnd("`r","`n") + "`r`n"
    [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}

if ($File -ne '') {
    Process-File (Join-Path $docDir "$File.md")
    Write-Output "Sorted: $File"
} else {
    $files = Get-ChildItem $docDir -Filter '*.md' | Where-Object { $_.BaseName -notin $excluded }
    foreach ($f in $files) { Process-File $f.FullName; Write-Output "Sorted: $($f.BaseName)" }
}
