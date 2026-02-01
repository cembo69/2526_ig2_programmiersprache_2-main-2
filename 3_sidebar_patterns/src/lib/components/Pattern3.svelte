<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ColorPickerJonas from '$lib/ui/ColorPickerJonas.svelte';

	// Tile-Dimensionen aus Pattern 3
	let tileWidth = $state(1230);
	let tileHeight = $state(1230);

	let tileCount = $state(5);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	
	// Offset controls
	let offsetX = $state(-50);
	let offsetY = $state(-48);
	let rotation = $state(0);
	let scale = $state(1);

	// Theme definitions - genau wie in Pattern 3
	const themes = {
		'Moonlight': ['#6D9BC3', '#C0C0C0', '#003366', '#2F3C45'],
		'Senegal': ['#E60012', '#FFD700', '#006747', '#2A2A2A'],
		'Forest': ['#228B22', '#8A9A5B', '#A67C52', '#6B4F2A'],
		'Miami': ['#00B5B8', '#FF6F61', '#FFDD00', '#F1F1F1'],
		'Amber Glow': ['#FFB000', '#FF8C42', '#D96C2C', '#A94A1F'],
		'Neon Party': ['#FF2EC4', '#7B5CFF', '#2EE6FF', '#00FF9C'],
		'Electric Sunset': ['#FF4E00', '#FF9500', '#FFB703', '#8338EC'],
		'Cosmic Candy': ['#FF61D2', '#9B5DE5', '#00BBF9', '#00F5D4']
	};

	let selectedTheme = $state('Moonlight');
	
	// Custom Color für ColorPicker
	let customColor = $state('#5ac07e');
	
	// 4 Farben für verschiedene Pattern-Bereiche
	let color1 = $derived(themes[selectedTheme][0]);
	let color2 = $derived(themes[selectedTheme][1]);
	let color3 = $derived(themes[selectedTheme][2]);
	let color4 = $derived(themes[selectedTheme][3]);
	
	// Hintergrund Toggle
	let backgroundColor = '#000000';

	// Theme Picker Toggle
	let showAllThemes = $state(false);

	// HSL Helper Functions
	function hexToRgb(hex) {
		const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
		return result
			? {
					r: parseInt(result[1], 16),
					g: parseInt(result[2], 16),
					b: parseInt(result[3], 16)
				}
			: { r: 0, g: 0, b: 0 };
	}

	function rgbToHsl(r, g, b) {
		r /= 255;
		g /= 255;
		b /= 255;
		const max = Math.max(r, g, b),
			min = Math.min(r, g, b);
		let h,
			s,
			l = (max + min) / 2;
		if (max === min) {
			h = s = 0;
		} else {
			const d = max - min;
			s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
			switch (max) {
				case r:
					h = (g - b) / d + (g < b ? 6 : 0);
					break;
				case g:
					h = (b - r) / d + 2;
					break;
				case b:
					h = (r - g) / d + 4;
					break;
			}
			h /= 6;
		}
		return { h: h * 360, s: s * 100, l: l * 100 };
	}

	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

	// Positionierungslogik - angepasst für keine Überlappung
	// Die Tiles müssen genau nebeneinander platziert werden
	function calculatePosition(index, count, size, gap) {
		// Einfache Berechnung: jede Tile bekommt ihre Position basierend auf Index
		return (index - count / 2) * size + (index - count / 2) * gap;
	}

	// Add extra tiles to ensure canvas is always filled
	const extraTiles = 8;
	const renderTileCountX = $derived(tileCountX + extraTiles);
	const renderTileCountY = $derived(tileCountY + extraTiles);

	let totalWidth = $derived(renderTileCountX * tileWidth + (renderTileCountX - 1) * offsetX);
	let totalHeight = $derived(renderTileCountY * tileHeight + (renderTileCountY - 1) * offsetY);

	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);
