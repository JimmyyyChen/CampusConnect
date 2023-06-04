# CampusConnect
前端flutter 数据库 firebase
firebase地址：https://console.firebase.google.com/project/android-forum-project/overview?hl=zh-cn

## Usage

flutter安装参考[[flutter](https://flutter.cn/docs/get-started/install)](https://flutter.cn/docs/get-started/test-drive)

- `flutter doctor`检查环境（需要安卓环境）
- `flutter channel master`切换到master分支
- `flutter upgrade`升级
- `flutter pub get`安装依赖
- `flutter run`运行

## TroubleShoot

### Resource missing

resource missing when 

```
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

use default `PUB_HOSTED_URL` and `FLUTTER_STORAGE_BASE_URL` instead.