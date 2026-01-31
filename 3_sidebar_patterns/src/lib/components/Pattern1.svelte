<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import ColorPickerHSV from '$lib/ui/ColorPicker/ColorPickerHSV.svelte';

	// Reduced dimensions for a single unit
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	let tileCount = $state(15);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	let offset = $state(140);
	let offsetX = $derived(offset);
	let offsetY = $derived(offset);

	// New "Exciting" Controls
	// Rotation is derived from offset: as offset increases, rotation increases
	let rotation = $derived(174 + (offset - 10) * (26 / 190)); // Maps offset 10-200 to rotation 174-200
	const scale = 1;
	const meshTightness = 0;

	// Dynamic Colors (Hue/Sat Based Shadow System)
	// (Simplified)

	// Manual Color Override
	let useManualColor = $state(true);
	let manualColor = $state('#8393ff');

	// Debug Colors
	let useDebugColors = $state(false);
	let debugColors = $state({
		top: '#eb00ab',
		bottom: '#230010',
		left: '#e00083',
		right: '#1c000c',
		center: '#ff009f'
	});

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
	const extraTiles = 4;
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
		{#each Array(renderTileCountY) as _, yi}
			{#each Array(renderTileCountX) as _, xi}
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, renderTileCountX, baseTileWidth, offsetX)}
				{@const posY = calculatePosition(yi, renderTileCountY, baseTileHeight, offsetY)}

				<!-- STATIC FRAME COLORS (or Dynamic Frame) -->
				{@const getFrameColors = (base) => {
					// Debug Mode Override
					if (useDebugColors) {
						return {
							cTop: debugColors.top,
							cLeft: debugColors.left,
							cBottom: debugColors.bottom,
							cRight: debugColors.right,
							cCenter: debugColors.center
						};
					}

					// Nordlichter Override
					if (base.toUpperCase() === '#0D1B2A') {
						return {
							cTop: '#0D1B2A', // Nachtblau
							cLeft: '#2EC4B6', // Türkis
							cBottom: '#7209B7', // Violett
							cRight: '#CBFF4D', // Aurora
							cCenter: darkenHex('#0D1B2A', 10)
						};
					}

					// Sportplatz Override
					if (base.toUpperCase() === '#4CAF50') {
						return {
							cTop: '#4CAF50', // Green
							cLeft: '#FFFFFF', // White
							cBottom: '#333333', // Dark
							cRight: '#1982C4', // Blue
							cCenter: darkenHex('#333333', 10)
						};
					}

					// Chinatown Override
					if (base.toUpperCase() === '#D32F2F') {
						return {
							cTop: '#D32F2F', // Red
							cLeft: '#F2F2F2', // Cloud White
							cBottom: '#2D3436', // Obsidian
							cRight: '#FFD700', // Gold
							cCenter: darkenHex('#2D3436', 10)
						};
					}

					// Miami Override
					if (base.toUpperCase() === '#FF91AF') {
						// Cheek for Flamingo Pink
						return {
							cTop: '#FF91AF', // Flamingo
							cLeft: '#F2F2F2', // Cloud White
							cBottom: '#00E5FF', // Electric Blue
							cRight: '#FFB347', // Sunset Orange
							cCenter: darkenHex('#00E5FF', 10)
						};
					}

					const hsl = getHslFromHex(base);
					const h = hsl.h;
					const s = hsl.s;
					const l = Math.max(0, Math.min(100, hsl.l));

					return {
						cTop: `hsl(${h}, ${s}%, ${l}%)`,
						cLeft: `hsl(${(h + 90) % 360}, ${s}%, ${Math.max(8, l - 20)}%)`,
						cBottom: `hsl(${(h + 180) % 360}, ${s}%, ${Math.max(8, l - 75)}%)`,
						cRight: `hsl(${(h + 270) % 360}, ${s}%, ${Math.max(8, l - 90)}%)`,
						cCenter: `hsl(${h}, ${s}%, ${Math.max(8, l - 100)}%)`
					};
				}}

				{@const isTheme = (c) => {
					const u = c.toUpperCase();
					return u === '#0D1B2A' || u === '#4CAF50' || u === '#D32F2F' || u === '#FF91AF';
				}}
				{@const fc = getFrameColors(manualColor)}

				{@const cTop = fc.cTop}
				{@const cLeft = fc.cLeft}
				{@const cBottom = fc.cBottom}
				{@const cRight = fc.cRight}

				<!-- DYNAMIC SKY (Rect Only) -->
				{@const cCenter = fc.cCenter}

				{@const finalX = posX + (scaleX === -1 ? baseTileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? baseTileHeight : 0)}

				// Correction for Mirroring: // If flipped, we swap the visual colors so the apparent light
				source (Top-Left) stays constant.
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
	<Slider min={15} max={45} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={6} max={135} bind:value={offset} label="Tile Offset / Rotation" />
	<hr />

	<!-- Unified Colors -->
	<!-- Hue/Sat are now automatic based on Time -->

	<hr />
	<ThemeSelector bind:color={manualColor} />
	<hr />

	<details open>
		<summary style="cursor: pointer; color: white; margin-bottom: 0.5rem;">Color Picker</summary>
		<div style="margin-top: 0.5rem;">
			<ColorPickerHSV bind:color={manualColor} width={250} />
		</div>
	</details>

	<hr />
	<label style="display: flex; align-items: center; gap: 8px; color: white;">
		<input type="checkbox" bind:checked={useDebugColors} />
		Debug Colors
	</label>

	{#if useDebugColors}
		<div style="margin-top: 10px; display: flex; flex-direction: column; gap: 10px;">
			<!-- Top -->
			<details>
				<summary style="cursor: pointer; color: white;">Top Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.top} width={250} />
				</div>
			</details>
			<!-- Bottom -->
			<details>
				<summary style="cursor: pointer; color: white;">Bottom Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.bottom} width={250} />
				</div>
			</details>
			<!-- Left -->
			<details>
				<summary style="cursor: pointer; color: white;">Left Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.left} width={250} />
				</div>
			</details>
			<!-- Right -->
			<details>
				<summary style="cursor: pointer; color: white;">Right Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.right} width={250} />
				</div>
			</details>
			<!-- Center -->
			<details>
				<summary style="cursor: pointer; color: white;">Center Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.center} width={250} />
				</div>
			</details>

			<hr />
			<div style="color: white; font-size: 0.8em;">
				<p>Current Configuration (Copy valid for JSON):</p>
				<code style="display: block; background: #222; padding: 5px; user-select: text;">
					{JSON.stringify(debugColors, null, 2)}
				</code>
			</div>
		</div>
	{/if}
</div>
