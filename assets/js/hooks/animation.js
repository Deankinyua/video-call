let AnimationHooks = {};

AnimationHooks.Animation = {
  mounted() {
    this.el.addEventListener("animationend", () => {
      this.pushEvent("animation-finished", { target: this.el.id });
    });
  },
};

export default AnimationHooks;
