<script>
	import Header from '$lib/components/Header.svelte';

	import { slide } from 'svelte/transition';

	import Pattern1 from '$lib/components/Pattern1.svelte';
	import Pattern2 from '$lib/components/Pattern2.svelte';
	import Pattern3 from '$lib/components/Pattern3.svelte';
	import Pattern4 from '$lib/components/Pattern4.svelte';

	let patterns = [
		{
			name: 'Pattern 1',
			component: Pattern1
		},
		{
			name: 'Pattern 2',
			component: Pattern2
		},
		{
			name: 'Pattern 3',
			component: Pattern3
		},
		{
			name: 'Pattern 4',
			component: Pattern4
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
				</button>
			{/each}
		</div>

		<SelectedPattern />
	</main>
</div>
