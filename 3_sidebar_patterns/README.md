# Implement Pattern-Sidebar

## 1. Änderung in app.css
app.css in eurem Projekt ersetzen. Falls ihr die geändert habt, darauf achten, dass ihr die Datei nicht komplett überschreibt.


## 2. Änderung in page.svelte


#### Slide-Transitions Patternwechsel
```
import { slide } from 'svelte/transition';
```


#### Eure Pattern-Imports
```
import Pattern1 from '$lib/components/1_PatternPolygonReactive.svelte';
import Pattern2 from '$lib/components/2_PatternPolygonReactiveOffsetSize.svelte';
```


#### Beschreibung der Patterns für die Sidebar, mit Verknüpfung zu euren Komponenten
```
let patterns = [
  {
    name: 'Squares in the Grid (offset)',
    component: Pattern1,
    description:
      'A grid of squares divided into two triangles that can get an offset.'
  },
  {
    name: 'Squares in the Grid (offset and size)',
    component: Pattern2,
    description:
      'A grid of squares divided into two triangles that can get an offset and size.'
  },
];
```


#### Trigger für Patternwechsel bei Klick auf Pattern in der Sidebar
```
let selectedPattern = $state(0);
let SelectedPattern = $derived(patterns[selectedPattern].component);
```


#### Sidebar-Left hinzufügen + variable SelectedPattern-Komponente (wird bei Klick ausgetauscht)
```
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
```


## 3. Änderung in euren Patterns
Sidebar-Right in Pattern-Komponente hinzufügen, sie z.b. 1_PatternPolygonReactive.svelte
```
<div class="sidebar-right">
	<Slider min={0} max={50} bind:value={squareOffset} label="Square Offset" />
</div>
```