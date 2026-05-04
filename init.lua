local vim = vim
vim.opt.number = true             -- 显示行号
vim.opt.relativenumber = true     -- 相对行号
vim.opt.tabstop = 4               -- Tab 宽度
vim.opt.shiftwidth = 4
vim.opt.expandtab = true          -- Tab 转空格
vim.opt.mouse = 'a'               -- 启用鼠标
vim.opt.clipboard = 'unnamedplus' -- 系统剪贴板(若Termux支持)
vim.opt.termguicolors = true      -- 真彩色支持

local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('junegunn/seoul256.vim')
--Plug('neoclide/coc.nvim', { ['branch'] = 'release' })
Plug('preservim/nerdtree', { ['on'] = 'NERDTreeToggle' })
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')
Plug('onsails/lspkind.nvim')
Plug('yetone/avante.nvim')
Plug('MunifTanjim/nui.nvim') -- avante-ai 的依赖
Plug('nvim-lua/plenary.nvim') -- avante-ai 的依赖
Plug('rafamadriz/friendly-snippets')
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && yarn install' })
Plug('dhruvasagar/vim-table-mode')
Plug('preservim/vim-markdown')
Plug('lewis6991/gitsigns.nvim')   -- 行内状态显示、块导航、历史对比[citation:5]
Plug('tpope/vim-fugitive')        -- Git 命令台，强大的 :Git 命令
vim.call('plug#end')

vim.g.mapleader = ' '
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config.ruff = {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
  settings = {}
}

local function get_venv_python()
  -- 获取当前文件的目录或项目根目录（可根据需要选一种）
  local cwd = vim.fn.getcwd()
  local venv_python = cwd .. '/.venv/bin/python'
  if vim.fn.executable(venv_python) == 1 then
    return venv_python
  end
  -- 若未找到，返回 nil，LSP 将使用系统默认 Python
  return nil
end

vim.lsp.config.jedi_language_server = {
  cmd = { "jedi-language-server" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
  -- Jedi 自身的设置（可选）
  settings = {
    jedi = {
      -- 比如可以禁用 Jedi 的代码检查，全交给 Ruff，避免重复提示
      diagnostics = {
        enable = false,
      },
      -- 保证补全功能开启
      completion = {
        disableSnippets = false,
      },
    },
  },
  capabilities = capabilities, -- 这一行是关键，让 Jedi 为 nvim-cmp 提供补全
}

vim.lsp.config.pyright = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
  settings = {
    python = {
      pythonPath = get_venv_python(),
      analysis = {
        typeCheckingMode = "standard", -- "basic", -- 基础类型检查
      }
    }
  }
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    pcall(function() vim.lsp.enable("ruff") end)
    pcall(function() vim.lsp.enable("pyright") end) -- 原来是 pyright，现在改这个
  end,
})

-- Rust LSP 配置
vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { ".git", "Cargo.toml" },
  -- 复用你已有的 capabilities（和 nvim-cmp 打通的关键）
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  settings = {
    ["rust-analyzer"] = {
        checkOnSave = true,
        inlayHints = {
            enable = true,
        }
    },
  },
}

-- 自动启动 LSP（和你之前配置 Python、YAML 的模式一样）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    pcall(function() vim.lsp.enable("rust_analyzer") end)
  end,
})

-- 替换掉你原来 LspAttach 里的整个回调函数
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then return end

    -- 新的检查方式 (Neovim 0.10+)
    if client.server_capabilities.signatureHelpProvider then
      -- 在插入模式下，手动触发参数提示
      vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = args.buf, desc = "参数提示" })

      -- 自动触发（输入 ( 或 , 时）
      vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = args.buf,
        callback = function()
          -- 安全获取刚输入的字符
          local char = vim.v.event and vim.v.event.char or ""
          if char == '(' or char == ',' then
            vim.lsp.buf.signature_help()
          end
        end,
      })
    end
  end,
})


vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = 0, desc = "跳转到定义" })
vim.keymap.set('n', '<leader>bb', '<C-o>', { desc = '返回上一位置' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = 0, desc = "悬浮文档" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = 0, desc = "变量重命名" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = 0, desc = "代码操作" })
vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { buffer = 0, desc = "格式化代码" })

local cmp = require('cmp')
local luasnip = require('luasnip')
require("luasnip.loaders.from_vscode").lazy_load()

vim.keymap.set({"i"}, "<C-K>", function() luasnip.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() luasnip.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() luasnip.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
	if luasnip.choice_active() then
		luasnip.change_choice(1)
	end
end, {silent = true})

local has_lspkind, lspkind = pcall(require, 'lspkind')
local function format_func(entry, vim_item)
  if has_lspkind then
    vim_item = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
    })(entry, vim_item)
  end
  return vim_item
end

cmp.setup({
  -- 代码片段引擎
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- 快捷键
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 回车确认
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),

  -- 补全源
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  }),

  -- 格式化补全菜单
  formatting = {
    format = format_func,
  },
})


-- 3.5 Shell 脚本 LSP 配置
vim.lsp.config.bashls = {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { ".git" },
  settings = {},
  capabilities = capabilities, -- 使用前面已定义的 capabilities 变量
}

-- 3.6 在自动启动部分，增加 Shell 类型
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh,bash,zsh", -- 对应 Shell 文件类型
  callback = function()
    pcall(function() vim.lsp.enable("bashls") end)
  end,
})

-- 针对 Shell 文件，额外增强 buffer 补全的优先级
cmp.setup.filetype({ "sh", "bash", "zsh" }, {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' }, -- LSP 提供的全命令和选项
    { name = 'buffer', keyword_length = 3 }, -- 当前文件里的单词
    { name = 'path' },     -- 文件路径
  }),
})


-- 3.7 YAML LSP 配置
vim.lsp.config.yamlls = {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      -- 可选：启用 GitHub Actions 等常用 schema 自动补全
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
        ["https://json.schemastore.org/github-action.json"] = ".github/actions/*",
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
      },
      format = {
        enable = true,
      },
      validate = true,
    },
  },
  capabilities = capabilities,
}

-- 3.8 在自动启动部分增加 YAML 文件类型
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml,yml",
  callback = function()
    pcall(function() vim.lsp.enable("yamlls") end)
  end,
})

-- 针对 YAML 文件，优先补全路径和缓冲区内容
cmp.setup.filetype({ "yaml", "yml" }, {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer', keyword_length = 3 },
    { name = 'path' },
  }),
})


-- Git 行内状态与操作配置
require('gitsigns').setup({
  signs = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
  },
  -- 行号栏显示改动标记
  numhl = true,
  -- 当前行自动显示 blame 信息
  current_line_blame = true,
  -- 快捷键推荐
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- 在修改块之间跳转
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- 查看修改详情与操作
    map('n', '<leader>hs', gs.stage_hunk, { desc = '暂存当前块' })
    map('n', '<leader>hr', gs.reset_hunk, { desc = '撤销当前块修改' })
    map('n', '<leader>hS', gs.stage_buffer, { desc = '暂存整个文件' })
    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = '取消暂存当前块' })
    map('n', '<leader>hp', gs.preview_hunk, { desc = '预览修改块' })
    map('n', '<leader>hb', function() gs.blame_line{ full = true } end, { desc = '查看完整行历史' })
  end,
})

vim.cmd('silent! colorscheme seoul256')

