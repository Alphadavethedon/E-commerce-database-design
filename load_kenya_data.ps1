# Database setup
$password = Read-Host "Enter MySQL password" -AsSecureString
$credentials = New-Object System.Management.Automation.PSCredential ("root", $password)

# Load all SQL files
@('counties.sql', 'carrier-compliance.sql', 'delivery_logics.sql') | ForEach-Object {
    Write-Host "Loading $_..."
    Get-Content $_ | mysql -u root -p$($credentials.GetNetworkCredential().Password) ecommerce
}

Write-Host "✅ Kenya database setup complete!"