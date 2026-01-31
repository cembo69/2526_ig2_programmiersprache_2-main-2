$files = @(
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\3_PatternVSC.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\4_PatternAdvanced.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\5_PatternDiagonal.svelte"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    
    # Update the lightness calculations based on new hierarchy
    # Left: Top + 2%
    $content = $content -replace 'const leftL = Math\.max\(0, topL - 1\);', 'const leftL = Math.min(100, topL + 2);'
    
    # Right: Top - 26%
    $content = $content -replace 'const rightL = Math\.max\(0, topL - 37\);', 'const rightL = Math.max(0, topL - 26);'
    
    # Bottom: Top - 25%
    $content = $content -replace 'const bottomL = Math\.max\(0, topL - 39\);', 'const bottomL = Math.max(0, topL - 25);'
    
    # Update comments
    $content = $content -replace '// Left: L - 1%', '// Left: L + 2%'
    $content = $content -replace '// Right: L - 37%', '// Right: L - 26%'
    $content = $content -replace '// Bottom: L - 39%', '// Bottom: L - 25%'
    
    Set-Content $file -Value $content -NoNewline
}

Write-Host "Updated color hierarchy to new values!"
Write-Host "Top: Base"
Write-Host "Left: Top + 2%"
Write-Host "Right: Top - 26%"
Write-Host "Bottom: Top - 25%"
Write-Host "Center: Always black"