</script>

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		<!-- Background Rectangle -->
		<rect x="{vbX}" y="{vbY}" width="{vbW}" height="{vbH}" fill="{backgroundColor}" />
		
		{#each Array(renderTileCountY) as _, yi}
			{#each Array(renderTileCountX) as _, xi}
				<!-- Spiegel-Logik aus Pattern 1 -->
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, renderTileCountX, tileWidth, offsetX)}
				{@const posY = calculatePosition(yi, renderTileCountY, tileHeight, offsetY)}

				{@const finalX = posX + (scaleX === -1 ? tileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? tileHeight : 0)}

				<!-- Modus: CustomColor verwendet HSL-Hierarchie, Theme verwendet Theme-Farben -->
				{@const getHierarchyColors = (base) => {
					const hsl = getHslFromHex(base);
					const h = hsl.h;
					const s = hsl.s;
					const baseL = hsl.l;
					const c1L = baseL;
					const c2L = Math.max(0, baseL - 15);
					const c3L = Math.max(0, baseL - 30);
					const c4L = Math.max(0, baseL - 45);
					return {
						c1: `hsl(${h}, ${s}%, ${c1L}%)`,
						c2: `hsl(${h}, ${s}%, ${c2L}%)`,
						c3: `hsl(${h}, ${s}%, ${c3L}%)`,
						c4: `hsl(${h}, ${s}%, ${c4L}%)`
					};
				}}

				{@const hierarchyColors = customColor ? getHierarchyColors(customColor) : null}

				{@const usedColor1 = customColor ? hierarchyColors.c1 : color1}
				{@const usedColor2 = customColor ? hierarchyColors.c2 : color2}
				{@const usedColor3 = customColor ? hierarchyColors.c3 : color3}
				{@const usedColor4 = customColor ? hierarchyColors.c4 : color4}

				<g
					transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {tileWidth /
						2} {tileHeight / 2}) scale({scale})"
				>
					<!-- Geometrie aus Pattern 3 -->
					<!-- Center Hexagon - Schwarz -->
					<polygon
						points="756.18,776.73 535.74,807.77 389.68,620.85 478.46,401.13 700.06,369.96 844.91,556.84"
						fill="#000000"
					/>

					<!-- Top arm - Farbe 1 -->
					<polygon
						points="474.73,396.97 386.08,616.36 240.73,438.22 415.28,9.63 556.43,180.08"
						fill={usedColor1}
					/>

					<!-- Top-right arm - Farbe 2 -->
					<polygon
						points="927.28,332.93 480.55,395.73 561.03,182.01 1017.2,117.87"
						fill={usedColor2}
					/>

					<!-- Right arm - Farbe 3 -->
					<polygon
						points="1219.94,711.58 996.74,743.02 705.8,369.17 927.98,337.91"
						fill={usedColor3}
					/>

					<!-- Bottom-right arm - Farbe 4 -->
					<polygon
						points="816.31,1168.5 675.95,988.88 762.56,774.3 848.7,561.01 992.68,745.95"
						fill={usedColor4}
					/>

					<!-- Bottom arm - Farbe 2 (wiederholt) -->
					<polygon
						points="213.84,1051.32 296.52,846.48 754.02,782.17 671.3,987.01"
						fill={usedColor2}
					/>

					<!-- Left arm - Farbe 4 (wiederholt) -->
					<polygon
						points="529.89,808.51 296,841.47 9.4,467.2 236.8,441.32 385.02,623.01"
						fill={usedColor4}
					/>
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={5} max={35} step={1} bind:value={tileCount} label="Tile Count" />
	<hr />
	<div class="theme-selector">
		<div class="label">Color Theme</div>
		<div class="theme-buttons">
			<!-- Aktives Theme immer anzeigen -->
			<button 
				class="theme-button active"
				onclick={() => showAllThemes = !showAllThemes}
			>
				<span class="theme-name">{selectedTheme}</span>
				<div class="theme-colors">
					{#each themes[selectedTheme] as color}
						<div class="color-dot" style="background-color: {color}"></div>
					{/each}
				</div>
				<span class="expand-arrow" class:expanded={showAllThemes}>▼</span>
			</button>
			
			<!-- Andere Themes ausklappbar -->
			{#if showAllThemes}
				{#each Object.keys(themes) as theme}
					{#if theme !== selectedTheme}
						<button 
							class="theme-button"
							onclick={() => { selectedTheme = theme; customColor = null; showAllThemes = false; }}
						>
							<span class="theme-name">{theme}</span>
							<div class="theme-colors">
								{#each themes[theme] as color}
									<div class="color-dot" style="background-color: {color}"></div>
								{/each}
							</div>
						</button>
					{/if}
				{/each}
			{/if}
		</div>
	</div>
	<hr />
	<ColorPickerJonas bind:color={customColor} width={250} />
</div>

<style>
	.toggle-container {
		width: 100%;
		margin-bottom: 0.5rem;
	}
	
	.toggle-button {
		width: 100%;
		height: 36px;
		background: #2a2a2a;
		border: 1px solid #444;
		border-radius: 6px;
		display: flex;
		align-items: center;
		padding: 3px;
		gap: 3px;
		cursor: pointer;
		transition: all 0.2s;
	}
	
	.toggle-option {
		flex: 1;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 4px;
		font-size: 0.85rem;
		color: #888;
		transition: all 0.2s;
	}
	
	.toggle-option.selected {
		background: #444;
		color: #fff;
		font-weight: 500;
	}
	
	.theme-selector {
		width: 100%;
		margin-bottom: 0.5rem;
	}
	
	.label {
		font-size: 0.75rem;
		margin-top: 0;
		margin-bottom: 0.5rem;
		color: #ccc;
	}
	
	.theme-buttons {
		display: flex;
		flex-direction: column;
		gap: 3px;
	}
	
	.theme-button {
		width: 100%;
		height: 32px;
		background: transparent;
		border: none;
		border-radius: 4px;
		font-size: 0.85rem;
		padding: 0 10px;
		outline: none;
		cursor: pointer;
		color: #999;
		transition: all 0.15s ease;
		font-weight: 400;
		text-align: left;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}
	
	.theme-button:hover {
		color: #ccc;
		background: #333;
	}
	
	.theme-button.active {
		color: white;
		background: #444;
		font-weight: 500;
	}
	
	.expand-arrow {
		margin-left: 8px;
		font-size: 10px;
		transition: transform 0.2s;
	}
	
	.expand-arrow.expanded {
		transform: rotate(180deg);
	}
	
	.theme-name {
		flex: 1;
	}
	
	.theme-colors {
		display: flex;
		gap: 3px;
	}
	
	.color-dot {
		width: 16px;
		height: 16px;
		border-radius: 3px;
		border: 1px solid #666;
	}
	.custom-color-btn {
		width: 100%;
		height: 36px;
		background: #2a2a2a;
		border: 1px solid #444;
		border-radius: 4px;
		color: #ccc;
		cursor: pointer;
		font-size: 0.85rem;
		transition: all 0.2s;
	}

	.custom-color-btn:hover {
		background: #333;
		border-color: #555;
		color: #fff;
	}

	.custom-color-active {
		width: 100%;
	}

	.custom-color-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 0.5rem;
		color: #ccc;
		font-size: 0.85rem;
	}

	.reset-btn {
		padding: 4px 8px;
		background: #2a2a2a;
		border: 1px solid #444;
		border-radius: 3px;
		color: #ccc;
		cursor: pointer;
		font-size: 0.75rem;
		transition: all 0.2s;
	}

	.reset-btn:hover {
		background: #333;
		color: #fff;
	}
	/* ColorPicker Centering */
	.sidebar-right :global(.container) {
		margin-left: auto;
		margin-right: auto;
	}
</style>
