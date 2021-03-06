#Author: James Lamphere (see Browse-ActiveDirectory function for author credit)
#Modified By: Aaron Baumgarner (modified to work with a different domain)

[console]::foregroundcolor="red"
 
write-host "Domain Utility Script version 1.0" -foreground green

[console]::resetcolor()

# Get AD credentials
$domain = ""
$prefix = ""

write-host "`n"
$name = read-host 'Please enter a username with permissions to manipulate computer objects in the Paciolan domain'
$pass = read-host 'Password' -assecurestring

$mycred = new-object system.management.automation.pscredential $domain\$name,$pass

$ppass=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))

$script:rootdomain="paciolan.corp"

$script:domain = New-Object DirectoryServices.DirectoryEntry("LDAP://$rootdomain",$name,$ppass)

$credTries = 3

# Check if supplied credentails are valid and if not, prompt again. 

while($script:domain.name -eq $null) {

    $credTries--

    if($credTries -eq 0) {
    
        write-host -fore red "`n3 failed authentication attempts!!"
        write-host -fore red "`nExiting."
        exit
        
    }
    
    write-host -fore red "`nAuthentication failed - please verify your username and password."
    
    write-host "`n"
    $name = read-host 'Please enter a username with permissions to manipulate computer objects in the Paciolan domain'
    $pass = read-host 'Password' -assecurestring
    $mycred = new-object system.management.automation.pscredential $prefix\$name,$pass
    $ppass=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
    $domain = New-Object DirectoryServices.DirectoryEntry("LDAP://$script:rootdomain",$name,$ppass)
    
}


write-host -fore green "`nSuccessfully authenticated with the"$script:domain.name "domain!!"

# Setup some variables

$strComputer = $env:computername

$Filter = "(&(ObjectCategory=computer)(name=$strComputer))"
    
$compSearch = New-Object DirectoryServices.DirectorySearcher $script:domain
    
$compSearch.filter = $Filter

$yes=new-object system.management.automation.host.choicedescription "&Yes",""

$no=new-object system.management.automation.host.choicedescription "&No",""

$choices = [system.Management.automation.host.choicedescription[]]($yes,$no)

$script:targetOU = $null

$script:ComputerDN = $null


# Menu selection function

function menuselection {

    $menuChoice = "x"

    write-host "`n"
    
    while(($menuChoice -ne "c") -and ($menuChoice -ne "j") -and ($menuChoice -ne "m") -and ($menuChoice -ne "d") -and ($menuChoice -ne "r") -and ($menuChoice -ne "q") -and ($menuChoice -ne "u")) {
        
        write-host -fore magenta "Main Menu"
        [console]::foregroundcolor="cyan"
        write-host "[c] Check if this computer object exists in AD"
        write-host "[j] Join this computer to the domain"
        write-host "[m] Move this computer object to a different OU"
        write-host "[r] Rename this computer" 
        write-host "[u] Unjoin this computer from the domain"
        write-host "[q] Quit and exit"
        write-host
        [console]::foregroundcolor="green"
        $menuChoice = read-host "Enter menu option"
        
    }
    
    [console]::resetcolor()
    
    switch($menuChoice){
        "c"{$noReturnValue=checkADforComp}
        "d"{write-host "d"}
        "j"{joinDomain}
        "m"{moveComputer}
        "r"{renameComputer}
        "u"{unjoinDomain}
        "q"{exit}
        
    }
    
    menuselection
    
} # end function menuselection


