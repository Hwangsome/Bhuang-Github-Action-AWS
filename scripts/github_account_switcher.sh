#!/bin/bash

# GitHub账号切换脚本
# 用法: ./github_account_switcher.sh [personal|work]

# 颜色设置
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置信息
PERSONAL_NAME="YOUR_PERSONAL_NAME"  # 替换为您的个人姓名
PERSONAL_EMAIL="YOUR_PERSONAL_EMAIL"  # 替换为您的个人邮箱
PERSONAL_SSH_KEY="$HOME/.ssh/id_rsa_personal"  # 个人SSH密钥路径

WORK_NAME="YOUR_WORK_NAME"  # 替换为您的工作姓名
WORK_EMAIL="YOUR_WORK_EMAIL"  # 替换为您的工作邮箱
WORK_SSH_KEY="$HOME/.ssh/id_rsa_work"  # 工作SSH密钥路径

CONFIG_FILE="$HOME/.github_account_config"

# 加载已保存的配置（如果存在）
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# 显示当前配置
show_current_config() {
    echo -e "${BLUE}当前Git配置:${NC}"
    echo -e "用户名: ${YELLOW}$(git config --global user.name)${NC}"
    echo -e "邮箱: ${YELLOW}$(git config --global user.email)${NC}"
    
    # 检查当前使用的SSH密钥
    CURRENT_KEY=$(ssh-add -l | grep -o "$HOME/.ssh/id_rsa.*")
    if [ -z "$CURRENT_KEY" ]; then
        echo -e "SSH密钥: ${RED}未加载任何SSH密钥${NC}"
    else
        echo -e "SSH密钥: ${YELLOW}$CURRENT_KEY${NC}"
    fi
    
    # 显示当前配置文件
    if [ -f "$CONFIG_FILE" ] && grep -q "CURRENT_ACCOUNT" "$CONFIG_FILE"; then
        CURRENT_ACCOUNT=$(grep "CURRENT_ACCOUNT" "$CONFIG_FILE" | cut -d'=' -f2)
        echo -e "当前账号: ${GREEN}$CURRENT_ACCOUNT${NC}"
    else
        echo -e "当前账号: ${RED}未设置${NC}"
    fi
}

# 切换到个人账号
switch_to_personal() {
    echo -e "${BLUE}切换到个人GitHub账号...${NC}"
    
    # 设置Git配置
    git config --global user.name "$PERSONAL_NAME"
    git config --global user.email "$PERSONAL_EMAIL"
    
    # 清除当前SSH密钥并添加个人SSH密钥
    ssh-add -D > /dev/null 2>&1
    ssh-add "$PERSONAL_SSH_KEY" > /dev/null 2>&1
    
    # 保存当前配置
    echo "CURRENT_ACCOUNT=personal" > "$CONFIG_FILE"
    echo "PERSONAL_NAME=\"$PERSONAL_NAME\"" >> "$CONFIG_FILE"
    echo "PERSONAL_EMAIL=\"$PERSONAL_EMAIL\"" >> "$CONFIG_FILE"
    echo "PERSONAL_SSH_KEY=\"$PERSONAL_SSH_KEY\"" >> "$CONFIG_FILE"
    echo "WORK_NAME=\"$WORK_NAME\"" >> "$CONFIG_FILE"
    echo "WORK_EMAIL=\"$WORK_EMAIL\"" >> "$CONFIG_FILE"
    echo "WORK_SSH_KEY=\"$WORK_SSH_KEY\"" >> "$CONFIG_FILE"
    
    echo -e "${GREEN}成功切换到个人账号!${NC}"
    show_current_config
}

