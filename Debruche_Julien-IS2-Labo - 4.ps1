$desktop = [System.Environment]::GetFolderPath("Desktop") #get the desktop environment as a variable
$filename = Read-Host "what's the name of your file to search ?" #get the filename the user wants

#waits for key press function
function waitForKeyPress{ 
    Write-Host "Press any key to close the program"
    [Console]::ReadKey($true) | Out-Null
}

#function to calculate typo score (Levenshtein Distance: lower score = closer match)
function Get-TypoScore ([string]$search, [string]$target) {
    $search = $search.ToLower()
    $target = $target.ToLower()
    $n = $search.Length
    $m = $target.Length
    $d = New-Object 'int[,]' ($n + 1), ($m + 1)

    if ($n -eq 0) { return $m }
    if ($m -eq 0) { return $n }

    for ($i = 0; $i -le $n; $i++) { $d[$i, 0] = $i }
    for ($j = 0; $j -le $m; $j++) { $d[0, $j] = $j }

    for ($i = 1; $i -le $n; $i++) {
        for ($j = 1; $j -le $m; $j++) {
            $cost = if ($target[$j - 1] -eq $search[$i - 1]) { 0 } else { 1 }
            $del = $d[($i - 1), $j] + 1
            $ins = $d[$i, ($j - 1)] + 1
            $sub = $d[($i - 1), ($j - 1)] + $cost
            $d[$i, $j] = [Math]::Min($del, [Math]::Min($ins, $sub))
        }
    }
    return $d[$n, $m]
}

# Check if there is an exact match directly on the desktop
$exactDesktopMatch = Get-ChildItem -Path $desktop -File | Where-Object { $_.BaseName -eq $filename }

if (-not $exactDesktopMatch) {
    Write-Host "file not found on desktop, searching in 1 level deep folders"
    # Expand search to include 1 level deep folders
    $filesToSearch = Get-ChildItem -Path $desktop -File -Recurse -Depth 1
} else {
    # Keep search limited to the desktop root
    $filesToSearch = Get-ChildItem -Path $desktop -File
}

#pipeline: get files -> sort by lowest typo score -> pick the #1 closest match
$closestFile = $filesToSearch | 
    Sort-Object { Get-TypoScore $filename $_.BaseName } | 
    Select-Object -First 1

if ($closestFile) {
    Write-Host "I found $($closestFile.Name)"
    
    # Ask the user if they want to open it (typed response triggered by Enter)
    $choice = Read-Host "would you like to open this file? (yes / no)"
    
    if ($choice.ToLower() -eq 'yes') {
        Invoke-Item $closestFile.FullName
    }
} else {
    Write-Host "No files found."
}

waitForKeyPress