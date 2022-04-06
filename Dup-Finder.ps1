$i = 0
Write-Progress -Activity "Caluating.." -PercentComplete 5

$src = @("C:\Users") #"F:\All Photos"
$dup = "C:\Users\VSayakanit\OneDrive - Pittsburgh Water and Sewer Authority\Dup"

$ftype = "*.zip" 

$a = gci -Path $src -Filter $ftype -Recurse  -File  -ErrorAction SilentlyContinue | `
Where-Object { $_.Length -gt 1kb} | Group-Object -Property Length | `
Where-Object { $_.Count -gt 1 } |  Select -ExpandProperty Group | `
 % {$_.FullName}  # Check file Dup by checking the file size - Setp 1

mkdir $dup -ErrorAction SilentlyContinue # Export Directory
$stat = $a.Count

$a | %{                                   `
 $i = $i + 1; $pct = [math]::Round(($i / $stat)*100); `
Write-Progress -Activity "Caluating.." -PercentComplete $pct;   `
Get-filehash $_.ToString() -Algorithm SHA1}  | `
Group-Object -Property Hash | `
Where-Object { $_.Count -gt 1 -and $_.Group -like "@{*" } | `
Select -ExpandProperty group | select hash,@{name="File";expression={split-path  $_.path -leaf}},@{name="Move";expression={"Move-Item -Destination ""$dup"" """ + $_.path+""""}}

$export_text | select hash,File | Format-Table -AutoSize -Wrap
#$export_text | Export-Csv -Path ($dup + "\Dup.csv") -NoTypeInformation # Using Hash Function to check duplicate file - Step 2 

$move_text = $export_text | Group-Object -property {$_.hash } | Where-Object { $_.Count -gt 1}  | ` 
% { """" + $_.Group[0].Path + """" } # | Format-Table -AutoSize - # $_.Group[0].Hash + ", """ + $_.Group[0].File+ """, """ + $_.Group[0].Path+ """"

"`nInvoke-Item Section"
$export_text | % {"ii """ + (split-Path -Path $_.path).ToString() + """" }

"`nMove-Item Section"
$move_text | % {"mv -Destination ""$dup"" """ + $_ + """" }

