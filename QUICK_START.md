# 🚀 后台定位服务 - 快速开始

## ✅ 所有修复已完成

所有必要的代码修改已经应用完毕！现在可以开始测试了。

---

## 📋 可用的脚本

### 1. 配置验证脚本
```bash
./check_config.sh
```
**功能**: 验证所有关键配置是否正确

**预期输出**:
```
✅ LocationTrackingService 配置正确
✅ LoginScreen SharedPreferences 同步正确
✅ Headless 回调配置正确
✅ VehicleSelectionWidget 配置正确
✅ Application ID 正确 (u.nus.edu.astar.demo)
✅ MainActivity package 正确
```

---

### 2. 一键快速部署 ⭐ 推荐
```bash
./quick_deploy.sh
```
**功能**: 
- 验证配置
- 卸载旧版本
- 清理并编译
- 安装到设备
- 授予权限
- 启动日志监控

**时间**: 约 3-5 分钟

---

### 3. 完整部署测试
```bash
./deploy_and_test.sh
```
**功能**: 
- 完整的编译安装流程
- 显示详细的测试步骤
- 自动启动日志监控

---

### 4. 仅监控日志
```bash
./monitor_logs.sh
```
**功能**: 实时监控关键日志

**监控内容**:
- `[LOGIN]` - 登录相关
- `[VehicleSelection]` - 车辆选择
- `[BG]` - 前台定位服务
- `[HEADLESS]` - 后台 Headless 模式

---

## 🧪 测试步骤（重要）⭐⭐⭐

### 步骤1: 运行快速部署
```bash
./quick_deploy.sh
```

### 步骤2: 在设备上操作

```
1. 打开 LPT App

2. 【先选择车辆】⭐⭐⭐ 
   在日志中应该看到：
   [VehicleSelection] ✅ Saved to GetStorage: xxx
   [VehicleSelection] ✅ Saved to SharedPreferences: xxx
   [VehicleSelection] ✅ Verification SUCCESS: xxx

3. 输入账号密码

4. 点击登录
   在日志中应该看到：
   [LOGIN] ✅ Saved token to SharedPreferences
   [LOGIN] ✅ Saved vehicleId to SharedPreferences: xxx
   [BG] calling start() ...
   [BG] ✅ Forced moving state
   [BG] start() success

5. 等待 3 分钟（180秒）
   在日志中应该看到：
   [BG] heartbeat @ ...
   [BG] ✅ upload success

6. Swipe 杀死 App ⭐⭐⭐

7. 继续观察日志 3 分钟
   在日志中应该看到：
   [HEADLESS] event=heartbeat ⭐⭐⭐
   [HEADLESS] vehicleId=xxx (from SharedPreferences) ✅
   [HEADLESS] ✅ upload success ⭐⭐⭐
```

---

## 🎯 成功标志

看到以下日志说明成功：

```
✅ [VehicleSelection] ✅ Verification SUCCESS
✅ [LOGIN] ✅ Saved vehicleId to SharedPreferences
✅ [BG] ✅ Forced moving state
✅ [BG] ✅ upload success
✅ [HEADLESS] event=heartbeat ⭐⭐⭐
✅ [HEADLESS] ✅ upload success ⭐⭐⭐
```

---

## ⚠️ 重要注意事项

### 1. 操作顺序很关键！
```
❌ 错误：先登录 → 再选车辆
✅ 正确：先选车辆 → 再登录
```

如果顺序错了，会看到：
```
[LOGIN] ⚠️ No vehicleId found in GetStorage
[HEADLESS] vehicleId=null
```

### 2. 必须授予后台位置权限
```
设置 > 应用 > LPT > 权限 > 位置
→ 选择"始终允许" ⭐
```

### 3. 必须关闭电池优化
```
设置 > 应用 > LPT > 电池
→ 选择"无限制" ⭐
```

### 4. 心跳间隔是 180 秒（3分钟）
```
不要只等 1 分钟就判断失败！
至少等待 3-5 分钟观察日志
```

---

## 🔧 故障排查

### 问题1: 看不到 [HEADLESS] 日志

**解决方法**:
```bash
# 1. 检查服务是否运行
adb shell dumpsys activity services | grep -i headless

# 2. 检查权限
adb shell dumpsys package u.nus.edu.astar.demo | grep -i location

# 3. 手动触发心跳（测试用）
adb shell am broadcast -a com.transistorsoft.flutter.backgroundgeolocation.EVENT_HEARTBEAT
```

### 问题2: [HEADLESS] vehicleId=null

**原因**: 登录前没有选择车辆

**解决**: 
1. 卸载 App
2. 重新安装
3. **先选择车辆**
4. 再登录

### 问题3: 编译失败

**解决**:
```bash
# 清理所有缓存
flutter clean
rm -rf build
rm -rf android/build
rm -rf ~/.gradle/caches

# 重新获取依赖
flutter pub get

# 重新编译
flutter build apk --release
```

---

## 📱 手机品牌特殊设置

### 小米/红米
```
设置 > 应用 > LPT
├─ 自启动：允许 ⭐
├─ 后台弹出界面：允许
├─ 省电策略：无限制 ⭐
└─ 关闭"神隐模式"
```

### 华为/荣耀
```
设置 > 应用 > LPT > 启动管理
选择"手动管理"，全部打开：
├─ 允许自启动 ⭐
├─ 允许后台活动 ⭐
└─ 允许关联启动
```

### OPPO/一加
```
设置 > 应用 > LPT
├─ 权限 > 位置：始终允许 ⭐
├─ 电池 > 后台冻结：关闭 ⭐
└─ 自启动：允许
```

---

## 📚 更多信息

详细的修复说明和技术细节请查看：
- `HEADLESS_FIX_SUMMARY.md` - 完整的修复总结

---

## 🎉 开始测试

一切准备就绪！现在运行：

```bash
./quick_deploy.sh
```

然后按照屏幕提示操作即可。

**Good luck! 🚀**

看到 `[HEADLESS] ✅ upload success` 就说明完全成功了！
