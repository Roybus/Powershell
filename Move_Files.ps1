#Setting the source and destionation
$source = "C:\Users\Curtis-Lee.Cleaver\Documents\Custom PS\SCC\New"
$destination = "C:\Users\Curtis-Lee.Cleaver\Desktop\Temp"

#Ask the user for the number of months they wish to back date to
[int]$months = Read-Host "Please enter a number of months..."

#Gets the date 9 months ago
$MoveDate = (Get-Date).AddMonths(-$months)

#Checks to see if CSV is there and removes if it is
$FileName = "c:\Users\$env:USERNAME\Desktop\raw.csv"
if (Test-Path $FileName) 
{
    Remove-Item $FileName
}

#Gets total file size of all files older than the months entered to the given day
Get-ChildItem -Path $source -Recurse | Where-Object { $_.LastAccessTime -lt $MoveDate } | Select-Object length | Export-Csv "c:\Users\$env:USERNAME\Desktop\raw.csv" -Append -NoTypeInformation

$csvfile = Import-Csv "c:\users\$env:USERNAME\Desktop\raw.csv"

$csvfile | group name | select length,@{Name="Totals";Expression={($_.group | Measure-Object -sum length).sum/1GB}}

#Moves all the files to the new destination - Keeping the same folderstructure
Get-ChildItem $source -Recurse | Where-Object { $_.CreationTime -lt $MoveDate } | `
    foreach{
        $targetDestination = $desination + $_.FullName.Substring($source.Length);
        New-Item -ItemType File -Path $targetDestination -Force;
        Move-Item $_.FullName -Destination $destination
    }
