<script>
	import Slider from '$lib/ui/Slider.svelte';

	// Tile-Dimensionen aus Pattern 3
	let tileWidth = $state(1230);
	let tileHeight = $state(1230);

	let tileCount = $state(10);
	let tileCountX = $derived(tileCount);
	let tileCountY = $derived(tileCount);
	
	// Offset controls
	let offset = $state(-400);
	let offsetX = $state(-50);
	let offsetY = $state(-48);
	let rotation = $state(0);
	let scale = $state(1);

	// Theme definitions - genau wie in Pattern 3
	const themes = {
		'Tron': ['#00D2FF', '#39FF14', '#FF073A', '#1B1B1B'],
		'Chinatown': ['#E60012', '#FFD700', '#006747', '#2A2A2A'],
		'Forest': ['#228B22', '#8A9A5B', '#A67C52', '#6B4F2A'],
		'Miami': ['#00B5B8', '#FF6F61', '#FFDD00', '#F1F1F1'],
		'Moonlight': ['#6D9BC3', '#C0C0C0', '#003366', '#2F3C45']
	};

	let selectedTheme = $state('Moonlight');
	
	// 4 Farben für verschiedene Pattern-Bereiche
	let color1 = $derived(themes[selectedTheme][0]);
	let color2 = $derived(themes[selectedTheme][1]);
	let color3 = $derived(themes[selectedTheme][2]);
	let color4 = $derived(themes[selectedTheme][3]);
	
	// Hintergrund Toggle
	let darkBackground = $state(true);
	let backgroundColor = $derived(darkBackground ? '#000000' : '#ffffff');

	// Debug Panel
	let showDebug = $state(false);

	// Keyboard handler for debug panel
	function handleKeydown(event) {
		if (event.key === 'd' || event.key === 'D') {
			showDebug = !showDebug;
		}
	}

	// Positionierungslogik - angepasst für keine Überlappung
	// Die Tiles müssen genau nebeneinander platziert werden
	function calculatePosition(index, count, size, gap) {
		// Einfache Berechnung: jede Tile bekommt ihre Position basierend auf Index
		return (index - count / 2) * size + (index - count / 2) * gap;
	}

	// Add extra tiles to ensure canvas is always filled
	const extraTiles = 8;
	const renderTileCountX = $derived(tileCountX + extraTiles);
	const renderTileCountY = $derived(tileCountY + extraTiles);

	let totalWidth = $derived(renderTileCountX * tileWidth + (renderTileCountX - 1) * offsetX);
	let totalHeight = $derived(renderTileCountY * tileHeight + (renderTileCountY - 1) * offsetY);

	let vbW = $derived(totalWidth);
	let vbH = $derived(totalHeight);
	let vbX = $derived(-vbW / 2);
	let vbY = $derived(-vbH / 2);
</script>

<svelte:window onkeydown={handleKeydown} />

<div class="svg-container">
	<svg viewBox="{vbX} {vbY} {vbW} {vbH}" class="svg-canvas" preserveAspectRatio="xMidYMid meet">
		<!-- Background Rectangle -->
		<rect x="{vbX}" y="{vbY}" width="{vbW}" height="{vbH}" fill="{backgroundColor}" />
		
		{#each Array(renderTileCountY) as _, yi}
			{#each Array(renderTileCountX) as _, xi}
				<!-- Spiegel-Logik aus Pattern 1 -->
				{@const scaleX = xi % 2 !== 0 ? -1 : 1}
				{@const scaleY = yi % 2 !== 0 ? -1 : 1}

				{@const posX = calculatePosition(xi, renderTileCountX, tileWidth, offsetX)}
				{@const posY = calculatePosition(yi, renderTileCountY, tileHeight, offsetY)}

				{@const finalX = posX + (scaleX === -1 ? tileWidth : 0)}
				{@const finalY = posY + (scaleY === -1 ? tileHeight : 0)}

				<g
					transform="translate({finalX}, {finalY}) scale({scaleX}, {scaleY}) rotate({rotation} {tileWidth /
						2} {tileHeight / 2}) scale({scale})"
				>
					<!-- Geometrie aus Pattern 3 -->
					<!-- Center Hexagon - Schwarz -->
					<polygon
						points="756.18,776.73 535.74,807.77 389.68,620.85 478.46,401.13 700.06,369.96 844.91,556.84"
						fill="#000000"
					/>

					<!-- Top arm - Farbe 1 -->
					<polygon
						points="474.73,396.97 386.08,616.36 240.73,438.22 415.28,9.63 556.43,180.08"
						fill={color1}
					/>

					<!-- Top-right arm - Farbe 2 -->
					<polygon
						points="927.28,332.93 480.55,395.73 561.03,182.01 1017.2,117.87"
						fill={color2}
					/>

					<!-- Right arm - Farbe 3 -->
					<polygon
						points="1219.94,711.58 996.74,743.02 705.8,369.17 927.98,337.91"
						fill={color3}
					/>

					<!-- Bottom-right arm - Farbe 4 -->
					<polygon
						points="816.31,1168.5 675.95,988.88 762.56,774.3 848.7,561.01 992.68,745.95"
						fill={color4}
					/>

					<!-- Bottom arm - Weiß -->
					<polygon
						points="213.84,1051.32 296.52,846.48 754.02,782.17 671.3,987.01"
						fill="#ffffff"
					/>

					<!-- Left arm - Farbe 1 (wiederholt) -->
					<polygon
						points="529.89,808.51 296,841.47 9.4,467.2 236.8,441.32 385.02,623.01"
						fill={color1}
					/>
				</g>
			{/each}
		{/each}
	</svg>
