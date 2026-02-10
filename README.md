# ClawChat - 自由连接你的 OpenClaw Gateway

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-lightgrey.svg)

**摆脱 IM 平台限制，自由连接你的 AI 服务**

一个优雅的跨平台 Flutter 应用，让你完全掌控自己的 OpenClaw Gateway 连接。

[功能特性](#功能特性) • [快速开始](#快速开始) • [连接方式](#连接方式) • [架构设计](#架构设计)

</div>

---

## 💡 项目初衷

在当今的 AI 时代，我们常常受限于各种 IM 平台的封闭生态：
- 🚫 **平台限制** - 无法自由选择 AI 服务
- 🚫 **数据隐私** - 对话数据存储在第三方服务器
- 🚫 **功能受限** - 受限于平台提供的功能
- 🚫 **网络依赖** - 依赖特定平台的网络环境

**ClawChat 的使命**：让你完全掌控自己的 AI 连接，享受真正的自由。

### ✨ 核心优势

- 🔓 **完全自主** - 连接你自己部署的 OpenClaw Gateway
- 🔒 **隐私优先** - 所有数据本地存储，完全掌控
- 🌐 **灵活连接** - 支持多种连接方式（Cloudflare、Tailscale、直连）
- 📱 **跨平台** - iOS、Android、macOS 统一体验
- 💾 **离线可用** - 本地消息存储，随时查看历史记录
- 🎨 **现代设计** - Material Design 3，流畅动画

---

## 📱 功能特性

### ✅ 已实现

- **🔐 多服务管理**
  - 支持添加多个 Gateway 服务
  - 快速切换不同服务
  - 独立的会话和消息历史
  - 服务配置持久化

- **💬 实时聊天**
  - WebSocket 实时通信
  - 流式消息接收（逐字显示）
  - 消息状态追踪（发送中/已发送/失败）
  - 消息重发功能
  - 本地消息历史记录
  - 自动滚动到最新消息

- **🎨 精美界面**
  - Material Design 3
  - 深色/浅色主题切换
  - 流畅的动画效果
  - 响应式布局
  - 现代化的消息气泡设计

- **💾 本地存储**
  - Hive 数据库
  - 消息持久化
  - 配置自动保存
  - 离线消息查看
  - 多服务数据隔离

- **🔄 连接管理**
  - 自动重连机制
  - 连接状态实时显示
  - Challenge-Response 认证
  - 错误处理与诊断
  - 网络权限自动配置

- **🔧 开发者工具**
  - 命令行连接测试工具
  - 自动化测试套件
  - 网络诊断工具
  - 详细的错误诊断和建议
  - URL 格式验证

### 🚧 开发中

- **🔔 通知系统**
  - 新消息通知
  - 后台消息接收
  - 通知设置

- **🎯 高级功能**
  - 消息搜索
  - 导出聊天记录
  - 语音输入
  - 图片发送
  - Markdown 渲染增强

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- iOS 12.0+ / Android 5.0+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/inteye/ClawChat.git
cd ClawChat
```

2. **安装依赖**
```bash
flutter pub get
```

3. **生成平台文件**
```bash
# 生成所有平台的项目文件
flutter create .

# 生成代码（Hive 适配器等）
flutter pub run build_runner build --delete-conflicting-outputs
```

> **注意**：本项目不包含平台特定文件（android/、ios/、macos/ 等）在版本控制中。
> 这些文件可以通过 `flutter create .` 命令自动生成。
> 详细说明请查看 [平台配置指南](docs/PLATFORM_SETUP.md)。

4. **配置应用图标（可选）**
```bash
# 项目提供了 logo.png，你可以使用它生成图标
# 详细步骤请查看 docs/PLATFORM_SETUP.md
```

5. **运行应用**
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos

# 模拟器
flutter run
```

## 🌐 连接方式

### 推荐：Cloudflare Tunnel（最简单）

使用 Cloudflare Tunnel 可以轻松将你的本地 Gateway 暴露到公网，无需公网 IP，无需配置路由器。

#### 1. 安装 Cloudflare Tunnel

```bash
# macOS
brew install cloudflare/cloudflare/cloudflared

# Linux
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb

# Windows
# 下载 https://github.com/cloudflare/cloudflared/releases
```

#### 2. 启动临时隧道（快速测试）

```bash
# 假设你的 Gateway 运行在 localhost:18789
cloudflared tunnel --url http://localhost:18789

# 输出示例：
# Your quick Tunnel has been created! Visit it at:
# https://random-name.trycloudflare.com
```

#### 3. 在 ClawChat 中配置

- **Gateway URL**: `https://random-name.trycloudflare.com`
- **Token**: 你的 Gateway token
- 点击"验证 URL 格式"测试连接

#### 4. 创建永久隧道（推荐生产使用）

```bash
# 登录 Cloudflare
cloudflared tunnel login

# 创建隧道
cloudflared tunnel create my-gateway

# 配置隧道
cat > ~/.cloudflared/config.yml << EOF
tunnel: <tunnel-id>
credentials-file: /path/to/<tunnel-id>.json

ingress:
  - hostname: gateway.yourdomain.com
    service: http://localhost:18789
  - service: http_status:404
EOF

# 添加 DNS 记录
cloudflared tunnel route dns my-gateway gateway.yourdomain.com

# 运行隧道
cloudflared tunnel run my-gateway
```

**优势**：
- ✅ 无需公网 IP
- ✅ 自动 HTTPS 加密
- ✅ 全球 CDN 加速
- ✅ 免费使用
- ✅ 配置简单

---

### 方案 2: Tailscale（私有网络）

适合个人使用，提供安全的点对点连接。

**Tailscale Serve（仅 Tailnet 内）**
```bash
# 在 Gateway 服务器上
tailscale serve https / http://localhost:18789
```

- **URL**: `https://your-machine.tailnet-name.ts.net`
- **Token**: 可选

**Tailscale Funnel（公共访问）**
```bash
tailscale funnel 18789
```

- **URL**: `https://your-machine.tailnet-name.ts.net`
- **Token**: 必填

📖 详细指南：[Tailscale 连接指南](docs/TAILSCALE_SETUP_GUIDE.md)

---

### 方案 3: 直接连接

如果你有公网 IP 或在同一局域网内：

- **公网**: `wss://your-domain.com:18789` 或 `https://your-domain.com`
- **局域网**: `ws://192.168.x.x:18789`
- **Token**: 你的 Gateway token

⚠️ **注意**：
- iOS/macOS 需要配置网络权限（已在项目中配置）
- 建议使用 HTTPS/WSS 加密连接
- 局域网连接需要在同一网络下

---

### 🧪 测试连接

使用命令行工具快速测试 WebSocket 连接：

```bash
# 运行自动化测试
flutter test test/protocol_parser_test.dart
```

**详细文档**: 
- 📖 [连接测试指南](docs/CONNECTION_TEST_GUIDE.md)
- 📖 [平台配置指南](docs/PLATFORM_SETUP.md)
- 📖 [iOS 网络权限](docs/IOS_NETWORK_PERMISSIONS.md)
- 📖 [macOS 网络权限](docs/MACOS_NETWORK_PERMISSIONS.md)

---

## 🏗️ 架构设计

### 项目结构

```
lib/
├── models/              # 数据模型
│   ├── config.dart           # 配置模型
│   ├── message.dart          # 消息模型
│   └── connection_state.dart # 连接状态模型
│
├── services/            # 业务服务
│   ├── websocket_service.dart  # WebSocket 通信
│   ├── storage_service.dart    # 本地存储
│   └── protocol_parser.dart    # 协议解析
│
├── providers/           # 状态管理
│   ├── config_provider.dart      # 配置状态
│   ├── connection_provider.dart  # 连接状态
│   ├── messages_provider.dart    # 消息状态
│   └── theme_provider.dart       # 主题状态
│
├── screens/             # 页面
│   ├── splash_screen.dart    # 启动页
│   ├── settings_screen.dart  # 设置页
│   └── chat_screen.dart      # 聊天页
│
├── widgets/             # 组件
│   ├── message_bubble.dart        # 消息气泡
│   ├── message_input.dart         # 输入框
│   └── connection_indicator.dart  # 连接指示器
│
├── utils/               # 工具类
│   ├── constants.dart           # 常量定义
│   ├── validators.dart          # 验证工具
│   ├── network_checker.dart     # 网络检查
│   └── connection_diagnostics.dart  # 连接诊断
│
└── main.dart            # 应用入口

bin/
└── test_connection.dart # 连接测试工具

test/
└── websocket_connection_test.dart  # 自动化测试

docs/
├── CONNECTION_TEST_GUIDE.md    # 连接测试指南
├── QUICK_REFERENCE.md          # 快速参考
└── TESTING_TOOLS_SUMMARY.md    # 测试工具总结
```

### 技术栈

- **状态管理**: Riverpod 2.x
- **本地存储**: Hive 2.x
- **网络通信**: web_socket_channel
- **UI 框架**: Flutter Material 3

### 核心流程

```
用户输入消息
    ↓
MessagesProvider.sendMessage()
    ↓
WebSocketService.send()
    ↓
Gateway 处理
    ↓
WebSocketService.messageStream
    ↓
MessagesProvider._handleIncomingMessage()
    ↓
UI 更新显示
```

---

## 📋 开发路线

### ✅ Milestone 1: 基础架构 (已完成)
- [x] 项目初始化
- [x] 数据模型定义
- [x] 核心服务实现
- [x] 状态管理搭建
- [x] 跨平台支持（iOS、Android、macOS）

### ✅ Milestone 2: UI 界面 (已完成)
- [x] 启动页（带动画和新 logo）
- [x] 设置页（多服务管理）
- [x] 聊天页（流式消息显示）
- [x] 通用组件（消息气泡、输入框、连接指示器）
- [x] Material Design 3 主题

### ✅ Milestone 3: 核心功能 (已完成)
- [x] WebSocket 连接（Challenge-Response 认证）
- [x] 消息收发（流式消息支持）
- [x] 多服务管理（添加、编辑、删除、切换）
- [x] 本地存储（Hive 数据库）
- [x] 消息排序和持久化
- [x] 自动滚动到最新消息

### ✅ Milestone 4: 网络和权限 (已完成)
- [x] iOS 网络权限配置
- [x] macOS 网络权限配置（App Sandbox）
- [x] Android 网络权限配置
- [x] Cloudflare Tunnel 支持
- [x] Tailscale 支持
- [x] 连接诊断工具

### ✅ Milestone 5: 测试和文档 (已完成)
- [x] 单元测试（协议解析器）
- [x] 集成测试（WebSocket 连接）
- [x] 命令行测试工具
- [x] 完整的文档体系
- [x] 平台配置指南

### 🚧 Milestone 6: 高级功能 (进行中)
- [ ] 消息搜索
- [ ] 导出聊天记录
- [ ] 通知系统
- [ ] 语音输入
- [ ] 图片发送
- [ ] Markdown 渲染增强

### 📅 Milestone 7: 发布准备 (计划中)
- [x] 应用图标（已完成）
- [x] 启动画面（已完成）
- [ ] 应用签名
- [ ] 商店发布（App Store、Google Play）
- [ ] 持续集成/持续部署

---

## 🔧 开发指南

### 项目架构

ClawChat 采用清晰的分层架构：

- **Models** - 数据模型和业务实体
- **Services** - 业务逻辑和外部服务（WebSocket、存储）
- **Providers** - 状态管理（Riverpod）
- **Screens** - 完整页面
- **Widgets** - 可复用组件
- **Utils** - 工具类和辅助函数

### 添加新功能

1. **定义数据模型** (`lib/models/`)
2. **实现业务服务** (`lib/services/`)
3. **创建状态管理** (`lib/providers/`)
4. **构建 UI 界面** (`lib/screens/` 或 `lib/widgets/`)
5. **编写测试** (`test/`)

### 代码规范

- 使用 `dart format` 格式化代码
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 为公共 API 添加文档注释
- 保持单一职责原则
- 详细规范请查看 [AGENTS.md](AGENTS.md)

### 调试技巧

```bash
# 查看日志
flutter logs

# 热重载
r

# 热重启
R

# 性能分析
flutter run --profile

# 详细输出
flutter run -d macos --verbose
```

### 常见问题

#### iOS/macOS 连接失败（Operation not permitted）

**原因**：缺少网络权限配置

**解决**：
- iOS: 查看 [iOS 网络权限配置](docs/IOS_NETWORK_PERMISSIONS.md)
- macOS: 查看 [macOS 网络权限配置](docs/MACOS_NETWORK_PERMISSIONS.md)

#### 消息显示重复

**原因**：协议解析错误

**解决**：已在最新版本修复，使用 `delta` 增量内容而不是 `text` 完整内容

#### 应用图标不显示

**原因**：需要重新构建应用

**解决**：
```bash
flutter clean
flutter pub get
flutter run -d <platform>
```

---

## 📝 协议说明

### OpenClaw Gateway 协议

ClawChat 使用 OpenClaw Gateway 的 WebSocket 协议进行通信：

**连接认证**
```json
{
  "type": "auth",
  "password": "your-password"
}
```

**发送消息**
```json
{
  "type": "message",
  "content": "Hello, OpenClaw!",
  "agentId": "optional-agent-id"
}
```

**接收消息**
```json
{
  "type": "message",
  "content": "Response from AI",
  "messageId": "unique-id",
  "isComplete": true
}
```

**流式消息**
```json
{
  "type": "stream",
  "content": "Partial response...",
  "messageId": "unique-id",
  "isComplete": false
}
```

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [Flutter](https://flutter.dev/) - 跨平台 UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理解决方案
- [Hive](https://docs.hivedb.dev/) - 轻量级本地数据库
- [OpenClaw](https://github.com/openclaw) - AI Gateway 平台

---

## 📞 联系方式

- 项目主页: [https://github.com/inteye/ClawChat](https://github.com/inteye/ClawChat)
- 问题反馈: [Issues](https://github.com/inteye/ClawChat/issues)
- 讨论交流: [Discussions](https://github.com/inteye/ClawChat/discussions)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个 Star！⭐**

Made with ❤️ by ClawChat Team

</div>
