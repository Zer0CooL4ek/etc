# ICRC — "Indicators of Compromise in Regional Courts"
# Define the path to the log file on the network share
$logFilePath = "\\path\to\your\network\share\file_check_log.txt"

# Function to write logs with file locking
function Write-Log {
    param (
        [string]$message
    )
    
    # Attempt to open the file for writing with locking
    $fileStream = [System.IO.File]::Open($logFilePath, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $writer = New-Object System.IO.StreamWriter($fileStream)
    
    try {
        # Write the timestamp, computer name, and message
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $computerName = $env:COMPUTERNAME
        $writer.WriteLine("[$timestamp] [$computerName] $message")
        $writer.Flush()
    }
    finally {
        # Close the stream to release the file lock
        $writer.Close()
        $fileStream.Close()
    }
}

# List of paths to check
$paths = @(
    "C:\Windows\System32\wuse.exe",
    "C:\Windows\System32\wusi.exe",
    "C:\Windows\System32\mstcv.exe",
    "C:\Windows\System32\msvcf.exe",
    "C:\Windows\System32\mscte.exe",
    "C:\Windows\System32\firefoxer.exe",
    "C:\Windows\PSEXESVC.EXE",
    "C:\windows\syswow64\sstray64.exe",
    "C:\windows\syswow64\sstray.exe",
    "C:\windows\syswow64\ltprx\ntcontrolsvc.exe",
    "C:\programdata\adobe\adobe.exe",
    "C:\intel\telegram\updater.exe",
    "C:\intel\telegram\telegram.exe",
    "C:\Users\Public\tivoli.exe"
)

# Add user-specific paths
$users = Get-ChildItem "C:\Users" | Where-Object { $_.PSIsContainer -and $_.Name -notmatch "Public|Default" }
foreach ($user in $users) {
    $paths += "C:\Users\$($user.Name)\appdata\local\adobe\arm\diagtrack.exe"
    $paths += "C:\Users\$($user.Name)\appdata\local\vmware\vmclient.exe"
    $paths += "C:\Users\$($user.Name)\AppData\Local\msedge.exe"
}

# Check each path for existence and delete if found
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Log "File exists: $path"
        # Forcefully remove the file and log the deletion
        Remove-Item -Path $path -Force
        Write-Log "File deleted: $path"
    } else {
        Write-Log "File not found: $path"
    }
}

# Regular expression for numeric files in C:\Windows
$regex = '^[0-9]{6,10}\.[0-9]{6,8}$'

# Check files in C:\Windows against the regular expression
$files = Get-ChildItem "C:\Windows" | Where-Object { $_.Name -match $regex }

# Log and delete matching files
if ($files) {
    foreach ($file in $files) {
        Write-Log "Found file matching pattern: $($file.FullName)"
        # Forcefully remove the file and log the deletion
        Remove-Item -Path $file.FullName -Force
        Write-Log "File deleted: $($file.FullName)"
    }
} else {
    # Log details when no files match the pattern
    Write-Log "No files matching pattern '^[0-9]{6,10}\.[0-9]{6,8}$' (numeric name with extension) found in C:\Windows"
}
