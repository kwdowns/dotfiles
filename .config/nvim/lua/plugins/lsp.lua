return {
    -- Tool installer (LSP servers, formatters, debuggers)
    {
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        opts = {},
    },

    -- Auto-install LSP servers via mason (no lspconfig bridge needed)
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = { "omnisharp", "lua_ls", "yamlls" },
        },
    },
    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

            -- C# / .NET via OmniSharp (nvim 0.11+ native API)
            vim.lsp.config("omnisharp", {
                cmd = {
                    mason_bin .. "/OmniSharp",
                    "--languageserver",
                    "--hostPID",
                    tostring(vim.fn.getpid()),
                },
                filetypes = { "cs", "vb" },
                root_markers = { "*.sln", "*.csproj", "omnisharp.json", ".git" },
                capabilities = capabilities,
                settings = {
                    FormattingOptions = {
                        EnableEditorConfigSupport = true,
                        OrganizeImports = true,
                    },
                    RoslynExtensionsOptions = {
                        EnableAnalyzersSupport = true,
                        EnableImportCompletion = true,
                        AnalyzeOpenDocumentsOnly = false,
                    },
                    MsBuild = {
                        LoadProjectsOnDemand = false,
                    },
                },
            })
            vim.lsp.enable("omnisharp")

            -- Lua
            vim.lsp.config("lua_ls", {
                cmd = { mason_bin .. "/lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })
            vim.lsp.enable("lua_ls")

            vim.lsp.config("yamlls", {
                cmd = { mason_bin .. "/yaml-language-server", "--stdio" },
                filetypes = { "yaml" },
                root_markers = { ".git" },
                capabilities = capabilities,
                settings = {
                }
            })
            vim.lsp.enable("yamlls")

            -- Keymaps on LSP attach
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf, silent = true }
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
                    end
                    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                    map("n", "K", vim.lsp.buf.hover, "Hover docs")
                    map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
                    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
                    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
                    map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")
                    map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostic list")
                end,
            })

            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            -- nvim-cmp setup
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"]   = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    }
}
