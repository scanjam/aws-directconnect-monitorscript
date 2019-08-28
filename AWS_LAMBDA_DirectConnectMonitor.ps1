# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#$region = $env:AWS_REGION
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement 
# indicating the module and version.
#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.522.0'}
#Log Connections that ARE NOT in an 'available' state with metric of 0
#Replace <MYDXREGION> withthe region your DX connctions are hosted. e.g "eu-west-1"
#This file can then be uploaded to lambda and run as a scheduled job to log metrics
#
$region = "<MYDXREGION>"
$connectionsdown = Get-DCConnection -Region $region | where-object {$_.ConnectionState -ne 'available'}
ForEach ($conndown in $connectionsdown) {
    $ConnectionsDownMetric = [Amazon.CloudWatch.Model.MetricDatum]::new()
    $ConnectionsDownMetric.MetricName = $conndown.ConnectionName
    $ConnectionsDownMetric.Value = 1
    $ConnectionsDownMetric.Dimensions = $ConnectionsDownMetricDimension
    $ConnectionsDownMetricDimension = [Amazon.CloudWatch.Model.Dimension]::new()
    $ConnectionsDownMetricDimension.Name = 'Availability'
    $ConnectionsDownMetricDimension.Value = $conndown.ConnectionState
    Write-CWMetricData -MetricData $ConnectionsDownMetric -NameSpace Custom/DirectConnect -region $region
    write-host ($conndown | convertto-json)
}
$interfacesdown = Get-DCVirtualInterface -Region $region | where-object {$_.VirtualInterfaceState -ne 'available'}
# write-host ($interfacesdown | convertto-json)
ForEach ($intfdown in $interfacesdown) {
    $InterfacesDownMetric = [Amazon.CloudWatch.Model.MetricDatum]::new()
    $InterfacesDownMetric.MetricName = $intfdown.VirtualInterfaceName
    $InterfacesDownMetric.Value = 1
    $InterfacesDownMetric.Dimensions = $InterfacesDownMetricDimension
    $InterfacesDownMetricDimension = [Amazon.CloudWatch.Model.Dimension]::new()
    $InterfacesDownMetricDimension.Name = 'Availability'
    $InterfacesDownMetricDimension.Value = $intfdown.VirtualInterfaceState
    Write-CWMetricData -MetricData $InterfacesDownMetric -NameSpace Custom/DirectConnect -region $region
    write-host ($intfdown | convertto-json)
}
#Log Connections that ARE in an 'available' state with a metric of 1
$connectionsup = Get-DCConnection -Region $region | where-object {$_.ConnectionState -eq 'available'}
ForEach ($connup in $connectionsup) {
    $ConnectionsUpMetric = [Amazon.CloudWatch.Model.MetricDatum]::new()
    $ConnectionsUpMetric.MetricName = $connup.ConnectionName
    $ConnectionsUpMetric.Value = 1
    $ConnectionsUpMetric.Dimensions = $ConnectionsUpMetricDimension
    $ConnectionsUpMetricDimension = [Amazon.CloudWatch.Model.Dimension]::new()
    $ConnectionsUpMetricDimension.Name = 'Availability'
    $ConnectionsUpMetricDimension.Value = $connup.ConnectionState
    Write-CWMetricData -MetricData $ConnectionsUpMetric -NameSpace Custom/DirectConnect -region $region
    write-host ($connup | convertto-json)
}
$interfacesup = Get-DCVirtualInterface -Region $region | where-object {$_.VirtualInterfaceState -eq 'available'}
ForEach ($intfup in $interfacesup) {
    $InterfacesUpMetric = [Amazon.CloudWatch.Model.MetricDatum]::new()
    $InterfacesUpMetric.MetricName = $intfup.VirtualInterfaceName
    $InterfacesUpMetric.Value = 1
    $InterfacesUpMetric.Dimensions = $InterfacesUpMetricDimension
    $InterfacesUpMetricDimension = [Amazon.CloudWatch.Model.Dimension]::new()
    $InterfacesUpMetricDimension.Name = 'Availability'
    $InterfacesUpMetricDimension.Value = $intfup.VirtualInterfaceState
    Write-CWMetricData -MetricData $InterfacesUpMetric -NameSpace Custom/DirectConnect -region $region
    write-host ($intfup | convertto-json)
}

