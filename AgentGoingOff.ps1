[CmdletBinding()]
param (
    [Parameter()]
    [Int32] $agentpool
)
$headers = @{}
$headers.Add("Accept", "*/*")
$headers.Add("Authorization", "Basic ") #TOKEN

$reqUrlAP = 'https://dev.azure.com/{organization}/_apis/distributedtask/pools?api-version=7.0' #Enter Your Organization Name


$responseAP = Invoke-RestMethod -Uri $reqUrlAP -Method Get -Headers $headers  
$filterAP = $responseAP.value | select name, id
Write-Host "Organization Pools"
Write-Host ""
$filterAP | Out-Host


foreach ($agentpool in $filterAP.id)
{  
    Write-Host "Agents in Agent Pool $agentpool"
    Write-Host ""
    $reqUrlAgents = "https://dev.azure.com/{organization}/_apis/distributedtask/pools/$agentpool/agents?api-version=7.0"  #Enter Your Organization Name
    $responseA = Invoke-RestMethod -Uri $reqUrlAgents -Method Get -Headers $headers  
    $filterA = $responseA.value | select name, id, status 
    
    $filterA | Out-Host
    
     foreach ($filter in $filterA)
     {
      if ($filter.status -eq "offline")
      {    
        $agentname = $filter.name 
          try {
            mail -s "Agent $agentname is offline!" "recieveremail@gmail.com" 
          }
          catch{
              throw
          }
      }
     }
}

