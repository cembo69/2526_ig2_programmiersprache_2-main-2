<script>
	import chroma from 'chroma-js';
	import Slider from '$lib/ui/Slider.svelte';
	import RangeSlider from '$lib/ui/RangeSlider.svelte';
	import Toggle from '$lib/ui/Toggle.svelte';
	import ColorPickerHSV from '$lib/ui/ColorPicker/ColorPickerHSV.svelte';
	import EditableColorPalette from '$lib/ui/EditableColorPalette.svelte';

	let testToggle = $state(false);
	let squareSize = $state(50);
	let squareCount = $derived(Math.min(Math.floor(1000 / squareSize), 50));
	let squareOffset = $state(0);
	let opacityMin = $state(0.1);
	let opacityMax = $state(1);

	let colors = $state(['#552255', '#00ffaa']);
	let selectedColorIndex = $state(0);

	// Derived colors for the two triangles based on color palette
	let color1 = $derived(colors[0] || '#552255');
	let color2 = $derived(colors[1] || '#00ffaa');

	function getOpacity(xi) {
		return opacityMin + (xi / (squareCount - 1)) * (opacityMax - opacityMin);
	}

	function patternClick(event) {
		const colorIndex = event.target.getAttribute('data-color-index');
		selectedColorIndex = parseInt(colorIndex, 10);
	}

	function patternKeyDown(event) {
		if (event.key === 'Enter' || event.key === ' ') {
			event.preventDefault();
			const colorIndex = event.target.getAttribute('data-color-index');
			selectedColorIndex = parseInt(colorIndex, 10);
		}
	}
</script>

<div class="sidebar">
	<h3 style="margin: 0 0 10px 0; font-size: 1rem; font-weight: 500;">Pattern Controls</h3>

	<Toggle bind:value={testToggle} label="Black/White Mode" />

	<Slider min={0} max={250} bind:value={squareOffset} label="Square Offset" />

	<RangeSlider
		min={0}
		max={1}
		step={0.01}
		bind:value1={opacityMin}
		bind:value2={opacityMax}
		label="Opacity Range"
	/>

	<div class="color-section">
		<h3 style="margin: 0 0 10px 0; font-size: 1rem; font-weight: 500;">
			Polygon Colors
		</h3>
		<EditableColorPalette
			bind:colors
			bind:selectedColorIndex
			width={310}
			height={310}
			swatchSize={30}
		/>
	</div>
</div>

<div class="svg-container">
	<svg viewBox="0 0 1000 1000" class="svg-canvas">
		{#each Array(squareCount) as _, yi}
			{#each Array(squareCount) as _, xi}
				<polygon
					role="button"
					transform="translate({xi * squareSize + xi * squareOffset} {yi * squareSize +
						yi * squareOffset})"
					points="0 0, {squareSize} 0, 0 {squareSize}"
					fill={testToggle ? 'black' : color1}
					opacity={getOpacity(xi)}
					data-color-index="0"
				/>
				<polygon
					role="button"
					transform="translate({xi * squareSize + xi * squareOffset} {yi * squareSize +
						yi * squareOffset})"
					points="{squareSize} 0, {squareSize} {squareSize}, 0 {squareSize}"
					fill={testToggle ? 'white' : color2}
					opacity={getOpacity(xi)}
					data-color-index="1"
				/>
			{/each}
		{/each}
	</svg>
</div>

<style>
	div.sidebar {
		display: flex;
		flex-direction: column;
		list-style: none;
		padding: 20px;
		margin: 0 0 1rem 0;
		gap: 20px;
		justify-content: flex-start;
		overflow-y: auto;
		min-width: 350px;
	}
</style>
