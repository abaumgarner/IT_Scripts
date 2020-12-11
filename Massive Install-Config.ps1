<#
    Author: Aaron Baumgarner
    Createed: 12/28/17
    Updated: 2/13/20
    Version: 1.3
    Notes: This script will display several configuration options for computers. Software and users will be built based on the menu options.
        
        3/19/18: Added the option to just have Pac7 info and link copied. Also added a prompt asking if the computer should be restarted.
        3/21/18: Added the option to just create the local user.
        4/10/18: Added the option to have just SBClient and Pulse installed. Added a prompt asking if the sbc icon folder should be copied.
        4/11/18: Added NWSS, TWMSU, TWUNR/Reno Rodeo, and Greeley as options
        2/28/19: Changed the dotNet install to work with Windows 1809 by enabling the feature in Windows Features rather than installing the framework
        3/29/19: Added Practical Automation drivers
        2/13/20: Added P5 to the menu option 
#>
param([String] $dir)
cd $dir
$menuReg = '^([0-9]|10|11|12|13|14|15|16)$'
$subReg = '^([0-9]|10|11|12)$'

function MainMenu {
    
    do {
        Write-Host "Select a Region/Client to Prep the Computer for"
        Write-Host "-----------------------------------------------"
        Write-Host "1 - TWCORP"
        Write-Host "2 - TWMSF"
        Write-Host "3 - TWSPOK"
        Write-Host "4 - Yakima"
        Write-Host "5 - NWSS"
        Write-Host "6 - TWMSU"
        Write-Host "7 - Greeley"
        Write-Host "8 - TWUNR/Reno Rodeo"
        Write-Host "9 - Lewis-Clark State College"
        Write-Host "10 - Spokane Indians"
        Write-Host "11 - Spokane County Fair"
        Write-Host "12 - Safeway"
        Write-Host "13 - Maui"
        Write-Host "14 - Military Bowl"
        Write-Host "15 - Spokane Chiefs"
        Write-Host "16 - Firestone Grand Prix"
        Write-Host "17 - P5"
        Write-Host "0 - Exit"
        $option = Read-Host -Prompt 'Option'

        if(-Not ($option -match $menuReg)) {
            Write-Host "$option is not a valid option"
        }
        if($option -eq 0) {
            Write-Host ""
            Write-Host "---------------"
            Write-Host "Exiting Program"
            Write-Host "Restart the computer?"
            $reboot = Read-Host -Prompt 'Y/N'

            if($reboot -eq "Y" -or $reboot -eq "y"){
                Write-Host "The computer will now restart"
                shutdown /r /t 0
            }else{
                exit
            }
        }
    }while(-Not ($option -match $menuReg))

    return $option
}
function SubMenu {
    
    do {
        Write-Host "Select a configuration"
        Write-Host "--------------------------------"
        Write-Host "1 - New user, tRes, Pulse, PSM, Chrome, TeamViewer"
        Write-Host "2 - New user, tRes, Pulse, Chrome"
        Write-Host "3 - New user, PSM, Chrome"
        Write-Host "4 - PSM, Chrome"
        Write-Host "5 - tRes, Pulse, Chrome"
        Write-Host "6 - tRes, Pulse, PSM, Chrome"
        Write-Host "7 - tRes, Pulse"
        Write-Host "8 - Copy Pac7 link and info"
        Write-Host "9 - Create User Only"
        Write-Host "10 - Install TeamViewer"
        Write-Host "11 - Copy tRes folder"
        Write-Host "12 - Install PA Drivers"
        Write-Host "0 - Back"
        $option = Read-Host -Prompt 'Option'
        Write-Host ""

        if(-Not ($option -match $subReg)) {
            Write-Host "$option is not a valid option"
        }
    }while(-Not ($option -match $subReg))

    return $option
}
function CreateUser($region) {
    if($region -eq "TWMSFP"){
        $user = Read-Host -Prompt 'Option'
        Write-Host "Creating the MSF User"
        net user /add msf *
        net user msf /passwordchg:no
        net user msf /expires:never

        Write-Host "Setting MSF user to autologin"
        REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V "DefaultUserName" /t REG_SZ /d "msf" /F
        REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V "DefaultPassword" /t REG_SZ /d "" /F
    }elseif($region -eq "CHIEFS"){
        Write-Host "Creating the chiefs User"
        net user /add user password
        net user user /passwordchg:no
        net user user /expires:never
    }else{
        Write-Host "Creating the TW User"
        net user /add tw *
        net user tw /passwordchg:no
        timeout 3
        net user tw /expires:never

        Write-Host "Setting TW user to autologin"
        REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V "DefaultUserName" /t REG_SZ /d "tw" /F
        REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V "DefaultPassword" /t REG_SZ /d "" /F
    }
    
}
function InstallPulse {
    Write-Host "Installing Pulse"
    Start-Process .\source\InstallPulse.bat
    pause
}
function InstallPADriver {
    Write-Host "Installing PA Drivers"
    pnputil -i -a .\source\ITL_ITX_CONSOLIDATED_v5.0.0.1\OEMPRINT.INF
    pause
}
function InstallSMap {
    Write-Host "Installing the Seat Map Software"
    $pathvargs = {.\source\Install_1.0.0.146\setup.exe }
    Invoke-Command -ScriptBlock $pathvargs 
    pause
}
function InstallTeamViewer {
    Write-Host "Installing the TeamViewer host client"
    $pathvargs = {.\source\TeamViewer_Host_Setup.exe }
    Invoke-Command -ScriptBlock $pathvargs 
    pause
}
function InstallTres($region) {
    Write-Host "Installing SBClient"
    if($region -eq "TWCORP" -or $region -eq "YAKIMA" -or $region -eq "LCS" -or $region -eq "IND" -or $region -eq "SCF" -or $region -eq "MAUI" -or $region -eq "CHIEFS"){
        $pathvargs = {.\source\sbclient\TWCORP.exe }
    }elseif($region -eq "TWMSF"){
        $pathvargs = {.\source\sbclient\TWMSF.exe }
    }elseif($region -eq "TWSPOK"){
        $pathvargs = {.\source\sbclient\TWSPOK.exe }
    }elseif($region -eq "NWSS"){
        $pathvargs = {.\source\sbclient\NWSS.exe }
    }elseif($region -eq "TWMSU"){
        $pathvargs = {.\source\sbclient\TWMSU.exe }
    }elseif($region -eq "GREELEY" -or $region -eq "TWMT"){
        $pathvargs = {.\source\sbclient\TWMT.exe }
    }elseif($region -eq "RENO"){
        $pathvargs = {.\source\sbclient\RENO.exe }
    }elseif($region -eq "P5"){
        $pathvargs = {.\source\sbclient\P5.exe }
    }else{
        Write-Host "Region does not exist"
    }
    
    Invoke-Command -ScriptBlock $pathvargs
    pause
}
function InstallPatch($region) {
    Write-Host "Installing the SBClient Patch"
    $pathvargs = {.\source\sbclient\SBC65Patch.exe }
    Invoke-Command -ScriptBlock $pathvargs 
    pause

    Write-Host "Copy sbc icons folder?"
    $folder = Read-Host -Prompt 'Y/N'

    if($folder -eq "Y" -or $folder -eq "y"){
        xcopy ".\source\tRes Icons" "C:\Users\Public\Desktop\tRes Icons" /i
    }else{
        copy "C:\SBC6-INSTALL\*.sbc" "C:\Users\Public\Desktop"
    }
}
function InstallDotNet {
    Write-Host "Installing the dotNet framework"
    
    Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All

    <# Previous to 1809
    $pathvargs = {DISM /Online /LogLevel:4 /Add-Package /PackagePath:".\source\net35\microsoft-windows-netfx3-ondemand-package.cab" /NoRestart }
    Invoke-Command -ScriptBlock $pathvargs #>
}
function InstallPSM {
    Write-Host "Installing the PSM"
    Start-Process .\source\InstallPSM.bat 
}
function InstallChrome {
    Write-Host "Installing Chrome"
    Start-Process .\source\ChromeSetup.exe
}
function CopyPac7Info($region) {
    Write-Host "Copying Pac7 Info to the Public Desktop"

    Remove-Item -Path "C:\Users\Public\Desktop\*.url"
    Remove-Item -Path "C:\Users\Public\Desktop\*.txt"

    xcopy ".\source\pac7\$region" "C:\Users\Public\Desktop" /i
}
function ConfigRegion($subOpt, $region) {
    if($subOpt -eq 1){
        Write-Host ""
        Write-Host "Configuring New user, tRes, Pulse, PSM, Chrome for $region"
        Write-Host "----------------------------------------------------------"
        Write-Host ""
        
        CreateUser $region
        InstallPulse
        InstallSMap
        InstallTres $region
        InstallPatch $region
        InstallDotNet
        InstallPSM
        InstallPADriver
        InstallChrome
        CopyPac7Info $region
        InstallTeamViewer
        
    }elseif($subOpt -eq 2){
        Write-Host ""
        Write-Host "Configuring New user, tRes, Pulse, Chrome for $region"
        Write-Host "-----------------------------------------------------"
        Write-Host ""

        CreateUser $region
        InstallPulse
        InstallSMap
        InstallTres $region
        InstallPatch $region
        InstallChrome
        InstallPADriver
    }elseif($subOpt -eq 3){
        Write-Host ""
        Write-Host "Configuring New user, PSM, Chrome for $region"
        Write-Host "--------------------------------------------"
        Write-Host ""

        CreateUser $region
        InstallDotNet
        InstallPSM
        InstallChrome
        InstallPADriver
        CopyPac7Info $region
    }elseif($subOpt -eq 4){
        Write-Host ""
        Write-Host "Configuring PSM, Chrome for $region"
        Write-Host "-----------------------------------"
        Write-Host ""
        
        InstallDotNet
        InstallPSM
        InstallPADriver
        InstallChrome
        CopyPac7Info $region
    }elseif($subOpt -eq 5){
        Write-Host ""
        Write-Host "Configuring tRes, Pulse, Chrome for $region"
        Write-Host "-------------------------------------------"
        Write-Host ""

        InstallPulse
        InstallSMap
        InstallTres $region
        InstallPatch $region
        InstallPADriver
        InstallChrome
    }elseif($subOpt -eq 6){
        Write-Host ""
        Write-Host "Configuring tRes, Pulse, PSM, Chrome for $region"
        Write-Host "------------------------------------------------"
        Write-Host ""
        
        InstallPulse
        InstallSMap
        InstallTres $region
        InstallPatch $region
        InstallDotNet
        InstallPSM
        InstallPADriver
        InstallChrome
        CopyPac7Info $region        
    }elseif($subOpt -eq 7){
        Write-Host ""
        Write-Host "Configuring tRes, Pulse for $region"
        Write-Host "-----------------------------------"
        Write-Host ""

        InstallPulse
        InstallSMap
        InstallPADriver
        InstallTres $region
        InstallPatch $region
    }elseif($subOpt -eq 8){
        CopyPac7Info $region
    }elseif($subOpt -eq 9){
        CreateUser $region
    }elseif($subOpt -eq 10){
        InstallTeamViewer
    }elseif($subOpt -eq 11){
        xcopy ".\source\tRes Icons" "C:\Users\Public\Desktop\tRes Icons" /i
    }elseif($subOption -eq 12){
        InstallPADriver
    }
}
function Config($opt, $subOpt) {
    $region = ""
    if($opt -eq 1){
        $region = "TWCORP"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 2){
        $region = "TWMSF"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 3){
        $region = "TWSPOK"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 4){
        $region = "YAKIMA"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 5){
        $region = "NWSS"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 6){
        $region = "TWMSU"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 7){
        $region = "GREELEY"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 8){
        $region = "RENO"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 9){
        $region = "LCS"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 11){
        $region = "SCF"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 13){
        $region = "MAUI"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 15){
        $region = "CHIEFS"
        ConfigRegion $subOpt $region
    }elseif($opt -eq 17){
        $region = "P5"
        ConfigRegion $subOpt $region
    }
}
do{
    $option = -1
    $subOption = -1

    $option = MainMenu

    if($option -eq 1){
        Write-Host ""
        Write-Host "-----------------------"
        Write-Host "Configuring for TWCORP"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 2){
        Write-Host ""
        Write-Host "----------------------"
        Write-Host "Configuring for TWMSF"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 3){
        Write-Host ""
        Write-Host "-----------------------"
        Write-Host "Configuring for TWSPOK"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 4){
        Write-Host ""
        Write-Host "----------------------"
        Write-Host "Configuring for Yakima"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 5){
        Write-Host ""
        Write-Host "---------------------"
        Write-Host "Configuring for NWSS"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 6){
        Write-Host ""
        Write-Host "----------------------"
        Write-Host "Configuring for TWMSU"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 7){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for Greeley"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 8){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for TWUNR/Reno Rodeo"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 9){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for Lewis-Clark State College"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 10){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for the Spokane Indians"
        Write-Host ""
        
        $region = "IND"
        
        InstallPulse
        InstallSMap
        InstallTres $region
        InstallPatch $region
        InstallDotNet
        InstallPSM
        InstallChrome
        CopyPac7Info $region

    }elseif($option -eq 11){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for the Spokane County Fair"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 12){
        $region = "PSW"
        CopyPac7Info $region
    }elseif($option -eq 13){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for Maui"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 14){
        $region = "MILB"
        CopyPac7Info $region
    }elseif($option -eq 15){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for Arena Box Office"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }elseif($option -eq 16){
        $region = "FIRE"
        CopyPac7Info $region
    }elseif($option -eq 17){
        Write-Host ""
        Write-Host "------------------------"
        Write-Host "Configuring for P5"
        Write-Host ""
        $subOption = SubMenu

        Config $option $subOption
    }else{
        Write-Host "Option does not exist....not sure how you got here"
    }
}while(-Not ($option -eq 0))
