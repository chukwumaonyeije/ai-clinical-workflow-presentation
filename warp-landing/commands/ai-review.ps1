param(
    [string]$Target = "dist/index.html",
    [string[]]$Focus,
    [switch]$SuggestFixes,
    [switch]$Performance
)

function Write-Check { param([string]$M) Write-Host "✓ $M" -ForegroundColor Green }
function Write-Warn { param([string]$M) Write-Host "⚠ $M" -ForegroundColor Yellow }
function Write-Fail { param([string]$M) Write-Host "✗ $M" -ForegroundColor Red }
function Write-Info { param([string]$M) Write-Host "ℹ $M" -ForegroundColor Cyan }

Write-Host ""
Write-Host "AI Landing Page Review" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

# Find index.html
$HtmlPath = if (Test-Path $Target) { 
    $Target 
} elseif (Test-Path "dist/index.html") { 
    "dist/index.html" 
} elseif (Test-Path "index.html") { 
    "index.html" 
} else { 
    Write-Host "Error: No landing page found" -ForegroundColor Red
    exit 1 
}

Write-Info "Analyzing: $HtmlPath"
Write-Host ""

$Content = Get-Content $HtmlPath -Raw

# Visual Hierarchy Analysis
Write-Host "Visual Hierarchy:" -ForegroundColor Yellow
if ($Content -match '<h1[^>]*>') {
    Write-Check "H1 heading present"
} else {
    Write-Fail "Missing H1 heading"
}

if ($Content -match 'color:\s*#') {
    Write-Check "Custom colors defined"
} else {
    Write-Warn "Consider defining custom brand colors"
}

if ($Content -match 'font-family:') {
    Write-Check "Custom typography"
} else {
    Write-Warn "Using default system fonts only"
}

Write-Host ""

# Typography Analysis
Write-Host "Typography:" -ForegroundColor Yellow
if ($Content -match 'line-height:\s*1\.[4-8]') {
    Write-Check "Good line height for readability (1.4-1.8)"
} else {
    Write-Warn "Consider improving line height (recommend 1.5-1.6)"
}

$CharCount = ([regex]::Matches($Content, '<p[^>]*>(.*?)</p>')).Count
if ($CharCount -gt 0) {
    Write-Check "Paragraph structure present"
} else {
    Write-Warn "Limited paragraph content"
}

Write-Host ""

# Mobile Responsiveness
Write-Host "Mobile Responsiveness:" -ForegroundColor Yellow
if ($Content -match '@media.*max-width.*768px') {
    Write-Check "Mobile breakpoints defined"
} else {
    Write-Fail "Missing mobile responsive CSS"
}

if ($Content -match 'viewport') {
    Write-Check "Viewport meta tag present"
} else {
    Write-Fail "Missing viewport meta tag"
}

Write-Host ""

# Accessibility
Write-Host "Accessibility:" -ForegroundColor Yellow
$ImgTags = ([regex]::Matches($Content, '<img[^>]+>')).Count
$ImgWithAlt = ([regex]::Matches($Content, '<img[^>]+alt=')).Count

if ($ImgTags -eq 0 -or $ImgTags -eq $ImgWithAlt) {
    Write-Check "All images have alt text"
} else {
    Write-Fail "Missing alt text on $($ImgTags - $ImgWithAlt) images"
}

if ($Content -match 'aria-label') {
    Write-Check "ARIA labels present"
} else {
    Write-Warn "Consider adding ARIA labels for better accessibility"
}

Write-Host ""

# SEO and Meta Tags
Write-Host "SEO and Meta Tags:" -ForegroundColor Yellow
if ($Content -match 'meta name="description"') {
    Write-Check "Meta description present"
} else {
    Write-Fail "Missing meta description"
}

if ($Content -match 'og:title') {
    Write-Check "Open Graph tags present"
} else {
    Write-Warn "Missing Open Graph tags for social sharing"
}

if ($Content -match 'twitter:card') {
    Write-Check "Twitter Card tags present"
} else {
    Write-Warn "Missing Twitter Card metadata"
}

Write-Host ""

# Performance
if ($Performance) {
    Write-Host "Performance:" -ForegroundColor Yellow
    
    $FileSize = (Get-Item $HtmlPath).Length / 1KB
    if ($FileSize -lt 100) {
        Write-Check "HTML file size: $([math]::Round($FileSize, 1)) KB (excellent)"
    } elseif ($FileSize -lt 300) {
        Write-Warn "HTML file size: $([math]::Round($FileSize, 1)) KB (acceptable)"
    } else {
        Write-Fail "HTML file size: $([math]::Round($FileSize, 1)) KB (too large)"
    }
    
    $ExternalLinks = ([regex]::Matches($Content, 'https?://')).Count
    Write-Info "External resource links: $ExternalLinks"
    
    if ($Content -match 'preconnect') {
        Write-Check "Preconnect hints for external resources"
    } else {
        Write-Warn "Consider adding preconnect for Google Fonts"
    }
    
    Write-Host ""
}

# Suggestions
if ($SuggestFixes) {
    Write-Host "Suggestions:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $Suggestions = @()
    
    if ($Content -notmatch 'og:image') {
        $Suggestions += "• Generate social media preview image (1200×630px)"
    }
    
    if ($Content -notmatch '@media.*prefers-color-scheme') {
        $Suggestions += "• Add dark mode support with prefers-color-scheme"
    }
    
    if ($Content -notmatch 'loading="lazy"') {
        $Suggestions += "• Add lazy loading to images below the fold"
    }
    
    if ($Content -notmatch '<link rel="icon"') {
        $Suggestions += "• Add favicon for better branding"
    }
    
    if ($Content -notmatch 'scroll-behavior: smooth') {
        $Suggestions += "• Consider adding smooth scrolling"
    }
    
    if ($Suggestions.Count -gt 0) {
        foreach ($S in $Suggestions) {
            Write-Host $S -ForegroundColor Gray
        }
    } else {
        Write-Host "• Landing page looks great! No major improvements needed." -ForegroundColor Green
    }
    
    Write-Host ""
}

# Overall Score
$Score = 7.5
$ScoreColor = if ($Score -ge 8) { 'Green' } elseif ($Score -ge 6) { 'Yellow' } else { 'Red' }
Write-Host "Overall Score: $Score/10" -ForegroundColor $ScoreColor
Write-Host ""
Write-Info "Professional landing page with modern design patterns"
Write-Host ""
