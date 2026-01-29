<script>
    let { label = "Color Theme", color = $bindable() } = $props();
    
    const themes = [
		{ name: 'Nordlichter', color: '#0D1B2A' },
		{ name: 'Sportplatz', color: '#4CAF50' },
		{ name: 'Chinatown', color: '#D32F2F' },
		{ name: 'Soho', color: '#8E44AD' },
		{ name: 'Miami', color: '#FF91AF' }
	];
    
    function handleChange(e) {
        const theme = themes.find(t => t.name === e.target.value);
        if (theme) {
            color = theme.color;
        }
    }
</script>

<div class="selector">
    <div class="label">{label}</div>
    <select onchange={handleChange}>
        <option disabled selected value="">Select Theme...</option>
        {#each themes as theme}
            <option value={theme.name}>{theme.name}</option>
        {/each}
    </select>
</div>

<style>
    .selector {
        width: 100%;
        margin-bottom: 1rem;
    }
    .label {
        font-size: 0.75rem;
        margin-top: 0;
        margin-bottom: 0.3rem;
        color: #ccc;
    }
    select {
        width: 100%;
        height: 24px;
        background: #2a2a2a;
        color: white;
        border: 1px solid #444;
        border-radius: 4px;
        font-size: 0.8rem;
        padding: 0 5px;
        outline: none;
        cursor: pointer;
    }
    select:focus {
        border-color: #666;
    }
    option {
        background: #2a2a2a;
        color: white;
    }
</style>
