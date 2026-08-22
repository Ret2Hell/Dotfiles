return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function()
      local dap = require("dap")
      local filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

      for _, filetype in ipairs(filetypes) do
        dap.configurations[filetype] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file with tsx",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "${workspaceFolder}/node_modules/.bin/tsx",
            sourceMaps = true,
            skipFiles = {
              "<node_internals>/**",
              "node_modules/**",
            },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to a running Node process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = {
              "<node_internals>/**",
              "node_modules/**",
            },
          },
        }
      end
    end,
  },
}
