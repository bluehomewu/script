#!/bin/bash

# 執行編譯系統的環境建構腳本指令
. build/envsetup.sh

# 詢問使用者輸入編譯設備的裝置代號
read -p "請輸入編譯設備的裝置代號: " codename

# 詢問使用者輸入編譯設備的變體
read -p "請輸入編譯設備的變體: " build

# 詢問使用者是否需要編譯 Gapps 套件
answer=""
while [[ ! "${answer,,}" =~ ^(y|n|yes|no)$ ]]; do
  read -p "是否需要編譯 Gapps 套件 (Y/N)? " answer
  case ${answer,,} in
    y|yes)
      # 如果回答 Y 或是 YES（大小寫皆可）, 則執行下列指令
      export ARROW_GAPPS=true
      export TARGET_GAPPS_ARCH=arm64
      ;;
    n|no)
      # 如果回答 N 或是 NO（大小寫皆可）, 則不執行任何指令
      ;;
    *)
      echo "無效的回答，請重新輸入"
      answer=""
      ;;
  esac
done

# 執行 lunch 指令
lunch arrow_${codename}-${build}

# 執行 make 指令
make bacon -j$(nproc --all)
