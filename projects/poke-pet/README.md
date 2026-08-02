# PokePet portfolio showcase

This folder is a self-contained technical case-study page for **PokePet**.

## Folder structure

```text
poke-pet-portfolio-showcase/
├── index.html
├── README.md
└── showcase/
    ├── PUBLISHING_CHECKLIST.md
    ├── project-card-snippet.html
    ├── styles.css
    ├── script.js
    ├── assets/
    │   ├── images/
    │   └── video/
    └── code-samples/
```

The root intentionally contains only `index.html`, `README.md`, and the `showcase` support folder.

## View locally

Open `index.html` in a modern browser. The page does not require a build step, package manager, server, or internet connection except when following the GitHub repository links.

## Recommended portfolio structure

Show **City Under Magic** and **PokePet** at the same time, but keep them as separate project pages under one main portfolio site.

- Use City Under Magic as the larger systems and game-architecture case study.
- Use PokePet as the smaller, completed, public-source desktop application.
- Put a short card for each project on the portfolio home page.
- Link each card to its own case-study folder.

Example:

```text
portfolio-site/
├── index.html
├── projects/
│   ├── city-under-magic/
│   │   ├── index.html
│   │   └── showcase/
│   └── poke-pet/
│       ├── index.html
│       └── showcase/
└── assets/
```

## Publishing recommendation

Publish the portfolio as a website and send employers one normal web link. Do not make a ZIP file the primary viewing method. A ZIP creates extra work, may trigger download warnings, and requires the reviewer to extract and open local files.

Keep a ZIP only as a backup for offline review or direct submission when a form specifically requests an uploaded portfolio file.

This package can be published directly with GitHub Pages because it contains static HTML, CSS, JavaScript, images, and MP4 files. See `showcase/PUBLISHING_CHECKLIST.md` for setup steps.

## Artwork and intellectual-property notice

The Pokémon names, characters, sprites, and related visual assets shown in this project are third-party intellectual property. They are used only to demonstrate the software in an unofficial fan-made portfolio project. The case study does not claim that artwork as original work and is not affiliated with Nintendo, Creatures Inc., Game Freak, or The Pokémon Company.
