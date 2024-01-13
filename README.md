# VOICEVOX_CLI
概要

    WindowsのCLI(PowerShell)からVOICEVOXでテキストを読み上げるスクリプトです。


構文

    VOICEVOX_CLI.ps1 [[-text] <String>] [[-stylelist] <String>] [[-style] <Int32>] [[-vvoxhost] <String>] [[-outpath] <String>] [-save] [-help]


説明

    VOICEVOX Engine API を利用してテキストを読み上げます。


パラメーター

    -text <String>
        読み上げテキストの設定を設定します。
        原則必須のパラメータです。パラメータ指定文字列(-text)は省略可能です。

    -stylelist <String>
        スタイル(speaker)のリストを取得します。
        省略可能なパラメータです。このオプションが有効な場合は text パラメータの処理が行われません。

    -style <Int32>
        スタイルを設定します。
        省略可能なパラメータです。省略した場合はid 3のスタイルを利用します。

    -vvoxhost <String>
        VOICEVOXを起動しているホストのIPアドレスを設定します。
        VOICEVOX Engine APIのリクエストに利用します。
        省略可能なパラメータです。省略した場合は127.0.0.1にリクエストします。

    -outpath <String>
        生成した音声ファイルの出力先パスを設定します。
        省略可能なパラメータです。省略した場合はテンポラリフォルダに保存されます。

    -save [<SwitchParameter>]
        生成した音声ファイルを保存します。
        省略可能なパラメータです。省略した場合は生成した音声ファイルを保存しません。

    -help [<SwitchParameter>]
        ヘルプを表示します。

### Usage
```
<path>\VOICEVOX_CLI.ps1 exampletext
    id 3のスタイルで"exampletext"を読み上げます。

<path>\VOICEVOX_CLI.ps1 -stylelist example
    exampleにマッチする名前(キャラクター)のスタイルの一覧を出力します。

<path>\VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -outpath C:\output.wav -save
    127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信します。
    生成した音声ファイルをC:\output.wavに保存します。
```

## Dockerfile
VOICEVOXサーバ用

//IPアドレスは変数で食わせたい……
```
docker run -d --network <network> --ip 172.18.50.21 -p 50021:50021 tag/image
```
