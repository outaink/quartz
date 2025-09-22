# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a Quartz v4 static site generator blog configured for outaink.github.io with content stored in the `content/` directory. The site is built using TypeScript, React (Preact), and various markdown processing libraries.

## Essential Commands

### Development
```bash
# Install dependencies
npm install

# Build the site
npx quartz build

# Build and serve locally with hot reload
npx quartz build --serve

# Build for specific output directory
npx quartz build -d docs

# Format code
npm run format

# Type checking
npm run check
```

### Deployment
```bash
# Deploy to server (outaink.com)
./deploy.sh

# Quick deploy
./quick-deploy.sh

# Deploy with checks
./deploy-check.sh
```

## Architecture Overview

### Core Components

1. **Content Structure**: All blog content lives in `content/` directory with submodules:
   - `Android-Notes/` - Android development notes (git submodule)
   - `CS-Notes/` - Computer Science notes including MIT 6.S081 (git submodule)
   - `.obsidian/` - Obsidian vault configuration

2. **Plugin System** (`quartz/plugins/`):
   - **Transformers**: Process markdown files (FrontMatter, ObsidianFlavoredMarkdown, GitHubFlavoredMarkdown, Latex with KaTeX)
   - **Filters**: Control which files are included (RemoveDrafts)
   - **Emitters**: Generate output files (ContentPage, FolderPage, TagPage, ContentIndex with RSS/Sitemap)

3. **Key Configuration Files**:
   - `quartz.config.ts`: Main configuration including theme, plugins, and site metadata
   - `quartz.layout.ts`: Layout structure definition
   - `package.json`: Dependencies and scripts

### Important Customizations

1. **SubmoduleDateFix Plugin**: Custom plugin configured for handling git dates in submodules (`Android-Notes`, `CS-Notes`)

2. **Chinese Localization**: Site configured with `locale: "zh-CN"`

3. **Theme Configuration**:
   - Light/dark mode support with custom color schemes
   - Google Fonts integration (Schibsted Grotesk for headers, Source Sans Pro for body)

4. **Analytics**: Plausible analytics integration enabled

### Build Process

The build system:
1. Processes markdown files from `content/`
2. Applies transformer plugins for syntax highlighting, math rendering, and markdown extensions
3. Generates static HTML pages in `public/` directory
4. Creates search index, RSS feed, and sitemap
5. Handles image optimization and OpenGraph image generation

### Deployment Notes

- Production URL: outaink.github.io
- Server deployment: outaink.com at `/var/www/outaink-quartz-dg/`
- Nginx configured with proper try_files for HTML routing
- Deploy scripts handle git status checks, dependency updates, and rsync deployment

## Testing Commands

```bash
# Run tests
npm test

# Check if build produces expected files
npx quartz build && ls public/index.html public/404.html
```