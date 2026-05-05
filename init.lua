local  vim  =  vim
vim.opt.backup  =  false
vim.opt.writebackup  =  false
vim.opt.signcolumn  =  "yes"
vim.opt.number  =  true
vim.opt.relativenumber  =  true
vim.opt.tabstop  =  4
vim.opt.shiftwidth  =  4
vim.opt.expandtab  =  true                              --  Tab  转空格
vim.opt.mouse  =  'a'                                        --  启用鼠标
vim.opt.clipboard  =  'unnamedplus'          --  系统剪贴板
vim.opt.termguicolors  =  true                      --  真彩色

--  vim-move  使用自定义键位，禁用默认映射
vim.g.move_map_keys  =  false

--  ============================================================
--  插件列表  (vim-plug)
--  ============================================================
local  Plug  =  vim.fn['plug#']

vim.call('plug#begin')
--  主题  /  外观
Plug('catppuccin/nvim',  {  ['as']  =  'catppuccin'  })
Plug('nvim-lualine/lualine.nvim')
Plug('akinsho/bufferline.nvim',  {  ['tag']  =  '*'  })

--  文件浏览  /  移动
Plug('preservim/nerdtree',  {  ['on']  =  'NERDTreeToggle'  })
Plug('matze/vim-move',  {  ['as']  =  'move'  })

--  LSP  /  补全  /  代码片段
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')
Plug('onsails/lspkind.nvim')
Plug('rafamadriz/friendly-snippets')

--  AI  辅助  (avante)
Plug('yetone/avante.nvim')
Plug('MunifTanjim/nui.nvim')              --  avante  依赖
Plug('nvim-lua/plenary.nvim')            --  avante  依赖

--  Markdown
Plug('iamcco/markdown-preview.nvim',  {  ['do']  =  'cd  app  &&  yarn  install'  })
Plug('dhruvasagar/vim-table-mode')
Plug('preservim/vim-markdown')

--  Git
Plug('lewis6991/gitsigns.nvim')
Plug('tpope/vim-fugitive')
vim.call('plug#end')

--  ============================================================
--  主题  &  界面插件设置
--  ============================================================
vim.cmd("colorscheme  catppuccin")
require("catppuccin").setup({})
require('lualine').setup()
require('bufferline').setup()

--  ============================================================
--  键位映射  (vim-move  移动行/块)
--  ============================================================
vim.keymap.set('n',  '<A-Up>',  '<Plug>MoveLineUp',  {  noremap  =  true,  silent  =  true  })
vim.keymap.set('n',  '<A-Down>',  '<Plug>MoveLineDown',  {  noremap  =  true,  silent  =  true  })
vim.keymap.set('v',  '<A-Up>',  '<Plug>MoveBlockUp',  {  noremap  =  true,  silent  =  true  })
vim.keymap.set('v',  '<A-Down>',  '<Plug>MoveBlockDown',  {  noremap  =  true,  silent  =  true  })
vim.keymap.set('i',  '<A-Up>',  '<Esc><Plug>MoveLineUp',  {  noremap  =  true,  silent  =  true  })
vim.keymap.set('i',  '<A-Down>',  '<Esc><Plug>MoveLineDown',  {  noremap  =  true,  silent  =  true  })

vim.g.mapleader  =  '  '

--  ============================================================
--  LSP  配置  (Neovim  内置客户端)
--  ============================================================
local  capabilities  =  require('cmp_nvim_lsp').default_capabilities()

--  辅助函数：获取虚拟环境  Python  路径
local  function  get_venv_python()
    local  venv_python  =  vim.fn.getcwd()  ..  '/.venv/bin/python'
    if  vim.fn.executable(venv_python)  ==  1  then
        return  venv_python
    end
    return  nil
end

--  Ruff  (Python  linter/formatter)
vim.lsp.config.ruff  =  {
    cmd  =  {  "ruff",  "server"  },
    filetypes  =  {  "python"  },
    root_markers  =  {  ".git",  "pyproject.toml",  "setup.py",  "setup.cfg",  "requirements.txt",  "Pipfile"  },
    settings  =  {}
}

--  Pyright  (Python  主补全/类型检查)  -  默认使用
vim.lsp.config.pyright  =  {
    cmd  =  {  "pyright-langserver",  "--stdio"  },
    filetypes  =  {  "python"  },
    root_markers  =  {  ".git",  "pyproject.toml",  "setup.py",  "setup.cfg",  "requirements.txt",  "Pipfile"  },
    capabilities  =  capabilities,
    settings  =  {
        python  =  {
            pythonPath  =  get_venv_python(),
            analysis  =  {
                typeCheckingMode  =  "standard",
                autoImportCompletions = true,
            }
        }
    }
}

--  Jedi  (备用  Python  LSP)  -  保留配置但默认不启用
vim.lsp.config.jedi_language_server  =  {
    cmd  =  {  "jedi-language-server"  },
    filetypes  =  {  "python"  },
    root_markers  =  {  ".git",  "pyproject.toml",  "setup.py",  "setup.cfg",  "requirements.txt",  "Pipfile"  },
    capabilities  =  capabilities,
    settings  =  {
        jedi  =  {
            diagnostics  =  {  enable  =  false  },    --  禁用诊断，避免与  Ruff  重复
            completion  =  {  disableSnippets  =  false  },
        },
    },
}

