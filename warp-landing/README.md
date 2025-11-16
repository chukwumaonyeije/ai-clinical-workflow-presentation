# Warp Generate Landing Page

Convert Markdown files into beautiful, modern landing pages and deploy to GitHub Pages with a single command.

## 🚀 Quick Start

```powershell
# Generate landing page from README
.\warp-landing.ps1 generate --source ..\README.md --theme modern-ai

# Generate and deploy to GitHub Pages
.\warp-landing.ps1 generate --source ..\README.md --theme modern-ai --deploy gh-pages

# Review the generated page
.\warp-landing.ps1 ai review landing-page --suggest-fixes --performance
```

## 📋 Commands

### Generate Landing Page

```powershell
.\warp-landing.ps1 generate --source <file> [options]

Options:
  --source <file>     Markdown or HTML file to convert (required)
  --theme <name>      Theme name (default: modern-ai)
  --slides            Generate Reveal.js slide deck
  --deploy <branch>   Deploy to GitHub Pages branch
  --output-dir <dir>  Output directory (default: dist)
```

### Theme Management

```powershell
# List all themes
.\warp-landing.ps1 theme list

# Preview theme details
.\warp-landing.ps1 theme preview --theme modern-ai

# Get theme info
.\warp-landing.ps1 theme info --theme medical-tech
```

### Deploy to GitHub Pages

```powershell
.\warp-landing.ps1 deploy [branch] [options]

Options:
  <branch>         Branch name (default: gh-pages)
  --domain <url>   Custom domain
  --output-dir     Directory to deploy (default: dist)
```

### AI Review

```powershell
.\warp-landing.ps1 ai review landing-page [options]

Options:
  --suggest-fixes   Get actionable suggestions
  --performance     Include performance analysis
  --focus <areas>   Focus on specific areas (accessibility, seo, etc.)
```

## 🎨 Available Themes

### modern-ai (default)
- **Best for:** AI/tech products, developer tools, modern SaaS
- **Colors:** Purple (#6366F1), Cyan (#06B6D4), Dark background
- **Features:** Animated gradient background, glassmorphism cards, dark/light mode

### developer-docs
- **Best for:** Documentation sites, open source projects
- **Colors:** GitHub blue (#0969DA), neutral grays
- **Features:** Sidebar navigation, syntax highlighting, clean minimal design

### medical-tech
- **Best for:** Healthcare products, medical services, clinical tools
- **Colors:** Clinical blue (#0066CC), white backgrounds
- **Features:** Trust-building design, credential badges, professional typography

### startup-landing
- **Best for:** Product launches, startups, landing pages
- **Colors:** Vibrant red (#FF6B6B), teal (#4ECDC4)
- **Features:** Full-screen hero, pricing tables, large animated CTAs

### minimalist
- **Best for:** Portfolios, blogs, minimalist brands
- **Colors:** Monochrome (black, white, gray)
- **Features:** Single-column layout, generous whitespace, elegant typography

## 📦 What It Does

1. **Parses Markdown** - Extracts title, headings, content
2. **Applies Theme** - Beautiful, responsive design with modern CSS
3. **Generates Navigation** - Auto-generated from H2 headings
4. **Adds CTAs** - Extracts links and creates call-to-action buttons
5. **SEO Optimized** - Meta tags, OpenGraph, Twitter Cards
6. **Mobile Responsive** - Works perfectly on all devices
7. **Dark Mode** - Automatic light/dark theme switching

## 🎯 Features

### Auto-Generated Elements
- Hero section from first H1 and paragraph
- Navigation menu from H2 headings (first 5)
- CTA buttons from prominent links
- Footer with copyright
- Social media meta tags

### Universal Theme Features
- Responsive breakpoints (320px, 768px, 1024px, 1440px)
- Dark/light mode with system preference detection
- Typography scale (modular 1.25 ratio)
- Spacing system (4px base unit)
- Smooth scroll navigation
- Mobile-friendly menu

## 🔧 Requirements

- Windows PowerShell 5.1+ or PowerShell Core 7+
- Git (for deployment)
- GitHub repository (for GitHub Pages deployment)

## 📖 Examples

### Example 1: Clinical AI Presentation

```powershell
# Perfect for your current project!
.\warp-landing.ps1 generate `
  --source ..\README.md `
  --theme modern-ai `
  --deploy gh-pages
```

### Example 2: Medical Documentation

```powershell
.\warp-landing.ps1 generate `
  --source docs.md `
  --theme medical-tech
```

### Example 3: Startup Product Launch

```powershell
.\warp-landing.ps1 generate `
  --source product.md `
  --theme startup-landing `
  --slides
```

## 🚀 Deployment Workflow

1. **Generate** the landing page
2. **Review** with AI analysis
3. **Deploy** to GitHub Pages
4. **Configure** GitHub repository settings

```powershell
# Full workflow
.\warp-landing.ps1 generate --source README.md --theme modern-ai
.\warp-landing.ps1 ai review landing-page --suggest-fixes
.\warp-landing.ps1 deploy gh-pages
```

Then in GitHub:
1. Go to Settings → Pages
2. Set source to `gh-pages` branch
3. Wait 1-2 minutes
4. Visit `https://username.github.io/repo-name/`

## 🎨 Customization

All themes support:
- Custom colors via CSS variables
- Google Fonts integration
- Responsive images
- Code syntax highlighting
- Smooth animations

## 📝 License

MIT License - Built with Warp Generate Landing Page

---

**Note:** This is a proof-of-concept implementation of the Warp Generate Landing Page feature specification.
