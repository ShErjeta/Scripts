$jsonSku = ".\files\skus.json"
$jsonVm = ".\files\vmLimit.json"

$skus=$(az rest -m get --header "Accept=application/json" -u 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Compute/skus?api-version=2021-07-01&$filter=location eq %27westus%27')
Set-Content -Path $jsonSku -Value $skus
jq --raw-output '.value[] | [.name, .family, (.capabilities[2] | .value) ] | join(\", \")' $jsonSku > ./files/queriedSkus.csv 
$arr = Import-Csv -Path './files/queriedSkus.csv' -Header 'Name', 'Family', 'Cores'


$vmLimit=$(az rest -m get --header "Accept=application/json" -u 'https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.Capacity/resourceProviders/Microsoft.Compute/locations/westus/serviceLimits?api-version=2020-10-25')
Set-Content -Path $jsonVm -Value $vmLimit
jq --raw-output '.value[] | [.properties.limit, .properties.name.value] | join(\", \")' $jsonVm > ./files/vmLimit.csv
$finalLimit = Import-Csv -Path './files/vmLimit.csv' -Header 'Limits', 'Family'


$prod=(Get-Content weeklyQuotas.txt | ? {$_ -match 'vm'} | ForEach-Object {($_ -split "=")[1]}  ) | % { $_ -Replace '"',""} | Out-File ./files/preprod.csv 
$prod = Import-Csv -Path './files/preprod.csv' -Header 'Name'

$final=$(foreach($sku in $arr){
    foreach($p in $prod) {
        if($p.Name -eq $sku.Name){
            $sku.Name + "," + $sku.Family + "," + $sku.Cores
            
        }
    }
}
)
$final > ./files/queriedSkus.csv

$checkLimit = Import-Csv -Path './files/queriedSkus.csv' -Header 'Name', 'Family', 'Cores'

$sizeLimits = $(foreach($f in $finalLimit){
    foreach($c in $checkLimit) {
        if($f.Family -eq $c.Family) {
            $c.Name + "," + $c.Cores + "," + $f.Limits
        }
    }
})

$sizeLimits > ./files/finalLimit.csv

$temp = (Import-Csv -Path './files/finalLimit.csv' -Header 'VMSize', 'Cores', 'Limit'`
 |  Group-Object VMSize, Cores, Limit | `
    Select-Object @{Name='VMSize' ; Expression={$_.Values[0]}},@{Name='Core' ; `
    Expression={$_.Values[1]}}, @{Name='Limit' ; Expression={$_.Values[2]}}, count)

$passedLimit = $(foreach($p in $temp){
    $mul = [int]$p.Core*[int]$p.Count     
    $limiti = [int]$p.Limit
    if($mul -gt $limiti){
        $p.VMSize + ", " + $mul + ", " + $p.Limit + ", PASSED LIMIT"
    } else {
        $p.VMSize + ", " + $mul + ", " + $p.Limit + ", OK"
    }
})

"Size, Cores, Limit" > report.csv
$passedLimit >> report.csv