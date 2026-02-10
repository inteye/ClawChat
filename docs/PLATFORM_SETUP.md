# 平台配置指南

本项目是一个跨平台 Flutter 应用。为了保持仓库简洁，平台特定的文件和生成的代码不包含在版本控制中。

## 🚀 快速开始

### 1. 克隆项目后的初始化

```bash
# 克隆项目
git clone <repository-url>
cd clawchat

# 安装依赖
flutter pub get

# 生成平台文件
flutter create .

# 生成代码（Hive 适配器等）
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 配置应用图标

项目提供了一个 `logo.png` 文件（1024x1024），你可以使用它来生成所有平台的图标。

#### 自动生成图标（推荐）

使用 `flutter_launcher_icons` 包：

```bash
# 添加到 dev_dependencies
flutter pub add --dev flutter_launcher_icons

# 在 pubspec.yaml 中配置
flutter_icons:
  android: true
  ios: true
  image_path: "logo.png"

# 生成图标
flutter pub run flutter_launcher_icons
```

#### 手动生成图标

**macOS:**
```bash
# 生成 .icns 文件
mkdir -p /tmp/AppIcon.iconset
sips -z 16 16 logo.png --out /tmp/AppIcon.iconset/icon_16x16.png
sips -z 32 32 logo.png --out /tmp/AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32 logo.png --out /tmp/AppIcon.iconset/icon_32x32.png
sips -z 64 64 logo.png --out /tmp/AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128 logo.png --out /tmp/AppIcon.iconset/icon_128x128.png
sips -z 256 256 logo.png --out /tmp/AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256 logo.png --out /tmp/AppIcon.iconset/icon_256x256.png
sips -z 512 512 logo.png --out /tmp/AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512 logo.png --out /tmp/AppIcon.iconset/icon_512x512.png
sips -z 1024 1024 logo.png --out /tmp/AppIcon.iconset/icon_512x512@2x.png
iconutil -c icns /tmp/AppIcon.iconset -o macos/Runner/Resources/app_icon.icns
rm -rf /tmp/AppIcon.iconset

# 更新 Info.plist
# 在 macos/Runner/Info.plist 中设置：
# <key>CFBundleIconFile</key>
# <string>app_icon.icns</string>
```

**Android:**
```bash
sips -z 48 48 logo.png --out android/app/src/main/res/mipmap-mdpi/ic_launcher.png
sips -z 72 72 logo.png --out android/app/src/main/res/mipmap-hdpi/ic_launcher.png
sips -z 96 96 logo.png --out android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
sips -z 144 144 logo.png --out android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
sips -z 192 192 logo.png --out android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

**iOS:**
```bash
sips -z 1024 1024 logo.png --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
sips -z 180 180 logo.png --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
sips -z 120 120 logo.png --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
# ... 其他尺寸
```

### 3. 平台特定配置

#### iOS

1. 打开 `ios/Runner.xcworkspace` 在 Xcode 中
2. 配置 Bundle Identifier
3. 配置签名证书
4. 配置网络权限（已在 Info.plist 中）

#### Android

1. 修改 `android/app/build.gradle` 中的 applicationId
2. 配置签名密钥（生产环境）
3. 配置网络权限（已在 AndroidManifest.xml 中）

#### macOS

1. 打开 `macos/Runner.xcworkspace` 在 Xcode 中
2. 配置 Bundle Identifier
3. 配置签名证书
4. 配置网络权限和 Entitlements（已配置）

## 📦 项目结构

```
clawchat/
├── lib/                    # Dart 源代码（已包含）
├── assets/                 # 资源文件（需要生成）
│   └── logo.png           # 应用图标源文件
├── android/               # Android 平台（需要生成）
├── ios/                   # iOS 平台（需要生成）
├── macos/                 # macOS 平台（需要生成）
├── linux/                 # Linux 平台（需要生成）
├── windows/               # Windows 平台（需要生成）
├── web/                   # Web 平台（需要生成）
├── test/                  # 测试文件（已包含）
├── docs/                  # 文档（已包含）
└── pubspec.yaml           # 项目配置（已包含）
```

## 🔧 常见问题

### Q: 为什么平台文件不在仓库中？

A: 平台文件包含大量自动生成的代码和二进制文件，会使仓库变得臃肿。通过 `flutter create .` 可以轻松重新生成这些文件。

### Q: 如何自定义平台配置？

A: 运行 `flutter create .` 后，你可以自由修改平台特定的配置文件，如：
- Android: `android/app/build.gradle`
- iOS: `ios/Runner/Info.plist`
- macOS: `macos/Runner/Info.plist`

### Q: 生成的代码（*.g.dart）为什么不在仓库中？

A: 这些文件是由 `build_runner` 自动生成的，可以通过命令重新生成，不需要版本控制。

## 📚 相关文档

- [Flutter 官方文档](https://flutter.dev/docs)
- [平台集成指南](https://flutter.dev/docs/development/platform-integration)
- [应用图标配置](https://flutter.dev/docs/deployment/android#adding-a-launcher-icon)

## 🆘 需要帮助？

如果遇到问题，请查看：
1. [项目 README](../README.md)
2. [问题反馈](https://github.com/your-repo/issues)
3. [讨论区](https://github.com/your-repo/discussions)
