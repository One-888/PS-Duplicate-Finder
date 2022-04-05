$src = @("C:\All Photos")  # Can check multiple folders seperate by comma
$dup = "C:\Dup" # Export File if you want it to export 

$ftype = "*.*" 
# Check file Dup by checking the file size - Setp 2
$a = gci -Path $src -Filter $ftype -Recurse -File | `
Where-Object { $_.Length -gt 1mb} | Group-Object -Property Length | `
Where-Object { $_.Count -gt 1 -and $_.Length -gt 0 } |  Select -ExpandProperty Group |  % {$_.FullName}  

# Export Directory
mkdir $dup -ErrorAction SilentlyContinue

# Using Has Funxtion to check duplicate file - Step 2 
# Show result in csv file
$a | %{Get-filehash $_.ToString() -Algorithm SHA1}  | `
Group-Object -Property Hash | `
Where-Object { $_.Count -gt 1 } | `
Select -ExpandProperty group | select hash,@{name="Move";expression={"Move-Item -Destination ""$dup"" """ + $_.path+""""}} | `
Export-Csv -Path ($dup + "\Dup_Result.csv") -NoTypeInformation
