<script>
	import { onMount, onDestroy } from 'svelte';
	import * as THREE from 'three';
	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
	import { converter, formatHex, clampChroma, parse } from 'culori';

	import Slider from '$lib/ui/Slider.svelte';

	let { color = $bindable('#ffffff') } = $props();

	// Conversions
	const toOklch = converter('oklch');
	const toRgb = converter('rgb');

	// Internal OKLCH state
	let l = $state(0.7);
	let c = $state(0.1);
	let h = $state(219);

	// Canvas ref
	let canvasContainer;
	let canvas;

	// Three.js variables
	let renderer, scene, camera, controls;
	let selectionMesh;
	let pointsMesh;

	// Track the last hex we generated to avoid feedback loops
	let lastGeneratedHex = '';

	// Update internal state when external color changes
	$effect(() => {
		if (color && color !== lastGeneratedHex) {
			const oklch = toOklch(color);
			if (oklch) {
				// Only update if significantly different
				if (
					Math.abs(oklch.l - l) > 0.01 ||
					Math.abs(oklch.c - c) > 0.005 ||
					Math.abs((oklch.h || 0) - h) > 1
				) {
					l = oklch.l;
					c = oklch.c;
					h = oklch.h || 0;
					updateSelectionVisual();
				}
			}
		}
	});

	// Update external color when internal state changes (Slider updates)
	$effect(() => {
		updateColor();
	});

	function updateColor() {
		// Create color object
		const oklchColor = { mode: 'oklch', l, c, h };
		// Clamp to displayable RGB if needed, or just format
		const hex = formatHex(oklchColor);

		if (hex !== color) {
			lastGeneratedHex = hex;
			color = hex;
		}
		updateSelectionVisual();
	}

	function updateSelectionVisual() {
		if (selectionMesh) {
			// Convert cylindrical to Cartesian
			// y = L, x = C * cos(h), z = C * sin(h)
			// Scale for visibility
			const rad = h * (Math.PI / 180);
			const x = c * Math.cos(rad) * 2; // Scale C
			const z = c * Math.sin(rad) * 2;
			const y = (l - 0.5) * 2; // Center L around 0

			selectionMesh.position.set(x, y, z);
			selectionMesh.material.color.set(color);
		}
	}

	// Initialize Three.js
	onMount(() => {
		const width = canvasContainer.offsetWidth;
		const height = 300; // Fixed height for 3D view

		// Scene
		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x111111);

		// Camera
		camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
		camera.position.set(2.5, 1.5, 2.5);

		// Renderer
		renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
		renderer.setSize(width, height);
		renderer.setPixelRatio(window.devicePixelRatio);

		// Controls
		controls = new OrbitControls(camera, canvas);
		controls.enableDamping = true;
		controls.autoRotate = true;
		controls.autoRotateSpeed = 1.0;

		// 1. Generate RGB Gamut Cloud
		const pointsGeometry = new THREE.BufferGeometry();
		const pointsSystem = generateGamutPoints();
		scene.add(pointsSystem);
		pointsMesh = pointsSystem;

		// 2. Selection Sphere
		const sphereGeo = new THREE.SphereGeometry(0.05, 16, 16);
		const sphereMat = new THREE.MeshBasicMaterial({ color: 0xffffff });
		selectionMesh = new THREE.Mesh(sphereGeo, sphereMat);
		scene.add(selectionMesh);

		// 3. Axes / Grid (Optional)
		const axesHelper = new THREE.AxesHelper(1);
		scene.add(axesHelper);

		// Initial update
		updateSelectionVisual();

		// Animation Loop
		let frameId;
		function animate() {
			frameId = requestAnimationFrame(animate);
			controls.update();
			renderer.render(scene, camera);
		}
		animate();

		// Resize handler
		const resizeObserver = new ResizeObserver(() => {
			const w = canvasContainer.clientWidth;
			const h = 300;
			camera.aspect = w / h;
			camera.updateProjectionMatrix();
			renderer.setSize(w, h);
		});
		resizeObserver.observe(canvasContainer);

		return () => {
			cancelAnimationFrame(frameId);
			renderer.dispose();
			resizeObserver.disconnect();
		};
	});

	function generateGamutPoints() {
		// We iterate reasonable steps of RGB, convert to OKLCH, and plot
		const positions = [];
		const colors = [];
		const steps = 15;

		for (let r = 0; r <= 1; r += 1 / steps) {
			for (let g = 0; g <= 1; g += 1 / steps) {
				for (let b = 0; b <= 1; b += 1 / steps) {
					// Convert RGB -> OKLCH
					const rgb = { mode: 'rgb', r, g, b };
					const oklch = toOklch(rgb);

					if (oklch) {
						// Cylindrical to Cartesian
						// Scale C and L to fit nicely in roughly -1..1 box
						const rad = (oklch.h || 0) * (Math.PI / 180);
						const C = oklch.c;
						const L = oklch.l;

						const x = C * Math.cos(rad) * 2;
						const z = C * Math.sin(rad) * 2;
						const y = (L - 0.5) * 2;

						positions.push(x, y, z);
						colors.push(r, g, b);
					}
				}
			}
		}

		const geometry = new THREE.BufferGeometry();
		geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
		geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));

		const material = new THREE.PointsMaterial({
			size: 0.03,
			vertexColors: true,
			transparent: true,
			opacity: 0.8
		});
		return new THREE.Points(geometry, material);
	}
</script>

<div class="picker-container">
	<div class="canvas-wrapper" bind:this={canvasContainer}>
		<canvas bind:this={canvas}></canvas>
	</div>

	<div class="controls">
		<Slider
			bind:value={l}
			min={0}
			max={1}
			step={0.01}
			label="Lightness ({(l * 100).toFixed(0)}%)"
		/>

		<Slider bind:value={c} min={0} max={0.4} step={0.001} label="Chroma ({c.toFixed(3)})" />

		<Slider bind:value={h} min={0} max={360} step={1} label="Hue ({h.toFixed(0)}°)" />

		<div class="hex-row">
			<span>{color}</span>
			<div class="swatch" style="background-color: {color};"></div>
		</div>
	</div>
</div>

<style>
	.picker-container {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		background: #222;
		padding: 1rem;
		border-radius: 8px;
		color: white;
		font-family: sans-serif;
	}
	.canvas-wrapper {
		width: 100%;
		height: 300px;
		background: #000;
		border-radius: 4px;
		overflow: hidden;
	}
	.hex-row {
		display: flex;
		align-items: center;
		justify-content: space-between;
		font-family: monospace;
		font-size: 1.1rem;
	}
	.swatch {
		width: 40px;
		height: 24px;
		border-radius: 4px;
		border: 1px solid #444;
	}
</style>
