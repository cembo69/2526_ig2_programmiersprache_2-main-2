<script>
	import Slider from '$lib/ui/Slider.svelte';
	import ThemeSelector from '$lib/ui/ThemeSelector.svelte';
	import OklchColorPicker from './OklchColorPicker.svelte';

	// Die Original-Tile-Größe aus dem SVG
	const baseTileWidth = 1407.59;
	const baseTileHeight = 1403.99;

	let tileCountX = $state(10);
	let tileCountY = $state(10);
	let offsetX = $state(0);
	let offsetY = $state(0);
	let rectSize = $state(150); // Further reduced to minimize "white space" feeling
	let tileScale = $state(1);
	let rotation = $state(0);
	let detailLayers = $state(1); // New: for "vermaschter" (meshed) look

	let viewBoxWidth = $derived(baseTileWidth * tileCountX * 1.2);
	let viewBoxHeight = $derived(baseTileHeight * tileCountY * 1.2);

	// Color System
	let manualColor = $state('#E7A15F');

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
		(r /= 255), (g /= 255), (b /= 255);
		const max = Math.max(r, g, b),
			min = Math.min(r, g, b);
		let h,
			s,
			l = (max + min) / 2;

		if (max === min) {
			h = s = 0; // achromatic
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

	let rgb = $derived(hexToRgb(manualColor));
	let hsl = $derived(rgbToHsl(rgb.r, rgb.g, rgb.b));
	let h = $derived(hsl.h);
	let s = $derived(hsl.s);
	let l = $derived(hsl.l);

	let isNordlichter = $derived(manualColor.toUpperCase() === '#0D1B2A');
	let isSportplatz = $derived(manualColor.toUpperCase() === '#4CAF50');
	let isChinatown = $derived(manualColor.toUpperCase() === '#D32F2F');
	let isMiami = $derived(manualColor.toUpperCase() === '#FF91AF');

	let cBase = $derived(
		isNordlichter ? '#0D1B2A' : 
		isSportplatz ? '#4CAF50' : 
		isChinatown ? '#D32F2F' :
		isMiami ? '#F2F2F2' :
		`hsl(${h}, ${s}%, ${l}%)`
	);
	
	let cLight = $derived(
		isNordlichter ? '#2EC4B6' : 
		isSportplatz ? '#FFFFFF' : 
		isChinatown ? '#FFD700' :
		isMiami ? '#FF91AF' :
		`hsl(${h}, ${s}%, ${Math.min(100, l + 10)}%)`
	);
	
	let cDark = $derived(
		isNordlichter ? '#7209B7' : 
		isSportplatz ? '#333333' : 
		isChinatown ? '#2D3436' :
		isMiami ? '#00E5FF' :
		`hsl(${h}, ${Math.max(0, s - 20)}%, ${Math.max(0, l - 30)}%)`
	);
	
	let cAccent = $derived(
		isNordlichter ? '#CBFF4D' : 
		isSportplatz ? '#1982C4' : 
		isChinatown ? '#F2F2F2' :
		isMiami ? '#FFB347' :
		`hsl(${(h + 25) % 360}, ${s}%, ${l}%)`
	);
	
	let cMid = $derived(
		isNordlichter ? '#2EC4B6' : 
		isSportplatz ? '#1982C4' : 
		isChinatown ? '#FFD700' :
		isMiami ? '#00E5FF' :
		`hsl(${h}, ${Math.max(0, s - 30)}%, ${Math.max(0, l - 20)}%)`
	);
</script>

<div class="svg-container">
	<svg
		viewBox="0 0 {viewBoxWidth} {viewBoxHeight}"
		class="svg-canvas"
		preserveAspectRatio="xMidYMid meet"
	>
		{#each Array(tileCountY) as _, yi}
			{#each Array(tileCountX) as _, xi}
				{@const centerX = xi * (baseTileWidth + offsetX) + baseTileWidth / 2}
				{@const centerY = yi * (baseTileHeight + offsetY) + baseTileHeight / 2}
				<g
					transform="translate({centerX}, {centerY}) rotate({rotation}) scale({tileScale}) translate({-baseTileWidth /
						2}, {-baseTileHeight / 2})"
				>
					{#each Array(detailLayers) as _, layer}
						{@const step = layer * 40}
						{@const opacityLayer = 1 - layer * 0.2}
						<g transform="translate({step}, {step})" opacity={opacityLayer}>
							<!-- Helle Parallelogramme (Base/Final) -->
							<path
								d="M1286.99 1284.99L1164.54 1370.99H704.002L826.458 1284.99H1286.99Z"
								fill={cBase}
							/>
							<path
								d="M582.992 582.991L460.536 668.991H0.00170898L122.458 582.991H582.992Z"
								fill={cLight}
							/>
							<path
								d="M120.602 1280.99L243.058 1366.99H703.592L581.136 1280.99H120.602Z"
								fill={cBase}
							/>
							<path
								d="M824.602 582.991L947.058 668.991H1407.59L1285.14 582.991H824.602Z"
								fill={cLight}
							/>

							<!-- Dunkle Parallelogramme -->
							<path
								d="M1407.59 735.001L1285.14 821.001H824.603L947.06 735.001H1407.59Z"
								fill={cDark}
							/>
							<path
								d="M703.594 33.0007L581.137 119.001H120.603L243.06 33.0007H703.594Z"
								fill={cDark}
							/>
							<path d="M0 731.001L122.456 817.001H582.99L460.534 731.001H0Z" fill={cDark} />
							<path d="M704 33.0007L826.456 119.001H1286.99L1164.53 33.0007H704Z" fill={cDark} />

							<!-- Vertikale Parallelogramme -->
							<path
								d="M824.594 1284.99L738.594 1162.53L738.594 702L824.594 824.456L824.594 1284.99Z"
								fill={cAccent}
							/>
							<path
								d="M120.594 582.991L34.5938 460.535L34.5938 0.000488281L120.594 122.457L120.594 582.991Z"
								fill={cAccent}
							/>
							<path d="M583 1280.99L669 1158.53L669 698L583 820.456L583 1280.99Z" fill={cMid} />
							<path
								d="M1287 582.991L1373 460.535L1373 0.000488281L1287 122.457L1287 582.991Z"
								fill={cMid}
							/>

							<!-- Weitere vertikale Parallelogramme -->
							<path
								d="M1372.59 1403.99L1286.59 1281.53L1286.59 821L1372.59 943.456L1372.59 1403.99Z"
								fill={cMid}
							/>
							<path
								d="M668.594 701.991L582.594 579.535L582.594 119L668.594 241.457L668.594 701.991Z"
								fill={cMid}
							/>
							<path d="M35 1399.99L121 1277.53L121 817L35 939.456L35 1399.99Z" fill={cAccent} />
							<path d="M739 701.991L825 579.535L825 119L739 241.457L739 701.991Z" fill={cMid} />
						</g>
					{/each}

					<!-- Zentrale Rechtecke (vorher rosa) -->
					<rect
						fill="#D4D4D4"
						height={rectSize}
						width={rectSize}
						transform="matrix(-1 0 0 1 {1055.59 + rectSize / 2} {1053.001 - rectSize / 2})"
					/>
					<rect
						fill="#E8E8E8"
						height={rectSize}
						width={rectSize}
						transform="matrix(-1 0 0 1 {351.594 + rectSize / 2} {351.001 - rectSize / 2})"
					/>
					<rect
						fill="#E8E8E8"
						height={rectSize}
						width={rectSize}
						x={352 - rectSize / 2}
						y={1049 - rectSize / 2}
					/>
					<rect
						fill="#D4D4D4"
						height={rectSize}
						width={rectSize}
						x={1056 - rectSize / 2}
						y={351 - rectSize / 2}
					/>
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={20} step={1} bind:value={tileCountX} label="Tiles Horizontal" />

	<hr />

	<Slider min={1} max={20} step={1} bind:value={tileCountY} label="Tiles Vertical" />

	<hr />

	<Slider min={-300} max={300} bind:value={offsetX} label="Tile Offset X" />

	<hr />

	<Slider min={-300} max={300} bind:value={offsetY} label="Tile Offset Y" />

	<hr />

	<Slider min={0.5} max={1.5} step={0.1} bind:value={tileScale} label="Tile Scale" />

	<hr />

	<Slider min={0} max={360} bind:value={rotation} label="Tile Rotation" />
	<hr />
	<Slider min={100} max={600} bind:value={rectSize} label="Rect Size" />
	<hr />
	<Slider min={1} max={5} step={1} bind:value={detailLayers} label="Mesh Complexity" />
	<hr />

	<ThemeSelector bind:color={manualColor} />
	<hr />

	<details open>
		<summary style="cursor: pointer; color: white; margin-bottom: 0.5rem;">Base Color</summary>
		<div style="margin-top: 0.5rem;">
			<OklchColorPicker bind:color={manualColor} />
		</div>
	</details>
</div>
