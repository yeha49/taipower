param(
    [int]$StartNumber = 0,
    [string]$Prefix = ""
)

$clipboardFiles = Get-Clipboard -Format FileDropList
if ($clipboardFiles) {
    $tempFiles = foreach ($file in $clipboardFiles) {
        if (-not $file.PSIsContainer) {
            $tempName = "temp_" + [guid]::NewGuid().ToString() + $file.Extension
            $tempPath = Join-Path $file.DirectoryName $tempName
            Rename-Item -LiteralPath $file.FullName -NewName $tempName
            [PSCustomObject]@{
                Path = $tempPath
                Extension = $file.Extension
                OriginalName = $file.Name
                Directory = $file.DirectoryName
            }
        }
    }

    $index = $StartNumber
    foreach ($item in $tempFiles) {
        $num = "{0:D3}" -f $index
        $newName = if ([string]::IsNullOrEmpty($Prefix)) { "$num$($item.Extension)" } else { "${Prefix}_${num}$($item.Extension)" }
        $newFullPath = Join-Path $item.Directory $newName

        if (Test-Path $newFullPath) {
            Remove-Item $newFullPath -Force
        }

        Rename-Item -LiteralPath $item.Path -NewName $newName
        Write-Host "已重新命名: $($item.OriginalName) -> $newName" -ForegroundColor Cyan
        $index++
    }
    Write-Host "`n全部完成！共重新命名了 $($index - $StartNumber) 個檔案。" -ForegroundColor Green
} else {
    Write-Host "錯誤：剪貼簿中沒有找到檔案，請確認剛剛是否有在檔案總管按 Ctrl+C。" -ForegroundColor Red
}