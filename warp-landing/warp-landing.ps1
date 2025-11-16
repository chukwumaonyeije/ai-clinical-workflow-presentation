# Warp Generate Landing Page CLI
# Usage: .\warp-landing.ps1 <command> [options]

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Command,
    
    [Parameter(Mandatory=$false)]
    [string]$Source,
    
    [Parameter(Mandatory=$false)]
    [string]$Theme = "modern-ai",
    
    [Parameter(Mandatory=$false)]
    [switch]$Slides,
    
    [Parameter(Mandatory=$false)]
    [string]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "dist",
    
    [Parameter(Mandatory=$false)]
    [string]$Domain,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Focus,
    
    [Parameter(Mandatory=$false)]
    [switch]$SuggestFixes,
    
    [Parameter(Mandatory=$false)]
    [switch]$Performance,
    
    [Parameter(Mandatory=$false)]
    [switch]$WebP,
    
    [Parameter(Mandatory=$false)]
    [switch]$CompressImages,
    
    [Parameter(Mandatory=$false)]
    [switch]$MinifyCss,
    
    [Parameter(Mandatory=$false)]
    [switch]$MinifyJs,
    
    [Parameter(Mandatory=$false)]
    [switch]$RemoveUnusedCss,
    
    [Parameter(Mandatory=$false)]
    [switch]$SocialCards,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateHtml
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Color output helpers
function Write-Success { param([string]$Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }
function Write-Warning { param([string]$Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "✗ $Message" -ForegroundColor Red }

# Main command dispatcher
switch ($Command) {
    "generate" {
        if (-not $Source) {
            Write-Error "Error: --source parameter required"
            Write-Host "Usage: .\warp-landing.ps1 generate --source <file> [--theme <name>] [--slides] [--deploy <branch>]"
            exit 1
        }
        & "$ScriptDir\commands\generate.ps1" -Source $Source -Theme $Theme -Slides:$Slides -Deploy $Deploy -OutputDir $OutputDir
    }
    
    "theme" {
        $SubCommand = $Source  # Reusing Source as subcommand
        & "$ScriptDir\commands\theme.ps1" -SubCommand $SubCommand -Theme $Theme
    }
    
    "deploy" {
        $Branch = if ($Source) { $Source } else { "gh-pages" }
        & "$ScriptDir\commands\deploy.ps1" -Branch $Branch -Domain $Domain -OutputDir $OutputDir
    }
    
    "optimize" {
        if (-not $Source) {
            Write-Error "Error: Directory path required"
            Write-Host "Usage: .\warp-landing.ps1 optimize <directory> [options]"
            exit 1
        }
        & "$ScriptDir\commands\optimize.ps1" -TargetDir $Source `
            -WebP:$WebP -CompressImages:$CompressImages -MinifyCss:$MinifyCss `
            -MinifyJs:$MinifyJs -RemoveUnusedCss:$RemoveUnusedCss `
            -SocialCards:$SocialCards -ValidateHtml:$ValidateHtml
    }
    
    "ai" {
        $SubCommand = $Source  # Reusing Source as subcommand (e.g., "review")
        $Target = $Theme      # Reusing Theme as target (e.g., "landing-page")
        & "$ScriptDir\commands\ai-review.ps1" -Target $Target -Focus $Focus -SuggestFixes:$SuggestFixes -Performance:$Performance
    }
    
    default {
        Write-Host "Warp Generate Landing Page v1.0.0" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "Usage:" -ForegroundColor Yellow
        Write-Host "  .\warp-landing.ps1 generate --source <file> [options]"
        Write-Host "  .\warp-landing.ps1 theme <list|preview|info|install> [--theme <name>]"
        Write-Host "  .\warp-landing.ps1 deploy [branch] [--domain <domain>]"
        Write-Host "  .\warp-landing.ps1 optimize <directory> [options]"
        Write-Host "  .\warp-landing.ps1 ai review landing-page [options]"
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\warp-landing.ps1 generate --source README.md --theme modern-ai --deploy gh-pages"
        Write-Host "  .\warp-landing.ps1 theme list"
        Write-Host "  .\warp-landing.ps1 optimize dist/ --webp --minify-css --social-cards"
        Write-Host "  .\warp-landing.ps1 ai review landing-page --suggest-fixes"
        exit 0
    }
}
