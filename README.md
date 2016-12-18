# sugoi-iko-yo-log-fetcher-ruby

## Amazon S3に保管されているログデータをダウンロードする
* https://github.com/actindi-dev/sugoi-iko-yo-log-fetcher のmruby実装です
* mruby-cliで作成しているので認証情報を置いている上でワンバイナリで使えます

## Installation
TODO

## Usage

認証情報は ~/.ai_s3log に用意します

```shell
$ cat ~/.ai_s3log
access_token
secret_toten
```

## TODO
* Glacier行きもダウンロードする
* プログレスバー
