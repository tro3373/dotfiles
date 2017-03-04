# jpegoptim for Ubuntu16.04

## 参考URL
- [http://satolabo.0t0.jp/2017/02/04/jpegoptim/](http://satolabo.0t0.jp/2017/02/04/jpegoptim/)

## 使用方法
```sh
## 出力先指定
jpegoptim --dest=ディレクトリパス オプション ファイル名

## 名前変更
jpegoptim --stdout オプション ファイル名 > 保存先ファイル名

## サイズ指定(Kb)
jpegoptim -Sサイズ ファイル名
jpegoptim --stdout -S100 test_org.jpg > s100_test.jpg

## 品質指定(1〜99)
pegoptim -m品質 ファイル名
jpegoptim -m50 test.jpg

## 画像情報削除
jpegoptim --strip-all ファイル名
#コメントのみ
jpegoptim --strip-com ファイル名
#Exifのみ
jpegoptim --strip-exif ファイル名
#IPTCのみ
jpegoptim --strip-iptc ファイル名
#ICCプロファイルのみ
jpegoptim --strip-icc ファイル名
#XMPのみ
jpegoptim --strip-xmp ファイル名
```
