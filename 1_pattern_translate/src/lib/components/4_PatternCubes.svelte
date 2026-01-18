<!-- 
  - Komplett alleine, erklären was machen
  - Berechnung über squareCount und squareSize

  https://de.serlo.org/mathe/1565/sinus-kosinus-und-tangens?utm_source=google_ads&utm_medium=89743468&utm_content=17205061708&utm_term=sinus%20cosinus%20tangens&gad_source=1&gad_campaignid=89743468&gbraid=0AAAAADtNaXQPCN5Y18FJU46ANgaxnVTRb&gclid=Cj0KCQiArt_JBhCTARIsADQZaynNx8eetJd5CNZwujhofVZdXrWHBStndbgBUwHrDEIOQ8XEf9alNIoaAspEEALw_wcB
-->

<script>
	const squareCount = 30;
	const squareSize = 50;
	const degreeAngle = 30; // 30 degrees for the cube pattern
	const angle = (Math.PI / 180) * degreeAngle; // Convert degrees to radians

	const x = squareSize / 2;
	const y = Math.tan(angle) * x;
	const hypo = x / Math.cos(angle);

	function getTranslate(xi, yi) {
		let tx, ty;

		ty = yi * (y + hypo);
    // ty = yi * (y * 3);

		if (yi % 2 === 0) {
			tx = xi * squareSize + squareSize;
		} else {
			tx = xi * squareSize + squareSize / 2;
		}

		return `translate(${tx - squareSize / 2} ${ty - hypo / 2})`;
	}
</script>

<div class="svg-container">
	<svg viewBox="0 0 1000 1000" class="svg-canvas" shape-rendering="crispEdges">
		{#each Array(squareCount) as _, yi}
			{#each Array(squareCount) as _, xi}
				<g transform={getTranslate(xi, yi)}>
					<polygon points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0" fill="rgb(31, 133, 134)" />
					<polygon
						transform-origin="0 {y * 2}"
						transform="rotate(120)"
						points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
						fill="rgb(84, 184, 159)"
					/>
					<polygon
						transform-origin="0 {y * 2}"
						transform="rotate(240)"
						points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
						fill="rgb(19, 47, 64)"
					/>
				</g>
			{/each}
		{/each}

		<!--  DAS ZEIGEN -->
		<!--  DAS ZEIGEN -->
		<!--  DAS ZEIGEN -->
		<!--  DAS ZEIGEN -->

		<!-- <g transform="translate(500 500)">
			<polygon points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0" fill="rgb(31, 133, 134)" />
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(120)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(84, 184, 159)"
			/>
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(240)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(19, 47, 64)"
			/>
		</g> -->
		<!-- <g transform="translate(550 500)">
			<polygon points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0" fill="rgb(31, 133, 134)" />
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(120)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(84, 184, 159)"
			/>
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(240)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(19, 47, 64)"
			/>
		</g>

		<g transform="translate(525 {500 + y + hypo})">
			<polygon points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0" fill="rgb(31, 133, 134)" />
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(120)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(84, 184, 159)"
			/>
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(240)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(19, 47, 64)"
			/>
		</g>

    <g transform="translate(575 {500 + y + hypo})">
			<polygon points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0" fill="rgb(31, 133, 134)" />
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(120)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(84, 184, 159)"
			/>
			<polygon
				transform-origin="0 {y * 2}"
				transform="rotate(240)"
				points="0 0, {x} {y}, 0 {y * 2}, -{x} {y}, 0 0"
				fill="rgb(19, 47, 64)"
			/>
		</g> -->
	</svg>
</div>
