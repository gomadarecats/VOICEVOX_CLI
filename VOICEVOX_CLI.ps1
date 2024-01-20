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
        省略可能なパラメータです。このオプションが有効な場合はtextパラメータの処理が行われません。

    .PARAMETER style
        スタイルを設定します。
        省略可能なパラメータです。省略した場合はid 3のスタイルを利用します。

    .PARAMETER vvoxhost
        VOICEVOXを起動しているホストのIPアドレスもしくはホスト名を設定します。
        VOICEVOX Engine APIのリクエストに利用します。
        省略可能なパラメータです。省略した場合は127.0.0.1にリクエストします。
        ホスト名を設定した場合はIPv6の接続テストが走って遅くなるのでIPアドレス指定を推奨します。

    .PARAMETER save
        生成した音声ファイルを保存します。
        省略可能なパラメータです。省略した場合は生成した音声ファイルを保存しません。

    .PARAMETER outpath
        生成した音声ファイルの出力先パスを設定します。
        省略可能なパラメータです。省略した場合はテンポラリフォルダに保存されます。
        省略した場合のファイル名はtextパラメータで指定した文字列になります。
        outpathのパラメータがディレクトリだった場合もファイル名はtextパラメータで指定した文字列になります。

    .PARAMETER overwrite
        outpathと同名のファイルが既に存在している場合に上書きします。
        省略可能なパラメータです。省略した場合は上書き確認のダイアログが出ます。

    .PARAMETER help
        ヘルプを表示します。

    .EXAMPLE
        VOICEVOX_CLI.ps1 exampletext
        id 3のスタイルで"exampletext"を読み上げます。

    .EXAMPLE
        VOICEVOX_CLI.ps1 -stylelist example
        exampleにマッチする名前(キャラクター)のスタイルの一覧を出力します。
 
    .EXAMPLE
        VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -save -outpath C:\
        127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信して再生します。
        生成した音声ファイルをC:\exampletext.wavに保存します。
        C:\exampletext.wavが既に存在している場合は上書き確認のダイアログが出ます。

    .EXAMPLE
        VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -save -outpath C:\output.wav -overwrite
        127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信して再生します。
        生成した音声ファイルをC:\output.wavに保存します。
        C:\output.wavが既に存在している場合は上書きします。

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
  [switch]$save,
  [string]$outpath,
  [switch]$overwrite,
  [switch]$help
)

if ($help -eq $true) {
  Get-Help $PSCommandPath -Detailed
  exit 0
}

if ((Test-NetConnection $vvoxhost -Port 50021 -InformationLevel Quiet 3> OUT-Null) -eq $false) {
  echo "Can not connect to VOICEVOX host."
  exit 1
}

if (-not ([string]::IsNullOrEmpty($stylelist))) {
  $sturi = "http://$vvoxhost"+":50021/speakers"
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


if ($save -eq $true) {
  if ([string]::IsNullOrEmpty($outpath)) {
    $outpath = [System.IO.Path]::GetTempPath() + $text + ".wav"
  }
  if ((Test-Path $outpath) -eq "True") {
    if ((Test-Path -PathType Leaf $outpath) -eq $true) {
      if ($overwrite -eq $false) {
        $title = "上書き確認"
        $msg = $outpath + "を上書きしますか？"
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "上書きする"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "上書きしない"
        $opts = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $res = $host.ui.PromptForChoice($title, $msg, $opts, 1)
        switch ($res)
        {
            1 {$outpath = $outpath+"_"+(Get-Date -Format "yyyymmdd_HHmmss")+".wav"}
        }
      }
    }
    else {
      $outpath = $outpath + "\" + $text + ".wav"
    }
  }
  else {
    New-Item -Path $outpath -Type File -Force | Out-Null
  }
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

function synthesis() {
  try {
    $fnsy = Invoke-RestMethod -Method Post -Uri $syuri -Body (audio_query | ConvertTo-Json -Depth 5) -ContentType 'application/json'
    return [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($fnsy)
  }
  catch {
    Write-Host $_.Exception.Message
    exit 1
  }
}
$synthe = synthesis

function speech() {
  try {
    $mstream = New-Object System.IO.MemoryStream($synthe, 0, $synthe.Length)
    $tts = New-Object System.Media.SoundPlayer($mstream)
    $tts.Play()
    if ($save -eq $true) {
      echo "save to:" $outpath
      [System.IO.File]::WriteAllBytes($outpath, $mstream.ToArray())
    }
  }
  catch {
    Write-Host $_.Exception.Message
    exit 1
  }
}
speech
