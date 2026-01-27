<script>
	import { onMount } from 'svelte';
	import { converter, formatHex, parse, wcagContrast } from 'culori';

	let { color = $bindable('#ffffff') } = $props();

	// Converters
	const toHsv = converter('hsv');
	const toRgb = converter('rgb');

	// Internal State (HSV)
	let h = $state(0); // 0-360
	let s = $state(0); // 0-1
	let v = $state(1); // 0-1
	let isDragging = $state(false);

	// DOM Elements
	let areaRef;
	let hueRef;

	// Update internal state when external color changes (and we are not dragging)
	$effect(() => {
		if (!isDragging && color) {
			const parsed = parse(color);
			if (parsed) {
				const hsv = toHsv(parsed);
				// Check for NaN (grayscale colors have undefined hue)
				if (!isNaN(hsv.h)) h = hsv.h;
				s = hsv.s;
				v = hsv.v;
			}
		}
	});

	// Derived values for UI
	let areaBackgroundColor = $derived(`hsl(${h}, 100%, 50%)`);
	let thumbColor = $derived(color);
	let textColor = $derived(wcagContrast(color, '#000000') > 4.5 ? '#000000' : '#ffffff');

	function updateColorFromState() {
		const newHex = formatHex({ mode: 'hsv', h: h || 0, s, v });
		if (newHex !== color) {
			color = newHex;
		}
	}

	// Interaction: Saturation / Value Area
	function handleAreaPointer(e) {
		if (!areaRef) return;
		const rect = areaRef.getBoundingClientRect();
		const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
		const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));

		s = x;
		v = 1 - y;
		updateColorFromState();
	}

	function onAreaPointerDown(e) {
		isDragging = true;
		areaRef.setPointerCapture(e.pointerId);
		handleAreaPointer(e);
	}

	function onAreaPointerMove(e) {
		if (isDragging && areaRef.hasPointerCapture(e.pointerId)) {
			handleAreaPointer(e);
		}
	}

	function onAreaPointerUp(e) {
		isDragging = false;
		areaRef.releasePointerCapture(e.pointerId);
	}

	// Interaction: Hue Slider
	function handleHuePointer(e) {
		if (!hueRef) return;
		const rect = hueRef.getBoundingClientRect();
		const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));

		h = x * 360;
		updateColorFromState();
	}

	function onHuePointerDown(e) {
		isDragging = true;
		hueRef.setPointerCapture(e.pointerId);
		handleHuePointer(e);
	}

	function onHuePointerMove(e) {
		if (isDragging && hueRef.hasPointerCapture(e.pointerId)) {
			handleHuePointer(e);
		}
	}

	function onHuePointerUp(e) {
		isDragging = false;
		hueRef.releasePointerCapture(e.pointerId);
	}
</script>

<div class="color-picker">
	<!-- Saturation/Value Area -->
	<div
		class="area"
		bind:this={areaRef}
		style="background-color: {areaBackgroundColor};"
		onpointerdown={onAreaPointerDown}
		onpointermove={onAreaPointerMove}
		onpointerup={onAreaPointerUp}
	>
		<div class="area-gradient white"></div>
		<div class="area-gradient black"></div>
		<div
			class="thumb"
			style="left: {s * 100}%; top: {(1 - v) *
				100}%; background-color: {thumbColor}; border-color: {textColor}"
		></div>
	</div>

	<!-- Hue Slider -->
	<div
		class="hue-slider"
		bind:this={hueRef}
		onpointerdown={onHuePointerDown}
		onpointermove={onHuePointerMove}
		onpointerup={onHuePointerUp}
	>
		<div class="hue-thumb" style="left: {(h / 360) * 100}%;"></div>
	</div>

	<!-- Text Input -->
	<div class="input-row">
		<div class="swatch" style="background-color: {color}"></div>
		<input type="text" bind:value={color} spellcheck="false" />
	</div>
</div>

<style>
	.color-picker {
		display: flex;
		flex-direction: column;
		gap: 12px;
		background: #1e1e1e;
		padding: 12px;
		border-radius: 12px;
		border: 1px solid #333;
		width: 100%;
		max-width: 300px;
		user-select: none;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
	}

	/* Saturation/Value Area */
	.area {
		position: relative;
		width: 100%;
		height: 180px;
		border-radius: 8px;
		overflow: hidden;
		cursor: crosshair;
		touch-action: none;
	}

	.area-gradient {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		pointer-events: none;
	}

	.area-gradient.white {
		background: linear-gradient(to right, #fff, rgba(255, 255, 255, 0));
	}

	.area-gradient.black {
		background: linear-gradient(to bottom, transparent, #000);
	}

	.thumb {
		position: absolute;
		width: 12px;
		height: 12px;
		border-radius: 50%;
		border: 2px solid white;
		box-shadow: 0 1px 4px rgba(0, 0, 0, 0.5);
		transform: translate(-50%, -50%);
		pointer-events: none;
	}

	/* Hue Slider */
	.hue-slider {
		position: relative;
		width: 100%;
		height: 16px;
		border-radius: 8px;
		background: linear-gradient(
			to right,
			#f00 0%,
			#ff0 17%,
			#0f0 33%,
			#0ff 50%,
			#00f 67%,
			#f0f 83%,
			#f00 100%
		);
		cursor: pointer;
		touch-action: none;
	}

	.hue-thumb {
		position: absolute;
		top: 0;
		bottom: 0;
		width: 8px;
		background: white;
		border-radius: 4px;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
		transform: translateX(-50%);
		pointer-events: none;
		border: 1px solid rgba(0, 0, 0, 0.1);
	}

	/* Input Row */
	.input-row {
		display: flex;
		align-items: center;
		gap: 8px;
	}

	.swatch {
		width: 24px;
		height: 24px;
		border-radius: 6px;
		border: 1px solid #444;
	}

	input[type='text'] {
		flex: 1;
		background: #2a2a2a;
		border: 1px solid #444;
		color: #eee;
		padding: 4px 8px;
		border-radius: 6px;
		font-family: monospace;
		font-size: 14px;
		outline: none;
	}

	input[type='text']:focus {
		border-color: #666;
	}
</style>
