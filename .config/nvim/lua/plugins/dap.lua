return {
  -- Install netcoredbg via mason
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "netcoredbg" },
      handlers = {},
    },
  },

  -- Core DAP
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- netcoredbg adapter for C# / .NET
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg") ~= "" and vim.fn.exepath("netcoredbg")
          or (vim.fn.stdpath("data") .. "/mason/bin/netcoredbg"),
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET",
          request = "launch",
          program = function()
            -- Try to find a .dll in the current project
            local cwd = vim.fn.getcwd()
            local result = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", false, true)
            result = vim.tbl_filter(function(f)
              return not f:match("%.resources%.dll$")
            end, result)
            if #result == 1 then
              return result[1]
            end
            return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
          end,
        },
        {
          type = "coreclr",
          name = "Attach to process",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<F5>",  dap.continue,                                    { desc = "DAP: Continue" })
      map("n", "<F10>", dap.step_over,                                   { desc = "DAP: Step over" })
      map("n", "<F11>", dap.step_into,                                   { desc = "DAP: Step into" })
      map("n", "<F12>", dap.step_out,                                    { desc = "DAP: Step out" })
      map("n", "<leader>db", dap.toggle_breakpoint,                      { desc = "DAP: Toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end,                                                                { desc = "DAP: Conditional breakpoint" })
      map("n", "<leader>dl", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log message: "))
      end,                                                                { desc = "DAP: Log breakpoint" })
      map("n", "<leader>dr", dap.repl.open,                              { desc = "DAP: Open REPL" })
      map("n", "<leader>dt", dap.terminate,                              { desc = "DAP: Terminate" })
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Auto-open/close UI with debug sessions
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
    end,
  },
}
