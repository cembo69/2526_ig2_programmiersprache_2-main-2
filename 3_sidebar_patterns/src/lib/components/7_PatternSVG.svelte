<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import OklchColorPicker from './OklchColorPicker.svelte';

	// Reduced dimensions for a single unit (matching Pattern Basic)
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	let tileCount = $state(15);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	let offset = $state(500); // Standard offset 500
	let offsetX = $derived(offset);
	let offsetY = $derived(offset);

	let rotation = $state(0);
	const scale = 1;

	// Split Controls - Simplified
	// Instead of 4 independent X/Y controls, let's focus on "Separation".
	// One slider to split them apart vertically (Y-Axis separation)
	// One slider to shear them horizontally (X-Axis shear)
	let splitY = $state(0); // Vertical Separation (moving away from center)
	let splitX = $state(0); // Horizontal Shift (Groups sliding past each other)

	// We calculate the individual shifts from these 2 master controls
	// Group A (Top) moves UP/LEFT?
	// Group B (Bottom) moves DOWN/RIGHT?
	
	// Symmetrical separation:
	// Top (A): Needs to go UP (-Y).
	// Bottom (B): Needs to go DOWN (+Y).
	let shiftAY = $derived(-splitY);
	let shiftBY = $derived(splitY);
	
	// Shearing:
	// Top (A): Moves Left (-X)
	// Bottom (B): Moves Right (+X)
	let shiftAX = $derived(-splitX);
	let shiftBX = $derived(splitX);

	// Manual Color Override
	let useManualColor = $state(true);
	let manualColor = $state('#8393ff');

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

	// Grid Position Calculation
	function calculatePosition(index, count, size, gap) {
		const basePosition = (index - count / 2) * size;
		const offsetPosition = (index - count / 2 + 0.5) * gap;
		return basePosition + offsetPosition;
	}

	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

	// Total size for viewBox
	let totalWidth = $derived(tileCountX * baseTileWidth + tileCountX * offsetX);
	let totalHeight = $derived(tileCountY * baseTileHeight + tileCountY * offsetY);

	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);

	// --- MATHEMATICALLY PERFECT RHOMBI (Gapless Hexagon) ---
	// 6 Rhombi meeting at the center (0,0) with their 60-degree acute angles.
	// This forms a perfect solid Hexagon with no gaps.
	
	const rhombusSide = 350; // Side length of the Rhombus

	const cx = baseTileWidth / 2;
	const cy = baseTileHeight / 2;
	
	// Parameters are simpler now: We just construct a Rhombus from two vectors.
	// Vector U = (Angle A)
	// Vector V = (Angle A + 60)
	function getRhombusPath(index) {
		const angleStart = index * 60;
		const angleEnd = angleStart + 60;
		
		// Convert to radians (subtract 90 to orient 0 degrees UP, or keep 0 as Right)
		// Let's stick to standard math: 0 is Right.
		const rad1 = angleStart * (Math.PI / 180);
		const rad2 = angleEnd * (Math.PI / 180);
		
		// Center
		const p0 = { x: cx, y: cy };
		
		// Vector 1 endpoint
		const p1 = { 
			x: cx + rhombusSide * Math.cos(rad1), 
			y: cy + rhombusSide * Math.sin(rad1) 
		};
		
		// Vector 2 endpoint (from center)
		const p3 = { 
			x: cx + rhombusSide * Math.cos(rad2), 
			y: cy + rhombusSide * Math.sin(rad2) 
		};
		
		// Far corner (Vector 1 + Vector 2 from center)
		const p2 = { 
			x: cx + rhombusSide * Math.cos(rad1) + rhombusSide * Math.cos(rad2), 
			y: cy + rhombusSide * Math.sin(rad1) + rhombusSide * Math.sin(rad2) 
		};

		return `M ${p0.x} ${p0.y} L ${p1.x} ${p1.y} L ${p2.x} ${p2.y} L ${p3.x} ${p3.y} Z`;
	}
	// Points: BottomLeft, BottomRight, TopRight, TopLeft relative to its own origin
	// We then translate it out by innerRadius and rotate it.
	function getParallelogramPath(angleDeg) {
		// Define unrotated shape at origin
		// Base is at y=0. Slants to right.
		// p1: -w/2, 0
		// p2: w/2, 0
		// p3: w/2 + skew, length
		// p4: -w/2 + skew, length
		
		// To place it in the circle:
		// Move up by innerRadius (along negative Y in SVG? No, let's work in math coords then flip Y or just rotate)
		// Let's assume Angle 0 is pointing UP (negative Y).
		
		const rad = (angleDeg - 90) * (Math.PI / 180); // -90 to point Up at 0 deg
		const cos = Math.cos(rad);
		const sin = Math.sin(rad);

		// Local points (relative to shape anchor)
		// Anchor is the center of the bottom edge
		const points = [
			{ x: -paraWidth / 2, y: innerRadius },
			{ x: paraWidth / 2, y: innerRadius },
			{ x: paraWidth / 2 + skewOffset, y: innerRadius + paraLength },
			{ x: -paraWidth / 2 + skewOffset, y: innerRadius + paraLength }
		];

		// Transform points
		const transformed = points.map(p => {
			// Rotate (x, y)
			// Standard rotation matrix
			const rx = p.x * Math.cos(rad + Math.PI/2) - p.y * Math.sin(rad + Math.PI/2); // Adjustment for orientation
			const ry = p.x * Math.sin(rad + Math.PI/2) + p.y * Math.cos(rad + Math.PI/2);
			
			// Translate to Center
			return {
				x: cx + rx,
				y: cy + ry
			};
		});

		return `M ${transformed[0].x} ${transformed[0].y} L ${transformed[1].x} ${transformed[1].y} L ${transformed[2].x} ${transformed[2].y} L ${transformed[3].x} ${transformed[3].y} Z`;
	}

	// Lighting logic for 6 sides to mimic 3D (similar to Basic Pattern's Tetradic)
	// We distribute lightness changes around the circle.
	// Light source assumed nicely Top-Left.
	// 0(Top): Bright. 60(TR): Med. 120(BR): Dark. 180(Bot): Darkest. 240(BL): Dark. 300(TL): Bright.
	const lightingOffsets = [0, -15, -40, -60, -40, -15];

    // Split Logic
    // Indexes 0-5.
    // 0: Right (0-60)
    // 1: Right-Down (60-120)
    // 2: Down-Left (120-180)
    // 3: Left (180-240)
    // 4: Left-Up (240-300)
    // 5: Up-Right (300-360)

    // Horizontal Split (Top vs Bottom)
    // Group Top (A): [3, 4, 5]
    // Group Bottom (B): [0, 1, 2]
    
    function getGroup(index) {
        if (index >= 3) return 'A'; // Top
        return 'B'; // Bottom
    }
