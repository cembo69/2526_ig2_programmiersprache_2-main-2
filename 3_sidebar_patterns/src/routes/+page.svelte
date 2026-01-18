<script>
	import Header from '$lib/components/Header.svelte';

  import { slide } from 'svelte/transition';
	import Pattern1 from '$lib/components/1_PatternPolygonReactive.svelte';
	import Pattern2 from '$lib/components/2_PatternPolygonReactiveOffsetSize.svelte';

	let patterns = [
		{
			name: 'Tile Pattern Grid (basic)',
			component: Pattern1,
			description:
				'A repeating grid pattern made from the base tile with adjustable tile count and spacing.'
		},
		{
			name: 'Tile Pattern Grid (advanced)',
			component: Pattern2,
			description:
				'A repeating grid pattern with advanced controls: tile count, spacing, scale, and rotation.'
		},
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