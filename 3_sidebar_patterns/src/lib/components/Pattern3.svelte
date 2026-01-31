<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import ColorPickerHSV from '$lib/ui/ColorPicker/ColorPickerHSV.svelte';

	let tileCount = $state(5);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);

	// Separate X and Y offsets for more control
	let offsetX = $state(100);
	let offsetY = $state(100);

	// Tile size controls
	let tileWidth = $state(1000);
	let tileHeight = $state(1000);

	// Scale and rotation
	let scale = $state(0.8);
	let rotation = $state(0);

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

	let maxDist = $derived(Math.sqrt(Math.pow(tileCountX / 2, 2) + Math.pow(tileCountY / 2, 2)));

	// User's requested center-out logic with rotation compensation
	function calculatePosition(index, count, size, gap) {
		const rotationFactor = Math.abs(rotation - 180) / 26;
		const rotationCompensation = 1 - rotationFactor * 0.3;
		const adjustedGap = gap * rotationCompensation;
		const effectiveSize = size + adjustedGap;
		return (index - count / 2) * effectiveSize;
	}

	function getHslFromHex(hex) {
		const rgb = hexToRgb(hex);
		return rgbToHsl(rgb.r, rgb.g, rgb.b);
	}

	function darkenHex(hex, amount) {
		const h = getHslFromHex(hex);
		return `hsl(${h.h}, ${h.s}%, ${Math.max(8, h.l - amount)}%)`;
	}

	// ViewBox calculation with rotation compensation
	const rotationFactor = $derived(Math.abs(rotation - 180) / 26);
	const rotationCompensation = $derived(1 - rotationFactor * 0.3);
	const adjustedOffsetX = $derived(offsetX * rotationCompensation);
	const adjustedOffsetY = $derived(offsetY * rotationCompensation);

	// Add extra tiles to ensure canvas is always filled
	const extraTiles = 4;
	const renderTileCountX = $derived(tileCountX + extraTiles);
	const renderTileCountY = $derived(tileCountY + extraTiles);

	let totalWidth = $derived(renderTileCountX * tileWidth + renderTileCountX * adjustedOffsetX);
	let totalHeight = $derived(renderTileCountY * tileHeight + renderTileCountY * adjustedOffsetY);

	// Minimal padding
	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);

	// Define the 7 polygons: 6 parallelograms around a central hexagon
	const polygons = [
		// Center hexagon (black)
		{
			points:
				'527.607,491.842 610.164,272.719 979.912,428.272 898.672,649.579 585.463,903.488 437.703,714.366',
			color: 'center'
		},

		// 1 - Bottom parallelogram
		{
			points:
				'437.703,714.366 585.463,903.488 345.713,937.184 260.758,1147.46 55.4975,558.195 288.727,531.727',
			color: 'bottom'
		},

		// 2 - Left parallelogram
		{
			points: '288.727,531.727 437.703,714.366 527.607,491.842 610.164,272.719 465.426,97.9122',
			color: 'left'
		},

		// 3 - Top-left parallelogram
		{ points: '610.164,272.719 527.607,491.842 979.912,428.272 1072.12,207.792', color: 'top' },

		// 4 - Top-right parallelogram
		{
			points: '979.912,428.272 1072.12,207.792 1275.43,806.516 1046.43,838.701 898.672,649.579',
			color: 'top'
		},

		// 5 - Right parallelogram
		{
			points: '898.672,649.579 1046.43,838.701 867.847,1266.53 723.955,1082.36 585.463,903.488',
			color: 'right'
		},

		// 6 - Bottom-right parallelogram
		{ points: '585.463,903.488 723.955,1082.36 260.758,1147.46 345.713,937.184', color: 'bottom' }
	];
