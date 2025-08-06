param(
    [string]$SourcePath = "",
    [string]$TargetFileName = ".\base64.json"
)

function Convert-ImageToBase64 {
    param(
        [string]$ImagePath
    )
    if (-not (Test-Path $ImagePath)) {
        Write-Warning "Bilddatei nicht gefunden: $ImagePath"
        return ""
    }
    try {
        $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
        $base64String = [System.Convert]::ToBase64String($imageBytes)

        $extension = [System.IO.Path]::GetExtension($ImagePath).ToLower()
        $mimeType = switch ($extension) {
            ".jpg"  { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".png"  { "image/png" }
            ".gif"  { "image/gif" }
            ".bmp"  { "image/bmp" }
            ".webp" { "image/webp" }
            default { "image/png" }
        }

        return "data:$mimeType;base64,$base64String"
    }
    catch {
        Write-Error "Fehler beim Konvertieren des Bildes zu Base64: $_"
        return ""
    }
}

function Convert-AudioToBase64 {
    param(
        [string]$AudioPath
    )

    if (-not (Test-Path $AudioPath)) {
        Write-Warning "Audiodatei nicht gefunden: $AudioPath"
        return ""
    }

    try {
        $audioBytes = [System.IO.File]::ReadAllBytes($AudioPath)
        $base64String = [System.Convert]::ToBase64String($audioBytes)

        $extension = [System.IO.Path]::GetExtension($AudioPath).ToLower()
        $mimeType = switch ($extension) {
            ".mp3"  { "audio/mpeg" }
            ".wav"  { "audio/wav" }
            ".ogg"  { "audio/ogg" }
            ".m4a"  { "audio/mp4" }
            default { "audio/mpeg" }
        }

        return "data:$mimeType;base64,$base64String"
    }
    catch {
        Write-Error "Fehler beim Konvertieren der Audiodatei zu Base64: $_"
        return ""
    }
}

Write-Host "=== IQB Transformation von Audio- und Bilddateien nach base64 ===" -ForegroundColor Cyan

if (($SourcePath -gt 0) -and (Test-Path $SourcePath)) {
    Write-Host "Starte Generieren Verzeichnis '$($SourcePath)'" -ForegroundColor Green
    Write-Host "Zieldatei '$($TargetFileName)'..." -ForegroundColor Green
} else {
    if ($SourcePath -gt 0) {
        Write-Host "Quellverzeichnis '$($SourcePath)' nicht gefunden!" -ForegroundColor Magenta
    } else {
        Write-Host "Bitte als Parameter das Quellverzeichnis angeben, in dem die Dateien liegen!" -ForegroundColor Magenta
    }
}
