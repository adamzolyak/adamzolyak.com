# adamzolyak.com

Personal site built with Jekyll, hosted on GitHub Pages.

## Editing Content

### Blog posts
Posts live in `_posts/` as HTML or Markdown files. Filenames must follow the format:

```
YYYY-MM-DD-post-slug.md
```

Front matter at the top of each file controls metadata:

```yaml
---
title: "Post Title"
date: 2025-01-01
tags: [making, spacious-work]
---
```

Available tags: `making`, `spacious-work`, `ideas`, `tools-for-humanity`

### Pages
Static pages live in `_pages/`. Edit `about.md` for the About page. Navigation links are configured in `_config.yml` under `nav_links`.

### Images
Place images in `assets/images/` and reference them in posts as:

```html
<img src="/assets/images/my-image.jpg" alt="Description">
```

## Preview Locally

```bash
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec jekyll serve
```

Then open http://127.0.0.1:4000

## Deploy to Production

Push to the `main` branch on GitHub — GitHub Pages builds and deploys automatically.

```bash
git add .
git commit -m "your message"
git push
```

Changes are live at https://adamzolyak.com within a minute or two.
