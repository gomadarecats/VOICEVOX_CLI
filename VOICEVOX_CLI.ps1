Param(
  [parameter(mandatory=$true)][string]$text,
  [int32]$speaker = 1,
  [string]$vvoxhost = "127.0.0.1",
  [string]$outpath = [System.IO.Path]::GetTempPath()+"vvoxout_"+(Get-Date -Format "yyyymmdd_HHmmss")+".wav",
  [switch]$save
)
$testcon = Test-NetConnection $vvoxhost -Port 50021 -InformationLevel Quiet 3> OUT-Null
if ($testcon -eq $false) {
  echo "Can not connect to VOICEVOX host."
  exit 1
}

$aquri = "http://$vvoxhost"+":50021/audio_query?text=$text&speaker=$speaker"
$syuri = "http://$vvoxhost"+":50021/synthesis?speaker=$speaker"

function audio_query() {
  try {
    $fnaq = Invoke-WebRequest -Method Post -Uri $aquri -ContentType 'application/json'
    return ([System.Text.Encoding]::UTF8.GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($fnaq.Content) ) | ConvertFrom-Json)
  }
  catch {
    Write-Host $_.Exception.Message
    exit 1
  }
}
$aq = audio_query

function synthesis() {
  try {
    Invoke-RestMethod -Method Post -Uri $syuri -Body ($aq | ConvertTo-Json -Depth 5) -ContentType 'application/json' -OutFile $outpath
  }
  catch {
    Write-Host $_.Exception.Message
    exit 1
  }
}
synthesis

function tts() {
  $tts = New-Object Media.SoundPlayer "$outpath"
  $tts.Play()
  if ( $save -eq $fasle ){
    Remove-Item $outpath
  }
}
tts
