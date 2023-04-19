#!/bin/bash

# 設定存放變數的檔案名稱
VAR_FILE=".last_build_vars"

# 讀取存放變數的檔案，如果檔案不存在就建立一個
if [ -f "$VAR_FILE" ]; then
  source "$VAR_FILE"
else
  touch "$VAR_FILE"
fi

# 詢問是否使用上次的類型
if [ -n "$codename" ] && [ -n "$build" ]; then
  read -p "上次的裝置類型為 $codename-$build （Gapps: $gapps_option），是否要使用？(y/n): " reuse_last
  if [[ "$reuse_last" == "y" || "$reuse_last" == "Y" ]]; then
    echo "使用上次的裝置類型 $codename-$build 和 Gapps 編譯選項 $gapps_option"
    if [["$gapps_option"]] == "編譯"; then
      export ARROW_GAPPS=true;
      export TARGET_GAPPS_ARCH=arm64;
    elif [["$gapps_option"]] == "不編譯"; then
      export ARROW_GAPPS=false;
      export TARGET_GAPPS_ARCH=arm64;
    else
      echo "Gapps 編譯選項錯誤，請重新執行腳本"
      exit 1
    fi
  else
    reuse_last="n"
  fi
else
  reuse_last="n"
fi

# 如果不使用上次的類型，就詢問新的裝置類型和編譯選項
if [[ "$reuse_last" == "n" ]]; then
  read -p "請輸入編譯設備的裝置代號: " codename
  read -p "請輸入編譯設備的變體: " build
  while true; do
    read -p "是否編譯 Gapps 套件？(y/n): " gapps_input
    case $gapps_input in
      [Yy]* )
        gapps_option="編譯";
        export ARROW_GAPPS=true;
        export TARGET_GAPPS_ARCH=arm64;
        break;;
      [Nn]* )
        gapps_option="不編譯";
        break;;
      * ) echo "請輸入 y 或 n.";;
    esac
  done

  # 將變數寫入檔案
  echo "codename=$codename" > "$VAR_FILE"
  echo "build=$build" >> "$VAR_FILE"
  echo "gapps_option=$gapps_option" >> "$VAR_FILE"
fi

# 初始化構建環境
. build/envsetup.sh

# 選擇裝置類型
lunch "arrow_$codename-$build"

# 編譯
make bacon -j$(nproc --all)
