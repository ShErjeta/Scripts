[CmdletBinding()]
param (
    [Parameter()]
    [String] $organization,
    [Parameter()]
    [String] $projectName,
    [Parameter()]
    [String] $userToken,
    [Parameter()]
    [Int32] $definitionid
)

Write-Host "Linking Variable Groups To Selected Release Stages"
Write-Host ""
Write-Host "This scripts enables you to automatically link the selected variable groups to the specified release stages"
Write-Host "In order to run this script you must provide an access token, ogranization name, project name and the definition id of the release definition."
Write-Host "Please put your information bellow!"
Write-Host "------------------------------------------------------------------------------------------------------------------------------------------------"
Write-Host ""

$headers = @{}
$userToken = Read-Host "Enter Your Token"
$organization = Read-host "Enter Your Organization Name" 
$projectName = Read-Host "Enter Your Project Name" 

$encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($userToken+":")
$encodedToken = [System.Convert]::ToBase64String($encodedBytes)
$headers.Add("Accept", "*/*")
$headers.Add("Authorization", "Basic $encodedToken")

$reqUrlVg = "https://dev.azure.com/$organization/$projectName/_apis/distributedtask/variablegroups?api-version=6.0-preview.2"


$responseVar = Invoke-RestMethod -Uri $reqUrlVg -Method Get -Headers $headers
$filter= $responseVar.value | select name, id
$filter | Out-Host


$selectID = @()

do {
    $input = (Read-Host -Prompt "Select Variable Group to Link or press dot(.) to finish adding ")
    foreach($i in $filter.id){
        if($i -eq $input){
            $selectID+= $input
        }
       else{
        
       }
}
}
until ($input -eq '.')

$definitionid = Read-Host "Enter Release Definition ID" 
$reqUrlRel = "https://vsrm.dev.azure.com/$organization/$projectName/_apis/release/definitions/"+$definitionid+"?api-version=6.0"

$responseRelease = Invoke-RestMethod -Uri $reqUrlRel -Method Get -Headers $headers
$filterR = $responseRelease.environments | select name, id
$filterR | Out-Host

$jsonvar = $responseRelease

[int32[]]$ia = $selectID

$inputRelease = Read-Host -Prompt "Enter the Release ID to link Variable Groups"

$jsonvar.environments | ? {$_.id -eq $inputRelease} |  % {$_.variableGroups = $ia}
$body=$jsonvar
$body = $body | ConvertTo-Json -Depth 100
$responseRelease = Invoke-RestMethod -Uri $reqUrlRel -Method Put -Headers $headers -ContentType 'application/json' -Body $body