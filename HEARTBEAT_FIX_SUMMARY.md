# 🔧 后台定位心跳修复总结

## 📋 问题分析

从原生日志和监控脚本发现：

### **问题现象**
```
[CONFIG] preventSuspend=null  ❌
[CONFIG] scheduleUseAlarmManager=true  ✅
[CONFIG] heartbeatInterval=60  ✅
```

**关键问题**：
1. ❌ **没有任何心跳触发**（60秒后仍无心跳日志）
2. ❌ `preventSuspend` 配置为 `null`（未生效）
3. ✅ App swipe 后进入 `paused` 状态
4. ❌ 原生日志中没有 `TSLocationManager: ❤️` 心跳

---

## 🛠️ 修复方案

### **修改 1: 重写 `_configure()` - 两步配置法**

**文件**: `lib/main/services/LocationTrackingService.dart`

**策略**: 使用 `ready()` + `setConfig()` 双重配置，确保关键参数生效

````dart
Future<void> _configure() async {
  if (_configured) {
    print('[BG] already configured, skipping');
    return;
  }

  print('[BG] configuring plugin...');
  bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
  bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);

  try {
    // ⭐ 步骤1：使用 ready() 初始化基础配置
    final state = await bg.BackgroundGeolocation.ready(bg.Config(
      reset: false,
      
      // 核心配置
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      foregroundService: true,
      
      // 心跳配置（关键！）
      heartbeatInterval: 60,
      
      // 停止检测配置
      disableStopDetection: true,
      stopTimeout: 0,
      stopOnStationary: false,
      
      // 位置更新配置
      distanceFilter: 0,
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      locationUpdateInterval: 60000,
      fastestLocationUpdateInterval: 30000,
      allowIdenticalLocations: true,
      
      // 电池优化相关
      disableElasticity: true,
      activityType: bg.Config.ACTIVITY_TYPE_OTHER,
      
      // 调试配置
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      logMaxDays: 3,
      
      notification: bg.Notification(
        title: 'Location Service Running',
        text: 'Tracking delivery position',
        channelName: 'DeliveryTracking',
        priority: bg.Config.NOTIFICATION_PRIORITY_HIGH,
        sticky: true,
      ),
    ));

    print('[BG] ready() -> enabled=${state.enabled}');

    // ⭐ 步骤2：使用 setConfig 强制应用关键配置
    await bg.BackgroundGeolocation.setConfig(bg.Config(
      heartbeatInterval: 60,
      disableStopDetection: true,
      stopTimeout: 0,
      distanceFilter: 0,
      locationUpdateInterval: 60000,
      fastestLocationUpdateInterval: 30000,
    ));
    
    print('[BG] ✅ Advanced config applied via setConfig');

    // ⭐ 步骤3：验证配置是否生效
    final verifyState = await bg.BackgroundGeolocation.state;
    print('[BG] ✅ Verification: heartbeatInterval=${verifyState.heartbeatInterval}');
    print('[BG] ✅ Verification: stopTimeout=${verifyState.stopTimeout}');
    print('[BG] ✅ Verification: disableStopDetection=${verifyState.disableStopDetection}');
    print('[BG] ✅ Verification: distanceFilter=${verifyState.distanceFilter}');
    print('[BG] ✅ Verification: locationUpdateInterval=${verifyState.locationUpdateInterval}');
    print('[BG] ✅ Verification: scheduleUseAlarmManager=${verifyState.scheduleUseAlarmManager}');

    if (verifyState.enabled) {
      _started = true;
      _cachedIdentityUserId ??= SpUtil.token.val;
      _startPeriodicUploader();
      await _tryUpload(
        force: true,
        identityUserId: _cachedIdentityUserId ?? '',
      );
    }
    
    _configured = true;
    print('[BG] configure done');
  } catch (e, stack) {
    print('[BG] ❌ configure error: $e');
    print(stack);
    rethrow;
  }
}
````

---

### **修改 2: 增强 Headless 配置验证**

**文件**: `lib/main/background_geolocation_headless.dart`

**策略**: 添加详细的配置检查日志，确保参数正确

