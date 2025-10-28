#!/bin/bash

echo "🚀 后台定位服务 - 完整重新编译测试"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 步骤0：完全卸载旧版本 ⭐ 重要！
echo -e "${RED}📱 步骤0/6: 完全卸载旧版本 App...${NC}"
echo -e "${YELLOW}这将清除所有旧配置和数据，确保新配置生效！${NC}"
adb uninstall u.nus.edu.astar.demo
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 卸载成功${NC}"
else
    echo -e "${YELLOW}⚠️ App 未安装或卸载失败（可能未安装）${NC}"
fi
echo ""
sleep 1

# 步骤1：清理
echo -e "${YELLOW}📦 步骤1/6: 清理旧的构建文件...${NC}"
flutter clean
rm -rf android/build
rm -rf build
echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# 步骤2：获取依赖
echo -e "${YELLOW}📦 步骤2/6: 获取依赖...${NC}"
flutter pub get
echo -e "${GREEN}✅ 依赖获取完成${NC}"
echo ""

# 步骤3：检查设备连接
echo -e "${YELLOW}📱 步骤3/6: 检查设备连接...${NC}"
adb devices
echo ""
read -p "按 Enter 继续..."
echo ""

# 步骤4：编译并安装（Release 模式）
echo -e "${YELLOW}🔨 步骤4/6: 编译并安装 (Release 模式)...${NC}"
echo "这可能需要 2-5 分钟..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 编译成功${NC}"
    echo ""
    echo -e "${YELLOW}📲 安装到设备...${NC}"
    adb install build/app/outputs/flutter-apk/app-release.apk
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 安装成功${NC}"
    else
        echo -e "${RED}❌ 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ 编译失败${NC}"
    exit 1
fi
echo ""

# 步骤5：授予后台位置权限
echo -e "${YELLOW}🔐 步骤5/6: 授予后台位置权限...${NC}"
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_FINE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_COARSE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_BACKGROUND_LOCATION
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 权限授予成功${NC}"
else
    echo -e "${YELLOW}⚠️ 权限授予失败，请手动在设置中授予"始终允许"位置权限${NC}"
fi
echo ""

# 步骤6：测试提示
echo -e "${BLUE}📋 步骤6/6: 测试操作顺序 ⭐⭐⭐${NC}"
echo ""
echo -e "${GREEN}请按照以下顺序操作：${NC}"
echo -e "${YELLOW}1. 打开 LPT App${NC}"
echo -e "${YELLOW}2. 【先选择车辆】⭐ 看到 3 条日志：${NC}"
echo "   - [VehicleSelection] ✅ Saved to GetStorage"
echo "   - [VehicleSelection] ✅ Saved to SharedPreferences"
echo "   - [VehicleSelection] ✅ Verification SUCCESS"
echo ""
echo -e "${YELLOW}3. 输入账号密码并登录${NC}"
echo -e "${YELLOW}4. 看到关键日志：${NC}"
echo "   - [LOGIN] ✅ Saved vehicleId to SharedPreferences"
echo "   - [BG] ✅ Stopped old service (如果有旧服务)"
echo "   - [BG] ✅ Forced moving state"
echo "   - [BG] start() success"
echo "   - [BG] ✅ Verification: stopTimeout=0 ⭐"
echo ""
echo -e "${YELLOW}5. 等待 60 秒，看到心跳：${NC}"
echo "   - [BG] heartbeat @..."
echo "   - [BG] upload success"
echo ""
echo -e "${RED}6. Swipe 杀死 App ⭐⭐⭐${NC}"
echo ""
echo -e "${YELLOW}7. 继续观察日志 1-2 分钟，应该看到：${NC}"
echo "   - [HEADLESS] event=heartbeat ⭐⭐⭐"
echo "   - [HEADLESS] vehicleId=xxx (from SharedPreferences) ✅"
echo "   - [HEADLESS] ✅ upload success ⭐⭐⭐"
echo ""
echo -e "${GREEN}🎯 成功标志: 看到 [HEADLESS] upload success 说明完全成功！${NC}"
echo ""
read -p "按 Enter 开始监控日志..."
echo ""

# 步骤7：启动日志监控
echo -e "${YELLOW}📊 启动日志监控...${NC}"
echo "按 Ctrl+C 停止监控"
echo "=================================="
echo ""

# 清空旧日志并开始监控
adb logcat -c
adb logcat | grep -E "\[LOGIN\]|\[VehicleSelection\]|\[BG\]|\[HEADLESS\]|stopTimeout|heartbeatInterval|Location-services"
