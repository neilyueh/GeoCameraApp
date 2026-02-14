#!/bin/bash

# Git 設定腳本
# 請在 Xcode 關閉後執行此腳本

echo "正在添加檔案到 Git..."
git add .

echo "正在建立 commit..."
git commit -m "Initial project setup

- Created Xcode project with SwiftUI
- Set deployment target to iOS 14.0
- Created folder structure (Views, ViewModels, Services, Models, Utilities, Resources)
- Added .gitignore for Xcode project

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

echo "完成！查看 commit 歷史："
git log --oneline -1

echo ""
echo "✅ Git 設定完成！"
