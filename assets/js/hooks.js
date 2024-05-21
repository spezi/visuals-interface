let Hooks = {}

Hooks.MeasureDiv = {
  mounted() {
    window.addEventListener("resize", () => this.measureAndPushSize());
    this.measureAndPushSize();
    this.getPosition();
  },
  destroyed() {
    window.removeEventListener("resize", () => this.measureAndPushSize());
  },
  measureAndPushSize() {
    const { width, height } = this.el.getBoundingClientRect();
    this.pushEvent("div_size", { width, height });
  },
  getPosition() {
    const top = this.el.offsetTop;
    const left = this.el.offsetLeft;
    this.pushEvent("mapping_position", { top, left });
  }
}



export default Hooks;
