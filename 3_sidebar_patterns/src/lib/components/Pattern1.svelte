<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ColorPickerJonas from '$lib/ui/ColorPickerJonas.svelte';

	// Reduced dimensions for a single unit
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	let tileCount = $state(5);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	
	// Offset controls rotation
	let offset = $state(135);
	const offsetX = $derived(offset);
	const offsetY = $derived(offset);
	const rotation = $derived(174 + (offset - 10) * (26 / 190));
	const scale = 1;
	const meshTightness = 0;

	// Theme definitions - genau wie in Pattern 3
	const themes = {
		'Tron': ['#00D2FF', '#39FF14', '#FF073A', '#1B1B1B'],
		'Chinatown': ['#E60012', '#FFD700', '#006747', '#2A2A2A'],
		'Forest': ['#228B22', '#8A9A5B', '#A67C52', '#6B4F2A'],
		'Miami': ['#00B5B8', '#FF6F61', '#FFDD00', '#F1F1F1'],
		'Moonlight': ['#6D9BC3', '#C0C0C0', '#003366', '#2F3C45']
	};

	let selectedTheme = $state('Miami');
	
	// Custom Color für ColorPicker
	let customColor = $state(null);
	
	// 4 Farben für verschiedene Pattern-Bereiche
	let color1 = $derived(themes[selectedTheme][0]);
	let color2 = $derived(themes[selectedTheme][1]);
	let color3 = $derived(themes[selectedTheme][2]);
	let color4 = $derived(themes[selectedTheme][3]);
	
	// Basis-Farbe für HSL-Berechnungen - nutzt customColor wenn gesetzt, sonst color1
	let baseColor = $derived(customColor || color1);
	
	// Kontrast-Steuerung für 3D-Effekt
	const contrast = 0.8;
	
	// Hintergrund Toggle
	let darkBackground = $state(true);
	let backgroundColor = $derived(darkBackground ? '#000000' : '#ffffff');

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

	// Determine max distance for normalization (center to corner)
	// Distance from center index (0) to corner index (count/2)
	// Actually, simple Euclidean distance in index-space works well.
	let maxDist = $derived(Math.sqrt(Math.pow(tileCountX / 2, 2) + Math.pow(tileCountY / 2, 2)));

	// User's requested center-out logic with rotation compensation
	function calculatePosition(index, count, size, gap) {
		const rotationFactor = Math.abs(rotation - 180) / 26;
		const rotationCompensation = 1 - rotationFactor * 0.3;
		const adjustedGap = gap * rotationCompensation;
		const effectiveSize = size + adjustedGap;
		return (index - count / 2) * effectiveSize;
	}

	// Helper to get HSL object directly from hex
	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

	function darkenHex(hex, amount) {
		const h = getHslFromHex(hex);
		return `hsl(${h.h}, ${h.s}%, ${Math.max(8, h.l - amount)}%)`;
	}

	// Dynamic ViewBox calculation?
	// User used fixed -500 -500 1000 1000 in snippet, but the tiles here are huge (700px).
	// Let's make the viewBox large enough or reactive.
	// If we want it to "grow from center", a fixed large viewBox is best, OR a reactive centered one.
	// Let's try a reactive one that ensures the whole pattern is visible, centered on 0,0.

	// Total width/height with rotation compensation
	const rotationFactor = $derived(Math.abs(rotation - 180) / 26);
	const rotationCompensation = $derived(1 - rotationFactor * 0.3);
	const adjustedOffsetX = $derived(offsetX * rotationCompensation);
	const adjustedOffsetY = $derived(offsetY * rotationCompensation);

	// Add extra tiles to ensure canvas is always filled
	const extraTiles = 8;
	const renderTileCountX = $derived(tileCountX + extraTiles);
	const renderTileCountY = $derived(tileCountY + extraTiles);

	let totalWidth = $derived(renderTileCountX * baseTileWidth + renderTileCountX * adjustedOffsetX);
	let totalHeight = $derived(
		renderTileCountY * baseTileHeight + renderTileCountY * adjustedOffsetY
	);

	// Minimal padding
	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);

	const colors = {
		get fill0() {
			return color0;
		},
		get fill1() {
			return color1;
		},
		get fill2() {
			return color2;
		}
	};

	// Standardized Coordinates to ensure perfect mating of edges
	// We make these Dynamic based on meshTightness
	// Original Core Ratio was approx 0.66.
	// meshTightness 0 -> Original (0.66).
	// meshTightness 1 -> Very Tight (Small Core, e.g. 0.3).

	let coreRatio = $derived(0.66 - meshTightness * 0.4);

	// Core Dimensions - Proportional Scaling
	// To preserve the "Grundform" (Basic Shape) without deformation,
	// the Inner Square MUST scale proportionally with the Outer Tile.
	let dynamicW = $derived(baseTileWidth * coreRatio);
	let dynamicH = $derived(baseTileHeight * coreRatio);

	// Center Point
	const cx = baseTileWidth / 2;
	const cy = baseTileHeight / 2;

	// The central rectangle is the anchor.
	let x_rect_L = $derived(cx - dynamicW / 2);
	let x_rect_R = $derived(cx + dynamicW / 2);
	let y_rect_T = $derived(cy - dynamicH / 2);
	let y_rect_B = $derived(cy + dynamicH / 2);

	let rect_W = $derived(x_rect_R - x_rect_L);
	let rect_H = $derived(y_rect_B - y_rect_T);

	// Outer limits based on original paths
	const y_top = 33.0;
	const y_bottom = 669.0;
	const x_left = 34.6;
	const x_right = 668.6; // Consistent with right piece width
	const x_extreme_right = 703.6; // For the top piece extension

	// Derived Points for Shapes
	// We adjust the diagonal connecting points using the new CORE corners.

	// Overlap amount to extend under the rectangle
	const overlap = 2.0;

	// Note: The "Outer" points (like x_left, y_top etc) stay fixed so the tile outer size is stable.
	// The "Inner" points (x_rect_...) move. The diagonals connecting Outer to Inner will change angle.

	// Top Piece (fill1 - Dark Red)
	// Outer Path + Tab under Rect
	// Start TR Corner -> Tab In -> Tab Left -> TL Corner -> Outer...
	let p_top = $derived(`
        M ${x_rect_R} ${y_rect_T} 
        L ${x_rect_R} ${y_rect_T + overlap} 
        L ${x_rect_L} ${y_rect_T + overlap} 
        L ${x_rect_L} ${y_rect_T} 
        L 243.1 ${y_top} 
        H ${x_extreme_right} 
        L ${x_rect_R} ${y_rect_T} 
        Z`);

	// Right Piece (fill0 - Light Red)
	// Start BR Corner -> Tab In -> Tab Up -> TR Corner -> Outer...
	let p_right = $derived(`
        M ${x_rect_R} ${y_rect_B}
        L ${x_rect_R - overlap} ${y_rect_B}
        L ${x_rect_R - overlap} ${y_rect_T}
        L ${x_rect_R} ${y_rect_T}
        L ${x_right} 241.5
        L ${x_right} 702
        L ${x_rect_R} ${y_rect_B}
        Z`);

	// Bottom Piece (fill0 - Light Red)
	// Start BL Corner -> Tab In -> Tab Right -> BR Corner -> Outer...
	let p_bottom = $derived(`
        M ${x_rect_L} ${y_rect_B}
        L ${x_rect_L} ${y_rect_B - overlap}
        L ${x_rect_R} ${y_rect_B - overlap}
        L ${x_rect_R} ${y_rect_B}
        L 460.5 ${y_bottom}
        H 0
        L ${x_rect_L} ${y_rect_B}
        Z`);

	// Left Piece (fill0 - Light Red)
	// Start TL Corner -> Tab In -> Tab Down -> BL Corner -> Outer...
	let p_left = $derived(`
        M ${x_rect_L} ${y_rect_T}
        L ${x_rect_L + overlap} ${y_rect_T}
        L ${x_rect_L + overlap} ${y_rect_B}
        L ${x_rect_L} ${y_rect_B}
        L ${x_left} 460.5
        L ${x_left} 0
        L ${x_rect_L} ${y_rect_T}
        Z`);
