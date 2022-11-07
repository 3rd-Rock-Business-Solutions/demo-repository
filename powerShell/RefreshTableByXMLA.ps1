$WorkspaceName = "Prod Model" #Here it is the workspace name! Not the id! 
$DatasetName = "Daily Sales" #Also known as database name
$TableName = "Brand Security" #Table name in the specified dataset

# Base variables
$PbiBaseConnection = "powerbi://api.powerbi.com/v1.0/myorg/"

$userName = "Email ID"
$password = ConvertTo-SecureString -String "Password" -AsPlainText -Force
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $userName, $password

# TMSL Script
$TmslScriptOrg = 
@"
    {  
      "refresh": {  
        "type": "full",  
        "objects": [  
          {  
                "database": "<<DatasetName>>",  
                "table": "<<TableName>>"
          }  
        ]  
      }  
    }  
"@

  
$XmlaEndpoint = $PbiBaseConnection + $WorkspaceName
$TmslScript = $TmslScriptOrg.replace('<<DatasetName>>',$DatasetName).replace('<<TableName>>',$TableName) 

# Execute refresh trigger on specified table
Try {
   Invoke-ASCmd -Query $TmslScript -Server: $XmlaEndpoint -Database $DatasetName  -Credential $Credential
   # Write message if succeeded
   Write-Host "Table" $TableName "in dataset" $DatasetName "successfully triggered to refresh" -ForegroundColor Green
}
Catch{
   # Write message if error
   Write-Host "An error occured" -ForegroundColor Red
}
