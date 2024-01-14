<#
    .SYNOPSIS
        WindowsのCLI(PowerShell)からVOICEVOXでテキストを読み上げるスクリプトです。

    .DESCRIPTION
        VOICEVOX Engine API を利用してテキストを読み上げます。

    .PARAMETER text
        読み上げテキストの設定を設定します。
        原則必須のパラメータです。パラメータ指定文字列(-text)は省略可能です。

    .PARAMETER stylelist
        スタイル(speaker)のリストを取得します。
        省略可能なパラメータです。このオプションが有効な場合は text パラメータの処理が行われません。

    .PARAMETER style
        スタイルを設定します。
        省略可能なパラメータです。省略した場合はid 3のスタイルを利用します。

    .PARAMETER vvoxhost
        VOICEVOXを起動しているホストのIPアドレスを設定します。
        VOICEVOX Engine APIのリクエストに利用します。
        省略可能なパラメータです。省略した場合は127.0.0.1にリクエストします。

    .PARAMETER outpath
        生成した音声ファイルの出力先パスを設定します。
        省略可能なパラメータです。省略した場合はテンポラリフォルダに保存されます。

    .PARAMETER save
        生成した音声ファイルを保存します。
        省略可能なパラメータです。省略した場合は生成した音声ファイルを保存しません。

    .PARAMETER help
        ヘルプを表示します。

    .EXAMPLE
        VOICEVOX_CLI.ps1 exampletext
        id 3のスタイルで"exampletext"を読み上げます。

    .EXAMPLE
        VOICEVOX_CLI.ps1 -stylelist example
        exampleにマッチする名前(キャラクター)のスタイルの一覧を出力します。
 
    .EXAMPLE
        VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -outpath C:\output.wav -save
        127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信して再生します。
        生成した音声ファイルをC:\output.wavに保存します。

    .LINK
        https://github.com/gomadarecats/VOICEVOX_CLI
        https://github.com/VOICEVOX/voicevox_engine
        https://voicevox.github.io/voicevox_engine/api/
#>

Param(
  [string]$text,
  [string]$stylelist,
  [int32]$style = 3,
  [string]$vvoxhost = "127.0.0.1",
  [string]$outpath = [System.IO.Path]::GetTempPath()+"vvoxout_"+(Get-Date -Format "yyyymmdd_HHmmss")+".wav",
  [switch]$save,
  [switch]$help
)

if ($help -eq $true) {
  Get-Help $PSCommandPath -Detailed
  exit 0
}

$testcon = Test-NetConnection $vvoxhost -Port 50021 -InformationLevel Quiet 3> OUT-Null
if ($testcon -eq $false) {
  echo "Can not connect to VOICEVOX host."
  exit 1
}

$sturi = "http://$vvoxhost"+":50021/speakers"
if (-not ([string]::IsNullOrEmpty($stylelist))) {
  $st = Invoke-WebRequest -Method Get -Uri $sturi -ContentType 'application/json'
  $stsearch = ([System.Text.Encoding]::UTF8.GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($st.Content) ) | ConvertFrom-Json) | where {$_.name -like "*$stylelist*"}
  if ($stsearch.length -ge 1) {
    for ($i = 0; $i -lt $stsearch.length; $i++) {
      echo $stsearch[$i].name
      if ($i -ge 1) {
        $spsize = "` " * [Math]::Ceiling(($stsearch.styles.name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2 - 4 + 1)
        echo "`nname${spsize}id`n----$spsize--"
      }
      echo $stsearch[$i].styles`r
    }
  }
  else {
    echo $stsearch.name $stsearch.styles
  }
  exit 0
}

if (([string]::IsNullOrEmpty($stylelist)) -and ([string]::IsNullOrEmpty($text))) {
  echo "次のパラメーターに値を指定してください:"
  $text = Read-Host "text"
}

$aquri = "http://$vvoxhost"+":50021/audio_query?text=$text&speaker=$style"
$syuri = "http://$vvoxhost"+":50021/synthesis?speaker=$style"

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
