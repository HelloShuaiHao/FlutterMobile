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
echo -e "${BLUE}📋 步骤6/6: 冷启动恢复测试 ⭐⭐⭐${NC}"
echo ""
echo -e "${GREEN}测试顺序：${NC}"
echo -e "${YELLOW}1. 登录并查看 3 个关键日志${NC}"
echo "   - [BG] ✅ Forced moving state"
echo "   - [BG] periodic uploader started"
echo "   - [BG] upload success"
echo ""
echo -e "${RED}2. Swipe 杀死 App (第一次)${NC}"
echo "   - 应看到 [HEADLESS] event=boot"
echo "   - [HEADLESS] ✅ upload success"
echo ""
echo -e "${YELLOW}3. 等待 10 秒，重新打开 App (第一次)${NC}"
echo "   - 应看到 [MAIN] Checking cold start state"
echo "   - [BG][COLD_START] Headless boot event handled recently"
echo "   - [DHOME] ✅ Location service already running"
echo "   - 无报错，正常显示界面 ✅"
echo ""
echo -e "${RED}4. 再次 Swipe 杀死 (第二次)${NC}"
echo "   - 重复观察 Headless 上传"
echo ""
echo -e "${GREEN}5. 再次打开 (第二次) - 关键测试点！${NC}"
echo "   - 如果出现报错 -> 说明冲突未解决 ❌"
echo "   - 正常应该：平滑恢复 + 心跳继续 ✅"
echo "   - 验证日志："
echo "     • [BG][COLD_START] Headless boot event handled recently"
echo "     • [DHOME] ✅ Location service already running"
echo "     • 无异常错误"
echo ""
echo -e "${BLUE}6. 继续测试 (第三次、第四次...)${NC}"
echo "   - 重复 Swipe + 打开，观察是否持续稳定"
echo "   - 每次打开都应该平滑恢复，无报错"
echo ""
echo -e "${GREEN}🎯 成功标志：${NC}"
echo "   1. Headless 持续上传位置"
echo "   2. 每次重新打开无报错"
echo "   3. 心跳间隔稳定 (60秒)"
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
adb logcat | grep -E "\[LOGIN\]|\[VehicleSelection\]|\[BG\]|\[HEADLESS\]|\[MAIN\]|\[DHOME\]|stopTimeout|heartbeatInterval|Location-services"
