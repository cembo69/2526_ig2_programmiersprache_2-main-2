<script>
	const squareCount = 20;
	const squareSize = 1000 / squareCount;
</script>

<div class="svg-container">
	<svg viewBox="0 0 1000 1000" class="svg-canvas">
		{#each Array(squareCount) as _, yi}
			{#each Array(squareCount) as _, xi}
				<polygon
					transform="translate({xi * squareSize } {yi * squareSize})"
					points="0 0, {squareSize} 0, 0 {squareSize}"
					fill="hotpink"
				/>
				<polygon
					transform="translate({xi * squareSize } {yi * squareSize})"
					points="{squareSize} 0, {squareSize} {squareSize}, 0 {squareSize}"
					fill="khaki"
				/>
			{/each}
		{/each}
	</svg>
</div>
