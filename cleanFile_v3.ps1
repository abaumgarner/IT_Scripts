<#
    Author: Aaron Baumgarner
    Created: 10/4/16
    Updated: 9/14/17
    Version: 3
    Notes: Takes a file specificed by the user, reads in each line, checks the line to see if there are non-ASCII characters in it with a regex, replaces 
        these characters with a space, then prints the clean line to an output file. Each line's length is also checked to see if it is not equal to 250.
        If the line length is less than 250 then spaces are added at the end of the line to get upto 250, then the clean line with the extra spaces is printed
        to the output file.
        [^a-zA-Z0-9 ,@.\-\/\n'#():_&]

        3/2/17 - Cleaned up code for printing to screen using a function instead of repeated calls to Write-Host and added a log that saves what is printed to 
            the screen with a timestamp of when the file was checked.
        
        9/14/17 - Added the ability to remove characters from the end of the line if the line length is greater than 250. This is so the word count can be checked again.
#>
function CleanFile {
    param([string]$fname)
    
    $fout = $fname.Split('.')[0] + 'Clean.txt'
    $fin = Get-Content $fname
    $ctr = 0
    
    $printStream = [System.IO.StreamWriter] $fout
    $regex = "[^\00-\x7F]"

    $print = "Line : Length" + "`r`n" + "-------------"
    
    PrintToScreen($print)
    SaveToLog($print)

    while($ctr -lt $fin.Length) {
        $line = $fin[$ctr]     
        $ctr++
        $str = ""

        if($line.Length -ne 250) {
            $print = "" + $ctr + " : " + $line.Length
            PrintToScreen($print)
            SaveToLog($print)
            
            if($ctr -eq $fin.Length) {
                $print = "`r`n" + "Last Line in the file:" + "`r`n" + $ctr + " : " + $line.Length + "`r`n"            
                PrintToScreen($print)
                SaveToLog($print)
            }

            if($line.Length -lt 250) {
                for($i = $line.Length; $i -lt 250; $i++) {
                    $str += " "
                }
                $line = $line + $str
                
            }elseif($line.Length -gt 250) {
                $i = $line.Length - ($line.Length - 250)

                $str += $line.Substring(0, $i)
                $line = $str
                
            }
            
        }

        if($line -match $regex) {
            $save = "" + $ctr + " : " + $line + "`r`n"
        }
        
        $clean = $line -replace $regex, ' '
        $printStream.WriteLine($clean)
    }

    if($save.Length -eq 0) {
        $save = "No lines were cleaned`r`n"
    }
    SaveToLog("`r`n" + "Lines Cleaned`r`n" + "-------------`r`n" + $save)
    
    $printStream.Close()
}

function GetFileName {
    do {
        $fname = Read-Host -Prompt 'File name'
    
        if(!(Test-Path $fname)) {
            Write-Host $fname 'does not exist.'
        }

    }while(!(Test-Path $fname))

    return $fname
}

function SaveToLog {
    param([string]$str)
    $fout = 'cleanFile-log.txt'
    $printStream = new-object 'System.IO.StreamWriter' -ArgumentList $fout,$true

    $printStream.WriteLine($str)

    $printStream.Close()
}

function TimeStampLog {
    param([string]$fname)

    $fout = 'cleanFile-log.txt'
    $printStream = new-object 'System.IO.StreamWriter' -ArgumentList $fout,$true
    $timeStamp = Get-Date

    $printStream.WriteLine("-----------------------------------")
    $printStream.WriteLine("| " + $fname + " - " +$timeStamp + " |")
    $printStream.WriteLine("-----------------------------------")

    $printStream.Close()
}

function PrintToScreen {
    param([string]$str)

    Write-Host $str
}

function Diag {
    param([Object]$parm)
    Write-Host "HERE"
    Write-Host $parm
}

$fname = GetFileName
TimeStampLog $fname
CleanFile $fname
Invoke-Item 'cleanFile-log.txt'
pause