$files = @(
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\3_PatternVSC.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\4_PatternAdvanced.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\5_PatternDiagonal.svelte"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    
    # Replace the cCenter logic to always use fc.cCenter
    # Pattern 1: Multi-line version with useDebugColors
    $pattern1 = '(?s)\{\@const cCenter = useDebugColors\s*\?\s*fc\.cCenter\s*:\s*isTheme\(manualColor\)\s*\?\s*fc\.cCenter\s*:\s*manualColor\}'
    $replacement1 = '{@const cCenter = fc.cCenter}'
    $content = $content -replace $pattern1, $replacement1
    
    # Pattern 2: Single line version with isTheme
    $pattern2 = '\{\@const cCenter = isTheme\(manualColor\) \? fc\.cCenter : manualColor\}'
    $replacement2 = '{@const cCenter = fc.cCenter}'
    $content = $content -replace $pattern2, $replacement2
    
    Set-Content $file -Value $content -NoNewline
}

Write-Host "Fixed cCenter logic in all pattern files!"
