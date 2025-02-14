#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/naptha.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由大赌社区哈哈哈哈编写，推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "如有问题，可联系推特，仅此只有一个号"
        echo "================================================================"
        echo "退出脚本，请按键盘 ctrl + C 退出即可"
        echo "请选择要执行的操作:"
        echo "1. 安装 Naptha 节点"
        echo "2. 退出"
        read -p "请输入操作编号: " option

        case $option in
            1)
                install_naptha_node
                ;;
            2)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选项，请重新输入..."
                sleep 2
                ;;
        esac
    done
}

# 安装 Naptha 节点的函数
function install_naptha_node() {
    echo "正在安装 Naptha 节点..."

    # 检查 Docker 是否已安装
    if ! command -v docker &> /dev/null
    then
        echo "Docker 未安装，正在安装 Docker..."
        # 安装 Docker
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo systemctl start docker
        sudo systemctl enable docker
        echo "Docker 安装完成"
    else
        echo "Docker 已安装"
    fi

    # 检查 Docker Compose 是否已安装
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose 未安装，正在安装 Docker Compose..."
        # 安装 Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker Compose 安装完成"
    else
        echo "Docker Compose 已安装"
    fi

    # 克隆 Git 仓库
    echo "正在克隆 Git 仓库..."
    git clone https://github.com/NapthaAI/node.git

    # 进入克隆的目录
    cd node

    # 复制 .env.example 为 .env
    if [ -f .env.example ]; then
        cp .env.example .env
        echo ".env.example 文件已复制为 .env"
    else
        echo ".env.example 文件不存在，无法复制为 .env"
    fi

    # 修改 .env 文件中的 LAUNCH_DOCKER=false 为 LAUNCH_DOCKER=true
    if [ -f .env ]; then
        # 使用 sed 命令替换 LAUNCH_DOCKER=false 为 LAUNCH_DOCKER=true
        sed -i 's/LAUNCH_DOCKER=false/LAUNCH_DOCKER=true/' .env
        echo ".env 文件中的 LAUNCH_DOCKER 已修改为 true"
    else
        echo ".env 文件不存在，无法修改 LAUNCH_DOCKER"
    fi

    # 执行 launch.sh
    if [ -f launch.sh ]; then
        echo "正在执行 launch.sh..."
        bash launch.sh
    else
        echo "launch.sh 文件不存在，无法执行"
    fi

    # 输出脚本路径
    echo "脚本保存路径：$SCRIPT_PATH"
}

# 调用主菜单
main_menu
