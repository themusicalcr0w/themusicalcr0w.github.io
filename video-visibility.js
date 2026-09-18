(() => {
  const videos = [...document.querySelectorAll('video')];
  const motion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const visible = new Set();
  const shouldPlay = video => visible.has(video) && !document.hidden && !motion.matches;
  const update = video => {
    if (!shouldPlay(video)) {
      video.pause();
      return;
    }
    const attempt = video.play();
    if (attempt) attempt.then(() => {
      if (!shouldPlay(video)) video.pause();
    }).catch(() => {}); // Controls remain available when autoplay is blocked.
  };
  videos.forEach(video => {
    video.muted = true;
    video.playsInline = true;
    video.loop = true;
    video.controls = true;
    video.removeAttribute('autoplay');
    video.addEventListener('play', () => {
      if (document.hidden || ('IntersectionObserver' in window && !visible.has(video))) video.pause();
    });
  });
  if (!('IntersectionObserver' in window)) return;
  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting && entry.intersectionRatio >= 0.2) visible.add(entry.target);
      else visible.delete(entry.target);
      update(entry.target);
    });
  }, { threshold: [0, 0.2] });
  videos.forEach(video => observer.observe(video));
  document.addEventListener('visibilitychange', () => videos.forEach(update));
  motion.addEventListener('change', () => videos.forEach(update));
})();