````dart
Future<void> _ensureConfig() async {
  try {
    final state = await bg.BackgroundGeolocation.state;
    
    // 检查关键配置项并打印详细信息
    final needsReconfigure = 
        state.distanceFilter != 0 || 
        state.heartbeatInterval != 60 ||
        state.stopTimeout != 0 ||
        state.disableStopDetection != true;
    
    if (needsReconfigure) {
      print('[HEADLESS] ⚠️ Config mismatch detected, enforcing...');
      print('[HEADLESS]   distanceFilter: ${state.distanceFilter} (expected: 0)');
      print('[HEADLESS]   heartbeatInterval: ${state.heartbeatInterval} (expected: 60)');
      print('[HEADLESS]   stopTimeout: ${state.stopTimeout} (expected: 0)');
      print('[HEADLESS]   disableStopDetection: ${state.disableStopDetection} (expected: true)');
      
      await bg.BackgroundGeolocation.setConfig(bg.Config(
        distanceFilter: 0,
        heartbeatInterval: 60,
        stopTimeout: 0,
        disableStopDetection: true,
        locationUpdateInterval: 60000,
        fastestLocationUpdateInterval: 30000,
        // ...其他配置
      ));
      
      print('[HEADLESS] ✅ Config enforced');
    } else {
      print('[HEADLESS] ✅ Config is correct');
    }
    
    if (state.isMoving != true) {
      await bg.BackgroundGeolocation.changePace(true);
      print('[HEADLESS] ✅ Forced moving state');
    }
  } catch (e) {
    print('[HEADLESS] ❌ ensureConfig error: $e');
  }
}
````

---

### **修改 3: 添加心跳诊断测试**

**文件**: `lib/main/services/LocationTrackingService.dart`

在 `startTracking` 方法最后添加：

````dart
// 启动后立即测试心跳机制
print('[BG] 🧪 Testing heartbeat mechanism...');

// 检查原生调度器状态
final scheduleState = await bg.BackgroundGeolocation.state;
print('[BG] 📋 Native scheduler state:');
print('[BG]   - heartbeatInterval: ${scheduleState.heartbeatInterval}s');
print('[BG]   - enabled: ${scheduleState.enabled}');
print('[BG]   - isMoving: ${scheduleState.isMoving}');
print('[BG]   - trackingMode: ${scheduleState.trackingMode}');
print('[BG]   - distanceFilter: ${scheduleState.distanceFilter}');

print('[BG] ✅ Service started with heartbeat=${scheduleState.heartbeatInterval}s');
print('[BG] ⏰ Next heartbeat expected in ~60 seconds...');
````

---

## 🧪 测试步骤

### **1. 完全重新编译部署**
```bash
./deploy_and_test.sh
```

### **2. 启动心跳监控脚本**
```bash
./monitor_heartbeat.sh
```

### **3. 登录并观察配置验证**

登录后应该看到：
```
[STATUS] [BG] configuring plugin...
[STATUS] [BG] ready() -> enabled=false
[STATUS] [BG] ✅ Advanced config applied via setConfig
[CONFIG] [BG] ✅ Verification: heartbeatInterval=60
[CONFIG] [BG] ✅ Verification: stopTimeout=0
[CONFIG] [BG] ✅ Verification: disableStopDetection=true
[CONFIG] [BG] ✅ Verification: distanceFilter=0
[CONFIG] [BG] ✅ Verification: scheduleUseAlarmManager=true
[STATUS] [BG] configure done
[STATUS] [BG] calling start() ...
[STATUS] [BG] start() success
[STATUS] [BG] ✅ Forced moving state
[STATUS] [BG] 🧪 Testing heartbeat mechanism...
[STATUS] [BG] 📋 Native scheduler state:
[STATUS] [BG]   - heartbeatInterval: 60s
[STATUS] [BG]   - enabled: true
[STATUS] [BG]   - isMoving: true
[STATUS] [BG] ✅ Service started with heartbeat=60s
[STATUS] [BG] ⏰ Next heartbeat expected in ~60 seconds...
```

### **4. 等待 60-90 秒观察心跳**

