<#
    Author: Aaron Baumgarner
    Created: 9/26/16
    Updated: 9/9/20
    Version: 6.1
    Notes: This script will take users defined in the file 'create.txt' and out put their username/password combination based on the first line of 'create.txt' to an 
        output file, 'user.txt'. The username is based on the first 3 letters of the user's first name and first 5 of their last name. The passwords for AIX and SB+ are 
        based on the array 'ara'. A number is randomly generated between 0 and the length of the array. This number becomes the index for which password to choose. AIX is
        the lower case version and SB+ is the uppercase version with an 'X' appened to the end. The Pac7 password is a random string based on randomly picking characters
        and then randomly inserting a number to garentee the password meets Pac7 password complexity. Some error checking is done to make sure a user has a first and last 
        name. If the file only contains one then the user is prompted to enter the full name. The user can either place the desired menu option (1,2,3,4,5,6,7,8,9) at the top of the file or 
        select it from the menu. The menu will apear if the first line in the 'create.txt' file is not 1, 2, 3, 4, 5, 6, 7, 8, or 9. 
        
        6/30/17 - Added the options to have an eQuery user info created or a temporary password for eVenue created. Evenue temporary passwords do not require the input file to contain 
                  values. When creating the username only (option 8) now allows for the user to not have anything in the input file but instead manually type the user's full name.
        
        9/9/20 - Added the GenSimplePassword function to generate a random number to the end of the string Tickets. This is to make it easier on end users to type in the password.
#>

$menuReg = '^([0-9,f]|10)$'
$menuGroupOne = '^([1,2,3,4])$'
$menuGroupTwo = '^([5,6,7])$'

function GenPassword {
  <#
    $pacPass = ([char[]](Get-Random -Input $(49..57 + 65..72 + 74..78 + 80..90 + 97..107 + 109..110 + 112..122) -Count 7)) -join ""
    $randNum = Get-Random -minimum 2 -maximum 9
    $randIndex = Get-Random -minimum 1 -maximum 7
    #>

    $pacPass = ([char[]](Get-Random -Input $(49..57 + 65..72 + 74..78 + 80..90 + 97..107 + 109..110 + 112..122) -Count 9)) -join ""
    $randNum = Get-Random -minimum 2 -maximum 9
    $randIndex = Get-Random -minimum 1 -maximum 9

    $pacPass = $pacPass.Insert($randIndex, $randNum)

    return $pacPass
}

function GenSimplePassword {
    $pacPass = "Tickets"
    $randNum = Get-Random -minimum 2 -maximum 9
    $pacPass += $randNum

    return $pacPass
}

function ToString {  
    param([int]$option, [string]$username, [string]$FullName, [string]$pacPass, [string]$aixPass, [string]$sbPass)

    $str = $userName.ToUpper() + "`r`n" + "$FUllName`r`n"

    if($option -eq 10){
        $str += "mPac Username: $userName`r`n" + "mPac Password: $pacPass`r`n"
        return $str
    }

    if($option -match '[1,5]') {
        $str += "Pac7 Username: $userName`r`n" + "Pac7 Password: $pacPass`r`n"
    }elseif($option -match '[2,6]') {
        $str += "First Username: $userName`r`n" + "First Password: $aixPass`r`n" + "Second Username: " + $userName + "`r`n" + "Second Password: $sbPass`r`n"
    }elseif($option -match '[3,7]') {
        $str += "tRes`r`n" + "First Username: $userName`r`n" + "First Password: $aixPass`r`n" + "Second Username: " + $userName + "`r`n" + "Second Password: $sbPass`r`n" +  "Pac7`r`n" + "Pac7 Username: $userName`r`n" + "Pac7 Password: $pacPass`r`n"
    }elseif($option -match '[4]'){
        $str += "eQuery Username: $userName`r`n" + "eQuery Password: $pacPass`r`n "
    }elseif($option -eq 'mpac'){
        $str += "mPac Username: $userName`r`n" + "mPac Password: $pacPass`r`n"
    }

    return $str
}

function GenUsername {
    param([string]$lname, [string] $fname)

    if($lname.length -lt 5) {
		$userName = $fname.Substring(0,3).ToLower() + $lname.ToLower()
	}else {
		$userName = $fname.Substring(0,3).ToLower() + $lname.Substring(0,5).ToLower()
	}
    
    return $userName
}

function GenmPacUsername {
    param([string]$lname, [string] $fname)

	$userName = "mpac" + $fname.Substring(0,1).ToLower() + $lname.Substring(0,2).ToLower()
    
    return $userName
}

function GetFullName {
    param([string]$FullName)
    $lname = $FullName.split(' ')[1]
    $fname = $FullName.Split(' ')[0]

    While($lname.length -eq 0 -or $fname -eq 0) {
        if($lname.length -eq 0) {
            Write-Host "$FullName does not contain a last name. Please enter the full name again."
        }else {
            Write-Host "The full name is empty is does not contain a full name. Please enter the full name."
        }
        $FullName = Read-Host -Prompt 'Full Name'
        $lname = $FullName.split(' ')[1]
    }

    return $FullName
}

