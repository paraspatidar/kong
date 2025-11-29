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


# delete plugin, intensionlly added opentelemetry in route so it doesnt accidently run
#$Plugins = Invoke-RestMethod -Uri "$KongAdminUrl/plugins/opentelemetry" -Method Get
#$id=($Plugins.data).id
#Invoke-RestMethod  -Method Delete -Uri "$KongAdminUrl/plugins/$id"

# Define the plugin payload
$pluginPayload = @{
    name = "redis-test-processor"
    protocols = @("grpc", "grpcs", "http", "https")
    config = @{
        connect_timeout = 1000
        # Use the correct key for a list of nodes (serv_list or nodes)
        # Assuming you've fixed the hostname resolution issue via KONG_LUA_RESOLVER
        redis_host = "redis-master-1"
        redis_port = 6379
        dict_name = "redis_cluster_slot_locks"
        redis_password = $null # Set to actual password if needed
        refresh_lock_key = "refresh_lock"
        max_connection_attempts = 1
        name = "testCluster"
        keepalive_cons = 1000
        max_redirection = 5
        keepalive_timeout = 60000
        lock_timeout = 5
    }
}

# Convert payload to JSON
$jsonPayload = $pluginPayload | ConvertTo-Json -Depth 5

# Enable the plugin globally (service = null, route = null)
Invoke-RestMethod -Method Post -Uri "$KongAdminUrl/plugins" -Body $jsonPayload -ContentType "application/json"