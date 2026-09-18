'use strict';
const viewer = document.querySelector('#image-viewer');
let imageTrigger;
document.querySelectorAll('[data-lightbox]').forEach(link => {
  link.addEventListener('click', event => {
    if (!viewer || !viewer.showModal) return;
    event.preventDefault();
    imageTrigger = link;
    viewer.querySelector('img').src = link.href;
    viewer.querySelector('img').alt = link.querySelector('img').alt;
    viewer.querySelector('p').textContent = link.querySelector('img').alt;
    viewer.showModal();
  });
});
if (viewer) {
  viewer.querySelector('button').addEventListener('click', () => viewer.close());
  viewer.addEventListener('click', event => { if (event.target === viewer) viewer.close(); });
  viewer.addEventListener('close', () => imageTrigger?.focus());
}
const player = document.querySelector('.feature-player video');
const cards = [...document.querySelectorAll('[data-video]')];
cards.forEach(card => card.addEventListener('click', () => {
  if (!player) return;
  player.pause();
  player.src = card.dataset.video;
  player.poster = card.dataset.poster;
  player.setAttribute('aria-label', card.dataset.title);
  document.querySelector('#clip-title').textContent = card.dataset.title;
  document.querySelector('#clip-time').textContent = card.dataset.time;
  cards.forEach(c => { c.classList.toggle('selected', c === card); c.setAttribute('aria-pressed', String(c === card)); });
  player.load();
  player.scrollIntoView({block: 'center', behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth'});
  player.focus({preventScroll:true});
  player.play().catch(() => { /* Native playback controls remain available. */ });
}));
document.querySelectorAll('[data-filter]').forEach(button => button.addEventListener('click', () => {
  document.querySelectorAll('[data-filter]').forEach(b => { b.classList.toggle('active', b === button); b.setAttribute('aria-pressed', String(b === button)); });
  cards.forEach(card => { card.hidden = button.dataset.filter !== 'all' && card.dataset.category !== button.dataset.filter; });
}));
document.querySelectorAll('video').forEach(video => video.addEventListener('play', () => {
  document.querySelectorAll('video').forEach(other => { if (other !== video) other.pause(); });
}));
