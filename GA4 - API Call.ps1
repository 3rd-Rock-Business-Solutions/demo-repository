[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)] 
    [string]$extractDays
)


function RefreshAccessToken([string]$clientId,[string]$secret, [string]$refreshToken){
   $data = "client_id=$clientId&client_secret=$secret&refresh_token=$refreshToken&grant_type=refresh_token"
   try {

       $response = Invoke-RestMethod -Uri "https://oauth2.googleapis.com/token" -Method POST -Body $data 
       return $response.access_token;

   } catch {
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}

$clientId = "<<<>>>"
$clientSecret = "<<<>>>"
$Property = "<<<>>>"

$refreshToken = Get-Content $PSScriptRoot"\tokenRefresh.txt" ; 


# This will refresh your access token (remember, it expires), using your refresh token
$accessToken = RefreshAccessToken $clientId $clientSecret $refreshToken

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $accessToken")
$headers.Add("Content-Type", "application/json")

$body = '{
  "dimensions": [
     {"name":"date"}
    ,{"name":"eventName"}
    ,{"name":"operatingSystem"}
  ],
  "metrics": [
     {"name": "eventCount"}
    ,{"name": "userEngagementDuration"}
    ,{"name": "conversions"}
  ],
  "dateRanges": [
    {
        "startDate": "'+ $extractDays + 'daysAgo",
        "endDate": "yesterday",
        "name": "Last10days"
    }
  ]
  
}'

$url = "https://analyticsdata.googleapis.com/v1beta/properties/" + $Property +":runReport"


Clear-Variable -Name response

$response = Invoke-RestMethod $url -Method POST -Headers $headers -Body $body

$totalRows = $response.rowCount;
$dimCount = 3;

"Property,date,eventName,operatingSystem,eventCount,userEngagementDuration,conversions"

for ($row = 0; $row -lt $totalRows; $row = $row + 1)
{
    $dimVal = "";
    $metVal = "";

    for($i = 0; $i -lt $dimCount; $i= $i + 1)
    {
        if($i -ge 1)
        {
            $dimVal = $dimVal + ",";
        }
        $dimVal = $dimVal + $response.rows[$row].dimensionValues[$i].value
    }
     

    for($i = 0; $i -lt $dimCount; $i= $i + 1)
    {
        if($i -ge 1)
        {
            $metVal = $metVal + ",";
        }
        $metVal = $metVal + $response.rows[$row].metricValues[$i].value
    }
    
    "$Property,$dimVal,$metVal"
}

#$json = $response | ConvertTo-Json
#$json