--  Rust  分析器
vim.lsp.config.rust_analyzer  =  {
    cmd  =  {  "rust-analyzer"  },
    filetypes  =  {  "rust"  },
    root_markers  =  {  ".git",  "Cargo.toml"  },
    capabilities  =  capabilities,
    settings  =  {
        ["rust-analyzer"]  =  {
            checkOnSave  =  true,
            inlayHints  =  {  enable  =  true  },
        },
    },
}

--  Bash  LSP
vim.lsp.config.bashls  =  {
    cmd  =  {  "bash-language-server",  "start"  },
    filetypes  =  {  "sh",  "bash",  "zsh"  },
    root_markers  =  {  ".git"  },
    capabilities  =  capabilities,
    settings  =  {},
}

--  YAML  LSP
vim.lsp.config.yamlls  =  {
    cmd  =  {  "yaml-language-server",  "--stdio"  },
    filetypes  =  {  "yaml",  "yml"  },
    root_markers  =  {  ".git"  },
    capabilities  =  capabilities,
    settings  =  {
        yaml  =  {
            schemas  =  {
                ["https://json.schemastore.org/github-workflow.json"]  =  ".github/workflows/*",
                ["https://json.schemastore.org/github-action.json"]  =  ".github/actions/*",
                ["https://json.schemastore.org/kustomization.json"]  =  "kustomization.yaml",
            },
            format  =  {  enable  =  true  },
            validate  =  true,
        },
    },
}

--  自动启动  LSP（按文件类型）
vim.api.nvim_create_autocmd("FileType",  {
    pattern  =  "python",
    callback  =  function()
        pcall(function()  vim.lsp.enable("ruff")  end)
        pcall(function()  vim.lsp.enable("pyright")  end)
        --  如需启用  Jedi（备用），取消下一行注释，并注释掉上面的  pyright  行
        --  pcall(function()  vim.lsp.enable("jedi_language_server")  end)
    end,
})
vim.api.nvim_create_autocmd("FileType",  {
    pattern  =  "rust",
    callback  =  function()
        pcall(function()  vim.lsp.enable("rust_analyzer")  end)
    end,
})
vim.api.nvim_create_autocmd("FileType",  {
    pattern  =  "sh,bash,zsh",
    callback  =  function()
        pcall(function()  vim.lsp.enable("bashls")  end)
    end,
})
vim.api.nvim_create_autocmd("FileType",  {
    pattern  =  "yaml,yml",
    callback  =  function()
        pcall(function()  vim.lsp.enable("yamlls")  end)
    end,
})

--  LSP  附着后的键位与功能
vim.api.nvim_create_autocmd("LspAttach",  {
    callback  =  function(args)
        local  client  =  vim.lsp.get_client_by_id(args.data.client_id)
        if  client  ==  nil  then  return  end

        --  跳转和引用
        vim.keymap.set('n',  'gd',  vim.lsp.buf.definition,  {  buffer  =  args.buf,  desc  =  "转到定义"  })
        vim.keymap.set('n',  'gi',  vim.lsp.buf.implementation,  {  buffer  =  args.buf,  desc  =  "转到实现"  })
        vim.keymap.set('n',  'gr',  vim.lsp.buf.references,  {  buffer  =  args.buf,  desc  =  "查找引用"  })
        vim.keymap.set('n',  'gy',  vim.lsp.buf.type_definition,  {  buffer  =  args.buf,  desc  =  "转到类型定义"  })
        vim.keymap.set('n',  'K',  vim.lsp.buf.hover,  {  buffer  =  args.buf,  desc  =  "悬浮文档"  })

        --  重命名、代码操作、格式化
        vim.keymap.set('n',  '<leader>rn',  vim.lsp.buf.rename,  {  buffer  =  args.buf,  desc  =  "重命名"  })
        vim.keymap.set('n',  '<leader>ca',  vim.lsp.buf.code_action,  {  buffer  =  args.buf,  desc  =  "代码操作"  })
        vim.keymap.set('n',  '<leader>f',  function()
            vim.lsp.buf.format({  async  =  true  })
        end,  {  buffer  =  args.buf,  desc  =  "格式化"  })

        --  返回上一位置
        vim.keymap.set('n',  '<leader>bb',  '<C-o>',  {  buffer  =  args.buf,  desc  =  "返回"  })

        --  签名帮助（参数提示）
        if  client.server_capabilities.signatureHelpProvider  then
            vim.keymap.set('i',  '<C-k>',  vim.lsp.buf.signature_help,  {  buffer  =  args.buf,  desc  =  "参数提示"  })
            --  自动触发  (输入  '('  或  ','  时)
            vim.api.nvim_create_autocmd("TextChangedI",  {
                buffer  =  args.buf,
                callback  =  function()
                    local  char  =  vim.v.event  and  vim.v.event.char  or  ""
                    if  char  ==  '('  or  char  ==  ','  then
                        vim.lsp.buf.signature_help()
                    end
                end,
            })
        end
    end,
})

