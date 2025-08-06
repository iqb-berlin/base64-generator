param(
    [string]$SourcePath = "",
    [string]$TargetFileName = ".\base64.json"
)

function Convert-ToBase64 {
    param(
        [string]$FilePath
    )
    if (-not (Test-Path $FilePath)) {
        Write-Warning "Datei nicht gefunden: $FilePath"
        return ""
    }
    try {
        $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
        $mimeType = switch ($extension) {
            ".jpg"  { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".png"  { "image/png" }
            ".gif"  { "image/gif" }
            ".bmp"  { "image/bmp" }
            ".webp" { "image/webp" }
            ".mp3"  { "audio/mpeg" }
            ".wav"  { "audio/wav" }
            ".ogg"  { "audio/ogg" }
            ".m4a"  { "audio/mp4" }
            default { "" }
        }
        if ($mimeType -gt 0) {
            $paramKey = $mimeType.Substring(0,5) + "Source"
            $filename = [System.IO.Path]::GetFileName($FilePath)
            # $imageBytes = [System.IO.File]::ReadAllBytes($FilePath)
            # $base64String = [System.Convert]::ToBase64String($imageBytes)
            $base64String = "yoyo"
            $base65parameter = "data:$mimeType;base64,$base64String"
            $file = [ordered]@{
                $paramKey = $base65parameter
                filename = $filename
            }
            return $file
        } else {
            Write-Warning "Unbekannter Dateityp: $FilePath - ignoriere"
            return ""
        }
    }
    catch {
        Write-Error "Fehler beim Konvertieren zu Base64: $_"
        return ""
    }
}

Write-Host "=== IQB Transformation von Audio- und Bilddateien nach base64 ===" -ForegroundColor Cyan

if (($SourcePath -gt 0) -and (Test-Path $SourcePath)) {
    Write-Host "Starte Generieren Verzeichnis '$($SourcePath)'" -ForegroundColor Green
    Write-Host "Zieldatei '$($TargetFileName)'..." -ForegroundColor Green
    $Files = Get-ChildItem -Path $SourcePath

    $convertedFiles = @()
    for ($i = 0; $i -lt $Files.Length; $i++) {
        $FileToConvert = $Files[$i]
        $Index = $i + 1
        Write-Host "$Index : $FileToConvert"
        $file = Convert-ToBase64 -FilePath "$SourcePath\$FileToConvert"

        if (-not ($file.GetType() -eq [string])) {
            $convertedFiles += $file
        }
    }
    $myDate = Get-Date
    $output = [ordered]@{
        tool = "iqb-base64-generator"
        created = $myDate.ToString()
        files = $convertedFiles
    }
    $jsonOutput = $output | ConvertTo-Json -Compress:$false
    try
    {
        $jsonOutput | Out-File -FilePath $TargetFileName -Encoding UTF8
        Write-Host "$TargetFileName erzeugt."
    } catch
    {
        Write-Host ""
        Write-Host "❌ Fehler beim Speichern der Datei:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
    Write-Host "beendet."
} else {
    if ($SourcePath -gt 0) {
        Write-Host "Quellverzeichnis '$($SourcePath)' nicht gefunden!" -ForegroundColor Magenta
    } else {
        Write-Host "Bitte als Parameter das Quellverzeichnis angeben, in dem die Dateien liegen!" -ForegroundColor Magenta
    }
}
