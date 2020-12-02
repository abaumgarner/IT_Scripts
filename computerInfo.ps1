<#
    Author: Aaron Baumgarner
    Created: 12/15/16
    Updated: 12/20/16
    Notes: Gets basic information about the computer (Computer name, manufacturer, model number, serial number, network adapter, and network adapter MAC address) and saves this info to a file (computerName-Info.txt). 
        The last step is setting the computer name to be TW-SericalNumber.
#>
$serialNum = wmic systemenclosure get serialnumber

$compPath = $serialNum[2].Trim()

$hardware = Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem"

$compName = $hardware.Name

$fout = $compPath + "-Info.txt"

$printStream = [System.IO.StreamWriter] $fout

$printStream.WriteLine("Computer Name: " + $compName)

$compInfo = Get-WmiObject -Query "SELECT manufacturer, model FROM Win32_ComputerSystem"

$printStream.WriteLine("Manufacturer: " + $compInfo.manufacturer)

$printStream.WriteLine("Model: " + $compInfo.model)

$serialNum = wmic systemenclosure get serialnumber

$printStream.WriteLine("Computer Serial Number: " + $serialNum[2].Trim())



$printStream.WriteLine("RAM (bytes): " + $hardware.TotalPhysicalMemory)
$printStream.WriteLine("Domain: " + $hardware.Domain)

$processor = Get-WmiObject -Query "SELECT * FROM Win32_Processor"
$printStream.WriteLine("Processor: " + $processor.Name)

$hdd = Get-WmiObject -Query "SELECT * FROM Win32_LogicalDisk"
$printStream.WriteLine("Drive:" + $hdd.DeviceID)
$printStream.WriteLine("Size:" + $hdd.Size)


$printStream.WriteLine()

$macInfo = Get-WmiObject -Query "SELECT description, macaddress FROM win32_networkadapterconfiguration"

for($i=0; $i -lt $macInfo.length; $i++){
    if(-not([string]::IsNullOrEmpty($macInfo[$i].macaddress))){
        $printStream.WriteLine("Adapter:" + $macInfo[$i].description)
        $printStream.WriteLine("MAC Address:" + $macInfo[$i].macaddress)
    }
}

$printStream.WriteLine("MAC Address: " + $macInfo.macaddress)

$printStream.Close()
