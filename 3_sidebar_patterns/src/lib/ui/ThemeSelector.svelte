<script>
    let { label = "Color Theme", color = $bindable() } = $props();
    
    const themes = [
		{ name: 'Nordlichter', color: '#0D1B2A' },
		{ name: 'Sportplatz', color: '#4CAF50' },
		{ name: 'Chinatown', color: '#D32F2F' },
		{ name: 'Soho', color: '#8E44AD' },
		{ name: 'Miami', color: '#FF91AF' }
	];
    
    function selectTheme(themeColor) {
        color = themeColor;
    }
</script>

<div class="selector">
    <div class="label">{label}</div>
    <div class="theme-buttons">
        {#each themes as theme}
            <button 
                class="theme-button" 
                class:active={color?.toUpperCase() === theme.color.toUpperCase()}
                onclick={() => selectTheme(theme.color)}
            >
                {theme.name}
            </button>
        {/each}
    </div>
</div>

<style>
    .selector {
        width: 100%;
        margin-bottom: 1rem;
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
        height: 28px;
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
</style>