function Menu {
    
    do {
        Write-Host "User Generator"
        Write-Host "--------------"
        Write-Host "Generate Username and Passwords"
        Write-Host "1 - Pac7 Username/password are generated"
        Write-Host "2 - AIX and SB+ username/passwords are generated"
        Write-Host "3 - Pac7, AIX, and SB+ username/passwords are generated"
        Write-Host "4 - eQuery Username/password are generated"
        Write-Host ""
        Write-Host "Generate Passwords Only. Usernames are in File"
        Write-Host "5 - Pac7 password is generated"
        Write-Host "6 - AIX and SB+ passwords are generated"
        Write-Host "7 - Pac7, AIX, and SB+ passwords are generated"
        Write-Host ""
        Write-Host "Other Options"
        Write-Host "8 - Username only"
        Write-Host "9 - eVenue Password"
        Write-Host "10 - mPac"
        Write-Host "0 - Exit"
        $option = Read-Host -Prompt 'Option'

        if(-Not ($option -match $menuReg)) {
            Write-Host "$option is not a valid option"
        }
        if($option -eq 0) {
            Write-Host ""
            Write-Host "---------------"
            Write-Host "Exiting Program"
            $printStream.Close()
            exit
        }
    }while(-Not ($option -match $menuReg))

    return $option
}

$fin = Get-Content create.txt
$fout = 'user.txt'
$ctr = 0
$ara = "asd", "qwe", "zxc"
$rand = Get-Random -Minimum 0 -Maximum $ara.Length
$printStream = [System.IO.StreamWriter] $fout
$option = -1

if($fin -eq $null){
    $option = Menu
}elseif($fin[$ctr] -match $menuReg) {
    $option = $fin[$ctr]
    $ctr++
}elseif($fin[$ctr] -match '\D') {
    $option = Menu
}

if($fin -eq $null -and $option -notmatch '^([8-9])$') {
    $option = -1;
}

$numLines = $fin | Measure-Object -Line
$sbPass = "XXXX"
$aixPass = $ara[$rand]

if($option -match $menuGroupOne) {
    while($ctr -lt $numLines.Lines ) { 
        if($numLines.Lines -eq 1) {
            $FullName = GetFullName $fin
        }else {
            $FullName = GetFullName $fin[$ctr]
        }

        $fname = $FullName.Split(' ')[0]
        $lname = $FullName.Split(' ')[1]

        $userName = GenUsername $lname $fname
        $userName = $userName.ToLower()

        $pacPass = GenSimplePassword

        $str = ToString $option $username $FullName $pacPass $aixPass $sbPass

        $printStream.WriteLine($str)
        $ctr++
    }
} elseif($option -match $menuGroupTwo) {
    while($ctr -lt $numLines.Lines) {       
        $FullName = $fin[$ctr]
        $ctr++
        $userName = $fin[$ctr].ToLower()

        $pacPass = GenSimplePassword

        $str = ToString $option $username $FullName $pacPass $aixPass $sbPass

        $printStream.WriteLine($str)
        $ctr++
    }
} elseif($option -eq '8') {
    if($numLines.Lines -eq 0){
        $FullName = GetFullName $fin
        $fname = $FullName.Split(' ')[0]
        $lname = $FullName.Split(' ')[1]

        $userName = GenUsername $lname $fname

        $str = $userName.ToUpper() + "`r`n" + "$FUllName`r`n"

        $printStream.WriteLine($str)
    }else{
        while($ctr -lt $numLines.Lines ) { 
        
            if($numLines.Lines -eq 1) {
                $FullName = GetFullName $fin
            }else {
                $FullName = GetFullName $fin[$ctr]
            }

            $fname = $FullName.Split(' ')[0]
            $lname = $FullName.Split(' ')[1]

            $userName = GenUsername $lname $fname

            $str = $userName.ToUpper() + "`r`n" + "$FUllName`r`n"

            $printStream.WriteLine($str)
            $ctr++
        }
    }
} elseif($option -eq '9') {
   $eVenuePass = GenPassword;
   $eVenuePass = $eVenuePass.Substring(0,7)
   $str = "eVenue Temp Password: $eVenuePass"
   $printStream.WriteLine($str)
} elseif($option -eq '10') {
   if($numLines.Lines -eq 0){
        $FullName = GetFullName $fin
        $fname = $FullName.Split(' ')[0]
        $lname = $FullName.Split(' ')[1]

        $userName = GenmPacUsername $lname $fname

        $str = $userName.ToUpper() + "`r`n" + "$FUllName`r`n"

        $pacPass = "tickets1"

        $str = ToString $option $username $FullName $pacPass $aixPass $sbPass

        $printStream.WriteLine($str)
    }else{
        while($ctr -lt $numLines.Lines ) { 
        
            if($numLines.Lines -eq 1) {
                $FullName = GetFullName $fin
            }else {
                $FullName = GetFullName $fin[$ctr]
            }

            $fname = $FullName.Split(' ')[0]
            $lname = $FullName.Split(' ')[1]

            $userName = GenmPacUsername $lname $fname

            $str = $userName.ToUpper() + "`r`n" + "$FUllName`r`n"

            $pacPass = "tickets" + ($ctr + 1)

            $str = ToString $option $username $FullName $pacPass $aixPass $sbPass
            $printStream.WriteLine($str)
            $ctr++
        }
    }
} elseif($option -eq 'f') {
    $ctr = 0
    while($ctr -lt 300){
       $eVenuePass = GenPassword;
       $eVenuePass = $eVenuePass.Substring(0,9)
       $str = "$eVenuePass"
       $ctr++
       $printStream.WriteLine($str)
   }
   
}else {
    Write-Host "File was not formated correctly"
    $printStream.WriteLine("File was not formated correctly")
}

$printStream.Close()
Invoke-Item $fout

Write-Host ""
Write-Host "---------------"
Write-Host "End of Program"