return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- ensure the fuzzy table exists
      opts.fuzzy = opts.fuzzy or {}
      -- pick the pure-Lua backend
      opts.fuzzy.implementation = "lua"
      
      -- Enhanced completion sources
      opts.sources = opts.sources or {}
      opts.sources.default = { "lsp", "path", "snippets", "buffer" }
      opts.sources.providers = opts.sources.providers or {}
      
      -- LSP source configuration
      opts.sources.providers.lsp = {
        name = "LSP",
        module = "blink.cmp.sources.lsp",
        enabled = true,
        score_offset = 0,
        async = true,
        timeout_ms = 1000,
        transform_items = function(ctx, items)
          -- Priority for TypeScript methods and properties
          for _, item in ipairs(items) do
            if item.kind == vim.lsp.protocol.CompletionItemKind.Method or 
               item.kind == vim.lsp.protocol.CompletionItemKind.Function then
              item.score_offset = (item.score_offset or 0) + 10 -- Higher priority for methods
            elseif item.kind == vim.lsp.protocol.CompletionItemKind.Property or
                   item.kind == vim.lsp.protocol.CompletionItemKind.Field then
              item.score_offset = (item.score_offset or 0) + 8 -- High priority for properties
            elseif item.kind == vim.lsp.protocol.CompletionItemKind.Variable then
              item.score_offset = (item.score_offset or 0) + 5 -- Medium priority for variables
            elseif item.kind == vim.lsp.protocol.CompletionItemKind.Class or
                   item.kind == vim.lsp.protocol.CompletionItemKind.Interface then
              item.score_offset = (item.score_offset or 0) + 7 -- Good priority for classes
            end
            
            -- Boost AWS CDK completions
            if item.label and (item.label:match("^aws%-") or item.label:match("^@aws%-")) then
              item.score_offset = (item.score_offset or 0) + 3
            end
          end
          return items
        end,
        override = {
          -- Ensure LSP completion is prioritized over other sources
          get_trigger_characters = function()
            return { ".", ":", "<", '"', "'", "/", "@" }
          end,
        },
      }
      
      -- Enhanced keymap configuration
      opts.keymap = opts.keymap or {}
      opts.keymap.preset = "default"
      opts.keymap["<C-Space>"] = { "show", "show_documentation" }
      opts.keymap["<C-e>"] = { "hide" }
      opts.keymap["<CR>"] = { "accept", "fallback" }
      opts.keymap["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" }
      opts.keymap["<S-Tab>"] = { "snippet_backward", "fallback" }
      opts.keymap["<C-k>"] = { "show_documentation", "hide_documentation" }
      opts.keymap["<C-n>"] = { "select_next", "fallback" }
      opts.keymap["<C-p>"] = { "select_prev", "fallback" }
      
      -- Completion behavior
      opts.completion = opts.completion or {}
      opts.completion.accept = { auto_brackets = { enabled = true } }
      opts.completion.menu = {
        auto_show = function(ctx)
          return ctx.mode ~= 'cmdline' and not vim.tbl_contains({ 'lua', 'markdown' }, ctx.filetype)
        end,
      }
      opts.completion.documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      }
      opts.completion.ghost_text = { enabled = true }
      
      -- Appearance configuration for better method visibility
      opts.appearance = opts.appearance or {}
      opts.appearance.use_nvim_cmp_as_default = true
      opts.appearance.kind_icons = {
        Method = "󰆧",
        Function = "󰊕",
        Class = "󰠱",
        Interface = "󰜰",
        Module = "󰏗",
        Property = "󰜢",
        Field = "󰽐",
        Variable = "󰀫",
      }
      
      return opts
    end,
  },
}
