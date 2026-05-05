$dest = 'c:\Users\PC\Desktop\cargos\apps\landing\src\assets\partners'
Set-Location $dest
$logos = [ordered]@{
  'artel'    = 'artel.uz'
  'akfa'     = 'akfagroup.com'
  'roison'   = 'roison.uz'
  'uzauto'   = 'uzautomotors.com'
  'chevrolet'= 'www.chevrolet.uz'
  'imzo'     = 'imzo.uz'
  'bekobod'  = 'bekabadcement.uz'
  'olmaliq'  = 'agmk.uz'
  'korzinka' = 'korzinka.uz'
  'makro'    = 'makro.uz'
  'havas'    = 'havas.uz'
  'texnomart'= 'texnomart.uz'
  'click'    = 'click.uz'
  'payme'    = 'payme.uz'
  'humo'     = 'humocard.uz'
  'uzcard'   = 'uzcard.uz'
  'beeline'  = 'beeline.uz'
  'uzum'     = 'uzum.uz'
}
foreach ($k in $logos.Keys) {
  $d = $logos[$k]
  $f = Join-Path $dest "$k.png"
  $tmp = Join-Path $dest "_t.bin"
  $best = 0
  $sources = @(
    "https://$d/apple-touch-icon.png",
    "https://$d/apple-touch-icon-precomposed.png",
    "https://$d/static/apple-touch-icon.png",
    "https://$d/favicon.png",
    "https://www.google.com/s2/favicons?domain=$d&sz=256",
    "https://icons.duckduckgo.com/ip3/$d.ico"
  )
  foreach ($u in $sources) {
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    & curl.exe -sL --max-time 12 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -o $tmp $u 2>$null
    if (-not (Test-Path $tmp)) { continue }
    $sz = (Get-Item $tmp).Length
    if ($sz -lt 600) { continue }
    $bytes = [System.IO.File]::ReadAllBytes($tmp)
    if ($bytes.Length -lt 8) { continue }
    $isPng = ($bytes[0] -eq 137 -and $bytes[1] -eq 80 -and $bytes[2] -eq 78 -and $bytes[3] -eq 71)
    $isIco = ($bytes[0] -eq 0 -and $bytes[1] -eq 0 -and ($bytes[2] -eq 1 -or $bytes[2] -eq 2))
    if (($isPng -or $isIco) -and $sz -gt $best) {
      Copy-Item $tmp $f -Force
      $best = $sz
    }
  }
  if (Test-Path $tmp) { Remove-Item $tmp -Force }
  if ($best -eq 0) { Write-Host "MISS $k ($d)" -ForegroundColor Red }
  else { Write-Host "OK   $k.png  $best  ($d)" -ForegroundColor Green }
}
Write-Host "---"
Get-ChildItem $dest *.png | Sort-Object Length -Desc | Format-Table Name,Length -Auto
