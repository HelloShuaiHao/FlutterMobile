#!/bin/bash

echo "🔍 后台定位配置验证"
echo "=================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "检查关键配置文件..."
echo ""

# 检查 LocationTrackingService.dart
echo "1. 检查 LocationTrackingService.dart 配置..."
if grep -q "stopTimeout: 0" lib/main/services/LocationTrackingService.dart && \
   grep -q "disableStopDetection: true" lib/main/services/LocationTrackingService.dart && \
   grep -q "DESIRED_ACCURACY_HIGH" lib/main/services/LocationTrackingService.dart && \
   grep -q "distanceFilter: 50" lib/main/services/LocationTrackingService.dart && \
   grep -q "changePace(true)" lib/main/services/LocationTrackingService.dart; then
    echo -e "${GREEN}✅ LocationTrackingService 配置正确${NC}"
else
    echo -e "${RED}❌ LocationTrackingService 配置有问题${NC}"
fi

# 检查 LoginScreen.dart
echo "2. 检查 LoginScreen.dart SharedPreferences 同步..."
if grep -q "SharedPreferences.getInstance()" lib/main/screens/LoginScreen.dart && \
   grep -q "prefs.setString('vehicleId'" lib/main/screens/LoginScreen.dart && \
   grep -q "prefs.setString('USER_TOKEN'" lib/main/screens/LoginScreen.dart; then
    echo -e "${GREEN}✅ LoginScreen SharedPreferences 同步正确${NC}"
else
    echo -e "${RED}❌ LoginScreen 缺少 SharedPreferences 同步${NC}"
fi

# 检查 background_geolocation_headless.dart
echo "3. 检查 background_geolocation_headless.dart..."
if grep -q "SharedPreferences.getInstance()" lib/main/background_geolocation_headless.dart && \
   grep -q "prefs.getString('vehicleId')" lib/main/background_geolocation_headless.dart && \
   grep -q "HEADLESS.*HEARTBEAT" lib/main/background_geolocation_headless.dart; then
    echo -e "${GREEN}✅ Headless 回调配置正确${NC}"
else
    echo -e "${RED}❌ Headless 回调配置有问题${NC}"
fi

# 检查 VehicleSelectionWidget.dart
echo "4. 检查 VehicleSelectionWidget.dart..."
if grep -q "SharedPreferences.getInstance()" lib/delivery/widgets/VehicleSelectionWidget.dart && \
   grep -q "prefs.setString('vehicleId'" lib/delivery/widgets/VehicleSelectionWidget.dart && \
   grep -q "Verification SUCCESS" lib/delivery/widgets/VehicleSelectionWidget.dart; then
    echo -e "${GREEN}✅ VehicleSelectionWidget 配置正确${NC}"
else
    echo -e "${RED}❌ VehicleSelectionWidget 配置有问题${NC}"
fi

# 检查 Application ID
echo "5. 检查 Application ID..."
if grep -q 'applicationId "u.nus.edu.astar.demo"' android/app/build.gradle && \
   grep -q 'namespace = "u.nus.edu.astar.demo"' android/app/build.gradle && \
   grep -q 'package="u.nus.edu.astar.demo"' android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ Application ID 正确 (u.nus.edu.astar.demo)${NC}"
else
    echo -e "${RED}❌ Application ID 不正确${NC}"
fi

# 检查 MainActivity package
echo "6. 检查 MainActivity package..."
if grep -q 'package u.nus.edu.astar.demo' android/app/src/main/kotlin/com/mighty/delivery/MainActivity.kt; then
    echo -e "${GREEN}✅ MainActivity package 正确${NC}"
else
    echo -e "${RED}❌ MainActivity package 不正确${NC}"
fi

echo ""
echo "=================================="
echo "验证完成！"
echo ""
echo -e "${YELLOW}提示: 如果所有检查都通过，可以运行 ./deploy_and_test.sh 开始测试${NC}"
