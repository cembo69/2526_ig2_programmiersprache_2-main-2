<script>
	// Theme definitions
	const themes = {
		'Tron': ['#00D2FF', '#39FF14', '#FF073A', '#1B1B1B'],
		'Chinatown': ['#E60012', '#FFD700', '#006747', '#2A2A2A'],
		'Forest': ['#228B22', '#8A9A5B', '#A67C52', '#6B4F2A'],
		'Miami': ['#00B5B8', '#FF6F61', '#FFDD00', '#F1F1F1'],
		'Moonlight': ['#6D9BC3', '#C0C0C0', '#003366', '#2F3C45']
	};

	let {
		selectedTheme = $bindable('Miami'),
		color1 = $bindable(),
		color2 = $bindable(),
		color3 = $bindable(),
		color4 = $bindable()
	} = $props();

	// Update colors when theme changes
	$effect(() => {
		const themeColors = themes[selectedTheme];
		if (themeColors) {
			color1 = themeColors[0];
			color2 = themeColors[1];
			color3 = themeColors[2];
			color4 = themeColors[3];
		}
	});
</script>

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

<style>
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
</style>
