<script>
	import { onMount } from 'svelte';
	import { converter, formatHex, parse, wcagContrast } from 'culori';
    import NumberSpinner from "svelte-number-spinner";

	let { color = $bindable('#ffffff') } = $props();

	// Converters
	const toHsv = converter('hsv');
	const toHsl = converter('hsl');
	const toRgb = converter('rgb');

	// Internal State (HSV) - Initialize from props
	let h = $state(0); // 0-360
	let s = $state(0); // 0-1
	let v = $state(1); // 0-1
	let isDragging = $state(false);
    
    // Internal State (HSL for Inputs) - Initialize from props
    let hsl_h = $state(0);
    let hsl_s = $state(0);
    let hsl_l = $state(0);

    let spinnerUpdating = false;
    
    // Initialize HSL values from color on mount
    if (color) {
        const parsed = parse(color);
        if (parsed) {
            const hsl = toHsl(parsed);
            hsl_h = isNaN(hsl.h) ? 0 : Math.round(hsl.h);
            hsl_s = Math.round(hsl.s * 100);
            hsl_l = Math.round(hsl.l * 100);
        }
    }

	// DOM Elements
	let areaRef;
	let hueRef;

    // Sync Color -> Visual State (HSV)
	$effect(() => {
		if (color) {
			const parsed = parse(color);
			if (parsed) {
				const hsv = toHsv(parsed);
				if (!isNaN(hsv.h)) h = hsv.h;
				s = hsv.s;
				v = hsv.v;
			}
		}
	});

    // Sync Color -> HSL Spinners
    // We only sync FROM color TO spinners if the update didn't originate from the spinners
    $effect(() => {
        // Dependency on color
        if (color) {
             if (spinnerUpdating) {
                 // The color changed because of the spinner.
                 // We DO NOT want to re-calculate HSL from color, 
                 // because that causes rounding errors and jumps (e.g. S changes when L changes).
                 // We trust the spinner values are already "correct" for the user's intent.
                 return; 
             }

            const parsed = parse(color);
            if (parsed) {
                const hsl = toHsl(parsed);
                hsl_h = isNaN(hsl.h) ? 0 : Math.round(hsl.h);
                hsl_s = Math.round(hsl.s * 100);
                hsl_l = Math.round(hsl.l * 100);
            }
        }
    });

    // Called when a spinner finishes changing (on:change)
    // We use a flag to tell the effect system "This is a spinner update"
    function commitSpinnerChange(e) {
        spinnerUpdating = true;
        
        // Calculate new color based on CURRENT spinner values
        const newColor = formatHex({ mode: 'hsl', h: hsl_h, s: hsl_s / 100, l: hsl_l / 100 });
        
        if (newColor && newColor !== color) {
            color = newColor;
        }
        
        // Force blur on the active element to "deselect" it
        if (typeof document !== 'undefined' && document.activeElement instanceof HTMLElement) {
            document.activeElement.blur();
        }

        // Reset the flag after a delay that is surely after the effect runs
        setTimeout(() => {
            spinnerUpdating = false;
        }, 50);
    }

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
    
    <!-- HSL Inputs -->
    <div class="hsl-inputs">
        <div class="field">
            <label>H</label>
            <div class="spinner-wrapper">
                <NumberSpinner bind:value={hsl_h} min={0} max={360} circular={true} on:change={commitSpinnerChange} speed={1} />
            </div>
        </div>
        <div class="field">
            <label>S</label>
            <div class="spinner-wrapper">
                <NumberSpinner bind:value={hsl_s} min={0} max={100} on:change={commitSpinnerChange} speed={0.5} />
            </div>
        </div>
        <div class="field">
            <label>L</label>
            <div class="spinner-wrapper">
                <NumberSpinner bind:value={hsl_l} min={0} max={100} on:change={commitSpinnerChange} speed={0.5} />
            </div>
        </div>
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
    
    .hsl-inputs {
        display: flex;
        gap: 8px;
    }
    
    .field {
        display: flex;
        align-items: center;
        gap: 4px;
        flex: 1;
        background: #2a2a2a;
        padding: 2px 4px;
        border-radius: 4px;
        border: 1px solid #444;
    }
    
    .field label {
        color: #888;
        font-size: 11px;
        font-weight: bold;
    }

    .spinner-wrapper {
        flex: 1;
        /* Ensure spinner fits */
        min-width: 0; 
    }

    /* Target inputs within the spinner */
    :global(.spinner-wrapper input) {
        width: 100% !important;
        background: transparent !important;
        border: none !important;
        color: #eee !important;
        font-family: monospace;
        font-size: 12px;
        outline: none;
        padding: 0 !important;
        text-align: left;
        cursor: ew-resize !important; /* Indicate drag behavior */
        pointer-events: auto; /* Ensure events are caught */
    }
    
    /* Disable text selection/caret which makes it feel like an input */
    :global(.spinner-wrapper input:focus) {
        caret-color: transparent; /* Hide caret */
        user-select: none; /* No text selection */
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
