<script>
	import Slider from '$lib/ui/Slider.svelte';
	import OklchColorPicker from './OklchColorPicker.svelte';

	// Reduced dimensions for a single unit
	const baseTileWidth = 703.8;
	const baseTileHeight = 702;

	// Radial Pattern Controls
	let ringCount = $state(15);
	let spacing = $state(40); // Was 'offset'
	let rotation = $state(90); // Default rotation alignment
	let spiralTwist = $state(0); // New fun parameter

	// Manual Color Override
	let useManualColor = $state(true);
	let manualColor = $state('#00002a');

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

	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

	// Generate Tiles Function
	// Returns array of objects: { x, y, rotation, scaleX, scaleY }
	let tiles = $derived.by(() => {
		let t = [];
		// Center tile
		t.push({ x: 0, y: 0, rot: rotation, scaleX: 1, scaleY: 1 });

		for (let r = 1; r <= ringCount; r++) {
			// Radius for this ring
			// Effective size of a tile in radial direction
			const effRad = baseTileWidth + spacing;
			const radius = r * effRad;

			// Circumference
			const circum = 2 * Math.PI * radius;

			// How many tiles fit?
			const tilesInRing = Math.floor(circum / (baseTileHeight + spacing)); // simple approx

			for (let i = 0; i < tilesInRing; i++) {
				const angleStep = (2 * Math.PI) / tilesInRing;
				const angle = i * angleStep + r * spiralTwist * 0.05; // Apply spiral twist

				const x = Math.cos(angle) * radius;
				const y = Math.sin(angle) * radius;

				// Rotational alignment:
				// Align tile with the radius? angle * 180/PI
				// Plus user rotation
				const rot = (angle * 180) / Math.PI + rotation;

				t.push({
					x,
					y,
					rot,
					scaleX: 1,
					scaleY: 1
				});
			}
		}
		return t;
	});

	// ViewBox Calculation
	let maxR = $derived((ringCount + 1) * (baseTileWidth + spacing));
	let vbSide = $derived(maxR * 2 + 1000); // Add padding
	let vbX = $derived(-vbSide / 2);
	let vbY = $derived(-vbSide / 2);

	const scale = 1;
	const meshTightness = 0;
	let coreRatio = $derived(0.66 - meshTightness * 0.4);
	let dynamicW = $derived(baseTileWidth * coreRatio);
	let dynamicH = $derived(baseTileHeight * coreRatio);

	const cx = baseTileWidth / 2;
	const cy = baseTileHeight / 2;

	let x_rect_L = $derived(cx - dynamicW / 2);
	let x_rect_R = $derived(cx + dynamicW / 2);
	let y_rect_T = $derived(cy - dynamicH / 2);
	let y_rect_B = $derived(cy + dynamicH / 2);

	let rect_W = $derived(x_rect_R - x_rect_L);
	let rect_H = $derived(y_rect_B - y_rect_T);

	const y_top = 33.0;
	const y_bottom = 669.0;
	const x_left = 34.6;
	const x_right = 668.6;
	const x_extreme_right = 703.6;
	const overlap = 2.0;

	let p_top = $derived(`
        M ${x_rect_R} ${y_rect_T} 
        L ${x_rect_R} ${y_rect_T + overlap} 
        L ${x_rect_L} ${y_rect_T + overlap} 
        L ${x_rect_L} ${y_rect_T} 
        L 243.1 ${y_top} 
        H ${x_extreme_right} 
        L ${x_rect_R} ${y_rect_T} 
        Z`);

	let p_right = $derived(`
        M ${x_rect_R} ${y_rect_B}
        L ${x_rect_R - overlap} ${y_rect_B}
        L ${x_rect_R - overlap} ${y_rect_T}
        L ${x_rect_R} ${y_rect_T}
        L ${x_right} 241.5
        L ${x_right} 702
        L ${x_rect_R} ${y_rect_B}
        Z`);

	let p_bottom = $derived(`
        M ${x_rect_L} ${y_rect_B}
        L ${x_rect_L} ${y_rect_B - overlap}
        L ${x_rect_R} ${y_rect_B - overlap}
        L ${x_rect_R} ${y_rect_B}
        L 460.5 ${y_bottom}
        H 0
        L ${x_rect_L} ${y_rect_B}
        Z`);

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
	<svg
		viewBox="{vbX} {vbY} {vbSide} {vbSide}"
		class="svg-canvas"
		preserveAspectRatio="xMidYMid meet"
	>
		{#each tiles as tile}
			{@const getFrameColors = (base) => {
				if (!useFrameColor)
					return { cTop: '#ffffff', cLeft: '#cccccc', cBottom: '#333333', cRight: '#000000' };
				const hsl = getHslFromHex(base);
				const h = hsl.h;
				const s = hsl.s;
				const l = Math.max(0, Math.min(100, hsl.l));

				return {
					cTop: `hsl(${h}, ${s}%, ${l}%)`,
					cLeft: `hsl(${(h + 90) % 360}, ${s}%, ${Math.max(0, l - 20)}%)`,
					cBottom: `hsl(${(h + 180) % 360}, ${s}%, ${Math.max(0, l - 75)}%)`,
					cRight: `hsl(${(h + 270) % 360}, ${s}%, ${Math.max(0, l - 90)}%)`
				};
			}}
			{@const fc = getFrameColors(frameColor)}
			{@const cCenter = manualColor}

			<g
				transform="translate({tile.x}, {tile.y}) rotate({tile.rot} {baseTileWidth /
					2} {baseTileHeight / 2})"
			>
				<path d={p_bottom} fill={fc.cBottom} id="Bottom" />
				<path d={p_top} fill={fc.cTop} id="Top" />
				<path d={p_left} fill={fc.cLeft} id="Left" />
				<path d={p_right} fill={fc.cRight} id="Right" />
				<rect fill={cCenter} x={x_rect_L} y={y_rect_T} width={rect_W} height={rect_H} />
			</g>
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={25} step={1} bind:value={ringCount} label="Ring Count" />
	<hr />
	<Slider min={10} max={300} bind:value={spacing} label="Spacing" />
	<hr />
	<Slider min={0} max={360} bind:value={rotation} label="Base Rotation" />
	<hr />
	<Slider min={-10} max={10} step={0.1} bind:value={spiralTwist} label="Spiral Twist" />
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
