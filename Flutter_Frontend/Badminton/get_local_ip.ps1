# PowerShell script to get your local IP address for Flutter backend connection
# Run this script to find the correct IP address to use in api_endpoints.dart

Write-Host "`n=== Finding Your Local IP Address ===" -ForegroundColor Cyan
Write-Host "This IP address should be used in Flutter_Frontend/Badminton/lib/core/constants/api_endpoints.dart`n" -ForegroundColor Yellow

# Get all network adapters with IPv4 addresses
$adapters = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.PrefixOrigin -ne "WellKnown"
} | Sort-Object InterfaceIndex

if ($adapters.Count -eq 0) {
    Write-Host "No network adapters found with valid IP addresses." -ForegroundColor Red
    exit 1
}

Write-Host "Available network interfaces:" -ForegroundColor Green
Write-Host ""

$index = 1
$adapterList = @()

foreach ($adapter in $adapters) {
    $interface = Get-NetAdapter -InterfaceIndex $adapter.InterfaceIndex -ErrorAction SilentlyContinue
    $adapterInfo = [PSCustomObject]@{
        Index = $index
        IPAddress = $adapter.IPAddress
        InterfaceName = if ($interface) { $interface.Name } else { "Unknown" }
        Status = if ($interface) { $interface.Status } else { "Unknown" }
    }
    $adapterList += $adapterInfo
    
    Write-Host "[$index] $($adapter.IPAddress)" -ForegroundColor White
    Write-Host "    Interface: $($adapterInfo.InterfaceName)" -ForegroundColor Gray
    Write-Host "    Status: $($adapterInfo.Status)" -ForegroundColor Gray
    Write-Host ""
    
    $index++
}

# Try to find the most likely candidate (usually WiFi or Ethernet)
$wifiAdapter = $adapterList | Where-Object { $_.InterfaceName -like "*Wi-Fi*" -or $_.InterfaceName -like "*Wireless*" -or $_.InterfaceName -like "*WLAN*" } | Select-Object -First 1
$ethernetAdapter = $adapterList | Where-Object { $_.InterfaceName -like "*Ethernet*" -or $_.InterfaceName -like "*LAN*" } | Select-Object -First 1

$recommended = $null
if ($wifiAdapter) {
    $recommended = $wifiAdapter
} elseif ($ethernetAdapter) {
    $recommended = $ethernetAdapter
} else {
    $recommended = $adapterList[0]
}

if ($recommended) {
    Write-Host "`n=== RECOMMENDED IP ADDRESS ===" -ForegroundColor Green
    Write-Host "IP Address: $($recommended.IPAddress)" -ForegroundColor Yellow
    Write-Host "Interface: $($recommended.InterfaceName)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Update this in: Flutter_Frontend\Badminton\lib\core\constants\api_endpoints.dart" -ForegroundColor Cyan
    Write-Host "Change line 13 to: return 'http://$($recommended.IPAddress):8000';" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Make sure your backend server is running on port 8000" -ForegroundColor White
Write-Host "2. Ensure your phone/emulator and computer are on the same WiFi network" -ForegroundColor White
Write-Host "3. Check Windows Firewall allows connections on port 8000" -ForegroundColor White
Write-Host "4. Update the IP address in api_endpoints.dart and rebuild the app" -ForegroundColor White
Write-Host ""
