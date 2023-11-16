require('mason').setup()
require('mason-lspconfig').setup {
	ensure_installed = {"clangd", "cmake", "lua_ls", "rust_analyzer", "ruby_ls", "jsonls"}
}

local cmp = require('cmp')
local luasnip = require('luasnip')
local select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end
		},
	 mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
	  { name = 'path'},
      { name = 'nvim_lsp'},
	  { name = 'luasnip'},
  },{
      { name = 'buffer', keyword_lenght = 3 },
    }),
	windows = {
		documentation = cmp.config.window.bordered()
	},
},
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
}))
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_attach = function (client, buf)
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("Format", { clear = true }),
			buffer = buf,
			callback = function()
				vim.lsp.buf.formatting_seq_sync()
			end,
		})
	end
end

local lspconfig = require('lspconfig')
lspconfig.clangd.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
lspconfig.rust_analyzer.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
lspconfig.cmake.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
lspconfig.lua_ls.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
lspconfig.pyright.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
lspconfig.jsonls.setup({
	lsp_attach = lsp_attach,
	capabilities = capabilities,
})
