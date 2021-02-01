# Input bindings are passed in via param block. 

param($Timer) 

  

# Get the current universal time in the default string format. 

$currentUTCtime = (Get-Date).ToUniversalTime() 

  

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled. 

if ($Timer.IsPastDue) { 

 Write-Host "PowerShell timer is running late!" 

} 

  

# Write an information log with the current time. 

Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime" 

  

# Variable Definitions 

$min_free_gibs = 1024 

$increase_amount_gibs = 1024 

$subscription_id = "subscription id" 

$resource_group = "resource group" 

$storage_account_name = "storage account name" 

$file_share_name = "file share name" 

  

#Connect to Azure and Import Az Module 

Connect-AzAccount -Identity 

Import-Module -Name Az 

Set-AzContext -SubscriptionId $subscription_id 

  

# Get file share 

$StorageContext = New-AzStorageContext -StorageAccountName $storage_account_name -Anonymous 

$PFS = Get-AzRmStorageShare -ResourceGroupName $resource_group -StorageAccountName $storage_account_name -Name $file_share_name -GetShareUsage 

$ProvisionedCapacity = $PFS.QuotaGiB 

$UsedCapacity = $PFS.ShareUsageBytes 

 

# Get storage account 

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $resource_group -AccountName $storage_account_name 

 

# Get provisioned capacity and used capacity 

Write-Host "Provisioned Capacity:" $ProvisionedCapacity 

Write-Host "Share Usage Bytes:" $UsedCapacity 

 

# if provisioned capacity is less than x GiB greater than used capacity, increase provisioned capacity by y GiB 

if (($ProvisionedCapacity - ($UsedCapacity / ([Math]::Pow(2,30)))) -lt $min_free_gibs)  { 

 $Quota = $ProvisionedCapacity + $increase_amount_gibs 

 Update-AzRmStorageShare -StorageAccount $StorageAccount -Name $file_share_name -QuotaGiB $Quota 

 $ProvisionedCapacity = $Quota 

} 

Write-Host "New Provisioned Capacity:" $ProvisionedCapacity 

  

# Write an information log with the current time. 

Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime" 

 
