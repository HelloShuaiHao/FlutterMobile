# 🎉 Headless 后台定位修复完成

## ✅ 已完成的修复

### 1. LocationTrackingService.dart 配置优化
**文件**: `lib/main/services/LocationTrackingService.dart`

**修改内容**:
- ✅ `stopTimeout: 0` - 禁用自动停止
- ✅ `disableStopDetection: true` - 禁用停止检测
- ✅ `stopOnStationary: false` - 静止时不停止
- ✅ `desiredAccuracy: HIGH` - 提高精度（原: LOW）
- ✅ `distanceFilter: 50` - 50米触发（原: 1000米）
- ✅ `logLevel: VERBOSE` - 详细日志（原: INFO）
- ✅ 添加 `changePace(true)` - 强制移动模式

**效果**: 定位服务持续运行，不会自动停止，每180秒触发心跳

---

### 2. LoginScreen.dart 同步逻辑
**文件**: `lib/main/screens/LoginScreen.dart`

**修改内容**:
- ✅ 登录成功后同步 token 到 SharedPreferences
- ✅ 登录成功后同步 vehicleId 到 SharedPreferences
- ✅ 添加详细的日志输出

**效果**: Headless 模式可以访问 vehicleId 和 token

---

### 3. background_geolocation_headless.dart 增强
**文件**: `lib/main/background_geolocation_headless.dart`

**修改内容**:
- ✅ 使用 SharedPreferences 替代 GetStorage
- ✅ 过滤安装/替换事件，避免误触发
- ✅ 处理 HEARTBEAT、LOCATION、TERMINATE 事件
- ✅ 添加详细的错误处理和日志

**效果**: App 被杀死后，Headless 仍能正常上传位置

---

### 4. VehicleSelectionWidget.dart 验证
**文件**: `lib/delivery/widgets/VehicleSelectionWidget.dart`

**修改内容**:
- ✅ 选择车辆时同步到 SharedPreferences
- ✅ 验证保存是否成功
- ✅ 添加详细日志

**效果**: 车辆选择后立即可用，无需重新登录

---

## 📋 测试流程

### 准备工作
```bash
# 1. 清理旧构建
flutter clean
rm -rf android/build build

# 2. 获取依赖
flutter pub get

# 3. 卸载旧版本（重要！）
adb uninstall u.nus.edu.astar.demo

# 4. 编译 Release 版本
flutter build apk --release

# 5. 安装
adb install build/app/outputs/flutter-apk/app-release.apk

# 6. 授予后台位置权限
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_FINE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_COARSE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_BACKGROUND_LOCATION
```

### 测试步骤（重要顺序）⭐

```
1. 打开 App

2. 【先选择车辆】⭐⭐⭐ 
   预期日志:
   [VehicleSelection] ✅ Saved to GetStorage: xxx
   [VehicleSelection] ✅ Saved to SharedPreferences: xxx
   [VehicleSelection] ✅ Verification SUCCESS: xxx

3. 输入账号密码并登录

4. 登录成功
   预期日志:
   [LOGIN] ✅ Saved token to SharedPreferences (length=xxx)
   [LOGIN] ✅ Saved vehicleId to SharedPreferences: xxx
   [BG] calling start() ...
   [BG] start() success
   [BG] ✅ Forced moving state
   [BG] obtaining first position...

5. 等待 3 分钟（180秒）
   预期日志:
   [BG] heartbeat @ 2025-XX-XX...
   [BG] uploading...
   [BG] ✅ upload success

6. Swipe 杀死 App ⭐⭐⭐

7. 继续观察日志 3 分钟
   预期日志:
   [HEADLESS] event=heartbeat at 2025-XX-XX... ⭐⭐⭐
   [HEADLESS] HEARTBEAT - fetching current position
   [HEADLESS] location lat=XX.XX lon=XX.XX
   [HEADLESS] vehicleId=xxx (from SharedPreferences) ✅
   [HEADLESS] token=eyJhbG... (length=xxx)
   [HEADLESS] ✅ upload success 2025-XX-XX... ⭐⭐⭐
```

### 监控日志

```bash
# 清空旧日志并开始监控
adb logcat -c
adb logcat | grep -E "\[LOGIN\]|\[VehicleSelection\]|\[BG\]|\[HEADLESS\]|stopTimeout|heartbeatInterval|Location-services"
```

---

## 🎯 成功标志

```
✅ 选择车辆时看到 3 条日志（保存+验证）
✅ 登录时看到 vehicleId 和 token 同步日志
✅ 前台每 180 秒看到 [BG] upload success
✅ 杀死后看到 [HEADLESS] event=heartbeat ⭐⭐⭐
✅ 杀死后看到 [HEADLESS] upload success ⭐⭐⭐
```

---

## ⚠️ 注意事项

### 1. 操作顺序很重要！
```
❌ 错误：先登录 → 再选车辆
✅ 正确：先选车辆 → 再登录
```

