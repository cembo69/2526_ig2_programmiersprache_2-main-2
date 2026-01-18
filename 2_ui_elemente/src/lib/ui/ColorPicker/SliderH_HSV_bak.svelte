<script>
  import { formatHex } from "culori";
  import DraggableSvgNode from "./DraggableSvgNode.svelte";
  import { hsv } from "chroma-js";

  let {
    hsvValues = $bindable(),
    width = 200,
    height = 16,
    margin = 6,
  } = $props();

  let minH = 0;
  let maxH = 360;

  let dragAreaElement = $state(null);
  let thumbX = $derived((hsvValues[0] / maxH) * width);

  function updateValues() {
    hsvValues[0] = (thumbX * maxH) / width;
  }

  let color = $derived(
    formatHex({
      mode: "okhsv",
      h: hsvValues[0],
      s: hsvValues[1],
      v: hsvValues[2],
    })
  );

  // the svg for the controls needs a bigger size than the gradient background
  let overhang = 10;

  let step = 10;
  let gradientStops = $derived.by(() => {
    let res = [];
    for (let x = 0; x <= 1; x += 1 / step) {
      let col = formatHex({
        mode: "okhsv",
        h: x * 360,
        s: hsvValues[1],
        v: hsvValues[2],
      });
      res.push({ color: col, offset: x });
    }
    return res;
  });
</script>

<div class="container" style="width: {width}px; height: {height}px">
  <!-- first svg for the gradient without margins and poitioned regularily by flex -->
  <svg
    id="gradient"
    viewBox="{0} {0} {width} {height}"
    {width}
    {height}
  >
    <!-- <rect x={0} y={0} {width} {height} fill="#dddddd" /> -->

    <g>
      <linearGradient
        id="luminanceGradient"
        gradientUnits="userSpaceOnUse"
        x1="0"
        y1="0"
        x2={width}
        y2="0"
      >
        {#each gradientStops as stop}
          <stop offset={stop.offset} style={"stop-color:" + stop.color} />
        {/each}
      </linearGradient>

      <rect
        fill="url(#luminanceGradient)"
        stroke="#444"
        x={1}
        y={1}
        width={width-2}
        height={height-2}
        rx="3"
        ry="3"
      />
    </g>
  </svg>

  <!-- second svg for the draggable node with margins (to not clip the shadow) and positioned absolutely -->
  <svg
    id="slider"
    viewBox="{-overhang} {-overhang} {width + 2 * overhang} {height+ 2 * overhang}"
    width={width + 2 * overhang}
    height={height + 2 * overhang}
    style="left: {-overhang}px; top: {-overhang + 1}px;"
  >
    <rect
      bind:this={dragAreaElement}
      fill="#f000"
      x={0}
      y={0}
      {width}
      {height}
    />

    <DraggableSvgNode
      {dragAreaElement}
      bind:x={thumbX}
      y={7}
      minX={0}
      maxX={width}
      minY={7}
      maxY={7}
      {color}
      onchange={updateValues}
    />

    <!-- <DraggableSvgNode
      bind:dragging
      bind:x={handleX}
      bind:y={handleY}
      bind:startDragging
      minX={0}
      maxX={0}
      minY={0}
      maxY={height}
    >
      <filter id="shadow">
        <feDropShadow dx="1" dy="1" stdDeviation="1" flood-opacity="0.5" />
      </filter>
      <g filter="url(#shadow)">
        <circle cx="0" cy="0" r="8" fill="#f000" stroke="none" />
        <circle cx="0" cy="0" r="5" fill={color.hexClipped} stroke="#fff" stroke-width="2" />
      </g>
    </DraggableSvgNode> -->
  </svg>
</div>

<style>
  .container {
    position: relative;
    /* background-color: #6aa; */
  }

  svg#slider {
    position: absolute;
  }
</style>