</script>

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		<!-- Background Rectangle -->
		<rect x="{vbX}" y="{vbY}" width="{vbW}" height="{vbH}" fill="{backgroundColor}" />
		{#each Array(renderTileCountY) as _, yi}
			{#each Array(renderTileCountX) as _, xi}
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, renderTileCountX, baseTileWidth, offsetX)}
				{@const posY = calculatePosition(yi, renderTileCountY, baseTileHeight, offsetY)}

			{@const finalX = posX + (scaleX === -1 ? baseTileWidth : 0)}
			{@const finalY = posY + (scaleY === -1 ? baseTileHeight : 0)}

			<!-- Modus: CustomColor verwendet HSL-Hierarchie, Theme verwendet direkte Farben -->
			{@const getHierarchyColors = (base) => {
				const hsl = getHslFromHex(base);
				const h = hsl.h;
				const s = hsl.s;
				const topL = hsl.l;
				const leftL = Math.max(0, topL - (8 * contrast));
				const rightL = Math.max(0, topL - (42 * contrast));
				const bottomL = Math.max(0, topL - (45 * contrast));
				const centerL = Math.max(0, topL - (75 * contrast));
				return {
					cTop: `hsl(${h}, ${s}%, ${topL}%)`,
					cLeft: `hsl(${h}, ${s}%, ${leftL}%)`,
					cRight: `hsl(${h}, ${s}%, ${rightL}%)`,
					cBottom: `hsl(${h}, ${s}%, ${bottomL}%)`,
					cCenter: `hsl(${h}, ${s}%, ${centerL}%)`
				};
			}}

			{@const hierarchyColors = customColor ? getHierarchyColors(customColor) : null}

			<!-- Theme-Farben für die einzelnen Formen (wenn kein customColor) -->
			{@const cTop = customColor ? hierarchyColors.cTop : color1}
			{@const cRight = customColor ? hierarchyColors.cRight : color2}
			{@const cBottom = customColor ? hierarchyColors.cBottom : color3}
			{@const cLeft = customColor ? hierarchyColors.cLeft : color4}
			{@const cCenter = customColor ? hierarchyColors.cCenter : '#000000'}

			<!-- Korrektur für Spiegelung -->
			{@const visualCTop = scaleY === -1 ? cBottom : cTop}
			{@const visualCBottom = scaleY === -1 ? cTop : cBottom}
			{@const visualCLeft = scaleX === -1 ? cRight : cLeft}
			{@const visualCRight = scaleX === -1 ? cLeft : cRight}

			<g
				transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {baseTileWidth /
					2} {baseTileHeight / 2}) scale({scale})"
			>
					<!-- Surrounding Shapes FIRST (Behind) -->
					<!-- Use the corrected 'visual' colors for the geometric paths -->
					<path d={p_bottom} fill={visualCBottom} id="Bottom" />
					<path d={p_top} fill={visualCTop} id="Top" />
					<path d={p_left} fill={visualCLeft} id="Left" />
					<path d={p_right} fill={visualCRight} id="Right" />

					<!-- Rect LAST (On Top) -->
					<rect fill={cCenter} x={x_rect_L} y={y_rect_T} width={rect_W} height={rect_H} />
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={5} max={35} step={1} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={6} max={135} bind:value={offset} label="Tile Offset / Rotation" />
	<hr />
	<div class="toggle-container">
		<span class="label">Background</span>
		<button class="toggle-button" class:active={darkBackground} onclick={() => darkBackground = !darkBackground}>
			<span class="toggle-option" class:selected={darkBackground}>Dark</span>
			<span class="toggle-option" class:selected={!darkBackground}>Light</span>
		</button>
	</div>
	<hr />
	<div class="theme-selector">
		<div class="label">Color Theme</div>
		<div class="theme-buttons">
			{#each Object.keys(themes) as theme}
				<button 
					class="theme-button" 
					class:active={selectedTheme === theme}
					onclick={() => selectedTheme = theme}
				>
					<span class="theme-name">{theme}</span>
					<div class="theme-colors">
						{#each themes[theme] as color}
							<div class="color-dot" style="background-color: {color}"></div>
						{/each}
					</div>
				</button>
			{/each}
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

	/* ColorPicker Centering */
	.sidebar-right :global(.container) {
		margin-left: auto;
		margin-right: auto;
	}
</style>
