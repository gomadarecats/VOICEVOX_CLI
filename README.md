# VOICEVOX_CLI
概要

    WindowsのCLI(PowerShell)からVOICEVOXでテキストを読み上げるスクリプトです。


構文

    VOICEVOX_CLI.ps1 [[-text] <String>] [[-stylelist] <String>] [[-style] <Int32>] [[-vvoxhost] <String>] [-save] [[-outpath] <String>] [-overwrite] [-help]


説明

    VOICEVOX Engine API を利用してテキストを読み上げます。


パラメーター

    -text <String>
        読み上げテキストの設定を設定します。
        原則必須のパラメータです。パラメータ指定文字列(-text)は省略可能です。

    -stylelist <String>
        スタイル(speaker)のリストを取得します。
        省略可能なパラメータです。このオプションが有効な場合はtextパラメータの処理が行われません。

    -style <Int32>
        スタイルを設定します。
        省略可能なパラメータです。省略した場合はid 3のスタイルを利用します。

    -vvoxhost <String>
        VOICEVOXを起動しているホストのIPアドレスもしくはホスト名を設定します。
        VOICEVOX Engine APIのリクエストに利用します。
        省略可能なパラメータです。省略した場合は127.0.0.1にリクエストします。
        ホスト名を設定した場合はIPv6の接続テストが走って遅くなるのでIPアドレス指定を推奨します。

    -save [<SwitchParameter>]
        生成した音声ファイルを保存します。
        省略可能なパラメータです。省略した場合は生成した音声ファイルを保存しません。

    -outpath <String>
        生成した音声ファイルの出力先パスを設定します。
        省略可能なパラメータです。省略した場合はテンポラリフォルダに保存されます。
        省略した場合のファイル名はtextパラメータで指定した文字列になります。
        outpathのパラメータがディレクトリだった場合もファイル名はtextパラメータで指定した文字列になります。

    -overwrite [<SwitchParameter>]
        outpathと同名のファイルが既に存在している場合に上書きします。
        省略可能なパラメータです。省略した場合は上書き確認のダイアログが出ます。

    -help [<SwitchParameter>]
        ヘルプを表示します。

### Usage
```
<path>\VOICEVOX_CLI.ps1 exampletext
    id 3のスタイルで"exampletext"を読み上げます。

<path>\VOICEVOX_CLI.ps1 -stylelist example
    exampleにマッチする名前(キャラクター)のスタイルの一覧を出力します。

<path>\VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -save -outpath C:\
    127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信して再生します。
    生成した音声ファイルをC:\exampletext.wavに保存します。
    C:\exampletext.wavが既に存在している場合は上書き確認のダイアログが出ます。

<path>\VOICEVOX_CLI.ps1 -text exampletext -speaker 123 -vvoxhost 127.0.0.1 -save -outpath C:\output.wav -overwrite
    127.0.0.1宛にid 123のスタイルで"exampletext"を読み上げる音声を生成するリクエストを送信して再生します。
    生成した音声ファイルをC:\output.wavに保存します。
    C:\output.wavが既に存在している場合は上書きします。
```

## Dockerfile
VOICEVOXサーバ用

//IPアドレスは変数で食わせたい……
```
docker run -d --network <network> --ip 172.18.50.21 -p 50021:50021 tag/image
```

アイコンはBing Image Creatorさんに生成いただきました
