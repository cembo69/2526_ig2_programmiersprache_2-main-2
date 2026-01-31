$files = @(
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\3_PatternVSC.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\4_PatternAdvanced.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\5_PatternDiagonal.svelte"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    
    # Replace cCenter: '#ffffff' with cCenter: '#000000'
    $content = $content -replace "cCenter: '#ffffff'", "cCenter: '#000000'"
    
    # Also update the comment
    $content = $content -replace "// Always white", "// Always black"
    $content = $content -replace "// Center is always white", "// Center is always black"
    
    Set-Content $file -Value $content -NoNewline
}

Write-Host "Changed center color to black in all pattern files!"
