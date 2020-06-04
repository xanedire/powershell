#reads from csv, deletes line by line
#csv needs literal path

$files = Get-Content "$PSScriptRoot\delete.csv"

foreach ($file in $files) {
    Write-Host "deleting $file"
   # gci $file
    Remove-Item -Path $file -force
    }