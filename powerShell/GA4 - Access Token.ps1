$clientId = "<<<>>>"
$clientSecret = "<<<>>>"
$redirect_uri = "<<<>>>"

$scopes = "https://www.googleapis.com/auth/analytics.readonly"

Start-Process "https://accounts.google.com/o/oauth2/auth?client_id=$clientId&scope=$([string]::Join("%20", $scopes))&access_type=offline&response_type=code&redirect_uri=$redirect_uri&prompt=consent"    
 
$code = Read-Host "Please enter the code"
   
$response = Invoke-WebRequest https://www.googleapis.com/oauth2/v4/token -ContentType application/x-www-form-urlencoded -Method POST -Body "client_id=$clientid&client_secret=$clientSecret&redirect_uri=$redirect_uri&code=$code&grant_type=authorization_code"
  
Write-Output $response.Content

# Store refreshToken
Set-Content $PSScriptRoot"\tokenRefresh.txt" ($response.Content | ConvertFrom-Json).refresh_token

# Store accessToken
Set-Content $PSScriptRoot"\tokenAccess.txt" ($response.Content | ConvertFrom-Json).access_token