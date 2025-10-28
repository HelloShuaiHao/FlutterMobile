#!/bin/bash

echo "🚀 快速重新部署（修复 BootReceiver 错误）"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 步骤1：完全卸载
echo -e "${RED}📱 步骤1/5: 完全卸载旧版本...${NC}"
adb uninstall u.nus.edu.astar.demo
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 卸载成功${NC}"
else
    echo -e "${YELLOW}⚠️ App 未安装或卸载失败${NC}"
fi
echo ""

# 步骤2：清理构建
echo -e "${YELLOW}📦 步骤2/5: 清理构建文件...${NC}"
flutter clean
rm -rf android/build build
echo -e "${GREEN}✅ 清理完成${NC}"
echo ""

# 步骤3：获取依赖
echo -e "${YELLOW}📦 步骤3/5: 获取依赖...${NC}"
flutter pub get
echo -e "${GREEN}✅ 依赖获取完成${NC}"
echo ""

# 步骤4：构建并安装
echo -e "${YELLOW}🔨 步骤4/5: 构建并安装 APK...${NC}"
flutter build apk --release
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 构建成功${NC}"
    adb install build/app/outputs/flutter-apk/app-release.apk
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 安装成功${NC}"
    else
        echo -e "${RED}❌ 安装失败${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ 构建失败${NC}"
    exit 1
fi
echo ""

# 步骤5：授权
echo -e "${YELLOW}🔐 步骤5/5: 授予权限...${NC}"
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_FINE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_COARSE_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.ACCESS_BACKGROUND_LOCATION
adb shell pm grant u.nus.edu.astar.demo android.permission.POST_NOTIFICATIONS
echo -e "${GREEN}✅ 权限授予完成${NC}"
echo ""

# 完成
echo -e "${GREEN}=================================="
echo -e "✅ 重新部署完成！"
echo -e "==================================${NC}"
echo ""
echo -e "${BLUE}📋 测试步骤：${NC}"
echo "1️⃣  打开 App 并登录"
echo "2️⃣  等待定位服务启动"
echo "3️⃣  Swipe 杀死 App"
echo "4️⃣  重新打开 App"
echo "5️⃣  观察是否还有 ClassNotFoundException"
echo ""
echo -e "${YELLOW}如需监控日志，运行：${NC}"
echo "adb logcat | grep -E '\[BG\]|\[HEADLESS\]|\[MAIN\]|\[DHOME\]|AndroidRuntime'"
echo ""
