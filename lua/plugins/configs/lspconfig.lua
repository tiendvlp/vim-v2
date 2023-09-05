dofile(vim.g.base46_cache .. "lsp")
require "nvchad_ui.lsp"

local util = require "lspconfig/util"

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client.server_capabilities.signatureHelpProvider then
    require("nvchad_ui.signature").setup(client)
  end

  if not utils.load_config().ui.lsp_semantic_tokens then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

require("lspconfig").lua_ls.setup {
  on_attach = M.on_attach,
  capabilities = M.capabilities,

  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/extensions/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

require("lspconfig").csharp_ls.setup{
  cmd = { "/Users/minhtiendang/.dotnet/tools/csharp-ls" }
}

require("lspconfig").bufls.setup{}

require("lspconfig").rust_analyzer.setup {
  on_attach = M.on_attach,
  filetypes={"rust"},
  capabilities=M.capabilities,
  root_dir=util.root_pattern("Cargo.toml"),
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        allFeatures = true,
        buildScripts = {
          enable = true,
        },
      },
      -- enable clippy on save
      checkOnSave = {
        command = "clippy",
      },
      procMacro = {
        enable = true
      },
    },
  },
}

local pid = vim.fn.getpid()
local omnisharp_bin = "/opt/homebrew/Cellar/omnisharp/1.35.3/libexec/run"
require("lspconfig").omnisharp.setup {
  enable_editorconfig_support = true,
  enable_ms_build_load_projects_on_demand = false,
  enable_roslyn_analyzers = true,
  organize_imports_on_format = false,
  enable_import_completion = true,
  sdk_include_prerelease = true,
  analyze_open_documents_only = false,
  capabilities = M.capabilities,
  on_attach = M.on_attach,
  cmd = { omnisharp_bin, "--languageserver" , "--hostPID", tostring(pid) };
}

local flutter = require('flutter-tools')
flutter.setup({
  lsp = {
    on_attach = M.on_attach,
    capabilities = M.capabilities
  }
})

return M