Function Browse-ActiveDirectory {

# Author: MOW (AKA The Powershell Guy)
# Modified by: James Lamphere
# Notes: I've modified MOW's original function to only return the pointer data for OU objects. 

$root=New-Object DirectoryServices.DirectoryEntry("LDAP://$script:rootdomain",$name,$ppass)

# Try to connect to the Domain root

    &{trap {throw "$($_)"};[void]$Root.psbase.get_Name()}

# Make the form
# add a reference to the forms assembly
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

    $form = new-object Windows.Forms.form
    $form.Size = new-object System.Drawing.Size @(800,600)
    $form.text = "Select destination OU for $strComputer"

# Make TreeView to hold the Domain Tree

    $TV = new-object windows.forms.TreeView
    $TV.Location = new-object System.Drawing.Size(10,30)
    $TV.size = new-object System.Drawing.Size(770,470)
    $TV.Anchor = "top, left, right"

# Add the Button to close the form and return the selected DirectoryEntry

    $btnSelect = new-object System.Windows.Forms.Button
    $btnSelect.text = "Select"
    $btnSelect.Location = new-object System.Drawing.Size(710,510)
    $btnSelect.size = new-object System.Drawing.Size(70,30)
    $btnSelect.Anchor = "Bottom, right"

# If Select button pressed set return value to Selected DirectoryEntry and close form

    $btnSelect.add_Click({
    $script:Return = new-object directoryservices.directoryEntry("LDAP://$script:rootdomain/$($TV.SelectedNode.text)",$name,$ppass)
    $form.close()
    })

# Add Cancel button

    $btnCancel = new-object System.Windows.Forms.Button
    $btnCancel.text = "Cancel"
    $btnCancel.Location = new-object System.Drawing.Size(630,510)
    $btnCancel.size = new-object System.Drawing.Size(70,30)
    $btnCancel.Anchor = "Bottom, right"

# If cancel button is clicked set returnvalue to $False and close form

    $btnCancel.add_Click({$script:Return = $false ; $form.close()})

# Create a TreeNode for the domain root found

    $TNRoot = new-object System.Windows.Forms.TreeNode("Root")
    $TNRoot.Name = $root.name
    $TNRoot.Text = $root.distinguishedName
    $TNRoot.tag = "NotEnumerated"

# First time a Node is Selected, enumerate the Children of the selected DirectoryEntry

    $TV.add_AfterSelect({
        if ($this.SelectedNode.tag -eq "NotEnumerated") {

            $de = new-object directoryservices.directoryEntry("LDAP://$script:rootdomain/$($TV.SelectedNode.text)",$name,$ppass)

# Add all Children found as Sub Nodes to the selected TreeNode

            $de.psbase.children | Where-Object {$_.objectClass -contains "organizationalunit"} |

            foreach-object{
            $TN = new-object System.Windows.Forms.TreeNode
            $TN.Name = $_.name
            $TN.Text = $_.distinguishedName
            $TN.tag = "NotEnumerated"
            $this.SelectedNode.Nodes.Add($TN)
            }

# Set tag to show this node is already enumerated

            $this.SelectedNode.tag = "Enumerated"
        }
    
    })

# Add the RootNode to the Treeview

    [void]$TV.Nodes.Add($TNRoot)

# Add the Controls to the Form

    $form.Controls.Add($TV)
    $form.Controls.Add($btnSelect )
    $form.Controls.Add($btnCancel )

# Set the Select Button as the Default

    $form.AcceptButton = $btnSelect

    $Form.Add_Shown({$form.Activate()})
    [void]$form.showdialog()

# Return selected DirectoryEntry or $false as Cancel Button is Used
    
    $script:targetOU = $script:Return.distinguishedname

} # end function Browse-ActiveDirectory

# Join domain function

function joinDomain {

    $script:targetOU = $null
    
# Check if the computer is already joined to the domain. If it is, go back to the main menu
    
    if ((gwmi win32_computersystem).partofdomain -eq $true) {
        
            write-host -fore red "`n$strComputer is already joined to $((gwmi win32_computersystem).domain)!!"
        
            break
    }
    
    $message = "`nDo you want to join $strComputer to the PACIOLAN domain?"
    $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
    
    if($result -eq 0) {

         
# Check if computer object already exists in the domain. If it does, rejoin the computer to it's current OU. 

        if(checkADforComp -eq $true){
        
            $computerCN = New-Object DirectoryServices.DirectoryEntry("LDAP://$script:rootdomain/$script:ComputerDN",$name,$ppass)
            
            $script:targetOU = ($computerCN.psbase.parent).path
            
            $message = "`nProceed with rejoining $strComputer to the domain? Note that the computer will be rejoined to the OU listed above. You can move the computer object to a different OU from the script's main menu."
            $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
            
            if($result -eq 0) {
            
                write-host "`nJoining $strComputer to the domain $script..."
                
                add-computer -DomainName $rootdomain -credential $mycred    
                
            }
            
            elseif($result -eq 1) {write-host "Join cancelled!"}
           
        }
        
# If a computer object does not exist, browse AD and select the OU for the new object. 
        
        else {
            
             write-host "`nA new computer object will be created in the domain for $strComputer."
             
             write-host "`nBrowse to the OU where this new computer object should reside:"
            
            . Browse-ActiveDirectory
            
            while($script:targetOU -eq $null) {
                
                $message = "`nYou did not select a destination OU for $strComputer. Browse again?"
                $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
                
                if($result -eq 0) {. Browse-ActiveDirectory}
                
                elseif($result -eq 1) {
                
                    write-host "`nJoin cancelled!"
                    break
                    
                }
                
            }
            
            $message = "`nProceed with joining the domain? A computer object for $strComputer will be created at $targetOU"
            $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
            
            if($result -eq 0) {add-computer -DomainName $script:rootdomain -oupath "$targetOU" -credential $mycred} 
            

            $message = "`nWould you like to rename $strComputer ?"
            $result = $Host.UI.promptforchoice($caption,$message,$choices,0)

            if($result -eq 0) {renameComputer}
            else {write-host "`n$strComputer was not renamed"}

            $message = "`nWould you like to restart now?"
            $result = $Host.UI.promptforchoice($caption,$message,$choices,0)

            if($result -eq 0) {Restart-Computer}
        }   
              
    }
    
   elseif($result -eq 1) {write-host "Join cancelled!"}
   
} # end function joinDomain

