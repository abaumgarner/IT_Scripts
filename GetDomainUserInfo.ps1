<#
    Author: Aaron Baumgarner
    Created: 7/27/20
    Updated: 7/27/20
    Notes: Generates domain user info based on the net user command. The script will then write the username, user's full name, 
        when the password was last set, and when the password expires to a csv file.
#>

$fin = Get-Content list.txt
$fout = 'userInfo.csv'
$printStream = [System.IO.StreamWriter] $fout
$str = "Username,Full Name,Password Last Set, Password Expires"
$printStream.WriteLine($str)
$numLines = $fin | Measure-Object -Line
$ctr = 0

while($ctr -lt $numLines.Lines) {
    if($numLines.Lines -eq 1) {
        $user = $fin
    }else{
        $user = $fin[$ctr]
    }
    $res = net user $user /domain
    $expire = $res[11].Replace('?','').Split()[14..16]
    $fullName = $res[3].Split()[21..22]
    $lastSet = $res[10].Replace('?','').Split()[14..16]

    $str = "$user,$fullName,$lastSet,$expire"

    $printStream.WriteLine($str)

    $ctr++
}

$printStream.Close()
Invoke-Item $fout