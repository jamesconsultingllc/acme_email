# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH. Please install Docker Desktop."
    exit 1
}

# Create directories if they don't exist
$directories = @("letsencrypt", "letsencrypt-lib", "letsencrypt-log")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created directory: $dir"
    }
}

# Check if Docker image exists
$imageExists = docker images acme-email-client -q
if (-not $imageExists) {
    Write-Host "Building Docker image..."
    docker build -t acme-email-client .
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build Docker image."
        exit 1
    }
}

Write-Host "Running ACME Email S/MIME Client..."
docker run --rm `
    -v "${PWD}/letsencrypt:/etc/letsencrypt" `
    -v "${PWD}/letsencrypt-lib:/var/lib/letsencrypt" `
    -v "${PWD}/letsencrypt-log:/var/log/letsencrypt" `
    acme-email-client $args

Write-Host "Done." 