</script>

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		{#each Array(renderTileCountY) as _, yi}
			{#each Array(renderTileCountX) as _, xi}
				{@const scaleX = 1}
				{@const scaleY = 1}

				{@const posX = calculatePosition(xi, renderTileCountX, tileWidth, offsetX)}
				{@const posY = calculatePosition(yi, renderTileCountY, tileHeight, offsetY)}

				{@const getFrameColors = (base) => {
					if (useDebugColors) {
						return {
							cTop: debugColors.top,
							cLeft: debugColors.left,
							cBottom: debugColors.bottom,
							cRight: debugColors.right,
							cCenter: debugColors.center
						};
					}

					const hsl = getHslFromHex(base);
					const h = hsl.h;
					const s = hsl.s;
					const topL = hsl.l;

					const leftL = Math.min(100, topL + 2);
					const rightL = Math.max(0, topL - 26);
					const bottomL = Math.max(0, topL - 25);

					return {
						cCenter: '#000000',
						cTop: `hsl(${h}, ${s}%, ${topL}%)`,
						cLeft: `hsl(${h}, ${s}%, ${leftL}%)`,
						cRight: `hsl(${h}, ${s}%, ${rightL}%)`,
						cBottom: `hsl(${h}, ${s}%, ${bottomL}%)`
					};
				}}

				{@const fc = getFrameColors(manualColor)}

				{@const cTop = fc.cTop}
				{@const cLeft = fc.cLeft}
				{@const cBottom = fc.cBottom}
				{@const cRight = fc.cRight}
				{@const cCenter = fc.cCenter}

				{@const finalX = posX + (scaleX === -1 ? tileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? tileHeight : 0)}

				{@const visualCTop = scaleY === -1 ? cBottom : cTop}
				{@const visualCBottom = scaleY === -1 ? cTop : cBottom}
				{@const visualCLeft = scaleX === -1 ? cRight : cLeft}
				{@const visualCRight = scaleX === -1 ? cLeft : cRight}

				{@const colorMap = {
					top: visualCTop,
					left: visualCLeft,
					bottom: visualCBottom,
					right: visualCRight,
					center: cCenter
				}}

				<g
					transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {tileWidth /
						2} {tileHeight / 2}) scale({scale})"
				>
					<!-- Center Hexagon -->
					<polygon
						points="756.18,776.73 535.74,807.77 389.68,620.85 478.46,401.13 700.06,369.96 844.91,556.84"
						fill={colorMap.center}
					/>

					<!-- Top arm -->
					<polygon
						points="474.73,396.97 386.08,616.36 240.73,438.22 415.28,9.63 556.43,180.08"
						fill={colorMap.top}
					/>

					<!-- Top-right arm -->
					<polygon
						points="927.28,332.93 480.55,395.73 561.03,182.01 1017.2,117.87"
						fill={colorMap.top}
					/>

					<!-- Right arm -->
					<polygon
						points="1219.94,711.58 996.74,743.02 705.8,369.17 927.98,337.91"
						fill={colorMap.right}
					/>

					<!-- Bottom-right arm -->
					<polygon
						points="816.31,1168.5 675.95,988.88 762.56,774.3 848.7,561.01 992.68,745.95"
						fill={colorMap.right}
					/>

					<!-- Bottom arm -->
					<polygon
						points="213.84,1051.32 296.52,846.48 754.02,782.17 671.3,987.01"
						fill={colorMap.bottom}
					/>

					<!-- Left arm -->
					<polygon
						points="529.89,808.51 296,841.47 9.4,467.2 236.8,441.32 385.02,623.01"
						fill={colorMap.left}
					/>
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={5} max={35} step={2} bind:value={tileCount} label="Tile Count" />
	<hr />

	<Slider min={-500} max={500} bind:value={offsetX} label="Offset X" />
	<hr />
	<Slider min={-500} max={500} bind:value={offsetY} label="Offset Y" />
	<hr />

	<Slider min={200} max={2000} bind:value={tileWidth} label="Tile Width" />
	<hr />
	<Slider min={200} max={2000} bind:value={tileHeight} label="Tile Height" />
	<hr />

	<Slider min={0.1} max={3} step={0.1} bind:value={scale} label="Scale" />
	<hr />
	<Slider min={0} max={360} bind:value={rotation} label="Rotation" />
	<hr />

	<hr />
	<ThemeSelector bind:color={manualColor} />
	<hr />
	<ColorPickerHSV bind:color={manualColor} width={250} />

	<hr />
	<label style="display: flex; align-items: center; gap: 8px; color: white;">
		<input type="checkbox" bind:checked={useDebugColors} />
		Debug Colors
	</label>

	{#if useDebugColors}
		<div style="margin-top: 10px; display: flex; flex-direction: column; gap: 10px;">
			<details>
				<summary style="cursor: pointer; color: white;">Top Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.top} width={250} />
				</div>
			</details>
			<details>
				<summary style="cursor: pointer; color: white;">Bottom Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.bottom} width={250} />
				</div>
			</details>
			<details>
				<summary style="cursor: pointer; color: white;">Left Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.left} width={250} />
				</div>
			</details>
			<details>
				<summary style="cursor: pointer; color: white;">Right Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.right} width={250} />
				</div>
			</details>
			<details>
				<summary style="cursor: pointer; color: white;">Center Color</summary>
				<div style="margin-top: 5px;">
					<ColorPickerHSV bind:color={debugColors.center} width={250} />
				</div>
			</details>

			<hr />
			<div style="color: white; font-size: 0.8em;">
				<p>Current Configuration:</p>
				<code style="display: block; background: #222; padding: 5px; user-select: text;">
					{JSON.stringify(debugColors, null, 2)}
				</code>
			</div>
		</div>
	{/if}
</div>
