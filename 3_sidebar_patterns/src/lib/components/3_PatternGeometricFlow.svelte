<script>
	import Slider from '$lib/ui/Slider.svelte';

	let tileCountX = $state(6);
	let tileCountY = $state(10);
	let scale = $state(0.15); // Overall scale to fit the long basis shape
	let globalRotation = $state(0);

	// The parallelogram path from basis.svg
	const baseW = 583;
	const baseH = 101;
	const indent = 122.458;
	const pathData = 'M583 0L460.542 101H0L122.458 0H583Z';

	const colors = [
		'#C5B951', // Gold
		'#E7A15F', // Orange
		'#5F4227', // Brown
		'#A37143' // Mid-Brown
	];

	/**
	 * TILING CONCEPT: "Symmetry Chain"
	 * We use the basis shape and mirror it horizontally in every second row (Spiegeln).
	 * We then use the mathematical indent (122.458) to shift them so they touch
	 * perfectly without overlapping and without leaving white space gaps.
	 */

	// Calculated distance to touch perfectly:
	// The width of the "box" the shape takes up is baseW.
	// But it starts at 0 and ends at baseW.
	// However, the bottom edge is shifted by indent.
	// To make them "chain", we offset by (baseW - indent).
	let xStep = $derived((baseW - indent) * scale);
	let yStep = $derived(baseH * scale);
</script>

<div class="svg-container">
	<svg
		viewBox="0 0 {(tileCountX + 2) * xStep} {(tileCountY + 2) * yStep}"
		class="svg-canvas"
		preserveAspectRatio="xMidYMid meet"
	>
		<g
			transform="translate({xStep}, {yStep}) rotate({globalRotation}, {(tileCountX * xStep) /
				2}, {(tileCountY * yStep) / 2})"
		>
			{#each Array(tileCountY) as _, yi}
				{#each Array(tileCountX) as _, xi}
					{@const isFlipped = yi % 2 !== 0}
					{@const color = colors[(xi + yi) % 4]}

					<!-- 
						Positioning:
						Every second row is flipped (mirrored).
						We adjust the X position so the skewed edges align perfectly.
					-->
					<g
						transform="translate({xi * xStep + (isFlipped ? indent * scale : 0)}, {yi *
							yStep}) scale({scale})"
					>
						<g transform={isFlipped ? 'scale(-1, 1) translate(-' + baseW + ', 0)' : ''}>
							<path d={pathData} fill={color} stroke="rgba(0,0,0,1)" stroke-width="1.5" />
						</g>
					</g>
				{/each}
			{/each}
		</g>
	</svg>
</div>

<div class="sidebar-right">
	<h3 style="color: #E7A15F;">Mirror Tessellation</h3>
	<p style="font-size: 0.7rem; color: #888; margin-bottom: 1rem;">No overlap. No gaps.</p>

	<Slider min={2} max={30} step={1} bind:value={tileCountX} label="Horizontal Count" />
	<Slider min={2} max={30} step={1} bind:value={tileCountY} label="Vertical Count" />

	<hr />

	<Slider min={0.05} max={0.5} step={0.01} bind:value={scale} label="Shape Scale" />
	<Slider min={-180} max={180} bind:value={globalRotation} label="Global Rotation" />

	<div
		style="margin-top: 2rem; padding: 10px; background: rgba(255,255,255,0.05); border-radius: 4px;"
	>
		<div style="font-size: 0.6rem; color: #666; margin-bottom: 5px;">RULES APPLIED:</div>
		<ul style="font-size: 0.65rem; color: #aaa; padding-left: 15px; margin: 0;">
			<li>Source: basis.svg</li>
			<li>No Overlapping</li>
			<li>Zero White Space</li>
			<li>Horizontal Mirroring</li>
		</ul>
	</div>
</div>

<style>
	.svg-container {
		flex: 1;
		background: #0a0a0a;
		display: flex;
		align-items: center;
		justify-content: center;
		overflow: hidden;
	}
	.svg-canvas {
		width: 100%;
		height: 100%;
		max-height: 90vh;
	}
	hr {
		border: none;
		border-top: 1px solid #222;
		margin: 1rem 0;
	}
</style>
