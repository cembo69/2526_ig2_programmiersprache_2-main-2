<script>
	import Header from '$lib/components/Header.svelte';

	import { slide } from 'svelte/transition';
	import Pattern3 from '$lib/components/3_PatternVSC.svelte';
	import Pattern4 from '$lib/components/4_PatternAdvanced.svelte';
	import Pattern5 from '$lib/components/5_PatternDiagonal.svelte';
	import Pattern6 from '$lib/components/6_PatternWarp.svelte';
	import Pattern7 from '$lib/components/7_PatternRadial.svelte';

	let patterns = [
		{
			name: 'Pattern Basic',
			component: Pattern3,
			description: 'The standard VSC Pattern with Sunrise Simulation.'
		},
		{
			name: 'Pattern Advanced',
			component: Pattern4,
			description: 'Advanced VSC Pattern with Warp Distortion.'
		},
		{
			name: 'Pattern Diagonal',
			component: Pattern5,
			description: 'Standard VSC Pattern tilted by 45 degrees.'
		},
		{
			name: 'Pattern Warp',
			component: Pattern6,
			description: 'Grid with sine wave distortion (Warp).'
		},
		{
			name: 'Pattern Radial',
			component: Pattern7,
			description: 'Concentric rings with spiral twist control.'
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
