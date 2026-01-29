<script>
	import Header from '$lib/components/Header.svelte';

	import { slide } from 'svelte/transition';
	
	import Pattern3 from '$lib/components/3_PatternVSC.svelte';
	import Pattern4 from '$lib/components/4_PatternAdvanced.svelte';
	import Pattern5 from '$lib/components/5_PatternDiagonal.svelte';

	import Pattern1 from '$lib/components/1_PatternPolygonReactive.svelte';
	import Pattern2 from '$lib/components/2_PatternPolygonReactiveOffsetSize.svelte';
	import PatternSVG from '$lib/components/7_PatternSVG.svelte';

	let patterns = [
		{
			name: 'Pattern Basic',
			component: Pattern3,
			description: 'The standard VSC Pattern with Sunrise Simulation.'
		},
		{
			name: 'Pattern 1',
			component: Pattern4,
			description: 'Advanced VSC Pattern with Warp Distortion.'
		},
		{
			name: 'Pattern 2',
			component: Pattern5,
			description: 'Standard VSC Pattern tilted by 45 degrees.'
		},
		{
			name: 'Pattern 3',
			component: PatternSVG,
			description: 'Pattern based on custom SVG path.'
		}
	];

	let selectedPattern = $state(0);
	let SelectedPattern = $derived(patterns[selectedPattern].component);
</script>

<div class="app-container">
	<Header />
	<main class="app-main">
		<div class="sidebar-left">
			{#each patterns as pattern, index}
				<button
					class="sidebar-left-item"
					class:selected={selectedPattern === index}
					onclick={() => (selectedPattern = index)}
					>{pattern.name}
					{#if selectedPattern === index}
						<div transition:slide class="sidebar-left-description">{pattern.description}</div>
					{/if}
				</button>
			{/each}
		</div>

		<SelectedPattern />
	</main>
</div>
