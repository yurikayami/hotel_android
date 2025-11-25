# PowerShell script to update ipComputer in api_config.dart and run Flutter
# Usage: Run this script in the project root directory


# Get the first non-loopback IPv4 address automatically
$ipList = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' }
if ($ipList.Count -eq 0) {
    Write-Host "Error: No IPv4 address found."
    exit 1
}
$newIP = $ipList[0].IPAddress
Write-Host "Detected local IPv4: $newIP"

# Path to the api_config.dart file (relative to project root)
$configFile = "lib\services\api_config.dart"

# Check if file exists
if (-not (Test-Path $configFile)) {
    Write-Host "Error: $configFile not found. Make sure you're running this script from the project root."
    exit 1
}

# Read the file content
$content = Get-Content $configFile -Raw

# Replace the ipComputer line using regex
$pattern = "static const String ipComputer = '[^']*';"
$replacement = "static const String ipComputer = '$newIP';"
$newContent = $content -replace $pattern, $replacement

# Write back to file
$newContent | Set-Content $configFile -Encoding UTF8

Write-Host "Updated ipComputer to: $newIP"

# Run flutter run
Write-Host "Running flutter run..."
flutter run