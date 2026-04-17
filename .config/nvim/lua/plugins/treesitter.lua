return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "c_sharp", "cpp", "python", "javascript", "typescript", "html", "css", "json", "yaml", "markdown", "bash", "dockerfile", "dart", "powershell", "xml", "sql", "bicep" },
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },
}