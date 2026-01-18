<!-- 
  - HTML und Svelte Code zeigen + Funktionsaufrufe
  - Zeige wie das erste kleine Pattern beginnt (außerhalb der Schleife)

  - 2 Rechtecke in der Schleife und entsprechend der Indizes x, y, width und height anpassen
  - Funktionen müssen sie schreiben 
  - Kleiner Tipp mit data-x um zu sehen welche Indizes die Rects haben
-->

<script>
	const squareCount = 20;
	const squareSize = 1000 / squareCount;

	function calculateSizeCords1(xi, yi) {
		const x = xi * squareSize;
		const y = yi * squareSize;

		if ((xi + yi) % 2 == 0) {
			return { x: x, y: y, width: squareSize, height: squareSize / 2 };
		} else {
			return { x: x, y: y, width: squareSize / 2, height: squareSize };
		}
	}

	function calculateSizeCords2(xi, yi) {
		if ((xi + yi) % 2 == 0) {
			const x = xi * squareSize;
			const y = yi * squareSize + squareSize / 2;

			return { x: x, y: y, width: squareSize, height: squareSize / 2 };
		} else {
			const x = xi * squareSize + squareSize / 2;
			const y = yi * squareSize;

			return { x: x, y: y, width: squareSize / 2, height: squareSize };
		}
	}
</script>

<div class="svg-container">
	<svg viewBox="0 0 1000 1000" class="svg-canvas" shape-rendering="crispEdges">
		{#each Array(squareCount) as _, yi}
			{#each Array(squareCount) as _, xi}
				<rect
					transform="translate({calculateSizeCords1(xi, yi).x} {calculateSizeCords1(xi, yi).y})"
					width={calculateSizeCords1(xi, yi).width}
					height={calculateSizeCords1(xi, yi).height}
					fill="hotpink"
					data-x={xi}
					data-y={yi}
				/>
				<rect
					transform="translate({calculateSizeCords2(xi, yi).x} {calculateSizeCords2(xi, yi).y})"
					width={calculateSizeCords2(xi, yi).width}
					height={calculateSizeCords2(xi, yi).height}
					fill="khaki"
					data-x={xi}
					data-y={yi}
				/>
			{/each}
		{/each}
    
		<!-- <rect transform="translate(0 0)" width={squareSize} height={squareSize / 2} fill="#BB397A" />

		<rect
			transform="translate(0 {squareSize / 2})"
			width={squareSize}
			height={squareSize / 2}
			fill="#1D64B2"
		/>

		<rect
			transform="translate({squareSize} 0)"
			width={squareSize / 2}
			height={squareSize}
			fill="#BB397A"
		/>
		<rect
			transform="translate({squareSize + squareSize / 2} 0)"
			width={squareSize / 2}
			height={squareSize}
			fill="#1D64B2"
		/> -->
	</svg>
</div>
