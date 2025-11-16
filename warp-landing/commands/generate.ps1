param(
    [string]$Source,
    [string]$Theme = "modern-ai",
    [switch]$Slides,
    [string]$Deploy,
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

# Load System.Web for HTML encoding
Add-Type -AssemblyName System.Web

function Write-Success { param([string]$M) Write-Host "[OK] $M" -ForegroundColor Green }
function Write-Info { param([string]$M) Write-Host "[INFO] $M" -ForegroundColor Cyan }
function Write-ErrorMsg { param([string]$M) Write-Host "[ERROR] $M" -ForegroundColor Red }
function Write-Warning { param([string]$M) Write-Host "[WARN] $M" -ForegroundColor Yellow }

Write-Info "Generating landing page from $Source..."

# Check if source exists
if (-not (Test-Path $Source)) {
    Write-ErrorMsg "Source file not found: $Source"
    exit 1
}

# Check if theme exists
$ThemePath = Join-Path $ScriptRoot "themes\$Theme.html"
if (-not (Test-Path $ThemePath)) {
    Write-ErrorMsg "Theme not found: $Theme"
    Write-Host "Available themes: modern-ai, developer-docs, medical-tech, startup-landing, minimalist"
    exit 1
}

# Create output directory
if ([System.IO.Path]::IsPathRooted($OutputDir)) {
    $OutputPath = $OutputDir
} else {
    $OutputPath = Join-Path (Get-Location) $OutputDir
}
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Read source file with UTF-8 encoding
$Content = Get-Content $Source -Raw -Encoding UTF8

# Parse Markdown metadata and content
$Title = "Generated Landing Page"
$Description = ""
$Author = ""
$SiteName = "Landing Page"
$HeroTitle = ""
$HeroSubtitle = ""

# Extract first H1 as title
if ($Content -match '(?m)^#\s+(.+)$') {
    $Title = $Matches[1] -replace '\s+', ' '
    $Title = $Title.Trim()
    $HeroTitle = $Title
}

# Extract subtitle - look for blockquote with description
if ($Content -match '(?m)^>\s*\*\*(.+?)\*\*') {
    $HeroSubtitle = $Matches[1].Trim()
} elseif ($Content -match '(?m)^>\s*(.+)$') {
    $HeroSubtitle = $Matches[1].Trim()
} else {
    $HeroSubtitle = "A Practical AI Tech Stack for Physicians Who Code"
}
$Description = $HeroSubtitle

# Extract author from "By Dr. ..." pattern
if ($Content -match 'By\s+(Dr\.\s+[^\n,]+)') {
    $Author = $Matches[1]
}

$SiteName = $Title -replace ':.+$', '' -replace 'The Future of ', ''

Write-Info "Title: $Title"
Write-Info "Theme: $Theme"

# Convert Markdown to HTML sections
$HtmlContent = ""
$InCodeBlock = $false
$CurrentSection = ""

$Lines = $Content -split "`n"
$SectionStarted = $false

foreach ($Line in $Lines) {
    $Line = $Line.TrimEnd()
    
    # Skip everything until first H2
    if (-not $SectionStarted -and $Line -match '^##\s+') {
        $SectionStarted = $true
    }
    
    if (-not $SectionStarted) {
        continue
    }
    
    # Handle code blocks
    if ($Line -match '^```') {
        if ($InCodeBlock) {
            $CurrentSection += "</code></pre>`n"
            $InCodeBlock = $false
        } else {
            $Lang = if ($Line -match '^```(\w+)') { $Matches[1] } else { "" }
            $CurrentSection += "<pre><code>`n"
            $InCodeBlock = $true
        }
        continue
    }
    
    if ($InCodeBlock) {
        $CurrentSection += [System.Web.HttpUtility]::HtmlEncode($Line) + "`n"
        continue
    }
    
    # H2 - Start new section
    if ($Line -match '^##\s+(.+)$') {
        if ($CurrentSection) {
            $HtmlContent += "<section><div class='container'>$CurrentSection</div></section>`n"
        }
        $Heading = $Matches[1].Trim()
        $Id = $Heading -replace '[^\w\s-]', '' -replace '\s+', '-' -replace '--+', '-'
        $Id = $Id.ToLower()
        $CurrentSection = "<h2 id='$Id'>$Heading</h2>`n"
        continue
    }
    
    # H3
    if ($Line -match '^###\s+(.+)$') {
        $Heading = $Matches[1].Trim()
        $CurrentSection += "<h3>$Heading</h3>`n"
        continue
    }
    
    # H4
    if ($Line -match '^####\s+(.+)$') {
        $Heading = $Matches[1].Trim()
        $CurrentSection += "<h4>$Heading</h4>`n"
        continue
    }
    
    # Bullet list
    if ($Line -match '^[-*]\s+(.+)$') {
        $Item = $Matches[1]
        $Item = $Item -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
        $Item = $Item -replace '\[(.+?)\]\((.+?)\)', '<a href="$2">$1</a>'
        if ($CurrentSection -notmatch '<ul>$') {
            $CurrentSection += "<ul>`n"
        }
        $CurrentSection += "<li>$Item</li>`n"
        continue
    } elseif ($CurrentSection -match '<ul>$' -and $Line -notmatch '^[-*]') {
        $CurrentSection += "</ul>`n"
    }
    
    # Numbered list
    if ($Line -match '^\d+\.\s+(.+)$') {
        $Item = $Matches[1]
        $Item = $Item -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
        $Item = $Item -replace '\[(.+?)\]\((.+?)\)', '<a href="$2">$1</a>'
        if ($CurrentSection -notmatch '<ol>$') {
            $CurrentSection += "<ol>`n"
        }
        $CurrentSection += "<li>$Item</li>`n"
        continue
    } elseif ($CurrentSection -match '<ol>$' -and $Line -notmatch '^\d+\.') {
        $CurrentSection += "</ol>`n"
    }
    
    # Blockquote
    if ($Line -match '^>\s+(.+)$') {
        $Quote = $Matches[1]
        $CurrentSection += "<blockquote>$Quote</blockquote>`n"
        continue
    }
    
    # Horizontal rule
    if ($Line -match '^---+$') {
        continue  # Skip HR in sections
    }
    
    # Paragraph
    if ($Line -match '\S') {
        $Para = $Line
        $Para = $Para -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
        $Para = $Para -replace '\*(.+?)\*', '<em>$1</em>'
        $Para = $Para -replace '\[(.+?)\]\((.+?)\)', '<a href="$2" target="_blank">$1</a>'
        $Para = $Para -replace '`(.+?)`', '<code>$1</code>'
        
        if ($Para -notmatch '^<') {
            $CurrentSection += "<p>$Para</p>`n"
        }
    }
}

# Close last section
if ($CurrentSection) {
    $HtmlContent += "<section><div class='container'>$CurrentSection</div></section>`n"
}

# Generate navigation from H2 headings
$NavLinks = ""
$SectionHeadings = [regex]::Matches($Content, '(?m)^##\s+(.+)$')
foreach ($Match in $SectionHeadings | Select-Object -First 5) {
    $NavText = $Match.Groups[1].Value.Trim()
    $NavId = $NavText -replace '[^\w\s-]', '' -replace '\s+', '-' -replace '--+', '-'
    $NavId = $NavId.ToLower()
    $NavLinks += "<li><a href='#$NavId'>$NavText</a></li>`n"
}

# Generate CTA buttons
$CtaButtons = ""
if ($Content -match '\[Live Demo\]\((.+?)\)') {
    $Url = $Matches[1]
    $CtaButtons += "<a href='$Url' class='cta'>View Live Demo</a>`n"
}
if ($Content -match 'github\.com/([^\)]+)') {
    $Repo = $Matches[1] -replace '\.git$', ''
    $CtaButtons += "<a href='https://github.com/$Repo' class='cta cta-secondary'>View on GitHub</a>`n"
}
if (-not $CtaButtons) {
    $CtaButtons = "<a href='#' class='cta'>Get Started</a>`n"
}

# Load theme template with UTF-8 encoding
$Template = Get-Content $ThemePath -Raw -Encoding UTF8

# Replace placeholders
$Html = $Template
$Html = $Html -replace '\{\{TITLE\}\}', [System.Web.HttpUtility]::HtmlEncode($Title)
$Html = $Html -replace '\{\{DESCRIPTION\}\}', [System.Web.HttpUtility]::HtmlEncode($Description)
$Html = $Html -replace '\{\{AUTHOR\}\}', [System.Web.HttpUtility]::HtmlEncode($Author)
$Html = $Html -replace '\{\{SITE_NAME\}\}', [System.Web.HttpUtility]::HtmlEncode($SiteName)
$Html = $Html -replace '\{\{HERO_TITLE\}\}', [System.Web.HttpUtility]::HtmlEncode($HeroTitle)
$Html = $Html -replace '\{\{HERO_SUBTITLE\}\}', [System.Web.HttpUtility]::HtmlEncode($HeroSubtitle)
$Html = $Html -replace '\{\{NAV_LINKS\}\}', $NavLinks
$Html = $Html -replace '\{\{CTA_BUTTONS\}\}', $CtaButtons
$Html = $Html -replace '\{\{CONTENT\}\}', $HtmlContent
$Html = $Html -replace '\{\{FOOTER_TEXT\}\}', "© $(Get-Date -Format yyyy) $SiteName. Built with Warp Generate Landing Page."
$Html = $Html -replace '\{\{OG_IMAGE\}\}', 'https://via.placeholder.com/1200x630/6366F1/ffffff?text=Landing+Page'

# Write output
$OutputFile = Join-Path $OutputPath "index.html"
Add-Type -AssemblyName System.Web
# Use UTF8 without BOM for proper emoji support
$Utf8NoBom = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText($OutputFile, $Html, $Utf8NoBom)

Write-Success "Landing page generated: $OutputFile"

# Generate slides if requested
if ($Slides) {
    Write-Info "Generating Reveal.js slide deck..."
    # Copy existing index.html as slides if it exists
    if (Test-Path "index.html") {
        Copy-Item "index.html" (Join-Path $OutputPath "slides.html")
        Write-Success "Slides generated: $(Join-Path $OutputPath 'slides.html')"
    } else {
        Write-Warning "No index.html found for slides generation"
    }
}

# Deploy if requested
if ($Deploy) {
    Write-Info "Deploying to GitHub Pages ($Deploy branch)..."
    & (Join-Path $ScriptRoot "commands\deploy.ps1") -Branch $Deploy -OutputDir $OutputDir
}

Write-Host ""
Write-Success "Done! Open $OutputFile in your browser to view."
