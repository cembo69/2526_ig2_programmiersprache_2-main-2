<script>
  import { formatHex } from "culori";

  import SliderSV_Gradient from "./SliderSV_HSV_Gradient_bak.svelte";
  import DraggableSvgNode from "./DraggableSvgNode.svelte";

  let {
    hsvValues = $bindable(),
    width = 200,
    height = 180,
    scale = 1,
  } = $props();

  // a and b range for oklab (0.35 is enough to cover all unclipped colors)
  let min = 0;
  let max = 1;

  let dragAreaElement = $state(null);
  let thumbX = $derived((hsvValues[1] * width) / max);
  let thumbY = $derived(((1 - hsvValues[2]) * height) / max);

  // the svg for the controls needs a bigger size than the gradient background
  let overhang = 10;

  function updateValues() {
    hsvValues[1] = (thumbX * max) / width;
    hsvValues[2] = max - (thumbY * max) / height;
  }
  // $inspect(hsvValues);

  let color = $derived(
    formatHex({
      mode: "okhsv",
      h: hsvValues[0],
      s: hsvValues[1],
      v: hsvValues[2],
    })
  );
</script>

<div class="container" style="width: {width}px; height: {height}px">
  <SliderSV_Gradient {width} {height} {hsvValues} {scale} {min} {max} />

  <svg
    viewBox="{-overhang} {-overhang} {width + 2 * overhang} {height +
      2 * overhang}"
    width={width + 2 * overhang}
    height={height + 2 * overhang}
    style="left:{-overhang}px; top:{-overhang}px"
  >
    <rect
      bind:this={dragAreaElement}
      x={0}
      y={0}
      {width}
      {height}
      fill="#f000"
      stroke-width="2"
    />

    <DraggableSvgNode
      bind:dragAreaElement
      bind:x={thumbX}
      bind:y={thumbY}
      minX={0}
      maxX={width}
      minY={0}
      maxY={height}
      {color}
      onchange={updateValues}
    />
  </svg>
</div>

<style>
  .container {
    position: relative;
    background-color: #3930;
  }

  svg {
    position: absolute;
    top: 0;
    left: 0;
  }
</style>
