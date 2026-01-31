$files = @(
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\3_PatternVSC.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\4_PatternAdvanced.svelte",
    "c:\Users\jonas\Desktop\Programmiertes\2526_ig2_programmiersprache_2-main-2-1\3_sidebar_patterns\src\lib\components\5_PatternDiagonal.svelte"
)

foreach ($file in $files) {
    $content = Get-Content $file -Raw
    
    # Replace cCenter: `hsl(${h}, ${s}%, ${l}%)` with cCenter: '#ffffff'
    $content = $content -replace "cCenter: ``hsl\(\$\{h\}, \$\{s\}%, \$\{l\}%\)``", "cCenter: '#ffffff'"
    
    # Replace const l = hsl.l; with const topL = hsl.l;
    $content = $content -replace "const l = hsl\.l;", "const topL = hsl.l;"
    
    # Replace const topL = Math.max(0, l - 4); with const leftL = Math.max(0, topL - 1);
    $content = $content -replace "const topL = Math\.max\(0, l - 4\);", "const leftL = Math.max(0, topL - 1);"
    
    # Replace const leftL = Math.max(0, l - 5); with const rightL = Math.max(0, topL - 37);
    $content = $content -replace "const leftL = Math\.max\(0, l - 5\);", "const rightL = Math.max(0, topL - 37);"
    
    # Replace const rightL = Math.max(0, l - 41); with const bottomL = Math.max(0, topL - 39);
    $content = $content -replace "const rightL = Math\.max\(0, l - 41\);", "const bottomL = Math.max(0, topL - 39);"
    
    # Remove const bottomL = Math.max(0, l - 43);
    $content = $content -replace "const bottomL = Math\.max\(0, l - 43\);[\r\n]*", ""
    
    # Update comments
    $content = $content -replace "// Center is Base\.", "// Top is the base color (from manualColor)"
    $content = $content -replace "// Center: Base", "// Center is always white"
    $content = $content -replace "// Top: L - 4%", "// Derived from Top:"
    $content = $content -replace "// Left: L - 5%", "// Left: L - 1%"
    $content = $content -replace "// Right: L - 41%", "// Right: L - 37%"
    $content = $content -replace "// Bottom: L - 43%", "// Bottom: L - 39%"
    
    Set-Content $file -Value $content -NoNewline
}

Write-Host "Updated all pattern files successfully!"
