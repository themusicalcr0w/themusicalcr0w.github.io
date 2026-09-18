# Cory Schreiner — public portfolio

This is the general-purpose website. BakuQuest and PokePet are featured; City Under Magic sits behind the closed archive dropdown near the bottom. The event-specific PDF is not included or linked.

No build step, package installation, backend, or external fonts are required. Open `index.html` to review the local files. Video support can depend on your browser's local-file permissions.

## Update the existing GitHub website

1. Extract `Cory_Schreiner_GitHub_Portfolio.zip`. Open the extracted folder; you should see `index.html`, `assets`, `projects`, `README.md`, and `.nojekyll`.
2. Open the repository that publishes your current website: https://github.com/themusicalcr0w/themusicalcr0w.github.io. If your current deployment uses a different repository, use that repository instead.
3. Open **Settings → Pages**. Under **Build and deployment**, check the source. For **Deploy from a branch**, note the selected branch and folder: `/ (root)` or `/docs`. Upload into that same branch and folder. Keep the existing settings for a working branch deployment.
4. Return to **Code**, select the publishing branch, and open `docs` if that is the configured publishing folder. Choose **Add file → Upload files**.
5. Drag the extracted folder's contents into the upload area, keeping the `assets` and `projects` folders intact. Upload the contents, not the ZIP or a containing `portfolio-site` folder. The new `index.html` must sit directly in the publishing folder. On a Mac, press **Command–Shift–Period** in Finder to show `.nojekyll` and include it.
6. Review the upload, enter a commit message such as `Update portfolio with BakuQuest and PokePet`, and commit to the publishing branch. If branch protection requires a pull request, create a branch, open the pull request, and merge it into the publishing branch instead.
7. Open **Actions** and wait for the Pages deployment to finish successfully. Visit https://themusicalcr0w.github.io/ and refresh. On a Mac, use **Command–Shift–R** if the old version remains cached. Check both featured projects, a BakuQuest video, an enlarged screenshot, and the archive dropdown.

GitHub's browser uploader accepts up to 100 files at once and limits each file to 25 MiB. This package fits those limits. If an upload times out, upload the media folders first, then the HTML and other files.

### If Pages currently uses GitHub Actions

Keep the existing workflow if it already publishes plain static files, and upload into the source folder that workflow publishes. If you want to replace a build-based setup with this plain static site, use **Settings → Pages → Source → Deploy from a branch**, choose the branch containing these files and its root or `docs` folder, then save. Do not retain a competing custom deployment workflow that publishes the old site.

### Replacing files and preserving existing content

Files uploaded at matching paths update the existing files. Uploading does not remove other old files. You do not need to delete the repository or wipe it first. Preserve repository configuration and any custom-domain `CNAME` file. Existing assets that are no longer referenced can stay until you decide to clean them up.

If you already uploaded an earlier version of this package, remove `downloads/Cory_Schreiner_Software_Development_Portfolio.pdf` from the repository in a separate commit if you do not want that old event packet accessible by its direct URL. This corrected package no longer includes it, but uploading new files alone will not delete an earlier copy.

## Editing

- `index.html`: homepage and archive dropdown.
- `projects/*/index.html`: project pages.
- `assets/style.css`: appearance and responsive layouts.
- `assets/site.js`: clip filtering, video selection and image enlargement.
- `assets/baku`, `assets/poke`, `assets/city`: local media.

Videos use native controls and do not autoplay or preload. Image enlargement supports Escape and returns focus to the original link. The pages use no analytics or external fonts.

## Media and validation

BakuQuest footage was captured with Godot Movie Maker at a fixed 60 FPS; it demonstrates features rather than realtime performance. Network multiplayer remains planned. Fan-project artwork belongs to its respective owners; City Under Magic visuals are placeholders.

Local links, anchors, image files, JavaScript syntax and all 21 video files were checked. Browser visual and interactive testing was unavailable because local preview URLs were blocked in the authoring session. Review in your browser before publishing.

## Official instructions

- GitHub uploads: https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository
- GitHub Pages publishing source: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
