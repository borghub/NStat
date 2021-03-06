#NStat v 0.1
#cd "C:\Users\Samuel\Google Drive\prog\NStat"
cd "D:\private\samuel\Google Drive\prog\NStat"

$connect = Get-Content connect.txt
$user = $connect[0]
$pass = $connect[1]
$sysinfo = Get-Content nodes.txt

$nodes = @()

$i = 0
do {
$name=$sysinfo[$i].ToString()
$core=$sysinfo[$i+1].ToString()
$net=$sysinfo[$i+2].ToString()

#Getting the information from the linux node to a powershell array
New-SshSession -ComputerName $net -Username $user -Password $pass
$temp = Invoke-SshCommand -ComputerName $net -Command "sensors" -Quiet
#$date = Invoke-SshCommand -ComputerName $net -Command "date" -Quiet
Invoke-SshCommand -ComputerName $net -Command "top -n 1 -b > top-output.txt" -Quiet
$use = Invoke-SshCommand -ComputerName $net -Command "head -15 top-output.txt" -Quiet

$tempStr = $temp[0] -split "`n"
$useStr = $use[0] -split "`n"


#Creation of a variable containing the cpu load.
$cpuStr = $useStr[2]
$cpu =  $cpuStr.Substring(27,5)

#Creation of an array containing the core's temp
$j=0
$temp=0
$readTempStr = @("","","","","","","","")
foreach ($element in $tempStr) {
$str = select-string -inputObject $element -pattern "Core" -CaseSensitive -Quiet
if ($str -eq "true") {
    $tempStr = select-string -inputObject $element -pattern "Core" -CaseSensitive
    $tempStr = "$tempStr"
    $readTempStr[$j] = $tempStr.Substring(15,4)
    $temp = $temp + $readTempStr[$j]
    $j++
}
}
$temp = $temp/$core

$date = get-date
$time=$date.ToString()

$node = New-Object System.Object
$node | Add-Member –type NoteProperty –name Node –value $name
$node | Add-Member –type NoteProperty –name Address –value $net
$node | Add-Member –type NoteProperty –name Cores –value $core
$node | Add-Member –type NoteProperty –name CPU –value $cpu
$node | Add-Member –type NoteProperty –name Temperature –value $temp
$node | Add-Member –type NoteProperty –name Date –value $time

$nodes += $node

$i=$i+3}
while ($sysinfo[$i] -ne "END")

$nodes | ConvertTo-Json | Out-File "nodes.json"