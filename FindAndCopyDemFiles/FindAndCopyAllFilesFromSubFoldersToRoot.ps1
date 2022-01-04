Function Get-Folder($initialDirectory = "") {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.ShowNewFolderButton = $false
    $foldername.SelectedPath = $initialDirectory

    if ($foldername.ShowDialog() -eq "OK") {
        $folder += $foldername.SelectedPath
    }
    else {
        Exit 1
    }

    return $folder
}

Write-Host "Welcome to the Super Copy 2000, please choose a folder" -ForegroundColor Green

$directory = Get-Folder(Get-Location)

if (-not(test-path $directory)) {
    Write-host "Invalid directory path, re-enter."
    $directory = $null
}
elseif (-not (get-item $directory).psiscontainer) {
    Write-host "Target must be a directory, re-enter."
    $directory = $null
}
Write-Host ""
Write-Host "Located the following files in $directory"

$files = Get-ChildItem -Path $directory -Recurse -Filter "*.*" -File | Where-Object { $_.DirectoryName -ne $directory } | sort-object -Property Name

Write-Host ""

$files | ForEach-Object {
    Write-Host $_.FullName.Substring($directory.Length + 1) -ForegroundColor Red
}

Write-Host ""
$answer = Read-Host -Prompt "Copy these files to $directory\? (Y/N)"

if ($answer -eq "Y" -or $answer -eq "y") {
    Write-Host "Copying files..." -ForegroundColor Green
    $files.FullName | Copy-Item -Destination $directory -Force
    Write-Host "Done!" -ForegroundColor Green
}
else {
    Write-Host "Exiting..." -ForegroundColor Red
}

