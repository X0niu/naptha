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
        echo "2. 删除 Naptha 节点"  # 新增删除节点的选项
        echo "3. 查看 PRIVATE_KEY"  # 新增查看 PRIVATE_KEY 的选项
        read -p "请输入操作编号: " option

        case $option in
            1)
                install_naptha_node
                ;;
            2)
                remove_naptha_node  # 调用删除节点的函数
                ;;
            3)
                view_private_key  # 调用查看 PRIVATE_KEY 的函数
                ;;
            *)
                echo "无效的选项，请重新输入..."
                sleep 2
                ;;
        esac
    done
}

# 删除 Naptha 节点的函数
function remove_naptha_node() {
    echo "正在删除 Naptha 节点..."
    bash docker-ctl.sh down
    echo "Naptha 节点已删除"

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 查看 PRIVATE_KEY 的函数
function view_private_key() {
    echo "查看 PRIVATE_KEY..."
    # 直接打开目录中的 .pem 文件
    for pem_file in /root/node/*.pem; do
        if [ -f "$pem_file" ]; then
            echo "打开文件: $pem_file"
            cat "$pem_file"  # 输出文件内容
            echo "-----------------------------"
        else
            echo "没有找到 .pem 文件"
        fi
    done
    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
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

    # 检查 Python3 和 pip 是否已安装
    if ! command -v python3 &> /dev/null
    then
        echo "Python3 未安装，正在安装 Python3..."
        sudo apt-get install -y python3
    else
        echo "Python3 已安装"
    fi

    if ! command -v pip3 &> /dev/null
    then
        echo "pip3 未安装，正在安装 pip3..."
        sudo apt-get install -y python3-pip
    else
        echo "pip3 已安装"
    fi

    # 检查 Poetry 是否已安装及版本
    if command -v poetry &> /dev/null
    then
        POETRY_VERSION=$(poetry --version | awk '{print \$2}')
        if [[ $(echo "$POETRY_VERSION < 1.2" | bc -l) -eq 1 ]]; then
            echo "Poetry 版本低于 1.2，正在更新 Poetry..."
            curl -sSL https://install.python-poetry.org | python3 -
        else
            echo "Poetry 已安装，版本为 $POETRY_VERSION"
        fi
    else
        echo "Poetry 未安装，正在安装 Poetry..."
        curl -sSL https://install.python-poetry.org | python3 -
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

    # 修改 .env 文件中的 LAUNCH_DOCKER=false 为 LAUNCH_DOCKER=true
    sed -i 's/LAUNCH_DOCKER=false/LAUNCH_DOCKER=true/' .env
    echo "已将 .env 文件中的 LAUNCH_DOCKER 设置为 true"
    else
    echo ".env.example 文件不存在，无法复制为 .env"
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

    # 提示用户按任意键返回主菜单
    read -n 1 -s -r -p "按任意键返回主菜单..."
    main_menu
}

# 调用主菜单
main_menu
