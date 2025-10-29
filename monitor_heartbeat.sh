#!/bin/bash

echo "❤️  后台定位心跳监控脚本"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 清空日志
adb logcat -c

echo -e "${GREEN}🎯 监控目标：${NC}"
echo "  1. Flutter 心跳日志: [BG] ❤️ heartbeat"
echo "  2. 原生心跳日志: TSLocationManager: ❤️"
echo "  3. AlarmManager 调度: alarm"
echo "  4. Headless 心跳: [HEADLESS] event=heartbeat"
echo ""

echo -e "${YELLOW}📋 测试流程：${NC}"
echo "  1. 在手机上登录 App"
echo "  2. 等待看到 [BG] ❤️ heartbeat 日志 (应该 60 秒一次)"
echo "  3. Swipe 杀死 App"
echo "  4. 观察是否继续有心跳日志"
echo ""

echo -e "${BLUE}开始监控...${NC}"
echo "按 Ctrl+C 停止"
echo "=================================="
echo ""

# 启动日志监控
adb logcat | while read -r line; do
  # Flutter 心跳
  if echo "$line" | grep -q "\[BG\].*❤️.*heartbeat"; then
    echo -e "${GREEN}[FLUTTER] $line${NC}"
  
  # Flutter 心跳状态检查
  elif echo "$line" | grep -q "\[BG\].*❤️.*State check"; then
    echo -e "${BLUE}[FLUTTER] $line${NC}"
  
  # Flutter 心跳配置
  elif echo "$line" | grep -q "\[BG\].*❤️.*Heartbeat config"; then
    echo -e "${MAGENTA}[FLUTTER] $line${NC}"
  
  # Headless 心跳
  elif echo "$line" | grep -q "\[HEADLESS\].*heartbeat"; then
    echo -e "${GREEN}[HEADLESS] $line${NC}"
  
  # 原生 TSLocationManager 心跳
  elif echo "$line" | grep -q "TSLocationManager.*❤️"; then
    echo -e "${GREEN}[NATIVE] $line${NC}"
  
  # AlarmManager 心跳相关
  elif echo "$line" | grep -iq "alarm.*heartbeat"; then
    echo -e "${YELLOW}[ALARM] $line${NC}"
  
  # TSLocationManager 心跳调度
  elif echo "$line" | grep -q "TSLocationManager.*schedule.*heartbeat"; then
    echo -e "${YELLOW}[SCHEDULE] $line${NC}"
  
  # 配置验证
  elif echo "$line" | grep -q "Verification:.*heartbeatInterval\|Verification:.*scheduleUseAlarmManager\|Verification:.*preventSuspend"; then
    echo -e "${MAGENTA}[CONFIG] $line${NC}"
  
  # App 生命周期
  elif echo "$line" | grep -q "\[DHOME\].*lifecycle.*paused"; then
    echo -e "${RED}[LIFECYCLE] $line${NC}"
    echo -e "${RED}⚠️  App 进入 paused 状态，观察是否继续有心跳...${NC}"
  
  # 启动和停止
  elif echo "$line" | grep -q "\[BG\].*start()\|configured\|stopped"; then
    echo -e "${BLUE}[STATUS] $line${NC}"
  fi
done