# Move computer function

function moveComputer {

$script:targetOU = $null

# Check if the computer exits in AD and if so, ask to move it to a different OU

    if (checkADforComp -eq $true) {

        $message = "`nDo you want to move $strComputer to a different OU?"
        $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
    
        if($result -eq 0) {
                
            $proceed = $false
            
            . Browse-ActiveDirectory
            
            while(($script:targetOU -eq $null) -and ($proceed -eq $false)) {
                
                $message = "`nYou did not select a new destination OU for $strComputer. Browse again?"
                $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
                
                if($result -eq 1) {$proceed = $true}
                
                elseif($result -eq 0) {. Browse-ActiveDirectory}
                
            }
                
            if($script:targetOU -ne $null) {
            
                $dest = New-Object DirectoryServices.DirectoryEntry("LDAP://$script:rootdomain/$script:targetOU",$name,$ppass)
                
                $message = "`nProceed with moving $strComputer to $script:targetOU"
                $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
                    
                if($result -eq 0) {
                
                    $serv2=$compSearch.findall()|where {$_.properties.item("cn") -like $strComputer}
        
                    $script:ComputerDN = $serv2.properties.item("distinguishedname")
                    
                    $comp_move = New-Object DirectoryServices.DirectoryEntry("LDAP://$script:rootdomain/$script:ComputerDN",$name,$ppass)
                            
                    $comp_move.PSBase.MoveTo($dest)
                            
                    if($?) {write-host "`nMove successful!!" -foreground green}
                            
                    else {write-host "`nMove failed"!! -foreground red}       
             
                }
                        
                elseif($result -eq 1) {write-host "`n$strComputer was not be moved."}
            
            }
        
            elseif($result -eq 1) {write-host "`n$strComputer was not be moved."}
                
        }
                
        elseif($result -eq 1) {write-host "`n$strComputer was not be moved."}
        
    }

} # end function moveComputer

# check if exists in AD function

function checkADforComp {

# check if the computer object exists in AD
    
    if (($compSearch.Findall()) -ne $null) {
    
        $serv2=$compSearch.findall()|where {$_.properties.item("cn") -like $strComputer}
        
        $script:ComputerDN = $serv2.properties.item("distinguishedname")
            
        write-host "`nA computer object was found at $script:ComputerDN"
		
        return $true
        
    }
    
    else {
    
        write-host "`nThe computer object $strComputer WAS NOT found in AD!"
        
        return $false
    
    }    
           
} # end fuction checkADforComp

function renameComputer {

    write-host "`n"
    
    $newName=read-host 'Enter the new computer name'
    
    $message = "`nProceed with renaming $strComputer to $newName"
    $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
    
    if($result -eq 0) {
    
        if ((gwmi win32_computersystem).partofdomain -eq $true) {
        
            $comp=get-wmiobject win32_computersystem -computername $strComputer
            $return=$comp.rename($newName,$ppass,$name)
    
            if($return.returnvalue -eq 0) {
    
                write-host "`nThe computer was successfully renamed from $strComputer to $newname" -foregroundcolor green
                write-host "`nYou must reboot the computer to apply this change."
   
            }
            
            else {write-host "`nRename failed!" -foregroundcolor red}
            
        }
        
        else {
        
            $comp=get-wmiobject win32_computersystem -computername $strComputer
            $return=$comp.rename($newName)
            
            if($return.returnvalue -eq 0) {
    
                write-host "`nThe computer was successfully renamed from $strComputer to $newname" -foregroundcolor green
                write-host "`nYou must reboot the computer to apply this change."
   
            }
            
            else {write-host "`nRename failed!" -foregroundcolor red}
            
        }
         
    
    }
    
    
} # end function renameComputer

function unjoinDomain {

    $message = "`nProceed with unjoining $strComputer from the $script:rootdomain domain"
    $result = $Host.UI.promptforchoice($caption,$message,$choices,0)
    
    if($result -eq 0) {
    
        remove-computer -credential $mycred -force
    
    }

} # end function unjoinDomain
    
menuselection
