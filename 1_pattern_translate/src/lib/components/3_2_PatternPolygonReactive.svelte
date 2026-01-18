<script>
	const squareCount = 20;
	const squareSize = 1000 / squareCount;

	let squareOffset = $state(0);
</script>

<ul>
	<li>
		<label class="caption">Offset</label>
		<div class="control">
			<input type="range" min="0" max="50" bind:value={squareOffset} />
			<label>{squareOffset}</label>
		</div>
	</li>
</ul>

<div class="svg-container">
	<svg viewBox="0 0 1000 1000" class="svg-canvas">
		{#each Array(squareCount) as _, yi}
			{#each Array(squareCount) as _, xi}
				<polygon
					transform="translate({xi * squareSize + xi * squareOffset} {yi * squareSize + yi * squareOffset})"
					points="0 0, {squareSize} 0, 0 {squareSize}"
					fill="hotpink"
				/>
				<polygon
					transform="translate({xi * squareSize + xi * squareOffset} {yi * squareSize + yi * squareOffset})"
					points="{squareSize} 0, {squareSize} {squareSize}, 0 {squareSize}"
					fill="khaki"
				/>
			{/each}
		{/each}
	</svg>
</div>

<style>
	ul {
		display: flex;
    flex-direction: column;
		list-style: none;
		padding: 20px;
		margin: 0 0 1rem 0;
		width: 200px;
    gap: 20px;
    justify-content: center;
	}
	li {
		display: flex;
		flex-direction: column;
		gap: 5px;
	}
	.control {
		display: flex;
		font-size: 20px;
		line-height: 20px;
		gap: 10px;
		font-weight: 600;
	}
	.caption {
		opacity: 0.7;
		font-size: 14px;
		font-weight: 600;
	}
</style>
