# 📦 Package ID 更新总结

**更新日期**: 2025-10-28  
**旧 Package ID**: `sg.glsapp.gls`  
**新 Package ID**: `u.nus.edu.astar.demo` ✅

---

## ✅ 已修改的文件

### 1. Android Build 配置
- ✅ `android/app/build.gradle`
  - `namespace = "u.nus.edu.astar.demo"`
  - `applicationId "u.nus.edu.astar.demo"`

### 2. AndroidManifest 文件
- ✅ `android/app/src/debug/AndroidManifest.xml`
  - `package="u.nus.edu.astar.demo"`
  
- ✅ `android/app/src/main/AndroidManifest.xml`
  - `package="u.nus.edu.astar.demo"`
  
- ✅ `android/app/src/profile/AndroidManifest.xml`
  - `package="u.nus.edu.astar.demo"`

### 3. Kotlin 源代码 ⭐ 关键修复
- ✅ `android/app/src/main/kotlin/u/nus/edu/astar/demo/MainActivity.kt`
  - `package u.nus.edu.astar.demo`

### 4. 部署脚本
- ✅ `deploy_and_test.sh` - 完整的编译、安装、测试流程
- ✅ `monitor_logs.sh` - 日志监控脚本

---

## 🔧 修复的错误

### ❌ 原错误
```
java.lang.ClassNotFoundException: Didn't find class "u.nus.edu.astar.demo.MainActivity"
```

### ✅ 原因
MainActivity.kt 文件在正确的目录 `u/nus/edu/astar/demo/` 下，但文件内部的 package 声明还是旧的 `sg.glsapp.gls`。

### ✅ 解决方案
将 MainActivity.kt 的 package 声明从 `package sg.glsapp.gls` 改为 `package u.nus.edu.astar.demo`。

---

## 🚀 使用部署脚本

### 方法 1: 完整重新编译测试
```bash
cd /Users/mbp/Desktop/18\ Jul\ 2025/localdelivery_flutter
chmod +x deploy_and_test.sh
./deploy_and_test.sh
```

这个脚本会：
1. ✅ 完全卸载旧版本 App（清除数据）
2. ✅ Flutter clean（清理构建缓存）
3. ✅ Flutter pub get（获取依赖）
4. ✅ Flutter build apk --release（编译 Release 版本）
5. ✅ adb install（安装到设备）
6. ✅ 自动授予位置权限
7. ✅ 启动日志监控

### 方法 2: 仅监控日志
```bash
chmod +x monitor_logs.sh
./monitor_logs.sh
```

---

## 📱 测试操作顺序

### ⭐ 重要：必须按顺序操作
1. 打开 LPT App
2. **【先选择车辆】** ⭐⭐⭐
   - 看到日志: `[VehicleSelection] ✅ Verification SUCCESS`
3. 输入账号密码并登录
4. 看到日志: `[LOGIN] ✅ Saved vehicleId to SharedPreferences`
5. 等待 60 秒，看到心跳: `[BG] heartbeat`
6. **Swipe 杀死 App** ⭐⭐⭐
7. 继续观察日志 1-2 分钟
8. **成功标志**: 看到 `[HEADLESS] upload success` ✅

---

## 🔍 关键配置验证

### 位置权限（手动检查）
进入手机设置：
```
设置 > 应用 > LPT > 权限 > 位置
→ 必须选择"始终允许" ⭐
```

### 后台限制（手动检查）
```
设置 > 应用 > LPT > 电池
→ 选择"无限制" ⭐
```

---

## 📊 预期日志输出

### 前台运行时
```
[VehicleSelection] ✅ Saved to SharedPreferences: xxx
[LOGIN] ✅ Saved vehicleId=xxx to SharedPreferences
[BG] start() success
[BG] ✅ Forced moving state
[BG] heartbeat @ 2025-10-28T...
[BG] upload success
```

### Swipe 后（Headless 模式）⭐⭐⭐
```
[HEADLESS] event=heartbeat at 2025-10-28T...
[HEADLESS] HEARTBEAT - fetching current position
[HEADLESS] location lat=XX.XX lon=XX.XX
[HEADLESS] vehicleId=xxx (from SharedPreferences)
[HEADLESS] ✅ upload success 2025-10-28T...
```

---

## 🐛 故障排查

### 问题 1: ClassNotFoundException
**已修复** ✅ MainActivity.kt 的 package 声明已更新

### 问题 2: 权限被拒绝
```bash
# 手动授予权限
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_FINE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_COARSE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_BACKGROUND_LOCATION
```

### 问题 3: 看不到 [HEADLESS] 日志
1. 确认位置权限设置为"始终允许"
2. 确认电池优化设置为"无限制"
3. 确认已先选择车辆再登录
4. 等待至少 60 秒后再 Swipe 杀死 App

---

## 📞 下一步

1. ✅ 执行 `./deploy_and_test.sh`
2. ✅ 按照测试顺序操作
3. ✅ 观察日志输出
4. ✅ 验证 Headless 模式是否正常工作

**Good luck! 🚀**
