#!/bin/bash

app_name="OpenIn"
app_full_name="${app_name}.app"
app_path="/Applications/${app_full_name}"
app_release_path=https://github.com/TozyZuo/OpenIn.Public/releases/latest
version_file=${app_path}/Contents/Info.plist

# 安装
install_version() {
  installed="y"
  _version=$1
  echo 开始下载 v${_version}……
  _version=${_version//~b/%25b}
  # 下载压缩包
  curl -L -o ${_version}.zip https://github.com/TozyZuo/OpenIn.Public/releases/download/v${_version}/${app_full_name}.zip
  if [ 0 -eq $? ]; then
    echo 下载完成
    # 解压为同名文件夹
    unzip -o -q ${_version}.zip -d /Applications
    # 删除压缩包
    rm ${_version}.zip
    echo 安装完成
    open $app_path --args "-s"
  else
    echo 下载失败，请稍后重试。
  fi
}

# 获取当前版本
if [ -f $version_file ]; then
  current_version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $version_file)
  current_version=${current_version//$'\r'/}
  echo 当前${app_name}版本为 v${current_version}
fi

if [ -z $latest_version ]; then
  echo 正在检查新版本……
  latest_version=$(curl -I -s ${app_release_path} | grep Location | sed -n 's/.*\/v\(.*\)/\1/p')
  latest_version=${latest_version//$'\r'/}
  if [ -z "$latest_version" ]; then
    echo 检查新版本时失败
  else
    latest_version=${latest_version//%25b/~b}

    echo 最新版本为 v${latest_version}

    current_version_array=(${current_version//~b/ })
    latest_version_array=(${latest_version//~b/ })
    need_update=false

    vlast=${latest_version_array[0]}
    vcur=${current_version_array[0]}

    # 版本号大
    if [[ $vlast > $vcur ]]; then
      need_update=true
    elif [[ $vlast = $vcur ]]; then
      # beta版本号大
      if [[ ${latest_version_array[1]} > ${current_version_array[1]} ]]; then
        need_update=true
      # 更新release  
      elif [[ ${#latest_version_array[@]} = 1 && ${#current_version_array[@]} != 1 ]]; then
        need_update=true
      fi
    fi

    if $need_update; then
      install_version $latest_version
    else
      echo 当前已是最新版本。
    fi
  fi
fi
