return {
    {
        'nvim-telescope/telescope.nvim',
        version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files (Telescope)" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep (Telescope)" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers (Telescope)" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Help Tags (Telescope)" },
        },
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                on_attach = function(bufnr)
                    local api = require('nvim-tree.api')
                    api.config.mappings.default_on_attach(bufnr)
                    vim.keymap.set("n", "<leader>ff", function()
                            require("telescope.builtin").find_files()
                        end,
                        {
                            buffer = bufnr,
                            desc = "Find Files (Telescope)",
                            silent = true,
                            noremap = true
                        }
                    )
                end,
            })
        end,
    },
    {
        "github/copilot.vim",
        version = "*",
    }
}
