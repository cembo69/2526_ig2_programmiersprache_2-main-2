<script>
	import Slider from '$lib/ui/Slider.svelte';

	// Die Original-Tile-Größe aus dem SVG
	const baseTileWidth = 1407.59;
	const baseTileHeight = 1403.99;
	
	let tileCountX = $state(3);
	let tileCountY = $state(3);
	let offsetX = $state(0);
	let offsetY = $state(0);
	let tileScale = $state(1);
	let rotation = $state(0);
	
	let viewBoxWidth = $derived(baseTileWidth * tileCountX * 1.2);
	let viewBoxHeight = $derived(baseTileHeight * tileCountY * 1.2);
</script>

<div class="svg-container">
	<svg viewBox="0 0 {viewBoxWidth} {viewBoxHeight}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		{#each Array(tileCountY) as _, yi}
			{#each Array(tileCountX) as _, xi}
				{@const centerX = xi * (baseTileWidth + offsetX) + baseTileWidth / 2}
				{@const centerY = yi * (baseTileHeight + offsetY) + baseTileHeight / 2}
				<g transform="translate({centerX}, {centerY}) rotate({rotation}) scale({tileScale}) translate({-baseTileWidth / 2}, {-baseTileHeight / 2})">
					<!-- Helle Parallelogramme (vorher rot) -->
					<path d="M1286.99 1284.99L1164.54 1370.99H704.002L826.458 1284.99H1286.99Z" fill="#E7A15F" />
					<path d="M582.992 582.991L460.536 668.991H0.00170898L122.458 582.991H582.992Z" fill="#EFA763" />
					<path d="M120.602 1280.99L243.058 1366.99H703.592L581.136 1280.99H120.602Z" fill="#E7A15F" />
					<path d="M824.602 582.991L947.058 668.991H1407.59L1285.14 582.991H824.602Z" fill="#EFA763" />
					
					<!-- Dunkle Parallelogramme (vorher dunkelrot) -->
					<path d="M1407.59 735.001L1285.14 821.001H824.603L947.06 735.001H1407.59Z" fill="#5F4227" />
					<path d="M703.594 33.0007L581.137 119.001H120.603L243.06 33.0007H703.594Z" fill="#5F4227" />
					<path d="M0 731.001L122.456 817.001H582.99L460.534 731.001H0Z" fill="#5F4227" />
					<path d="M704 33.0007L826.456 119.001H1286.99L1164.53 33.0007H704Z" fill="#5F4227" />
					
					<!-- Vertikale Parallelogramme -->
					<path d="M824.594 1284.99L738.594 1162.53L738.594 702L824.594 824.456L824.594 1284.99Z" fill="#C5B951" />
					<path d="M120.594 582.991L34.5938 460.535L34.5938 0.000488281L120.594 122.457L120.594 582.991Z" fill="#C5B951" />
					<path d="M583 1280.99L669 1158.53L669 698L583 820.456L583 1280.99Z" fill="#A37143" />
					<path d="M1287 582.991L1373 460.535L1373 0.000488281L1287 122.457L1287 582.991Z" fill="#A37143" />
					
					<!-- Weitere vertikale Parallelogramme -->
					<path d="M1372.59 1403.99L1286.59 1281.53L1286.59 821L1372.59 943.456L1372.59 1403.99Z" fill="#815A35" />
					<path d="M668.594 701.991L582.594 579.535L582.594 119L668.594 241.457L668.594 701.991Z" fill="#815A35" />
					<path d="M35 1399.99L121 1277.53L121 817L35 939.456L35 1399.99Z" fill="#C5B951" />
					<path d="M739 701.991L825 579.535L825 119L739 241.457L739 701.991Z" fill="#A37143" />
					
					<!-- Zentrale Rechtecke (vorher rosa) -->
					<rect fill="#D4D4D4" height="464" width="462" transform="matrix(-1 0 0 1 1286.59 821.001)" />
					<rect fill="#E8E8E8" height="464" width="462" transform="matrix(-1 0 0 1 582.594 119.001)" />
					<rect fill="#E8E8E8" height="464" width="462" x="121" y="817.001" />
					<rect fill="#D4D4D4" height="464" width="462" x="825" y="119.001" />
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={1} max={5} step={1} bind:value={tileCountX} label="Tiles Horizontal" />

  <hr/>

	<Slider min={1} max={5} step={1} bind:value={tileCountY} label="Tiles Vertical" />
	
	<hr/>
	
	<Slider min={-300} max={300} bind:value={offsetX} label="Tile Offset X" />
	
	<hr/>
	
	<Slider min={-300} max={300} bind:value={offsetY} label="Tile Offset Y" />
	
	<hr/>
	
	<Slider min={0.5} max={1.5} step={0.1} bind:value={tileScale} label="Tile Scale" />
	
	<hr/>
	
	<Slider min={0} max={360} bind:value={rotation} label="Tile Rotation" />
</div>
