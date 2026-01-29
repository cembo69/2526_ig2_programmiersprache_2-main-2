<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import OklchColorPicker from './OklchColorPicker.svelte';

	// Reduced dimensions for a single unit
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	let tileCount = $state(15);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	let offset = $state(10);
	let offsetX = $derived(offset);
	let offsetY = $derived(offset);

	// New "Exciting" Controls
	let rotation = $state(180);
	const scale = 1;
	// Shear/Skew
	let skew = $state(0);

	const meshTightness = 0; // 0 = Original Look (Fixed)

	// Dynamic Colors (Hue/Sat Based Shadow System)
	// (Simplified)

	// Manual Color Override
	let useManualColor = $state(true);
	let manualColor = $state('#8393ff');

	// Frame Color Override
	let useFrameColor = $state(true);
	let frameColor = $state('#ffffff');

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

	// User's requested center-out logic
	function calculatePosition(index, count, size, gap) {
		const basePosition = (index - count / 2) * size;
		const offsetPosition = (index - count / 2 + 0.5) * gap;
		return basePosition + offsetPosition;
	}

	// Helper to get HSL object directly from hex
	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

    function darkenHex(hex, amount) {
        const h = getHslFromHex(hex);
        return `hsl(${h.h}, ${h.s}%, ${Math.max(0, h.l - amount)}%)`;
    }

	// Dynamic ViewBox calculation?
	// User used fixed -500 -500 1000 1000 in snippet, but the tiles here are huge (700px).
	// Let's make the viewBox large enough or reactive.
	// If we want it to "grow from center", a fixed large viewBox is best, OR a reactive centered one.
	// Let's try a reactive one that ensures the whole pattern is visible, centered on 0,0.

	// Grid calculations
	// Increase render count to cover corners when rotated
	let renderCount = $derived(Math.ceil(tileCount * 1.5) + 2);
	let renderCountX = $derived(renderCount);
	let renderCountY = $derived(renderCount);

	// ViewBox stays based on the visible tileCount
	let totalWidth = $derived(tileCountX * baseTileWidth + tileCountX * offsetX);
	let totalHeight = $derived(tileCountY * baseTileHeight + tileCountY * offsetY);

	// Add some padding
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
	<!-- Apply 45 degree rotation to the entire SVG content around the center -->
	<!-- Center is 0,0 since vbox is centered on 0,0 -->
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		<g transform="rotate(45)">
			{#each Array(renderCountY) as _, yi}
				{#each Array(renderCountX) as _, xi}
					{@const scaleX = xi % 2 !== 0 ? -1 : 1}
					{@const scaleY = yi % 2 !== 0 ? -1 : 1}

					<!-- Use renderCount for positioning calculation to maintain center -->

					<!-- Unified HSL Shadow Logic -->

					<!-- STATIC FRAME COLORS (or Dynamic Frame) -->
					{@const getFrameColors = (base) => {
						if (!useFrameColor)
							return { cTop: '#ffffff', cLeft: '#cccccc', cBottom: '#444444', cRight: '#1a1a1a' };
						
                        // Nordlichter Override
                        if (base.toUpperCase() === '#0D1B2A') {
                             return {
                                cTop: '#0D1B2A',     // Nachtblau
                                cLeft: '#2EC4B6',    // Türkis
                                cBottom: '#7209B7',  // Violett
                                cRight: '#CBFF4D'    // Aurora
                             };
                        }

                        // Sportplatz Override
                        if (base.toUpperCase() === '#4CAF50') {
                             return {
                                cTop: '#4CAF50',     // Green
                                cLeft: '#FFFFFF',    // White
                                cBottom: '#333333',  // Dark
                                cRight: '#1982C4'    // Blue
                             };
                        }

                        // Chinatown Override
                        if (base.toUpperCase() === '#D32F2F') {
                             return {
                                cTop: '#D32F2F',     // Red
                                cLeft: '#F2F2F2',    // Cloud White
                                cBottom: '#2D3436',  // Obsidian
                                cRight: '#FFD700'    // Gold
                             };
                        }

                        // Miami Override
                        if (base.toUpperCase() === '#FF91AF') { // Cheek for Flamingo Pink
                            return {
                                cTop: '#FF91AF',     // Flamingo
                                cLeft: '#F2F2F2',    // Cloud White
                                cBottom: '#00E5FF',  // Electric Blue
                                cRight: '#FFB347',   // Sunset Orange
                                cCenter: darkenHex('#00E5FF', 10)
                            };
                        }
                        
                        const hsl = getHslFromHex(base);
						const h = hsl.h;
						const s = hsl.s;
						const l = hsl.l;

						// Guarantee 4 distinct lightness levels
						// We define a spread (e.g. 15% per step)
						// If base L is too low to support drops, we shift the whole range up.
						// Target offsets: 0, -15, -30, -50

						const maxDrop = 50;
						let startL = l;

						// If starting lightness is lower than the max drop + buffer, shift it up
						// so distinctness is preserved.
						if (startL < maxDrop + 10) {
							startL = maxDrop + 10;
						}
						// Cap at 100
						if (startL > 100) startL = 100;

						return {
							cTop: `hsl(${h}, ${s}%, ${startL}%)`,
							cLeft: `hsl(${(h + 90) % 360}, ${s}%, ${Math.max(0, startL - 15)}%)`,
							cBottom: `hsl(${(h + 180) % 360}, ${s}%, ${Math.max(0, startL - 30)}%)`,
							cRight: `hsl(${(h + 270) % 360}, ${s}%, ${Math.max(0, startL - 50)}%)`,
                            cCenter: `hsl(${h}, ${s}%, ${Math.max(0, Math.max(0, startL - 50) - 10)}%)`
						};
					}}
                    
                    {@const isTheme = (c) => {
                         const u = c.toUpperCase();
                         return u==='#0D1B2A' || u==='#4CAF50' || u==='#D32F2F' || u==='#FF91AF';
                    }}
                    {@const effectiveFrameBase = isTheme(manualColor) ? manualColor : frameColor}
					{@const fc = getFrameColors(effectiveFrameBase)}

					{@const cTop = fc.cTop}
					{@const cLeft = fc.cLeft}
					{@const cBottom = fc.cBottom}
					{@const cRight = fc.cRight}

					<!-- DYNAMIC SKY (Rect Only) -->
					{@const cCenter = isTheme(manualColor) ? fc.cCenter : manualColor}

					{@const posX = calculatePosition(xi, renderCountX, baseTileWidth, offsetX)}
					{@const posY = calculatePosition(yi, renderCountY, baseTileHeight, offsetY)}

					{@const finalX = posX + (scaleX === -1 ? baseTileWidth : 0)}
					{@const finalY = posY + (scaleY === -1 ? baseTileHeight : 0)}

					<!-- Correction for Mirroring: If flipped, we swap the visual colors so the apparent light source (Top-Left) stays constant. -->
					{@const visualCTop = scaleY === -1 ? cBottom : cTop}
					{@const visualCBottom = scaleY === -1 ? cTop : cBottom}
					{@const visualCLeft = scaleX === -1 ? cRight : cLeft}
					{@const visualCRight = scaleX === -1 ? cLeft : cRight}

					<g
						transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {baseTileWidth /
							2} {baseTileHeight / 2}) scale({scale}) skewX({skew})"
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
		</g>
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={101} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={10} max={200} bind:value={offset} label="Tile Offset" />
	<hr />
	<Slider min={174} max={200} bind:value={rotation} label="Rotation (deg)" />
	<hr />
	<hr />
	<Slider min={-45} max={45} bind:value={skew} label="Shear (Skew)" />
	<hr />

	<!-- Unified Colors -->
	<!-- Hue/Sat are now automatic based on Time -->

	<hr />
    <ThemeSelector bind:color={manualColor} />
    <hr />

	<details open>
		<summary style="cursor: pointer; color: white; margin-bottom: 0.5rem;">Center Color</summary>
		<div style="margin-top: 0.5rem;">
			<OklchColorPicker bind:color={manualColor} />
		</div>
	</details>

	<hr />
	<details>
		<summary style="cursor: pointer; color: white; margin-bottom: 0.5rem;">Frame Color</summary>
		<div style="margin-top: 0.5rem;">
			<OklchColorPicker bind:color={frameColor} />
		</div>
	</details>
</div>