**预期日志**（第一个心跳）：
```
[FLUTTER] [BG] ❤️ heartbeat @ 2025-10-28T18:XX:XX.XXXXXX
[FLUTTER] [BG] ❤️ State check: enabled=true isMoving=true
[FLUTTER] [BG] ❤️ Heartbeat config: interval=60s alarm=true
[NATIVE] TSLocationManager: ❤️ Heartbeat fired
```

如果看到这些日志 → ✅ **心跳机制正常工作**

### **5. Swipe App 后观察**

Swipe 杀死 App，继续观察日志：

**情况 A**：进程仍存活（paused 状态）
```
[LIFECYCLE] [DHOME] App lifecycle changed to: AppLifecycleState.paused
⚠️  App 进入 paused 状态，观察是否继续有心跳...

# 60秒后应该仍然看到：
[FLUTTER] [BG] ❤️ heartbeat @ ...
```

**情况 B**：进程被完全杀死
```
# 应该看到 Headless 日志：
[HEADLESS] event=heartbeat at ...
[HEADLESS] ✅ upload success
```

---

## 🔍 问题排查

### **如果 60 秒后仍无心跳**

#### **检查 1: 原生日志**
```bash
adb logcat | grep -i "TSLocationManager\|HeartbeatService\|ScheduleManager"
```

查找：
- `⏰ Scheduled Heartbeat` - 心跳是否被调度
- `❌ Heartbeat disabled` - 心跳是否被禁用
- `Doze mode` - 是否被省电模式限制

#### **检查 2: 电池优化状态**
```bash
adb shell dumpsys deviceidle whitelist | grep "u.nus.edu.astar.demo"
```

如果没有输出 → 需要手动禁用电池优化：
```
设置 > 应用 > LPT > 电池 > 不限制
```

#### **检查 3: AlarmManager 权限**
```bash
adb shell dumpsys alarm | grep "u.nus.edu.astar.demo"
```

应该看到类似：
```
RTC #0: Alarm{... type 0 when ... u.nus.edu.astar.demo}
  tag=*alarm*:com.transistorsoft.locationmanager.service.HeartbeatService
```

如果没有 → AlarmManager 未调度，可能是权限问题

---

## 🎯 成功标准

| 测试项 | 预期结果 | 验证方法 |
|--------|---------|---------|
| **配置应用** | `heartbeatInterval=60` | 看配置验证日志 |
| **心跳触发** | 60秒内第一次心跳 | 看 `❤️ heartbeat` 日志 |
| **持续心跳** | 每60秒一次 | 观察3-5分钟 |
| **Swipe后** | 心跳继续或Headless触发 | 看 `[BG]` 或 `[HEADLESS]` |
| **位置上传** | 每次心跳后上传 | 看 `upload success` 日志 |

---

## 📊 修改文件清单

1. ✅ `lib/main/services/LocationTrackingService.dart`
   - 重写 `_configure()` 使用两步配置法
   - 添加详细的配置验证日志
   - 添加心跳诊断测试

2. ✅ `lib/main/background_geolocation_headless.dart`
   - 增强 `_ensureConfig()` 配置检查
   - 添加详细的配置对比日志

3. ✅ `monitor_heartbeat.sh`
   - 创建专用心跳监控脚本
   - 彩色日志输出
   - 智能过滤关键信息

---

## 🆘 常见问题

### **Q1: 配置验证时 `scheduleUseAlarmManager=null`**
**A**: 该属性可能不在旧版本插件中，但 `heartbeatInterval` 生效即可。

### **Q2: 60秒后仍无心跳**
**A**: 
1. 检查电池优化是否禁用
2. 检查原生日志中是否有错误
3. 尝试强制杀死进程（而不是swipe）

### **Q3: Swipe后没有Headless日志**
**A**: 
- Swipe 只会暂停进程（paused），不会完全杀死
- 应该看到 `[BG]` 心跳继续，而不是 `[HEADLESS]`
- 如果要测试Headless，使用 `adb shell am force-stop u.nus.edu.astar.demo`

---

**修复日期**: 2025-10-28  
**修复作者**: GitHub Copilot  
**版本**: v3.0 - 后台心跳配置修复
