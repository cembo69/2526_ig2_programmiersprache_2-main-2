<script>
	import Slider from '$lib/ui/Slider.svelte';

	// Reduced dimensions for a single unit
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	let tileCount = $state(5);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	let offset = $state(10);
	let offsetX = $derived(offset);
	let offsetY = $derived(offset);

	// New "Exciting" Controls
	let rotation = $state(0);
	const scale = 1;
	const meshTightness = 0; // 0 = Original Look (Fixed)

	// Dynamic Colors (Hue/Sat Based Shadow System)
	let baseHue = $state(0);
	let baseSaturation = $state(0); // Default to Grayscale (B&W)
	let daylightTime = $state(12); // Default Noon (12h)

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

	function lerp(start, end, t) {
		return start * (1 - t) + end * t;
	}

	function interpolateHsl(c1, c2, t) {
		const rgb1 = hexToRgb(c1);
		const rgb2 = hexToRgb(c2);
		const hsl1 = rgbToHsl(rgb1.r, rgb1.g, rgb1.b);
		const hsl2 = rgbToHsl(rgb2.r, rgb2.g, rgb2.b);

		// Shortest path interpolation for Hue
		let dh = hsl2.h - hsl1.h;
		if (dh > 180) dh -= 360;
		if (dh < -180) dh += 360;

		const h = (hsl1.h + dh * t + 360) % 360; // Normalize
		const s = lerp(hsl1.s, hsl2.s, t);
		const l = lerp(hsl1.l, hsl2.l, t);

		return { h, s, l }; // Return object (easier modification)
	}

	// Shift lightness helper
	function shiftHsl(hsl, amount) {
		// Amount is -100 to +100
		const l = Math.max(0, Math.min(100, hsl.l + amount));
		return `hsl(${hsl.h}, ${hsl.s}%, ${l}%)`;
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

	// Dynamic ViewBox calculation?
	// User used fixed -500 -500 1000 1000 in snippet, but the tiles here are huge (700px).
	// Let's make the viewBox large enough or reactive.
	// If we want it to "grow from center", a fixed large viewBox is best, OR a reactive centered one.
	// Let's try a reactive one that ensures the whole pattern is visible, centered on 0,0.

	// Total width approx: count * size + count * gap
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
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		{#each Array(tileCountY) as _, yi}
			{#each Array(tileCountX) as _, xi}
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, tileCountX, baseTileWidth, offsetX)}
				{@const posY = calculatePosition(yi, tileCountY, baseTileHeight, offsetY)}

				<!-- Unified HSL Shadow Logic -->
				<!-- Daylight Simulation for Center Rectangle (Sky) -->

				<!-- Sky Color Logic based on Time (0-24h) -->

				<!-- Smooth Interpolation would be better but simple logic first -->
				<!-- Let's do a more continuous function for smoother transitions -->
				{@const timeNorm = daylightTime / 24}

				<!-- Smooth Sky Transition Logic -->
				{@const getSkyParams = (t) => {
					// Keyframes for the sky cycle
					// t = Time (0-24)
					// Returns {h, s} interpolated

					const keyframes = [
						// 1. Night - Deep Black/Navy (Very Dark)
						{ t: 0, h: 220, s: 20, l: 2 }, // Midnight: Almost distinct black
						{ t: 4, h: 220, s: 30, l: 10 }, // "Blue Hour": Deepest Navy

						// 2. Morning - Deep Cold Blue -> Deep Russet
						{ t: 5, h: 210, s: 20, l: 30 }, // Dark Slate Blue
						{ t: 5.5, h: 10, s: 25, l: 40 }, // Deep Muted Earth/Red

						// 3. Golden Hour AM - Burnt Orange (Darker)
						{ t: 6, h: 25, s: 60, l: 45 }, // Rich Deep Orange
						{ t: 7, h: 30, s: 50, l: 55 }, // Amber/Copper

						// FIX: Transition via Red/Grey to avoid Green/Yellow interpolation
						{ t: 8.5, h: 340, s: 5, l: 70 }, // Desaturated Warm Grey (Bridge)

						// 4. Noon - Cool Grey/White (Not Blinding)
						{ t: 10, h: 205, s: 15, l: 65 }, // Mid-Grey Blue
						{ t: 12, h: 210, s: 5, l: 75 }, // NOON: Light Grey (Not pure white)

						// 5. Afternoon - Warm Grey
						{ t: 14, h: 15, s: 15, l: 70 }, // Warm Grey/Taupe
						{ t: 16, h: 25, s: 25, l: 60 }, // Darker Beige

						// 3b. Sunset Approach - Deepening
						{ t: 17, h: 20, s: 50, l: 50 }, // Deep Orange

						// 6. Sunset - Dark Rust / Deep Maroon
						{ t: 18, h: 10, s: 60, l: 45 }, // Dark Rust Red
						{ t: 18.5, h: 220, s: 30, l: 30 }, // Deep Steel Blue

						// 7. Blue Hour - Dark Indigo
						{ t: 19, h: 230, s: 35, l: 20 }, // Midnight Blue
						{ t: 19.5, h: 230, s: 40, l: 10 }, // Near Black

						// 1. Night Loop
						{ t: 21, h: 220, s: 20, l: 5 }, // Deep Dark
						{ t: 24, h: 220, s: 20, l: 2 } // Loop
					];

					// Find current segment
					let start = keyframes[0];
					let end = keyframes[1];
					for (let i = 0; i < keyframes.length - 1; i++) {
						if (t >= keyframes[i].t && t <= keyframes[i + 1].t) {
							start = keyframes[i];
							end = keyframes[i + 1];
							break;
						}
					}

					// Normalize t within segment (0 to 1)
					const segmentDuration = end.t - start.t;
					const localT = (t - start.t) / (segmentDuration || 1); // Avoid div by 0

					// Lerp Hue, Sat, AND Lightness
					const h = start.h + (end.h - start.h) * localT;
					const s = start.s + (end.s - start.s) * localT;
					const l = start.l + (end.l - start.l) * localT;

					return { h, s, l };
				}}

				{@const sky = getSkyParams(daylightTime)}
				{@const skyHue = sky.h}
				{@const skySat = sky.s}
				{@const skyLig = sky.l}

				<!-- We override the lightness logic to respect the Time Cycle completely -->
				<!-- The 'skyLig' variable now carries the realistic brightness (Noon=Bright, Night=Dark) -->

				<!-- DYNAMIC SHADOWS based on SUN POSITION -->
				<!-- Map Time to Angle. -->
				<!-- 6h (Sunrise) = Sun at Left (-90 deg or 180) -->
				<!-- 12h (Noon) = Sun at Top (-90 deg visual, 270) -->
				<!-- 18h (Sunset) = Sun at Right (0 deg) -->
				<!-- Simplified Vector Math: -->

				<!-- Sun Vector (sx, sy) -->
				<!-- We map 6h..18h to -PI to 0 range (Top semi-circle) -->
				<!-- Actually, let's say Sun moves from Left (-1, 0) to Top (0, -1) to Right (1, 0) -->

				{@const calculateLight = (t) => {
					// Continuous Sun Path
					// 6h = Horizon (Left, -PI)
					// 12h = Zenith (Top, -PI/2)

					// We allow t to be < 6 for pre-dawn shadow angles (light coming from "below" or just grazing)
					// But realistically, pre-dawn light is ambient.
					// Let's model the Sun Angle continuously anyway for smoothness.
					const progress = (t - 6) / 12;
					const angle = -Math.PI + progress * Math.PI;

					let sunX = Math.cos(angle);
					let sunY = Math.sin(angle);

					// Intensity Ramp (Dawn Transition)
					// 0-5h: Night Ambient (0.15)
					// 5-7h: Dawn Ramp (0.15 -> 1.0)
					// 7h+: Day Full (1.0)

					let intensity = 0.15;
					if (t > 5 && t <= 7) {
						const ramp = (t - 5) / 2;
						intensity = lerp(0.15, 1.0, ramp);
					} else if (t > 7) {
						intensity = 1.0;
					}

					// Shadow Dot Products
					const litTop = Math.max(0, -sunY * 0.8 - sunX * 0.2) * intensity;
					const litLeft = Math.max(0, -sunX * 0.8 + sunY * 0.2) * intensity;
					const litBottom = Math.max(0, sunY * 0.8 + sunX * 0.2) * intensity;
					const litRight = Math.max(0, sunX * 0.8 - sunY * 0.2) * intensity;

					return { litTop, litLeft, litBottom, litRight, intensity };
				}}

				{@const lights = calculateLight(daylightTime)}

				<!-- Apply Lighting to Base Lightness (skyLig) -->
				<!-- We scale the offset impact by intensity too? Already handled by multiplying lit factors -->
				<!-- But we also need shadow impact. -->

				{@const calcL = (baseL, litFactor) => {
					// LitFactor 0..1 (Scaled by intensity)
					// Base Offset range: -40 (Shadow) to +15 (Highlight)
					// If intensity is low (Night), contrast should be low.

					// At intensity 1: Range -40..+15
					// At intensity 0.15: Range -5..+2 ??

					// Let's rely on litFactor * magnitude.
					// But we also need the "dark side" (when litFactor is 0).
					// We didn't calculate "shadow factor" explicitly, just "lit factor".
					// If litTop is 0, it means it's in shadow.
					// The default should be Shadow. Add Light if lit.

					// Let's restructure calcL:
					// Start at BaseL - MaxShadow.
					// Add (MaxShadow + MaxHighlight) * litFactor.

					// Scale dynamic range by Global Intensity?
					// Night = Low Contrast. Day = High Contrast.
					// We can use the 'intensity' from lights object (need to return it or simpler hack).
					// lights.intensity is available in scope? Yes if we updated struct.

					const contrastScale = lights.intensity;
					const maxShadow = 40 * contrastScale;
					const maxLight = 15 * contrastScale;

					// LitFactor is already scaled by intensity in calculation?
					// Wait, in previous step: litTop = ... * intensity.
					// So litFactor is 0.15 at night.

					// If we just map 0..1 to -40..15:
					// 0 -> -40. 0.15 -> -31. (Still very dark).
					// We want Neutral at night.

					// Better approach for CalcL:
					// Neutral Base.
					// Add Highlight * litFactor.
					// Subtract Shadow * (1 - litFactor)? No, directional.

					// Let's stick to the previous simple logic but dampen the range if intensity is low.
					// We need to recover 'intensity' from the block above.

					// Re-reading calculateLight above: I added intensity to return object.

					const range = 55 * lights.intensity; // Total dynamic range
					const shadowDepth = 40 * lights.intensity;

					// If litFactor is high (1.0 * 1.0), we add 15.
					// If litFactor is low (0), we subtract 40.

					// We need a normalized 0-1 "Lit-ness" of the surface relative to current sun?
					// My litTop calculation includes * intensity. So it goes 0..intensity.

					// Normalized Lit = litFactor / (lights.intensity || 1)
					const normLit = litFactor / (lights.intensity || 1);

					const offset = -shadowDepth + range * normLit;
					return Math.max(0, Math.min(100, baseL + offset));
				}}

				<!-- STATIC FRAME COLORS (No Sunrise Effect) -->
				<!-- The frame stays constant architectural B&W -->
				{@const cTop = '#ffffff'}
				{@const cLeft = '#cccccc'}
				{@const cBottom = '#333333'}
				{@const cRight = '#000000'}

				<!-- DYNAMIC SKY (Rect Only) -->
				{@const cCenter = `hsl(${skyHue}, ${skySat}%, ${skyLig}%)`}

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
	<Slider min={1} max={101} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={10} max={200} bind:value={offset} label="Tile Offset" />
	<hr />
	<Slider min={0} max={360} bind:value={rotation} label="Rotation (deg)" />
	<hr />

	<!-- Unified Colors -->
	<!-- Hue/Sat are now automatic based on Time -->
	<hr />
	<Slider min={0} max={24} step={0.1} bind:value={daylightTime} label="Daylight Time (h)" />
</div>
