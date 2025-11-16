param(
    [string]$SubCommand = "list",
    [string]$Theme
)

$ScriptRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$ThemesDir = Join-Path $ScriptRoot "themes"

function Write-Success { param([string]$M) Write-Host "✓ $M" -ForegroundColor Green }
function Write-Info { param([string]$M) Write-Host "ℹ $M" -ForegroundColor Cyan }

switch ($SubCommand) {
    "list" {
        Write-Host "Available Landing Page Themes:" -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "modern-ai" -ForegroundColor Cyan -NoNewline
        Write-Host " - Neon gradients, AI icons, glassmorphism (default)"
        
        Write-Host "developer-docs" -ForegroundColor Cyan -NoNewline
        Write-Host " - Minimal GitHub-style documentation"
        
        Write-Host "medical-tech" -ForegroundColor Cyan -NoNewline
        Write-Host " - Clinical whites/blues, professional typography"
        
        Write-Host "startup-landing" -ForegroundColor Cyan -NoNewline
        Write-Host " - Bold hero, CTA buttons, feature cards"
        
        Write-Host "minimalist" -ForegroundColor Cyan -NoNewline
        Write-Host " - Monochrome, elegant, lots of whitespace"
        
        Write-Host ""
        Write-Host "Use: .\warp-landing.ps1 generate --source file.md --theme <name>" -ForegroundColor Gray
    }
    
    "preview" {
        if (-not $Theme) {
            Write-Host "Error: --theme parameter required" -ForegroundColor Red
            Write-Host "Usage: .\warp-landing.ps1 theme preview --theme <name>"
            exit 1
        }
        
        Write-Info "Theme: $Theme"
        Write-Host ""
        
        $ThemeInfo = @{
            "modern-ai" = @"
Theme: modern-ai
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Colors:      Purple (#6366F1), Cyan (#06B6D4), Dark background
Typography:  Inter (body) + Space Grotesk (headings)
Features:    Animated gradient background, glassmorphism cards
             Dark/light mode toggle, smooth animations
Best for:    AI/tech products, developer tools, modern SaaS
"@
            "developer-docs" = @"
Theme: developer-docs
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Colors:      GitHub blue (#0969DA), neutral grays
Typography:  System fonts (SF Pro, Segoe UI)
Features:    Sidebar navigation, syntax highlighting, breadcrumbs
             Clean minimal design
Best for:    Documentation sites, open source projects
"@
            "medical-tech" = @"
Theme: medical-tech
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Colors:      Clinical blue (#0066CC), white backgrounds
Typography:  Source Sans Pro + Merriweather serif
Features:    Trust-building design, credential badges
             Professional color palette
Best for:    Healthcare products, medical services, clinical tools
"@
            "startup-landing" = @"
Theme: startup-landing
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Colors:      Vibrant red (#FF6B6B), teal (#4ECDC4)
Typography:  Poppins (headings) + Open Sans (body)
Features:    Full-screen hero, pricing tables, social proof
             Large animated CTAs
Best for:    Product launches, startups, landing pages
"@
            "minimalist" = @"
Theme: minimalist
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Colors:      Monochrome (black, white, gray)
Typography:  Crimson Text serif or IBM Plex Sans
Features:    Single-column layout, generous whitespace
             Elegant typography, fade-in animations
Best for:    Portfolios, blogs, minimalist brands
"@
        }
        
        if ($ThemeInfo.ContainsKey($Theme)) {
            Write-Host $ThemeInfo[$Theme]
        } else {
            Write-Host "Theme not found: $Theme" -ForegroundColor Red
            Write-Host "Use 'theme list' to see available themes"
        }
    }
    
    "info" {
        & $PSCommandPath -SubCommand "preview" -Theme $Theme
    }
    
    default {
        Write-Host "Theme Management Commands:" -ForegroundColor Yellow
        Write-Host "  list     - List all available themes"
        Write-Host "  preview  - Preview theme details"
        Write-Host "  info     - Get theme information"
    }
}
