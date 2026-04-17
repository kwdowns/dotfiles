return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({
            dap = { justMyCode = false },
            discovery_root = "solution",  -- or "project"
          }),
        },
        output = { open_on_run = true },
        summary = {
          animated = true,
        },
      })

      local nt = require("neotest")
      local map = vim.keymap.set
      map("n", "<leader>tr", nt.run.run,                                 { desc = "Test: Run nearest" })
      map("n", "<leader>tf", function() nt.run.run(vim.fn.expand("%")) end, { desc = "Test: Run file" })
      map("n", "<leader>ta", function() nt.run.run(vim.fn.getcwd()) end, { desc = "Test: Run all" })
      map("n", "<leader>ts", nt.summary.toggle,                         { desc = "Test: Toggle summary" })
      map("n", "<leader>to", nt.output_panel.toggle,                    { desc = "Test: Toggle output" })
      map("n", "<leader>td", function() nt.run.run({ strategy = "dap" }) end, { desc = "Test: Debug nearest" })
    end,
  },
}
