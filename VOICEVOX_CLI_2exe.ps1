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
  Start-Process -Filepath Powershell.exe -ArgumentList '-command &{echo "VOICEVOX_CLI.ps1` [[-text]` `<String`>]` `[[-stylelist]` `<String`>]` `[[-style]` `<Int32`>]` `[[-vvoxhost]` `<String`>]` `[-save]` `[[-outpath]` `<String`>]` `[-overwrite]`n -text �ǂݏグ�e�L�X�g�̐ݒ��ݒ肵�܂��B �����K�{�̃p�����[�^�ł��B�p�����[�^�w�蕶����`(-text`)�͏ȗ��\�ł��B`n  -stylelist �X�^�C��`(speaker`)�̃��X�g���擾���܂��B �ȗ��\�ȃp�����[�^�ł��B���̃I�v�V�������L���ȏꍇ��text�p�����[�^�̏������s���܂���B`n -style �X�^�C����ݒ肵�܂��B �ȗ��\�ȃp�����[�^�ł��B�ȗ������ꍇ��id 3�̃X�^�C���𗘗p���܂��B`n -vvoxhost VOICEVOX���N�����Ă���z�X�g��IP�A�h���X�������̓z�X�g����ݒ肵�܂��B VOICEVOX` Engine` API�̃��N�G�X�g�ɗ��p���܂��B �ȗ��\�ȃp�����[�^�ł��B�ȗ������ꍇ��127.0.0.1�Ƀ��N�G�X�g���܂��B �z�X�g����ݒ肵���ꍇ��IPv6�̐ڑ��e�X�g�������Ēx���Ȃ�̂�IP�A�h���X�w��𐄏����܂��B`n -save �������������t�@�C����ۑ����܂��B �ȗ��\�ȃp�����[�^�ł��B�ȗ������ꍇ�͐������������t�@�C����ۑ����܂���B`n -outpath �������������t�@�C���̏o�͐�p�X��ݒ肵�܂��B �ȗ��\�ȃp�����[�^�ł��B�ȗ������ꍇ�̓e���|�����t�H���_�ɕۑ�����܂��B �ȗ������ꍇ�̃t�@�C������text�p�����[�^�Ŏw�肵��������ɂȂ�܂��B outpath�̃p�����[�^���f�B���N�g���������ꍇ���t�@�C������text�p�����[�^�Ŏw�肵��������ɂȂ�܂��B`n -overwrite outpath�Ɠ����̃t�@�C�������ɑ��݂��Ă���ꍇ�ɏ㏑�����܂��B �ȗ��\�ȃp�����[�^�ł��B�ȗ������ꍇ�͏㏑���m�F�̃_�C�A���O���o�܂��B`n "; pause}'  
  exit 0
}

if (-not ([string]::IsNullOrEmpty($stylelist))) {
  $sturi = "http://$vvoxhost"+":50021/speakers"
  $st = Invoke-WebRequest -Method Get -Uri $sturi -ContentType 'application/json'
  $stsearch = ([System.Text.Encoding]::UTF8.GetString( [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($st.Content) ) | ConvertFrom-Json) | where {$_.name -like "*$stylelist*"}
  if ($stsearch.length -ge 1) {
    for ($i = 0; $i -lt $stsearch.length; $i++) {
      $spsize = "` " * [Math]::Ceiling(($stsearch.styles.name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2 - 4 + 1)
      $stlist += $stsearch[$i].name + "`nname${spsize}id`n----$spsize--`n"
      for ($j=0; $j -lt $stsearch[$i].styles.id.length; $j++) {
        $spsize =  "` " * ([Math]::Ceiling(($stsearch.styles.name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2 + 3) - [Math]::Ceiling(($stsearch[$i].styles[$j].name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2) - [Math]::Ceiling(($stsearch[$i].styles[$j].id -as [System.String] |  ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum))
        $stlist += $stsearch[$i].styles[$j].name + "${spsize}" + $stsearch[$i].styles[$j].id + "`n"
      }
      $stlist += "`n"
    }
  }
  else {
    $spsize = "` " * [Math]::Ceiling(($stsearch.styles.name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2 - 4 + 1)
    $stlist += $stsearch.name + "`nname${spsize}id`n----$spsize--`n"
    for ($j=0; $j -lt $stsearch.styles.id.length; $j++) {
      $spsize =  "` " * ([Math]::Ceiling(($stsearch.styles.name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2 + 3) - [Math]::Ceiling(($stsearch.styles[$j].name | ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum * 2) - [Math]::Ceiling(($stsearch.styles[$j].id -as [System.String] |  ForEach-Object {$_.Length} | Measure-Object -Maximum).Maximum))
      $stlist += $stsearch.styles[$j].name + "${spsize}" + $stsearch.styles[$j].id + "`n"
    }
  }
  echo $stlist
  exit 0
}


if (([string]::IsNullOrEmpty($stylelist)) -and ([string]::IsNullOrEmpty($text))) {
  echo "���̃p�����[�^�[�ɒl���w�肵�Ă�������:"
  $text = Read-Host "text"
}

if ($save -eq $true) {
  if ([string]::IsNullOrEmpty($outpath)) {
    $outpath = [System.IO.Path]::GetTempPath() + $text + ".wav"
  }
  if ((Test-Path $outpath) -eq "True") {
    if ((Test-Path -PathType Leaf $outpath) -eq $true) {
      if ($overwrite -eq $false) {
        $title = "�㏑���m�F"
        $msg = $outpath + "���㏑�����܂����H"
        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "�㏑������"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "�㏑�����Ȃ�"
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
    New-Item -Path $outpath -Type File -Force > $null
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
    $streamlength = [Math]::Ceiling($mstream.Length / (384 * 1024 / 8))
    $tts = New-Object System.Media.SoundPlayer($mstream)
    $tts.Play()
    Start-Sleep -Seconds $streamlength
        if ($save -eq $true) {
      [System.IO.File]::WriteAllBytes($outpath, $mstream.ToArray())
    }
  }
  catch {
    Write-Host $_.Exception.Message
    exit 1
  }
}
speech
