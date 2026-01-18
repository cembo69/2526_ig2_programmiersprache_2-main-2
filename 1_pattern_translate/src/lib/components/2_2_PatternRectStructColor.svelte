<!-- 
  - Aufbauend auf 2.1, dann erweitern, wenn 2.1 fertig 
  - Nochmal Tipps mit den Indizes
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

	function getColor1(xi, yi) {
		if (yi % 2 == 0 && xi % 2 == 0) return '#FFA3D0'; // rosa
		if (yi % 2 == 0 && xi % 2 == 1) return '#ABD4FF'; // blau hell
		if (yi % 2 == 1 && xi % 2 == 0) return '#ABD4FF'; // blau hell
		if (yi % 2 == 1 && xi % 2 == 1) return '#FFA3D0'; // rosa hell
	}
	function getColor2(xi, yi) {
		if (yi % 2 == 0 && xi % 2 == 0) return '#BB397A'; // pink
		if (yi % 2 == 0 && xi % 2 == 1) return '#1D64B2'; // blau dunkel
		if (yi % 2 == 1 && xi % 2 == 0) return '#1D64B2'; // blau dunkel
		if (yi % 2 == 1 && xi % 2 == 1) return '#BB397A'; // pink
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
					fill={getColor1(xi, yi)}
					data-x={xi}
					data-y={yi}
				/>
				<rect
					transform="translate({calculateSizeCords2(xi, yi).x} {calculateSizeCords2(xi, yi).y})"
					width={calculateSizeCords2(xi, yi).width}
					height={calculateSizeCords2(xi, yi).height}
					fill={getColor2(xi, yi)}
					data-x={xi}
					data-y={yi}
				/>
			{/each}
		{/each}
	</svg>
</div>
