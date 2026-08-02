# City Under Magic — Portfolio Case Study

This is a static technical case-study page for **City Under Magic**. It uses selected gameplay recordings and limited code excerpts while keeping the complete game repository private.

All artwork, icons, interface skins, character imagery, and environmental visuals shown on the page are temporary development placeholders. They are included only to demonstrate functionality and do not represent the final art direction.

## Folder structure

The root folder is intentionally kept simple:

```text
city-under-magic-portfolio/
├── index.html
├── README.md
└── showcase/
    ├── styles.css
    ├── script.js
    ├── assets/
    │   ├── images/
    │   └── video/
    ├── code-samples/
    ├── PUBLISHING_CHECKLIST.md
    └── project-card-snippet.html
```

`index.html` references all required styles, scripts, videos, images, and code samples from the adjacent `showcase` folder. No framework, package manager, database, or build step is required.

## Preview locally

Opening `index.html` directly should display the page. A local web server is more reliable for testing all browser behavior.

From this folder, run:

```bash
python -m http.server 8000
```

Then open `http://localhost:8000` in a browser.

## Publish it

### Inside an existing portfolio

Copy this entire folder into a path such as `projects/city-under-magic`. Link to its `index.html` from the main projects page. Keep the `showcase` folder beside `index.html`; changing that relationship will break the relative file paths.

### As a standalone GitHub Pages site

1. Create a repository for the showcase rather than the complete game.
2. Upload `index.html`, `README.md`, and the `showcase` folder to the repository root.
3. Enable GitHub Pages for the repository's main branch and root folder.
4. Use the resulting Pages address as the project link in the main portfolio.

The private game repository does not need to be connected or made public.

## What the page presents

The selected examples cover:

- world population and residence allocation
- NPC observation memory and dialogue context
- runtime page-curl mesh generation
- genetic inheritance resolution
- incremental and background save processing

The excerpts are intentionally limited and are not sufficient to reconstruct the complete project.

## Placeholder artwork notice

The page repeats the placeholder-art notice in the hero area, a dedicated visual-development section, the interface section, the source section, and the footer. This is deliberate. It keeps the technical work separate from any impression that the current visual assets are final or are being presented as finished art production.

Before publishing, verify that the wording accurately describes every displayed visual asset. Replace the recordings and poster images later as final or licensed artwork becomes available.

## Updating media

Replace a video in `showcase/assets/video/` while keeping the same filename. Use an H.264 MP4 with no audio, approximately 854 pixels wide. Replace the matching poster image in `showcase/assets/images/` as well.

## Other included files

- `showcase/PUBLISHING_CHECKLIST.md` contains the final review list.
- `showcase/project-card-snippet.html` contains a sample card for linking this case study from a larger portfolio.
- `showcase/code-samples/` contains the longer selected GDScript excerpts.

Do not upload the original source archive, original GIF archive, paid assets, dialogue databases, or the private game repository to the public showcase.
