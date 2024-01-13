# VOICEVOX_CLI
CLIからVOICEVOXの音声を生成、再生する

VOICEVOXは起動させておく必要があります。
### Usage
```
<path>\VOICEVOX_CLI.ps1 exampletext
<path>\VOICEVOX_CLI.ps1 -stylelist example
<path>\VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -outpath C:\output.wav -save
```
```
OPTIONS
-text[string]          : 必須(-textは省略可能), 生成するテキストを入力
-stylelist[string]     : 省略可, キャラクター名にマッチするスタイルの一覧を表示
-style[int32]          : 省略可, スタイル番号, デフォルト値は3
-vvoxhost[string]      : 省略可, VOICEVOXを動かしているホストのIPアドレス, デフォルト値は127.0.0.1
-outpath[string]       : 省略可, 保存先パス(saveオプション必須), デフォルト値は [System.IO.Path]::GetTempPath()
-save[SwitchParameter] : 省略可, outpathに保存する, デフォルト値はなし(false), -saveだけでtrueになる
-help[SwitchParameter] : 省略可, ヘルプを表示
```

## Dockerfile
VOICEVOXサーバ用

//IPアドレスは変数で食わせたい……
```
docker run -d --network <network> --ip 172.18.50.21 -p 50021:50021 tag/image
```
