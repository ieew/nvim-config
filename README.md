# nvim-config
这是一个nvim的配置储存仓库

## 用法

1. 你需要先安装 `Plug` 
    > sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
2. 将 `init.lua` 放入 `~/.config/nvim/`
3. 在 `shell` 执行下列指令
    ```shell
    pacman -S yarn
    npm install -g pyright
    npm install -g yaml-language-server
    npm install -g bash-language-server
    nvim +PlugInstall
    ```
4. 开始享受吧~