# 切换到工作账号
switch_to_work() {
    echo -e "${BLUE}切换到工作GitHub账号...${NC}"
    
    # 设置Git配置
    git config --global user.name "$WORK_NAME"
    git config --global user.email "$WORK_EMAIL"
    
    # 清除当前SSH密钥并添加工作SSH密钥
    ssh-add -D > /dev/null 2>&1
    ssh-add "$WORK_SSH_KEY" > /dev/null 2>&1
    
    # 保存当前配置
    echo "CURRENT_ACCOUNT=work" > "$CONFIG_FILE"
    echo "PERSONAL_NAME=\"$PERSONAL_NAME\"" >> "$CONFIG_FILE"
    echo "PERSONAL_EMAIL=\"$PERSONAL_EMAIL\"" >> "$CONFIG_FILE"
    echo "PERSONAL_SSH_KEY=\"$PERSONAL_SSH_KEY\"" >> "$CONFIG_FILE"
    echo "WORK_NAME=\"$WORK_NAME\"" >> "$CONFIG_FILE"
    echo "WORK_EMAIL=\"$WORK_EMAIL\"" >> "$CONFIG_FILE"
    echo "WORK_SSH_KEY=\"$WORK_SSH_KEY\"" >> "$CONFIG_FILE"
    
    echo -e "${GREEN}成功切换到工作账号!${NC}"
    show_current_config
}

# 交互式配置
configure() {
    echo -e "${BLUE}开始配置GitHub账号信息...${NC}"
    
    echo -e "${YELLOW}个人GitHub账号配置:${NC}"
    read -p "输入个人账号用户名: " input_personal_name
    read -p "输入个人账号邮箱: " input_personal_email
    read -p "输入个人账号SSH密钥路径 [$HOME/.ssh/id_rsa_personal]: " input_personal_key
    
    echo -e "${YELLOW}工作GitHub账号配置:${NC}"
    read -p "输入工作账号用户名: " input_work_name
    read -p "输入工作账号邮箱: " input_work_email
    read -p "输入工作账号SSH密钥路径 [$HOME/.ssh/id_rsa_work]: " input_work_key
    
    # 更新配置
    [ -n "$input_personal_name" ] && PERSONAL_NAME="$input_personal_name"
    [ -n "$input_personal_email" ] && PERSONAL_EMAIL="$input_personal_email"
    [ -n "$input_personal_key" ] && PERSONAL_SSH_KEY="$input_personal_key"
    
    [ -n "$input_work_name" ] && WORK_NAME="$input_work_name"
    [ -n "$input_work_email" ] && WORK_EMAIL="$input_work_email"
    [ -n "$input_work_key" ] && WORK_SSH_KEY="$input_work_key"
    
    # 保存配置
    echo "CURRENT_ACCOUNT=none" > "$CONFIG_FILE"
    echo "PERSONAL_NAME=\"$PERSONAL_NAME\"" >> "$CONFIG_FILE"
    echo "PERSONAL_EMAIL=\"$PERSONAL_EMAIL\"" >> "$CONFIG_FILE"
    echo "PERSONAL_SSH_KEY=\"$PERSONAL_SSH_KEY\"" >> "$CONFIG_FILE"
    echo "WORK_NAME=\"$WORK_NAME\"" >> "$CONFIG_FILE"
    echo "WORK_EMAIL=\"$WORK_EMAIL\"" >> "$CONFIG_FILE"
    echo "WORK_SSH_KEY=\"$WORK_SSH_KEY\"" >> "$CONFIG_FILE"
    
    echo -e "${GREEN}配置已保存!${NC}"
    
    # 询问是否立即切换
    echo -e "${BLUE}是否要立即切换到某个账号?${NC}"
    echo "1) 个人账号"
    echo "2) 工作账号"
    echo "3) 不切换"
    read -p "选择 [1-3]: " switch_choice
    
    case $switch_choice in
        1) switch_to_personal ;;
        2) switch_to_work ;;
        *) echo -e "${YELLOW}保持当前配置.${NC}" ;;
    esac
}

