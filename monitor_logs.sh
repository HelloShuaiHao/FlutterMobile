#!/bin/bash

echo "📊 后台定位服务 - 日志监控"
echo "=================================="
echo ""
echo "监控以下关键日志："
echo "  - [LOGIN] 登录相关"
echo "  - [VehicleSelection] 车辆选择"
echo "  - [BG] 前台定位服务"
echo "  - [HEADLESS] 后台 Headless 模式"
echo ""
echo "按 Ctrl+C 停止监控"
echo "=================================="
echo ""

# 清空旧日志并开始监控
adb logcat -c
adb logcat | grep -E "\[LOGIN\]|\[VehicleSelection\]|\[BG\]|\[HEADLESS\]|stopTimeout|heartbeatInterval|Location-services|TSLocationManager"
