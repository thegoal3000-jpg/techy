param(
    [string]$DocUrl,
    [int]$WordsPerMinute = 60,
    [int]$StartDelaySeconds = 3
)

Add-Type -AssemblyName System.Windows.Forms

if (-not $DocUrl) {
    $DocUrl = Read-Host "Paste your Google Doc address"
}

if (-not $DocUrl) {
    Write-Host "No Google Doc address was entered."
    exit 1
}

$text = Get-Clipboard -Raw

if (-not $text) {
    Write-Host "Your clipboard is empty. Copy the text you want typed, then run this script again."
    exit 1
}

$charactersPerSecond = ($WordsPerMinute * 5) / 60
$delayMilliseconds = [Math]::Max(1, [int](1000 / $charactersPerSecond))

Start-Process $DocUrl

Write-Host "Google Doc opened."
Write-Host "Click inside the Google Doc where you want the text to appear."
Write-Host "Typing starts in $StartDelaySeconds seconds..."
Start-Sleep -Seconds $StartDelaySeconds

function Send-TextCharacter {
    param([char]$Character)

    $value = [string]$Character

    switch ($value) {
        "`r" { return }
        "`n" {
            [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
            return
        }
        "`t" {
            [System.Windows.Forms.SendKeys]::SendWait("{TAB}")
            return
        }
    }

    if ($value -eq "{") {
        [System.Windows.Forms.SendKeys]::SendWait("{{}")
    } elseif ($value -eq "}") {
        [System.Windows.Forms.SendKeys]::SendWait("{}}")
    } elseif ("+^%~()".Contains($value)) {
        [System.Windows.Forms.SendKeys]::SendWait("{$value}")
    } else {
        [System.Windows.Forms.SendKeys]::SendWait($value)
    }
}

foreach ($character in $text.ToCharArray()) {
    Send-TextCharacter $character
    Start-Sleep -Milliseconds $delayMilliseconds
}

Write-Host "Done typing."