# 生成SSH密钥
generate_ssh_key() {
    account_type=$1
    
    if [ "$account_type" == "personal" ]; then
        key_path="$PERSONAL_SSH_KEY"
        email="$PERSONAL_EMAIL"
        name="个人账号"
    elif [ "$account_type" == "work" ]; then
        key_path="$WORK_SSH_KEY"
        email="$WORK_EMAIL"
        name="工作账号"
    else
        echo -e "${RED}无效的账号类型!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}为${name}生成SSH密钥...${NC}"
    
    # 检查密钥是否已存在
    if [ -f "$key_path" ]; then
        read -p "SSH密钥已存在，是否覆盖? [y/N]: " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}取消生成SSH密钥.${NC}"
            return 0
        fi
    fi
    
    # 生成新的SSH密钥
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path"
    
    echo -e "${GREEN}SSH密钥已生成: $key_path${NC}"
    echo -e "${YELLOW}请将下面的公钥添加到您的GitHub账号:${NC}"
    cat "${key_path}.pub"
    
    echo -e "\n${BLUE}如何添加SSH密钥到GitHub:${NC}"
    echo "1. 登录到GitHub账号"
    echo "2. 点击右上角个人头像，选择'Settings'"
    echo "3. 在左侧菜单中选择'SSH and GPG keys'"
    echo "4. 点击'New SSH key'按钮"
    echo "5. 输入标题（例如：'Work Laptop' 或 'Personal Laptop'）"
    echo "6. 复制上方显示的公钥内容到'Key'字段"
    echo "7. 点击'Add SSH key'按钮"
}

# 设置每个仓库的配置
setup_per_repo() {
    echo -e "${BLUE}设置每个仓库的单独配置...${NC}"
    echo -e "${YELLOW}请进入您想要配置的Git仓库目录，然后运行以下命令:${NC}"
    
    echo -e "${GREEN}对于个人账号的仓库:${NC}"
    echo "git config user.name \"$PERSONAL_NAME\""
    echo "git config user.email \"$PERSONAL_EMAIL\""
    
    echo -e "${GREEN}对于工作账号的仓库:${NC}"
    echo "git config user.name \"$WORK_NAME\""
    echo "git config user.email \"$WORK_EMAIL\""
    
    echo -e "${BLUE}或者，您可以使用这个脚本的以下命令:${NC}"
    echo "./github_account_switcher.sh repo-personal"
    echo "./github_account_switcher.sh repo-work"
}

# 为当前仓库设置个人账号
setup_repo_personal() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}当前目录不是Git仓库!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}为当前仓库设置个人GitHub账号...${NC}"
    git config user.name "$PERSONAL_NAME"
    git config user.email "$PERSONAL_EMAIL"
    
    echo -e "${GREEN}已为当前仓库设置个人账号配置!${NC}"
    echo -e "仓库: ${YELLOW}$(basename $(pwd))${NC}"
    echo -e "用户名: ${YELLOW}$PERSONAL_NAME${NC}"
    echo -e "邮箱: ${YELLOW}$PERSONAL_EMAIL${NC}"
    
    # 提示设置SSH密钥
    echo -e "${BLUE}请确保您已加载个人账号的SSH密钥:${NC}"
    echo "ssh-add $PERSONAL_SSH_KEY"
}

# 为当前仓库设置工作账号
setup_repo_work() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}当前目录不是Git仓库!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}为当前仓库设置工作GitHub账号...${NC}"
    git config user.name "$WORK_NAME"
    git config user.email "$WORK_EMAIL"
    
    echo -e "${GREEN}已为当前仓库设置工作账号配置!${NC}"
    echo -e "仓库: ${YELLOW}$(basename $(pwd))${NC}"
    echo -e "用户名: ${YELLOW}$WORK_NAME${NC}"
    echo -e "邮箱: ${YELLOW}$WORK_EMAIL${NC}"
    
    # 提示设置SSH密钥
    echo -e "${BLUE}请确保您已加载工作账号的SSH密钥:${NC}"
    echo "ssh-add $WORK_SSH_KEY"
}