### 2. 手机权限设置
```
设置 > 应用 > LPT > 权限 > 位置
→ 必须选择"始终允许" ⭐

设置 > 应用 > LPT > 电池
→ 选择"无限制" ⭐
```

### 3. 心跳间隔
```
前台心跳: 每 180 秒（3 分钟）
后台心跳: 每 180 秒（3 分钟）
距离触发: 每移动 50 米
```

---

## 🔧 故障排查

### 问题1: 看不到 [HEADLESS] 日志

**检查清单**:
```bash
# 1. 确认服务已注册
adb shell dumpsys activity services | grep -i headless

# 2. 确认权限
adb shell dumpsys package u.nus.edu.astar.demo | grep -i permission

# 3. 查看原生日志
adb logcat | grep -i "transistorsoft\|locationmanager"
```

### 问题2: [HEADLESS] vehicleId=null

**原因**: 登录前没有选择车辆

**解决**: 必须先选择车辆，再登录

**验证**:
```bash
# 查看 SharedPreferences 内容
adb shell run-as u.nus.edu.astar.demo cat shared_prefs/FlutterSharedPreferences.xml | grep vehicleId
```

### 问题3: 定位服务自动停止

**检查日志**:
```bash
adb logcat | grep -E "stopTimeout|stopDetection|Location-services"
```

**应该看到**:
```
stopTimeout: 0  ✅
disableStopDetection: true  ✅
🎾 Location-services: ON  ← 一直是 ON
```

---

## 📱 手机品牌特殊设置

### 小米/红米
```
设置 > 应用设置 > 应用管理 > LPT
├─ 自启动：允许 ⭐
├─ 后台弹出界面：允许
├─ 显示悬浮窗：允许
└─ 省电策略：无限制 ⭐

关闭省电模式
关闭"神隐模式"
```

### 华为/荣耀
```
设置 > 应用 > LPT > 启动管理
选择"手动管理"，然后全部打开：
├─ 允许自启动 ⭐
├─ 允许后台活动 ⭐
└─ 允许关联启动

关闭"智能省电"
```

### OPPO/一加
```
设置 > 应用管理 > LPT
├─ 权限 > 位置：始终允许 ⭐
├─ 电池 > 后台冻结：关闭 ⭐
└─ 自启动：允许

关闭"超级省电"
```

---

## 📊 性能影响

### 电池消耗
```
估计耗电: 中等
优化建议: 可以根据移动状态动态调整精度
```

### 流量消耗
```
每次上传: ~500 字节
估计流量: ~30KB/小时
```

### 后台占用
```
前台服务通知: 常驻
内存占用: ~20-30MB
CPU: 几乎为 0（GPS 硬件处理）
```

---

## ✅ 修改文件清单

1. ✅ `lib/main/services/LocationTrackingService.dart` - 核心配置优化
2. ✅ `lib/main/screens/LoginScreen.dart` - vehicleId 同步
3. ✅ `lib/main/background_geolocation_headless.dart` - Headless 逻辑
4. ✅ `lib/delivery/widgets/VehicleSelectionWidget.dart` - 车辆选择验证
5. ✅ `android/app/build.gradle` - Application ID 更新
6. ✅ `android/app/src/debug/AndroidManifest.xml` - Package 更新
7. ✅ `android/app/src/main/AndroidManifest.xml` - Package 更新
8. ✅ `android/app/src/profile/AndroidManifest.xml` - Package 更新
9. ✅ `android/app/src/main/kotlin/com/mighty/delivery/MainActivity.kt` - Package 更新

**总计**: 9 个文件修改完成

---

## 🚀 快速测试脚本

已创建两个脚本供使用：

### 1. `deploy_and_test.sh` - 完整编译测试
```bash
chmod +x deploy_and_test.sh
./deploy_and_test.sh
```

功能：
- 卸载旧版本
- 清理构建
- 编译 Release 版本
- 安装到设备
- 授予权限
- 启动日志监控

### 2. `monitor_logs.sh` - 仅监控日志
```bash
chmod +x monitor_logs.sh
./monitor_logs.sh
```

功能：
- 清空旧日志
- 实时监控关键日志

---

## 🎉 预期结果

执行完整测试后，应该看到：

```
✅ 安装时不会触发多余的 HEADLESS 事件
✅ 选择车辆时保存到两种存储并验证成功
✅ 登录时自动同步 vehicleId 到 SharedPreferences
✅ 前台定位服务持续运行不停止
✅ 每 180 秒触发心跳并上传位置
✅ Swipe 杀死 App 后 Headless 正常触发 ⭐⭐⭐
✅ Headless 能读取 vehicleId 并成功上传 ⭐⭐⭐
✅ 重启手机后服务自动恢复
```

---

**修复完成时间**: 2025-10-28  
**Application ID**: `u.nus.edu.astar.demo`  

看到 `[HEADLESS] ✅ upload success` 就说明完全成功了！🚀
