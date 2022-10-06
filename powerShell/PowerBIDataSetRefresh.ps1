#AUTHOR: 3rd Rock Business Solutions 

$dataset = "bXXXXXX-XXXX-XXXX-XX-XXXXXXbb4"
$groupID = "6cXXXXX-XXXX-XXXX-XXXX-XXXXXX0374" #WorkSpace ID 

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$clientid = "7dXXX-XXXX-XXXX-XXXXX-XXXXXXa4c9" 
$clientsecret = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXo"
$scope = "https://analysis.windows.net/powerbi/api/.default"
$tenantid = "06XXXXX-XXXX-XXXX-XXXXX-XXXXXXXXdd75"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
$body = "client_id=$clientid&client_secret=$clientsecret&scope=$scope&grant_type=client_credentials"


try 
{

    $response = Invoke-RestMethod "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token" -Method 'POST' -Headers $headers -Body $body
    $token = $response.access_token
    $token = "Bearer $token"

    # Building Rest API header with authorization token
    $authHeader = @{
       'Content-Type'='application/json'
       'Authorization'= $token
    }

    $groupsPath = ""
    if ($groupID -eq "me") {
        $groupsPath = "myorg"
    } else {
        $groupsPath = "myorg/groups/$groupID"
    }
    
    # Trigger refresh of the dataset
    $uri = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$dataset/refreshes"
    Invoke-RestMethod -Uri $uri –Headers $authHeader –Method POST

    $DateTime = Get-Date -Format G
    Write-Host "Job Refresh Started at $DateTime"
    Start-Sleep -s 30

    # Check the status 
    $count = 1
    $success = 0
    $statusURL = "https://api.powerbi.com/v1.0/$groupsPath/datasets/$dataset/refreshes"
    while($count -le 50)
    {
        #get job status
        $response = Invoke-RestMethod $statusURL -Method 'GET' -Headers $authHeader
        $status = $response.value[0].status
        $DateTime = Get-Date -Format G

        Write-Host "$count. Dataset Refresh Status: $status at $DateTime"
        $count = ++$count

        if($status -eq "Completed")
        {
            $success = 1
            break
        }
        elseif($status -eq "Failed")
        {
            throw $_.Exception
            break
        }

        Start-Sleep -s 60
    }

    if($success -eq 0)
    {
        #Refresh token valid for an hour
        Write-Host "Program aborded. The job has been running for more than an hour. Please monitor the job directly in the powerbi portal"
    }


}
 catch {
    Write-Host "Status Code:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "Status Description:" $_.Exception.Response.StatusDescription
    Write-Host "Error" $_
    Write-Host $_.ScriptStackTrace
    Write-Host "Error occurred due to previous job has not been finished yet."
    throw $_.Exception
}