</div>

<div class="sidebar-right">
	<Slider min={5} max={35} step={1} bind:value={tileCount} label="Tile Count" />
	<hr />
	<Slider min={-200} max={200} bind:value={offset} label="Tile Offset" />
	<hr />
	<div class="toggle-container">
		<span class="label">Background</span>
		<button class="toggle-button" class:active={darkBackground} onclick={() => darkBackground = !darkBackground}>
			<span class="toggle-option" class:selected={darkBackground}>Dark</span>
			<span class="toggle-option" class:selected={!darkBackground}>Light</span>
		</button>
	</div>
	<hr />
	<div class="theme-selector">
		<div class="label">Color Theme</div>
		<div class="theme-buttons">
			{#each Object.keys(themes) as theme}
				<button 
					class="theme-button" 
					class:active={selectedTheme === theme}
					onclick={() => selectedTheme = theme}
				>
					<span class="theme-name">{theme}</span>
					<div class="theme-colors">
						{#each themes[theme] as color}
							<div class="color-dot" style="background-color: {color}"></div>
						{/each}
					</div>
				</button>
			{/each}
		</div>
	</div>
</div>

{#if showDebug}
	<div class="debug-panel">
		<div class="debug-header">
			<h2>🐛 Debug Panel - Pattern 2 (Live Editing)</h2>
			<button class="debug-close" onclick={() => showDebug = false}>✕</button>
		</div>
		<div class="debug-content">
			<div class="debug-section">
				<h3>🎨 Theme</h3>
				<div class="debug-item">
					<span class="debug-label">Theme:</span>
					<select class="debug-select" bind:value={selectedTheme}>
						{#each Object.keys(themes) as theme}
							<option value={theme}>{theme}</option>
						{/each}
					</select>
				</div>
				<div class="debug-item">
					<span class="debug-label">Background:</span>
					<select class="debug-select" bind:value={darkBackground}>
						<option value={true}>Dark</option>
						<option value={false}>Light</option>
					</select>
				</div>
			</div>

			<div class="debug-section">
				<h3>🎨 Colors (Read-Only)</h3>
				<div class="debug-item-single">
					<span class="debug-label">Color 1:</span>
					<span class="debug-value">{color1}</span>
					<span class="color-preview-small" style="background-color: {color1}"></span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Color 2:</span>
					<span class="debug-value">{color2}</span>
					<span class="color-preview-small" style="background-color: {color2}"></span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Color 3:</span>
					<span class="debug-value">{color3}</span>
					<span class="color-preview-small" style="background-color: {color3}"></span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Color 4:</span>
					<span class="debug-value">{color4}</span>
					<span class="color-preview-small" style="background-color: {color4}"></span>
				</div>
			</div>

			<div class="debug-section">
				<h3>📐 Dimensions</h3>
				<div class="debug-item">
					<span class="debug-label">Tile Count:</span>
					<input type="range" min="1" max="50" bind:value={tileCount} class="debug-slider" />
					<input type="number" bind:value={tileCount} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Tile Width:</span>
					<input type="range" min="500" max="2000" step="10" bind:value={tileWidth} class="debug-slider" />
					<input type="number" bind:value={tileWidth} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Tile Height:</span>
					<input type="range" min="500" max="2000" step="10" bind:value={tileHeight} class="debug-slider" />
					<input type="number" bind:value={tileHeight} class="debug-number" />
				</div>
			</div>

			<div class="debug-section">
				<h3>🔧 Transform</h3>
				<div class="debug-item">
					<span class="debug-label">Offset (Linked):</span>
					<input type="range" min="-500" max="500" step="10" bind:value={offset} class="debug-slider" />
					<input type="number" bind:value={offset} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Offset X:</span>
					<input type="range" min="-500" max="500" step="10" bind:value={offsetX} class="debug-slider" />
					<input type="number" bind:value={offsetX} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Offset Y:</span>
					<input type="range" min="-500" max="500" step="10" bind:value={offsetY} class="debug-slider" />
					<input type="number" bind:value={offsetY} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Rotation:</span>
					<input type="range" min="0" max="360" bind:value={rotation} class="debug-slider" />
					<input type="number" bind:value={rotation} class="debug-number" />
				</div>
				<div class="debug-item">
					<span class="debug-label">Scale:</span>
					<input type="range" min="0.1" max="3" step="0.1" bind:value={scale} class="debug-slider" />
					<input type="number" step="0.1" bind:value={scale} class="debug-number" />
				</div>
			</div>

			<div class="debug-section">
				<h3>📏 Mirroring Info</h3>
				<div class="debug-item-single">
					<span class="debug-label">Pattern:</span>
					<span class="debug-value">Alternating Mirror (X & Y)</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Odd Tiles X:</span>
					<span class="debug-value">Flipped Horizontally</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Odd Tiles Y:</span>
					<span class="debug-value">Flipped Vertically</span>
				</div>
			</div>

			<div class="debug-section">
				<h3>📊 Render Info (Read-Only)</h3>
				<div class="debug-item-single">
					<span class="debug-label">Render Tiles X:</span>
					<span class="debug-value">{renderTileCountX}</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Render Tiles Y:</span>
					<span class="debug-value">{renderTileCountY}</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">Total Tiles:</span>
					<span class="debug-value">{renderTileCountX * renderTileCountY}</span>
				</div>
			</div>

			<div class="debug-section">
				<h3>🖼️ ViewBox (Read-Only)</h3>
				<div class="debug-item-single">
					<span class="debug-label">ViewBox X:</span>
					<span class="debug-value">{vbX.toFixed(2)}</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">ViewBox Y:</span>
					<span class="debug-value">{vbY.toFixed(2)}</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">ViewBox Width:</span>
					<span class="debug-value">{vbW.toFixed(2)}</span>
				</div>
				<div class="debug-item-single">
					<span class="debug-label">ViewBox Height:</span>
					<span class="debug-value">{vbH.toFixed(2)}</span>
				</div>
			</div>

			<div class="debug-section">
				<h3>ℹ️ Info</h3>
				<div class="debug-item-single">
					<span class="debug-label">Keyboard:</span>
					<span class="debug-value">Press <kbd>D</kbd> to toggle</span>
				</div>
			</div>
		</div>
	</div>
{/if}

<style>
	.toggle-container {
		width: 100%;
		margin-bottom: 0.5rem;
	}
	
	.toggle-button {
		width: 100%;
		height: 36px;
		background: #2a2a2a;
		border: 1px solid #444;
		border-radius: 6px;
		display: flex;
		align-items: center;
		padding: 3px;
		gap: 3px;
		cursor: pointer;
		transition: all 0.2s;
	}
	
	.toggle-option {
		flex: 1;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 4px;
		font-size: 0.85rem;
		color: #888;
		transition: all 0.2s;
	}
	
	.toggle-option.selected {
		background: #444;
		color: #fff;
		font-weight: 500;
	}
	
	.theme-selector {
		width: 100%;
		margin-bottom: 0.5rem;
	}
	
	.label {
		font-size: 0.75rem;
		margin-top: 0;
		margin-bottom: 0.5rem;
		color: #ccc;
	}
	
	.theme-buttons {
		display: flex;
		flex-direction: column;
		gap: 3px;
	}
	
	.theme-button {
		width: 100%;
		height: 32px;
		background: transparent;
		border: none;
		border-radius: 4px;
		font-size: 0.85rem;
		padding: 0 10px;
		outline: none;
		cursor: pointer;
		color: #999;
		transition: all 0.15s ease;
		font-weight: 400;
		text-align: left;
		display: flex;
		align-items: center;
		justify-content: space-between;
	}
	
	.theme-button:hover {
		color: #ccc;
		background: #333;
	}
	
	.theme-button.active {
		color: white;
		background: #444;
		font-weight: 500;
	}
	
	.theme-name {
		flex: 1;
	}
	
	.theme-colors {
		display: flex;
		gap: 3px;
	}
	
	.color-dot {
		width: 16px;
		height: 16px;
		border-radius: 3px;
		border: 1px solid #666;
	}

	/* Debug Panel Styles */
	.debug-panel {
		position: fixed;
		top: 80px;
		left: 50%;
		transform: translateX(-50%);
		width: 90vw;
		max-width: 1400px;
		height: 85vh;
		background: rgba(20, 20, 20, 0.98);
		border: 2px solid #00ff00;
		border-radius: 12px;
		z-index: 10000;
		overflow: hidden;
		box-shadow: 0 0 50px rgba(0, 255, 0, 0.3);
		display: flex;
		flex-direction: column;
	}

	.debug-header {
		background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
		padding: 20px 30px;
		border-bottom: 2px solid #00ff00;
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.debug-header h2 {
		margin: 0;
		color: #00ff00;
		font-size: 1.8rem;
		font-weight: 600;
		text-shadow: 0 0 10px rgba(0, 255, 0, 0.5);
	}

	.debug-close {
		background: #ff0000;
		color: white;
		border: none;
		width: 40px;
		height: 40px;
		border-radius: 50%;
		font-size: 1.5rem;
		cursor: pointer;
		transition: all 0.2s;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.debug-close:hover {
		background: #ff3333;
		transform: scale(1.1);
	}

	.debug-content {
		flex: 1;
		overflow-y: auto;
		padding: 30px;
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
		gap: 25px;
		align-content: start;
	}

	.debug-section {
		background: rgba(30, 30, 30, 0.8);
		border: 1px solid #333;
		border-radius: 8px;
		padding: 20px;
	}

	.debug-section h3 {
		margin: 0 0 15px 0;
		color: #00d4ff;
		font-size: 1.2rem;
		font-weight: 500;
		border-bottom: 2px solid #00d4ff;
		padding-bottom: 10px;
	}

	.debug-item {
		display: grid;
		grid-template-columns: 150px 1fr auto;
		gap: 10px;
		align-items: center;
		padding: 10px 0;
		border-bottom: 1px solid #2a2a2a;
		font-family: 'Courier New', monospace;
	}

	.debug-item:last-child {
		border-bottom: none;
	}

	.debug-item-single {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 10px 0;
		border-bottom: 1px solid #2a2a2a;
		font-family: 'Courier New', monospace;
	}

	.debug-item-single:last-child {
		border-bottom: none;
	}

	.debug-label {
		color: #aaa;
		font-size: 0.95rem;
		font-weight: 500;
	}

	.debug-value {
		color: #00ff00;
		font-size: 1rem;
		font-weight: 600;
		display: flex;
		align-items: center;
		gap: 10px;
	}

	.color-preview-small {
		display: inline-block;
		width: 30px;
		height: 30px;
		border-radius: 4px;
		border: 2px solid #666;
	}

	kbd {
		background: #333;
		border: 1px solid #555;
		border-radius: 4px;
		padding: 3px 8px;
		font-family: monospace;
		font-size: 0.9rem;
		color: #fff;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
	}

	/* Debug Controls */
	.debug-select {
		background: #2a2a2a;
		border: 1px solid #555;
		border-radius: 4px;
		color: #00ff00;
		padding: 6px 12px;
		font-size: 1rem;
		font-family: monospace;
		cursor: pointer;
		grid-column: 2 / 4;
	}

	.debug-select:focus {
		outline: none;
		border-color: #00ff00;
		box-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
	}

	.debug-slider {
		height: 6px;
		background: #333;
		border-radius: 3px;
		outline: none;
		-webkit-appearance: none;
	}

	.debug-slider::-webkit-slider-thumb {
		-webkit-appearance: none;
		appearance: none;
		width: 16px;
		height: 16px;
		background: #00ff00;
		border-radius: 50%;
		cursor: pointer;
		box-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
	}

	.debug-slider::-moz-range-thumb {
		width: 16px;
		height: 16px;
		background: #00ff00;
		border-radius: 50%;
		cursor: pointer;
		border: none;
		box-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
	}

	.debug-number {
		background: #2a2a2a;
		border: 1px solid #555;
		border-radius: 4px;
		color: #00ff00;
		padding: 6px 10px;
		font-size: 0.95rem;
		font-family: monospace;
		width: 80px;
		text-align: center;
	}

	.debug-number:focus {
		outline: none;
		border-color: #00ff00;
		box-shadow: 0 0 5px rgba(0, 255, 0, 0.5);
	}

	/* Remove arrows from number inputs */
	.debug-number::-webkit-inner-spin-button,
	.debug-number::-webkit-outer-spin-button {
		-webkit-appearance: none;
		margin: 0;
	}
</style>
