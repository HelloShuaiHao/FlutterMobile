#!/bin/bash

echo "🔍 冷启动恢复问题诊断工具"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}这个脚本将帮助你诊断重复打开 App 时的报错问题${NC}"
echo ""

# 步骤1：清空日志
echo -e "${BLUE}步骤1: 清空旧日志${NC}"
adb logcat -c
echo -e "${GREEN}✅ 日志已清空${NC}"
echo ""

# 步骤2：启动实时日志监控
echo -e "${BLUE}步骤2: 启动实时日志监控${NC}"
echo -e "${YELLOW}请按以下步骤操作：${NC}"
echo ""
echo "1️⃣  打开 App 并登录"
echo "2️⃣  等待看到 [BG] upload success"
echo "3️⃣  Swipe 杀死 App"
echo "4️⃣  等待 5-10 秒，观察 Headless 日志"
echo "5️⃣  重新打开 App"
echo "6️⃣  观察是否有错误"
echo "7️⃣  再次 Swipe 杀死"
echo "8️⃣  再次打开 App - 看这次是否报错 ⭐"
echo ""
echo -e "${RED}重点观察：${NC}"
echo "  • [HEADLESS] ⏭️ Skipping duplicate upload - 说明去重生效"
echo "  • [BG][COLD_START] Headless boot event handled recently - 说明避免了冲突"
echo "  • 任何包含 'error'、'exception'、'failed' 的行"
echo ""
read -p "按 Enter 开始监控..."
echo ""

# 创建临时日志文件
LOGFILE="/tmp/lpt_debug_$(date +%Y%m%d_%H%M%S).log"

echo -e "${GREEN}📊 日志监控中... (同时保存到 $LOGFILE)${NC}"
echo -e "${YELLOW}按 Ctrl+C 停止监控${NC}"
echo "=================================="
echo ""

# 监控日志并保存
adb logcat | tee "$LOGFILE" | grep -E "\[LOGIN\]|\[VehicleSelection\]|\[BG\]|\[HEADLESS\]|\[MAIN\]|\[DHOME\]|error|Error|ERROR|exception|Exception|EXCEPTION|failed|Failed|FAILED|stopTimeout|heartbeatInterval" --color=always

# 脚本结束后的提示
echo ""
echo -e "${BLUE}=================================="
echo -e "日志已保存到: $LOGFILE"
echo -e "=================================="${NC}
echo ""
echo -e "${YELLOW}如果看到错误，请发送以下信息：${NC}"
echo "1. 完整的错误日志（从 logcat 中）"
echo "2. 错误发生的时间点（第几次打开 App）"
echo "3. 日志文件路径：$LOGFILE"
