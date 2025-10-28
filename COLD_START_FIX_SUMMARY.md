# 🔧 冷启动恢复冲突修复总结

## 问题描述
App 被 swipe 杀死后，第二次重新打开时会报错，需要完全关闭再打开才能正常运行。

**根本原因**：
- Headless isolate 处理 `boot` 事件时已经初始化定位服务
- 主 Dart 引擎的 `ensureColdStartInit` 又尝试重新配置
- 两个 isolate 同时操作原生状态，导致配置冲突和状态不一致

## 修复方案

### 1️⃣ 延迟冷启动检测 (`main.dart`)
**修改位置**：`lib/main.dart` - `main()` 函数

**改动**：
- 将 `ensureColdStartInit` 从 `runApp()` 之前移到 `addPostFrameCallback`
- 延迟 1 秒执行，等待 Headless boot 事件完成处理

**效果**：
```dart
// 旧代码：立即执行，可能与 Headless 冲突
await LocationTrackingService.instance.ensureColdStartInit();
runApp(MyApp());

// 新代码：延迟执行，避免冲突
WidgetsBinding.instance.addPostFrameCallback((_) async {
  await Future.delayed(const Duration(seconds: 1));
  await LocationTrackingService.instance.ensureColdStartInit();
});
runApp(MyApp());
```

---

### 2️⃣ 增强冷启动逻辑 (`LocationTrackingService.dart`)
**修改位置**：`lib/main/services/LocationTrackingService.dart` - `ensureColdStartInit()`

**改动**：
1. **添加状态检查**：如果服务已运行，直接返回
2. **添加时间戳判断**：检查 Headless 是否在 5 秒内处理过位置
3. **移除立即上传**：恢复后等待自然心跳或定时器触发

**关键逻辑**：
```dart
// 1. 检查服务是否已运行
if (_configured && _started) {
  print('Already running, skip init');
  return;
}

// 2. 检查 Headless 是否刚处理过
final prefs = await SharedPreferences.getInstance();
final lastHeadlessTime = prefs.getInt('lastHeadlessUploadTime') ?? 0;
if (now - lastHeadlessTime < 5000) {
  print('Headless boot handled recently, skip Dart-side init');
  // 仅重建监听器，不触发新操作
  _configured = true;
  _started = true;
  return;
}

// 3. 不立即上传，等待自然心跳
print('Restored service, waiting for next heartbeat/timer');
```

---

### 3️⃣ 记录处理时间 (`background_geolocation_headless.dart`)
**修改位置**：`lib/main/background_geolocation_headless.dart` - `_handleLocation()`

**改动**：
- 在 Headless 处理位置时记录时间戳到 SharedPreferences

**代码**：
```dart
Future<void> _handleLocation(bg.Location loc) async {
  // ⭐ 新增：记录处理时间
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastHeadlessUploadTime', 
                       DateTime.now().millisecondsSinceEpoch);
  } catch (e) {
    print('[HEADLESS] ⚠️ Failed to save timestamp: $e');
  }
  // ... 其他逻辑
}
```

---

### 4️⃣ 优化恢复检查 (`DHomeFragment.dart`)
**修改位置**：`lib/delivery/fragment/DHomeFragment.dart` - `_checkAndRestoreLocationService()`

**改动**：
1. **修正 token key**：从 `auth_token` 改为 `USER_TOKEN`
2. **添加延迟**：500ms 延迟检查，避免与冷启动冲突
3. **增强日志**：显示 `enabled` 和 `isMoving` 状态

**代码**：
```dart
Future<void> _checkAndRestoreLocationService() async {
  // 1. 检查凭据
  final token = prefs.getString('USER_TOKEN'); // ⭐ 修正
  
  // 2. 延迟检查
  await Future.delayed(const Duration(milliseconds: 500)); // ⭐ 新增
  
  // 3. 检查状态
  final bg.State state = await bg.BackgroundGeolocation.state;
  print('[DHOME] ✅ Location service already running '
        '(enabled=${state.enabled} isMoving=${state.isMoving})');
}
```

---

### 5️⃣ 更新测试文档 (`deploy_and_test.sh`)
**改动**：
- 更新测试步骤，强调冷启动恢复流程
- 添加多次 Swipe + 打开的循环测试说明
- 明确成功标志：无报错 + 平滑恢复

---

## 🧪 测试流程

### 预期正常流程：

```bash
# 1. 首次登录
[BG] ✅ Forced moving state
[BG] periodic uploader started
[BG] upload success

# 2. 第一次 Swipe 杀死
[HEADLESS] event=boot
[HEADLESS] ✅ upload success

# 3. 第一次重新打开
[MAIN] Checking cold start state after delay...
[BG][COLD_START] Headless boot event handled recently, skip Dart-side init
[DHOME] ✅ Location service already running (enabled=true isMoving=true)
# ✅ 无报错，界面正常

# 4. 第二次 Swipe 杀死
[HEADLESS] event=boot
[HEADLESS] ✅ upload success

# 5. 第二次重新打开 - 关键测试点！
[MAIN] Checking cold start state after delay...
[BG][COLD_START] Headless boot event handled recently
[DHOME] ✅ Location service already running
# ✅ 无报错，持续稳定

# 6. 重复测试...
# 每次都应该平滑恢复，无异常
```

---

## 🎯 成功标志

1. **Headless 持续工作**：App 杀死后每 60 秒上传位置
2. **多次恢复无报错**：重复 Swipe + 打开，每次都正常
3. **状态一致**：`enabled=true`、`isMoving=true`、心跳正常

---

## 📝 关键改进点

| 模块 | 旧逻辑 | 新逻辑 | 效果 |
|------|--------|--------|------|
| **main.dart** | 立即执行冷启动检测 | 延迟 1 秒执行 | 等待 Headless 完成 |
| **LocationTrackingService** | 无状态检查 | 添加时间戳判断 | 避免重复初始化 |
| **background_geolocation_headless** | 无时间记录 | 记录处理时间戳 | 提供判断依据 |
| **DHomeFragment** | 立即检查 | 延迟 500ms 检查 | 避免检测冲突 |

---

## 🚀 部署步骤

```bash
# 1. 运行完整重新编译脚本
./deploy_and_test.sh

# 2. 按照脚本提示操作
#    - 完全卸载旧版
#    - 编译安装新版
#    - 授予位置权限
#    - 循环测试 Swipe + 打开

# 3. 观察日志
#    - 确认无报错
#    - 验证平滑恢复
#    - 检查心跳持续
```

---

## ⚠️ 注意事项

1. **必须完全卸载**：使用 `adb uninstall` 清除旧配置
2. **授予后台权限**：必须授予"始终允许"位置权限
3. **多次测试**：至少重复 3-5 次 Swipe + 打开
4. **观察日志**：重点关注 `[BG][COLD_START]` 和 `[DHOME]` 日志

---

## 📊 修改文件清单

- ✅ `lib/main.dart`
- ✅ `lib/main/services/LocationTrackingService.dart`
- ✅ `lib/main/background_geolocation_headless.dart`
- ✅ `lib/delivery/fragment/DHomeFragment.dart`
- ✅ `deploy_and_test.sh`

---

## 🔗 相关文档

- [HEADLESS_FIX_SUMMARY.md](./HEADLESS_FIX_SUMMARY.md) - Headless 模式修复
- [PACKAGE_ID_UPDATE_SUMMARY.md](./PACKAGE_ID_UPDATE_SUMMARY.md) - 包名修复
- [QUICK_START.md](./QUICK_START.md) - 快速开始指南

---

**修复日期**：2025-10-28  
**修复版本**：v2.1 - Cold Start Recovery Fix
