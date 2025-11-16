param(
    [string]$Branch = "gh-pages",
    [string]$Domain,
    [string]$OutputDir = "dist"
)

function Write-Success { param([string]$M) Write-Host "✓ $M" -ForegroundColor Green }
function Write-Info { param([string]$M) Write-Host "ℹ $M" -ForegroundColor Cyan }
function Write-Error { param([string]$M) Write-Host "✗ $M" -ForegroundColor Red }
function Write-Warning { param([string]$M) Write-Host "⚠ $M" -ForegroundColor Yellow }

# Check if git is available
$GitAvailable = Get-Command git -ErrorAction SilentlyContinue
if (-not $GitAvailable) {
    Write-Error "Git is not installed or not in PATH"
    exit 1
}

# Check if we're in a git repo
$IsGitRepo = Test-Path ".git"
if (-not $IsGitRepo) {
    Write-Error "Not a git repository. Initialize with 'git init' first."
    exit 1
}

# Check if output directory exists
if (-not (Test-Path $OutputDir)) {
    Write-Error "Output directory not found: $OutputDir"
    Write-Host "Generate a landing page first with: .\warp-landing.ps1 generate --source file.md"
    exit 1
}

Write-Info "Deploying $OutputDir to GitHub Pages ($Branch branch)..."

# Get current branch
$CurrentBranch = git rev-parse --abbrev-ref HEAD 2>$null

# Check for uncommitted changes
$GitStatus = git status --porcelain
if ($GitStatus) {
    Write-Warning "You have uncommitted changes. Continuing anyway..."
}

# Create CNAME file if domain specified
if ($Domain) {
    Write-Info "Setting custom domain: $Domain"
    $Domain | Out-File -FilePath (Join-Path $OutputDir "CNAME") -Encoding ASCII -NoNewline
    Write-Success "CNAME file created"
}

# Create .nojekyll file (important for GitHub Pages)
$NoJekyllPath = Join-Path $OutputDir ".nojekyll"
if (-not (Test-Path $NoJekyllPath)) {
    "" | Out-File -FilePath $NoJekyllPath -Encoding ASCII
    Write-Success "Created .nojekyll file"
}

# Check if gh-pages branch exists
$BranchExists = git show-ref --verify --quiet "refs/heads/$Branch"
$BranchExistsRemote = git ls-remote --heads origin $Branch 2>$null

if ($LASTEXITCODE -eq 0 -or $BranchExistsRemote) {
    Write-Info "Branch '$Branch' exists, updating..."
    
    # Save current work
    git stash push -u -m "warp-landing-deploy-stash" 2>$null
    
    # Checkout gh-pages
    git checkout $Branch 2>$null
    if ($LASTEXITCODE -ne 0) {
        # If branch doesn't exist locally but exists remotely
        git checkout -b $Branch origin/$Branch 2>$null
    }
    
    # Remove old files (except .git)
    Get-ChildItem -Path . -Exclude ".git", $OutputDir | Remove-Item -Recurse -Force
    
    # Copy new files
    Get-ChildItem -Path $OutputDir | Copy-Item -Destination . -Recurse -Force
    
    # Add and commit
    git add -A
    $CommitMessage = "Deploy landing page - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $CommitMessage 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Changes committed"
        
        # Push to remote
        Write-Info "Pushing to origin/$Branch..."
        git push origin $Branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Deployed successfully!"
        } else {
            Write-Error "Failed to push to remote"
        }
    } else {
        Write-Info "No changes to commit"
    }
    
    # Return to original branch
    git checkout $CurrentBranch 2>$null
    
    # Restore stashed work
    $HasStash = git stash list | Select-String "warp-landing-deploy-stash"
    if ($HasStash) {
        git stash pop 2>$null
    }
    
} else {
    Write-Info "Creating new '$Branch' branch..."
    
    # Create orphan branch
    git checkout --orphan $Branch 2>$null
    
    # Remove all files from staging
    git rm -rf . 2>$null
    
    # Copy dist files
    Get-ChildItem -Path $OutputDir | Copy-Item -Destination . -Recurse -Force
    
    # Add and commit
    git add -A
    git commit -m "Initial GitHub Pages deployment" 2>$null
    
    # Push to remote
    Write-Info "Pushing to origin/$Branch..."
    git push -u origin $Branch 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Deployed successfully!"
    } else {
        Write-Error "Failed to push to remote. Make sure you have a remote configured."
        Write-Host "Add remote with: git remote add origin <url>"
    }
    
    # Return to original branch
    git checkout $CurrentBranch 2>$null
}

Write-Host ""
Write-Info "Next steps:"
Write-Host "1. Go to GitHub repository → Settings → Pages"
Write-Host "2. Set source to '$Branch' branch"
Write-Host "3. Wait 1-2 minutes for deployment"
Write-Host "4. Visit: https://YOUR-USERNAME.github.io/YOUR-REPO/"
Write-Host ""

if ($Domain) {
    Write-Host "With custom domain, visit: https://$Domain" -ForegroundColor Cyan
    Write-Host "Configure DNS: Add CNAME record pointing to YOUR-USERNAME.github.io"
}