# 创建SSH配置文件
create_ssh_config() {
    ssh_config="$HOME/.ssh/config"
    
    # 检查SSH配置文件是否已存在
    if [ -f "$ssh_config" ]; then
        read -p "SSH配置文件已存在，是否添加多账号配置? [y/N]: " add_config
        if [[ ! $add_config =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}取消创建SSH配置.${NC}"
            return 0
        fi
    fi
    
    echo -e "${BLUE}创建SSH配置文件...${NC}"
    
    # 备份现有配置
    if [ -f "$ssh_config" ]; then
        cp "$ssh_config" "${ssh_config}.bak"
        echo -e "${YELLOW}已备份现有SSH配置到 ${ssh_config}.bak${NC}"
    fi
    
    # 添加多账号配置
    cat >> "$ssh_config" << EOF

# GitHub 个人账号
Host github.com-personal
    HostName github.com
    User git
    IdentityFile $PERSONAL_SSH_KEY
    IdentitiesOnly yes

# GitHub 工作账号
Host github.com-work
    HostName github.com
    User git
    IdentityFile $WORK_SSH_KEY
    IdentitiesOnly yes
EOF
    
    echo -e "${GREEN}SSH配置已创建!${NC}"
    echo -e "${YELLOW}现在您可以使用以下方式克隆仓库:${NC}"
    echo -e "${BLUE}个人账号:${NC}"
    echo "git clone git@github.com-personal:username/repo.git"
    echo -e "${BLUE}工作账号:${NC}"
    echo "git clone git@github.com-work:username/repo.git"
    
    echo -e "\n${YELLOW}对于现有仓库，您可以更新远程URL:${NC}"
    echo -e "${BLUE}个人账号:${NC}"
    echo "git remote set-url origin git@github.com-personal:username/repo.git"
    echo -e "${BLUE}工作账号:${NC}"
    echo "git remote set-url origin git@github.com-work:username/repo.git"
}

# 显示帮助信息
show_help() {
    echo -e "${BLUE}GitHub账号切换脚本${NC}"
    echo -e "${YELLOW}用法:${NC} ./github_account_switcher.sh [选项]"
    echo
    echo -e "${GREEN}可用选项:${NC}"
    echo "  personal            切换到个人GitHub账号"
    echo "  work                切换到工作GitHub账号"
    echo "  status              显示当前配置状态"
    echo "  configure           交互式配置账号信息"
    echo "  gen-personal-key    为个人账号生成SSH密钥"
    echo "  gen-work-key        为工作账号生成SSH密钥"
    echo "  repo-personal       为当前仓库设置个人账号"
    echo "  repo-work           为当前仓库设置工作账号"
    echo "  repo-info           查看仓库级别配置"
    echo "  setup-repo-config   显示如何设置每个仓库的配置"
    echo "  create-ssh-config   创建SSH配置文件以支持多账号"
    echo "  help                显示此帮助信息"
}

# 主函数，处理命令行参数
main() {
    if [ $# -eq 0 ]; then
        show_current_config
        echo
        show_help
        exit 0
    fi
    
    case "$1" in
        personal)
            switch_to_personal
            ;;
        work)
            switch_to_work
            ;;
        status)
            show_current_config
            ;;
        configure)
            configure
            ;;
        gen-personal-key)
            generate_ssh_key "personal"
            ;;
        gen-work-key)
            generate_ssh_key "work"
            ;;
        repo-personal)
            setup_repo_personal
            ;;
        repo-work)
            setup_repo_work
            ;;
        repo-info)
            if [ ! -d ".git" ]; then
                echo -e "${RED}当前目录不是Git仓库!${NC}"
                exit 1
            fi
            echo -e "${BLUE}当前仓库配置:${NC}"
            echo -e "仓库: ${YELLOW}$(basename $(pwd))${NC}"
            echo -e "用户名: ${YELLOW}$(git config user.name)${NC}"
            echo -e "邮箱: ${YELLOW}$(git config user.email)${NC}"
            ;;
        setup-repo-config)
            setup_per_repo
            ;;
        create-ssh-config)
            create_ssh_config
            ;;
        help)
            show_help
            ;;
        *)
            echo -e "${RED}未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
