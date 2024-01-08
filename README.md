# VOICEVOX_CLI
CLIからVOICEVOXの音声を生成、再生する
### Usage
```
<path>\VOICEVOX_CLI.ps1 exampletext [OPTION]
<path>\VOICEVOX_CLI.ps1 -text exampletext -speaker 1 -vvoxhost 127.0.0.1 -outpath C:\User\<name>\Desktop\output.wav -save
```
```
OPTIONS
-text[string]     必須(-textは省略可能), 生成するテキストを入力
-speaker[int]     省略可, キャラクター番号？, デフォルト値は1
-vvoxhost[string] 省略可, VOICEVOXを動かしているホストのIPアドレス, デフォルト値はlocalhost
-outpath[string]  省略可, 保存先パス(saveオプション必須), デフォルト値は [System.IO.Path]::GetTempPath()
-save[boolean]　  省略可, outpathに保存する, デフォルト値はなし(false)
```

## Dockerfile
VOICEVOXサーバ用
IPアドレスは変数で食わせたい……
```
docker run -d --network <network> --ip <IPaddress> -p 50021:50021 tag/image
```
