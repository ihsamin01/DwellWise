<#
.SYNOPSIS
  Builds the web app for public hosting, without the API key in it.

.DESCRIPTION
  assets/secrets/gemini.json is bundled into the web output like any other
  asset, so a plain `flutter build web` produces a folder with the key sitting
  in it in plain text. Publishing that anywhere public hands the key to
  whoever looks. This swaps in a placeholder for the build and puts the real
  key back afterwards, even if the build fails.

  The assistant is therefore quiet in a build made by this script. That is the
  intended trade: the Android build keeps the key locally and still answers.

.PARAMETER BaseHref
  Where the app will be served from. '/' for Vercel or any site root,
  '/DwellWise/app/' for the GitHub Pages folder.

.EXAMPLE
  .\tool\build_web.ps1 -BaseHref "/"
  npx vercel deploy --prod build/web
#>
param(
    [string]$BaseHref = "/"
)

$ErrorActionPreference = "Stop"

$secret = "assets/secrets/gemini.json"

# Kept outside assets/, because Flutter bundles that whole folder — a backup
# sitting next to the original ends up in the build with the key intact.
$backup = Join-Path $env:TEMP "dwellwise_gemini_key.bak"

if (-not (Test-Path $secret)) {
    Write-Error "$secret not found. Nothing to protect — check you are in the project root."
}

Copy-Item $secret $backup -Force
try {
    '{ "GEMINI_API_KEY": "your-key-here" }' | Set-Content $secret -NoNewline
    Write-Host "Key replaced with a placeholder for the build." -ForegroundColor Yellow

    flutter build web --release --base-href $BaseHref
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed" }
}
finally {
    # Runs even if the build throws, so the working copy never keeps the
    # placeholder.
    Copy-Item $backup $secret -Force
    Remove-Item $backup -Force
    Write-Host "Real key restored." -ForegroundColor Green
}

# Belt and braces: fail loudly rather than let a keyed build reach a host.
$key = (Get-Content $secret -Raw | ConvertFrom-Json).GEMINI_API_KEY
if ($key -and (Select-String -Path "build/web/**/*" -Pattern ([regex]::Escape($key)) -List -ErrorAction SilentlyContinue)) {
    Write-Error "The API key is present in build/web. Do not publish it."
}

Write-Host ""
Write-Host "Built into build/web with base href $BaseHref" -ForegroundColor Cyan
Write-Host "Deploy with:  npx vercel deploy --prod build/web"