</script>

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		{#each Array(tileCountY) as _, yi}
			{#each Array(tileCountX) as _, xi}
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, tileCountX, baseTileWidth, offsetX)}
				{@const posY = calculatePosition(yi, tileCountY, baseTileHeight, offsetY)}
				
				<!-- STATIC FRAME COLORS (or Dynamic Frame) -->
				{@const getFrameColors = (base) => {
					const hsl = getHslFromHex(base);
					// Tetradic Rotation (90deg steps) - Same as Basic Pattern
					const h = hsl.h;
					const s = hsl.s;
					const l = Math.max(0, Math.min(100, hsl.l));

					return {
						h, s, l: l, // Return base HSL so we can modulate L in the loop
						cTop: `hsl(${h}, ${s}%, ${l}%)`,
					};
				}}
				{@const fc = getFrameColors(manualColor)}
				
                {@const isNordlichter = manualColor.toUpperCase() === '#0D1B2A'}
                {@const nordlichterPalette = ['#0D1B2A', '#2EC4B6', '#CBFF4D', '#7209B7']}
                
                {@const isSportplatz = manualColor.toUpperCase() === '#4CAF50'}
                {@const sportplatzPalette = ['#4CAF50', '#FFFFFF', '#1982C4', '#333333']}
                
                {@const isChinatown = manualColor.toUpperCase() === '#D32F2F'}
                {@const chinatownPalette = ['#D32F2F', '#FFD700', '#2D3436', '#F2F2F2']}

                {@const isMiami = manualColor.toUpperCase() === '#FF91AF'}
                {@const miamiPalette = ['#F2F2F2', '#FF91AF', '#00E5FF', '#FFB347']}
				
				{@const finalX = posX + (scaleX === -1 ? baseTileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? baseTileHeight : 0)}

				<g
					transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {baseTileWidth / 2} {baseTileHeight / 2}) scale({scale})"
				>
                    <!-- Mathematically Perfect Rhombi (Solid Hexagon) -->
					{#each Array(6) as _, i}
						{@const h = fc.h} 
						{@const s = fc.s} 
						{@const baseL = fc.l}
						// Lighting: 6 steps
						{@const l = Math.max(0, Math.min(100, baseL + lightingOffsets[i]))}
						
                        {@const color = isNordlichter
                            ? nordlichterPalette[i % 4] // Cycle through palette
                            : isSportplatz
                            ? sportplatzPalette[i % 4]
                            : isChinatown
                            ? chinatownPalette[i % 4]
                            : isMiami
                            ? miamiPalette[i % 4]
                            : `hsl(${h}, ${s}%, ${l}%)`
                        }
                        
                        {@const group = getGroup(i)}
                        // Use derived simplified shifts
                        {@const gx = group === 'A' ? shiftAX : shiftBX}
                        {@const gy = group === 'A' ? shiftAY : shiftBY}
						
						<path 
							d={getRhombusPath(i)} 
                            transform="translate({gx}, {gy})"
							fill={color} 
						/>
					{/each}
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={51} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />
	<!-- Offset Slider Removed (Fixed at 500) -->
	
	<Slider min={0} max={360} bind:value={rotation} label="Rotation (deg)" />
	<hr />

    <p style="color: white; font-weight: bold; margin-bottom: 0.5rem">Split Control</p>
    <!-- Simplified Controls -->
    <Slider min={0} max={300} bind:value={splitY} label="Split Vertical" />
    <Slider min={0} max={248} bind:value={splitX} label="Shift Horizontal" />
    
    <hr />

    <ThemeSelector bind:color={manualColor} />
    <hr />

	<details open>
		<summary style="cursor: pointer; color: white; margin-bottom: 0.5rem;">Fill Color</summary>
		<div style="margin-top: 0.5rem;">
			<OklchColorPicker bind:color={manualColor} />
		</div>
	</details>
</div>
