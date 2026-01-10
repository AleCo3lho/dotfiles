return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
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
                      "textEdit",
                    },
                  },
                },
                completionList = {
                  itemDefaults = {
                    "commitCharacters",
                    "editRange",
                    "insertTextFormat",
                    "insertTextMode",
                  },
                },
              },
            },
          },
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
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
            yaml = {
              -- Enhanced schema configuration with fallback
              schemas = (function()
                local ok, schemastore = pcall(require, "schemastore")
                if ok then
                  -- Get all schemas and add some custom ones
                  local schemas = schemastore.yaml.schemas()
                  -- Add Kind cluster schema specifically
                  schemas["https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/static/examples/config-with-mounts.yaml"] =
                    "kind-*.yaml"
                  return schemas
                else
                  -- Fallback with basic schemas
                  return {
                    ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                    ["https://raw.githubusercontent.com/docker/compose/master/compose/config/compose_spec.json"] = {
                      "docker-compose*.yml",
                      "docker-compose*.yaml",
                      "compose*.yml",
                      "compose*.yaml",
                    },
                    ["https://raw.githubusercontent.com/kubernetes-sigs/kind/main/site/static/examples/config-with-mounts.yaml"] = "kind-*.yaml",
                  }
                end
              end)(),
              -- Better validation and formatting
              validate = true,
              completion = true,
              hover = true,
              format = {
                enable = true,
                singleQuote = false,
                bracketSpacing = true,
              },
              -- Improved schema store configuration
              schemaStore = {
                enable = false, -- We handle schemas manually for better control
                url = "",
              },
              -- Custom tags for better Kind support
              customTags = {
                "!Ref",
                "!GetAtt",
                "!Join sequence",
                "!Base64",
                "!Sub",
                "!ImportValue",
                "!Split sequence",
                "!Select sequence",
                "!Equals sequence",
              },
            },
            redhat = {
              telemetry = { enabled = false },
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
        tsserver = false,
        ts_ls = false,
        -- Emmet configuration
        emmet_ls = {
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "javascript",
            "typescript",
            "markdown",
            "ejs",
            "template",
          },
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = true,
              },
            },
          },
        },
        -- Tailwind configuration
        tailwindcss = {},
        -- Zig configuration
        zls = {},
        -- Lua enhanced configuration
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      setup = {
        -- Ensure conflicting TS servers are disabled
        tsserver = function()
          return true
        end,
        ts_ls = function()
          return true
        end,
      },
    },
  },
}