--  ============================================================
--  补全引擎  (nvim-cmp)  配置
--  ============================================================
local  cmp  =  require('cmp')
local  luasnip  =  require('luasnip')

--  加载  friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

--  补全菜单格式化（集成  lspkind  图标）
local  has_lspkind,  lspkind  =  pcall(require,  'lspkind')
local  function  format_func(entry,  vim_item)
    if  has_lspkind  then
        vim_item  =  lspkind.cmp_format({
            mode  =  'symbol_text',
            maxwidth  =  50,
        })(entry,  vim_item)
    end
    return  vim_item
end

cmp.setup({
    snippet  =  {
        expand  =  function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping  =  cmp.mapping.preset.insert({
        ['<C-b>']  =  cmp.mapping.scroll_docs(-4),
        ['<C-f>']  =  cmp.mapping.scroll_docs(4),
        ['<C-Space>']  =  cmp.mapping.complete(),
        ['<C-e>']  =  cmp.mapping.abort(),
        ['<CR>']  =  cmp.mapping.confirm({  select  =  true  }),

        --  Tab  在补全菜单与代码片段之间导航
        ['<Tab>']  =  cmp.mapping(function(fallback)
            if  cmp.visible()  then
                cmp.select_next_item()
            elseif  luasnip.expand_or_jumpable()  then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end,  {  'i',  's'  }),
        ['<S-Tab>']  =  cmp.mapping(function(fallback)
            if  cmp.visible()  then
                cmp.select_prev_item()
            elseif  luasnip.jumpable(-1)  then
                luasnip.jump(-1)
            else
                fallback()
            end
        end,  {  'i',  's'  }),
    }),

    sources  =  cmp.config.sources({
        {  name  =  'nvim_lsp'  },
        {  name  =  'luasnip'  },
        {  name  =  'path'  },
        {  name  =  'buffer'  },
    }),

    formatting  =  {
        format  =  format_func,
    },
})

--  保留  LuaSnip  的独立跳转键（非必需，但可快速跳到下/上一个占位符）
vim.keymap.set({  'i',  's'  },  '<C-l>',  function()  luasnip.jump(1)  end,  {  silent  =  true  })
vim.keymap.set({  'i',  's'  },  '<C-j>',  function()  luasnip.jump(-1)  end,  {  silent  =  true  })
vim.keymap.set({  'i',  's'  },  '<C-o>',  function()
    if  luasnip.choice_active()  then  luasnip.change_choice(1)  end
end,  {  silent  =  true  })

--  针对不同文件类型微调补全源
cmp.setup.filetype({  "sh",  "bash",  "zsh"  },  {
    sources  =  cmp.config.sources({
        {  name  =  'nvim_lsp'  },
        {  name  =  'buffer',  keyword_length  =  3  },
        {  name  =  'path'  },
    }),
})
cmp.setup.filetype({  "yaml",  "yml"  },  {
    sources  =  cmp.config.sources({
        {  name  =  'nvim_lsp'  },
        {  name  =  'buffer',  keyword_length  =  3  },
        {  name  =  'path'  },
    }),
})

--  ============================================================
--  Git  行内增强  (gitsigns)
--  ============================================================
require('gitsigns').setup({
    signs  =  {
        add                    =  {  text  =  '│'  },
        change              =  {  text  =  '│'  },
        delete              =  {  text  =  '_'  },
        topdelete        =  {  text  =  '‾'  },
        changedelete  =  {  text  =  '~'  },
    },
    numhl  =  true,
    current_line_blame  =  true,
    on_attach  =  function(bufnr)
        local  gs  =  package.loaded.gitsigns

        local  function  map(mode,  l,  r,  opts)
            opts  =  opts  or  {}
            opts.buffer  =  bufnr
            vim.keymap.set(mode,  l,  r,  opts)
        end

        --  块间跳转
        map('n',  ']c',  function()
            if  vim.wo.diff  then  return  ']c'  end
            vim.schedule(function()  gs.next_hunk()  end)
            return  '<Ignore>'
        end,  {  expr  =  true  })
        map('n',  '[c',  function()
            if  vim.wo.diff  then  return  '[c'  end
            vim.schedule(function()  gs.prev_hunk()  end)
            return  '<Ignore>'
        end,  {  expr  =  true  })

        --  块操作
        map('n',  '<leader>hs',  gs.stage_hunk,  {  desc  =  '暂存当前块'  })
        map('n',  '<leader>hr',  gs.reset_hunk,  {  desc  =  '撤销当前块修改'  })
        map('n',  '<leader>hS',  gs.stage_buffer,  {  desc  =  '暂存整个文件'  })
        map('n',  '<leader>hu',  gs.undo_stage_hunk,  {  desc  =  '取消暂存当前块'  })
        map('n',  '<leader>hp',  gs.preview_hunk,  {  desc  =  '预览修改块'  })
        map('n',  '<leader>hb',  function()  gs.blame_line{  full  =  true  }  end,  {  desc  =  '查看完整行历史'  })
    end,
})
