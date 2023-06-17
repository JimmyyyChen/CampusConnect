# Campus Connect

<!-- Folded Table of Contents -->

<details>
<summary>Table of Contents</summary>


- [Campus Connect](#campus-connect)
- [About The Project](#about-the-project)
- [Build With](#build-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
    - [前端](#前端)
    - [后端](#后端)
  - [Notice](#notice)

</details>

# About The Project

**Campus Connect**是一个校园信息发布平台，旨在为同学们提供一个综合平台，以分享身边趣事、交流校园动态和发布二手交易信息等多种多样的功能。

该平台满足以下基本用户需求：

- 注册和编辑用户信息：用户可以注册账号，并随时编辑和修改个人信息。
- 浏览信息：用户可以浏览其他用户在平台上发布的信息，并可以按照不同的类型和排序方式进行查看。
- 发布信息：用户可以发布包含文字、图片和视频等多种类型的信息，并选择不同的信息类型将其发布到平台上。
- 互动操作：用户可以对发布的信息进行点赞、收藏和评论等操作，以表达对信息的喜爱或提供反馈。
- 社交功能：用户可以关注其他用户，并与关注的用户进行私信聊天，同时还可以浏览其他用户发布信息的时间线

# Build With

该项目基于Flutter开发，并使用Firebase作为后端数据库和存储解决方案，同时利用Firebase提供的认证服务和云函数来处理后端逻辑。

- **Flutter**：跨平台的移动应用开发框架，用于构建美观且高性能的移动应用界面。
- **Firebase**：全面的移动和Web应用开发平台，提供多种云端服务和工具，简化开发和管理过程。
  - **Firebase数据库**：用于存储和同步应用数据的云端NoSQL数据库。
  - **Firebase身份验证**：提供安全的用户认证和身份管理功能，确保应用数据的访问权限。
  - **Firebase存储**：用于在云端安全地存储用户上传的图片等文件。
  - **Firebase云函数**：无服务器的后端代码托管服务，用于执行自定义逻辑和处理请求。

通过结合Flutter和Firebase技术栈，该项目能够快速构建功能强大且可靠的移动应用，实现用户认证、数据存储和后端逻辑处理等关键功能。

# Getting Started

## Prerequisites



1. 安装Flutter并配置虚拟机，参考[Flutter安装和环境配置教程](https://flutter.cn/docs/get-started/install)
2. 安装Firebase CLI用于部署Firebase后端，参考[Firebase CLI 参考](https://firebase.google.com/docs/cli?hl=zh-cn)
3. 使用CLI登录Firebase
```
firebase login
```
4. 安装FlutterFire CLI使Flutter项目与Firebase后端连接
```
dart pub global activate flutterfire_cli
```
安装后，flutterfire命令在全局范围内可用。

## Usage
### 前端

在forum目录下运行以下命令

```
flutter doctor # 检查环境（需要安卓环境）
flutter channel master # 切换到master分支
flutter upgrade # 升级
flutter pub get # 安装依赖
flutter run # 运行
```

### 后端

首先要取得firebase项目权限，此步需要项目所有者在[firebase控制台](https://console.firebase.google.com/project/android-forum-project/settings/iam?hl=zh-cn)中添加权限，或者是创建一个新的firebase项目，参考[Firebase文档](https://firebase.google.com/docs?hl=zh-cn)。


获取项目权限后，在forum目录下运行以下命令
```
flutterfire configure
```
配置命令引导您完成以下过程：

1. 根据`.firebaserc`文件或从Firebase控制台选择Firebase项目。
2. 确定配置平台，如Android、iOS、macOS和Web。
3. 确定要从中提取配置的Firebase应用程序。默认情况下，CLI会尝试根据您当前的项目配置自动匹配Firebase应用程序。
4. 在您的项目中生成`firebase_options.dart`文件。

## Notice
- 如果你在中国的网络环境下使用 Flutter，请先看一下[这篇文章](https://flutter.cn/community/china)，查看是否需要对网络环境进行特别设置。
- 在中国的网络环境下可能无法正常使用Firebase。