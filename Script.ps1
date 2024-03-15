function ProcessUrl {
    param (
        [string]$url
    )
    Write-Host "Current URL: $url"
    
    # Check if URL is from Spotify
    if ($url -match "spotify.com") {
        Write-Host "Downloading from Spotify: $url"
        # Use spotdl for Spotify URLs
        $spotDlCommand = "spotdl"
        $spotDlArgs = @(
            "$url",
            "--output", "$DownloadFolder\%(title)s.%(ext)s"
        )
        & $spotDlCommand $spotDlArgs
    }
    else {
        Write-Host "Downloading: $url"
        # Use yt-dlp for non-Spotify URLs
        $ytDlpCommand = "yt-dlp"
        
        # Check if default format is in audio mode
        if ($DefaultFormatInfo -eq "audio") {
            $ytDlpArgs = @(
                "-x", "--audio-format", "mp3", "--embed-thumbnail", "--audio-quality", "0",
                "--output", "$DownloadFolder\%(title)s.%(ext)s",
                "$url"
            )
        } else {
            $ytDlpArgs = @(
                "-f", "bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4",
                "--merge-output-format", "mp4",
                "--output", "$DownloadFolder\%(title)s.%(ext)s",
                "$url"
            )
        }
        
        & $ytDlpCommand $ytDlpArgs




	}
	Set-Clipboard
    $script:LastUrl = $url
}
function MonitorClipboard {
    while ($true) {
        try {
            Write-Host "Monitoring clipboard for URL..."
            $url = Get-Clipboard
            if (-not [string]::IsNullOrWhiteSpace($url)) {
                ProcessUrl $url
            }
            Start-Sleep -Seconds 2 # Check every 2 seconds
        } catch {
            Write-Host "An error occurred: $_"
            Start-Sleep -Seconds 2 # Wait before retrying

        }
    }
}


# Set your folders
$Mp3folder = "C:\Musique"
$Videofolder = "C:\Videos"
$DownloadFolder = $Mp3folder
$DefaultFormatInfo = "audio"
$DefaultFormat = "-x --audio-format mp3 --embed-thumbnail --audio-quality 0"

while ($true) {
    Clear-Host
    Write-Host "1. Use clipboard URL"
    Write-Host "2. Enter URL manually"
    Write-Host "3. Choose format (Currently: $DefaultFormatInfo)"
    Write-Host "4. Exit"
    $choice = Read-Host "Choose an option (1-4)"
    
    switch ($choice) {
        "1" {
            do {
               MonitorClipboard
            } while ($true)
        }
        "2" {
            do {
                $url = Read-Host "Enter the URL (type 'menu' to return to the main menu)"
                if ($url -eq 'menu') { break }
                ProcessUrl $url
            } while ($true)
        }
        "3" {
            do {
                Write-Host "Choose format:"
                Write-Host "1. Audio"
                Write-Host "2. Video"
                Write-Host "3. Back to menu"
                $formatChoice = Read-Host "Choose format (1-2, default is Audio)"
                if ($formatChoice -eq "1") {
                    $DefaultFormat = "-x --audio-format mp3 --embed-thumbnail --audio-quality 0"
                    Write-Host "Set to Audio"
                    $DefaultFormatInfo = "audio"
                    $DownloadFolder = $Mp3folder
                    break
                } elseif ($formatChoice -eq "2") {
                    $DefaultFormat = "-f bestvideo+bestaudio --merge-output-format mp4"
                    Write-Host "Set to Video"
                    $DefaultFormatInfo = "video"
                    $DownloadFolder = $Videofolder
                    break
                } elseif ($formatChoice -eq "3") {
                    break
                } else {
                    Write-Host "Invalid format option, please try again."
                }
            } while ($true)
        }
        "4" {
            Write-Host "Exiting..."
            return
        }
        default {
            Write-Host "Invalid option, please choose again."
        }
    }
}
