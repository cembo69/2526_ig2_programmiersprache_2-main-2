<script>
	import Header from '$lib/components/Header.svelte';

	import { slide } from 'svelte/transition';

	import PatternBasic from '$lib/components/PatternBasic.svelte';
	import Pattern1 from '$lib/components/Pattern1.svelte';
	import Pattern2 from '$lib/components/Pattern2.svelte';
	import Pattern3 from '$lib/components/Pattern3.svelte';

	let patterns = [
		{
			name: 'Pattern Basic',
			component: PatternBasic,
			description: 'The standard VSC Pattern with Sunrise Simulation.'
		},
		{
			name: 'Pattern 1',
			component: Pattern1,
			description: 'Advanced VSC Pattern with Warp Distortion.'
		},
		{
			name: 'Pattern 2',
			component: Pattern2,
			description: 'Standard VSC Pattern tilted by 45 degrees.'
		},
		{
			name: 'Pattern 3',
			component: Pattern3,
			description: 'Geometric mesh pattern with interconnected polygons.'
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
