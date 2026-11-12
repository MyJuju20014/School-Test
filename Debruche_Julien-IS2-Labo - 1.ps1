$desktop = [System.Environment]::GetFolderPath("Desktop") #get the desktop environment as a variable
$filename = Read-Host "what's the name of your file to search ?" #get thefilename the user wants

#waits for key press function
function waitForKeyPress{ 
    Write-Host "Press any key to close the program"
    [Console]::ReadKey($true)
}

#pipeline to get children from the desktop -> find the right basename -> display it
Get-ChildItem -Path $desktop | Where-Object {$_.BaseName -eq "$filename"} | ForEach-Object {Write-Host "I found $($_.name)"}
waitForKeyPress