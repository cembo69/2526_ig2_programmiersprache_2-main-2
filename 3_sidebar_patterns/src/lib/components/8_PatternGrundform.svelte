<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import ColorPickerHSV from '$lib/ui/ColorPicker/ColorPickerHSV.svelte';

	// Base tile dimensions derived from SVG viewBox
	const baseTileWidth = 1182.18;
	const baseTileHeight = 1223.07;

	let tileCount = $state(15);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	let offset = $state(100);
	let offsetX = $derived(offset);
	let offsetY = $derived(offset);

	let rotation = $state(0);
	let strokeWidth = $state(5);
	const scale = 1;

	// Manual Color Override
	let useManualColor = $state(true);
	let manualColor = $state('#8393ff');

	// Center hexagon vertices (derived from original path analysis)
	// The hexagon center is formed by these 6 points meeting at the middle
	const centerHex = {
		top: { x: 481.098, y: 403.619 },
		topRight: { x: 937.848, y: 403.619 },
		bottomRight: { x: 826.598, y: 611.465 },
		bottom: { x: 481.098, y: 819.311 },
		bottomLeft: { x: 361.098, y: 611.465 },
		topLeft: { x: 238.991, y: 409.869 }
	};

	// 6 parallelograms - each connects center hexagon vertex to outer points
	const parallelograms = [
		// Top (vertical parallelogram pointing up)
		`M ${centerHex.topLeft.x} ${centerHex.topLeft.y} L ${centerHex.top.x} ${centerHex.top.y} L 593.348 198.119 L 474.348 4.86875 Z`,
		
		// Top-Right (horizontal parallelogram)
		`M ${centerHex.top.x} ${centerHex.top.y} L ${centerHex.topRight.x} ${centerHex.topRight.y} L 1059.85 198.119 L 593.348 198.119 Z`,
		
		// Right (vertical parallelogram pointing down-right)
		`M ${centerHex.topRight.x} ${centerHex.topRight.y} L ${centerHex.bottomRight.x} ${centerHex.bottomRight.y} L 946.598 819.311 L 1177.85 403.619 Z`,
		
		// Bottom-Right (vertical parallelogram pointing down)
		`M ${centerHex.bottomRight.x} ${centerHex.bottomRight.y} L ${centerHex.bottom.x} ${centerHex.bottom.y} L 593.348 1015.71 L 710.206 1218.12 Z`,
		
		// Bottom-Left (horizontal parallelogram)
		`M ${centerHex.bottomLeft.x} ${centerHex.bottomLeft.y} L ${centerHex.bottom.x} ${centerHex.bottom.y} L 238.991 819.311 L 125.598 1015.71 Z`,
		
		// Left (vertical parallelogram pointing up-left)
		`M ${centerHex.topLeft.x} ${centerHex.topLeft.y} L ${centerHex.bottomLeft.x} ${centerHex.bottomLeft.y} L 238.991 819.311 L 4.34781 403.619 Z`
	];

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

	// Lighting offsets for 6 parallelograms (creates 3D effect)
	const lightingOffsets = [0, -15, -30, -45, -30, -15];

	// Grid Position Calculation
	function calculatePosition(index, count, size, gap) {
		const basePosition = (index - count / 2) * size;
		const offsetPosition = (index - count / 2 + 0.5) * gap;
		return basePosition + offsetPosition;
	}

	// Total size for viewBox
	let totalWidth = $derived(tileCountX * baseTileWidth + tileCountX * offsetX);
	let totalHeight = $derived(tileCountY * baseTileHeight + tileCountY * offsetY);

	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);
</script>

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		{#each Array(tileCountY) as _, yi}
			{#each Array(tileCountX) as _, xi}
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, tileCountX, baseTileWidth, offsetX)}
				{@const posY = calculatePosition(yi, tileCountY, baseTileHeight, offsetY)}

				{@const finalX = posX + (scaleX === -1 ? baseTileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? baseTileHeight : 0)}

				<g
					transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {baseTileWidth / 2} {baseTileHeight / 2}) scale({scale})"
				>
					{#each parallelograms as path, i}
						{@const hsl = getHslFromHex(manualColor)}
						{@const h = hsl.h}
						{@const s = hsl.s}
						{@const baseL = hsl.l}
						{@const l = Math.max(8, Math.min(100, baseL + lightingOffsets[i]))}
						{@const color = `hsl(${h}, ${s}%, ${l}%)`}
						
						<path 
							d={path} 
							fill={color}
						/>
					{/each}
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={49} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={10} max={500} bind:value={offset} label="Tile Offset" />
	<hr />
	<Slider min={0} max={360} bind:value={rotation} label="Rotation (deg)" />
	<hr />
	<ThemeSelector bind:color={manualColor} />
	<hr />
	<ColorPickerHSV bind:color={manualColor} width={250} />
</div>

<style>
	.svg-container {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #1a1a1a;
		overflow: hidden;
	}

	.svg-canvas {
		width: 100%;
		height: 100%;
	}

	.sidebar-right {
		width: 280px;
		background-color: #2a2a2a;
		padding: 1.5rem;
		overflow-y: auto;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	hr {
		border: none;
		border-top: 1px solid #444;
		margin: 0.5rem 0;
	}
</style>
