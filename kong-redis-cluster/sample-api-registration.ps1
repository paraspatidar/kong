# post-up.ps1

$KongAdminUrl = "http://localhost:8001"

Write-Host " Waiting for Kong Admin API to be ready..."
do {
    Start-Sleep -Seconds 2
    try {
        $response = Invoke-WebRequest -Uri $KongAdminUrl -UseBasicParsing -TimeoutSec 3
        $ready = $true
    } catch {
        $ready = $false
    }
} until ($ready)

Write-Host "Kong Admin API is up."

# Create service
Write-Host "Creating service..."
Invoke-RestMethod -Method POST -Uri "$KongAdminUrl/services" -Body @{
    name = "sample-api"
    url  = "http://sample-api:80"
} -ContentType "application/x-www-form-urlencoded"

# Create route
Write-Host "Creating route..."
Invoke-RestMethod -Method POST -Uri "$KongAdminUrl/services/sample-api/routes" -Body @{
    "paths[]" = "/api/sample/v1"
} -ContentType "application/x-www-form-urlencoded"
