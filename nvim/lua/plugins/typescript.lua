return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          -- Enhanced completion capabilities
          capabilities = {
            textDocument = {
              completion = {
                completionItem = {
                  snippetSupport = true,
                  preselectSupport = true,
                  insertReplaceSupport = true,
                  labelDetailsSupport = true,
                  deprecatedSupport = true,
                  commitCharactersSupport = true,
                  documentationFormat = { "markdown", "plaintext" },
                  resolveSupport = {
                    properties = { 
                      "documentation", 
                      "detail", 
                      "additionalTextEdits",
                      "sortText",
                      "filterText",
                      "insertText",
                      "textEdit"
                    },
                  },
                },
                completionList = {
                  itemDefaults = { 
                    "commitCharacters", 
                    "editRange", 
                    "insertTextFormat", 
                    "insertTextMode" 
                  },
                },
              },
            },
          },
          -- Ensure proper file type association
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
          end,
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = true,
                includeCompletionsForModuleExports = true,
              },
              preferences = {
                importModuleSpecifier = "relative",
                includePackageJsonAutoImports = "on",
              },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
            javascript = {
              suggest = {
                completeFunctionCalls = true,
                includeCompletionsForModuleExports = true,
              },
              preferences = {
                importModuleSpecifier = "relative",
                includePackageJsonAutoImports = "on",
              },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
          },
        },
        -- Disable conflicting TypeScript servers
        tsserver = false, -- Completely disable
        ts_ls = false,   -- Completely disable
      },
      setup = {
        -- Ensure vtsls gets priority and others are skipped
        tsserver = function() return true end,
        ts_ls = function() return true end,
      },
    },
  },
}