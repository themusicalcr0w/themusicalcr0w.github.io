(() => {
  const labels = {
    windows: "PokePet.gd — multi-window manager",
    geometry: "MainNode.gd — monitor-aware geometry",
    persistence: "PokeEmote.gd — persistent pet slots",
    native: "NativeWindowIntegration.cs — OS integration",
    sprites: "PokePet.gd — runtime sprite-sheet slicing"
  };

  const tabs = Array.from(document.querySelectorAll("[data-code-tab]"));
  const panels = Array.from(document.querySelectorAll("[data-code-panel]"));
  const label = document.getElementById("code-label");

  function selectTab(name, focus = false) {
    tabs.forEach((tab) => {
      const active = tab.dataset.codeTab === name;
      tab.setAttribute("aria-selected", String(active));
      tab.tabIndex = active ? 0 : -1;
      if (active && focus) tab.focus();
    });
    panels.forEach((panel) => {
      panel.hidden = panel.dataset.codePanel !== name;
    });
    if (label) label.textContent = labels[name] || "Selected excerpt";
  }

  tabs.forEach((tab, index) => {
    tab.addEventListener("click", () => selectTab(tab.dataset.codeTab));
    tab.addEventListener("keydown", (event) => {
      if (event.key !== "ArrowRight" && event.key !== "ArrowLeft") return;
      event.preventDefault();
      const offset = event.key === "ArrowRight" ? 1 : -1;
      const next = (index + offset + tabs.length) % tabs.length;
      selectTab(tabs[next].dataset.codeTab, true);
    });
  });

  selectTab("windows");

  const copyButton = document.querySelector("[data-copy-code]");
  copyButton?.addEventListener("click", async () => {
    const visible = panels.find((panel) => !panel.hidden);
    if (!visible) return;
    try {
      await navigator.clipboard.writeText(visible.textContent || "");
      const old = copyButton.textContent;
      copyButton.textContent = "Copied";
      window.setTimeout(() => { copyButton.textContent = old; }, 1400);
    } catch {
      copyButton.textContent = "Copy unavailable";
    }
  });

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (reduceMotion) {
    document.querySelectorAll("video[autoplay]").forEach((video) => {
      video.removeAttribute("autoplay");
      video.pause();
    });
  }
})();
