return {
  {
    "transparent-background",
    dir = vim.fn.stdpath("config"),
    name = "transparent-background",
    priority = 1000,
    lazy = false,
    config = function()
      local function apply_transparency()
        -- Core UI elements
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })

        -- Popups and menus
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
        vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none" })
        vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "none" })
        vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "none" })

        -- Window separators
        vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
        vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })

        -- Status and tab lines
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none" })
        vim.api.nvim_set_hl(0, "WinBar", { bg = "none" })
        vim.api.nvim_set_hl(0, "WinBarNC", { bg = "none" })

        -- Line numbers and signs
        vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "none" })
        vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "Folded", { bg = "none" })

        -- Misc UI
        vim.api.nvim_set_hl(0, "Terminal", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
        vim.api.nvim_set_hl(0, "MsgArea", { bg = "none" })
        vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })

        -- WhichKey
        vim.api.nvim_set_hl(0, "WhichKey", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyGroup", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeySeparator", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyDesc", { bg = "none" })
        vim.api.nvim_set_hl(0, "WhichKeyValue", { bg = "none" })

        -- Telescope
        vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "none" })

        -- NeoTree
        vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NeoTreeTitleBar", { bg = "none" })

        -- NvimTree
        vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeVertSplit", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { bg = "none" })
        vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

        -- Notify
        vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyINFOTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyERRORTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyWARNTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyTRACETitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyINFOBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyERRORBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyWARNBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { bg = "none" })

        -- LSP floating windows
        vim.api.nvim_set_hl(0, "LspInfoBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "LspFloatWinNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "LspFloatWinBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { bg = "none" })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { bg = "none" })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { bg = "none" })
        vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { bg = "none" })

        -- Lazy.nvim UI
        vim.api.nvim_set_hl(0, "LazyNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyBackdrop", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyButton", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyButtonActive", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyH1", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyProgressDone", { bg = "none" })
        vim.api.nvim_set_hl(0, "LazyProgressTodo", { bg = "none" })

        -- Mason UI
        vim.api.nvim_set_hl(0, "MasonNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonHeader", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonHeaderSecondary", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonHighlight", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonHighlightBlock", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonMuted", { bg = "none" })
        vim.api.nvim_set_hl(0, "MasonMutedBlock", { bg = "none" })

        -- Snacks.nvim dashboard
        vim.api.nvim_set_hl(0, "SnacksDashboardNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardFile", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardDir", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardFooter", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardKey", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardSpecial", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksDashboardTitle", { bg = "none" })

        -- Blink.cmp (completion menu)
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = "none" })
        vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { bg = "none" })

        -- Mini.nvim
        vim.api.nvim_set_hl(0, "MiniAnimateCursor", { bg = "none" })
        vim.api.nvim_set_hl(0, "MiniAnimateNormalFloat", { bg = "none" })

        -- Harpoon
        vim.api.nvim_set_hl(0, "HarpoonWindow", { bg = "none" })
        vim.api.nvim_set_hl(0, "HarpoonBorder", { bg = "none" })

        -- Noice.nvim (if used)
        vim.api.nvim_set_hl(0, "NoicePopup", { bg = "none" })
        vim.api.nvim_set_hl(0, "NoicePopupmenu", { bg = "none" })
        vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "none" })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = "none" })

        -- Gitsigns
        vim.api.nvim_set_hl(0, "GitSignsAdd", { bg = "none" })
        vim.api.nvim_set_hl(0, "GitSignsChange", { bg = "none" })
        vim.api.nvim_set_hl(0, "GitSignsDelete", { bg = "none" })

        -- Trouble.nvim
        vim.api.nvim_set_hl(0, "TroubleNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "TroubleNormalNC", { bg = "none" })

        -- BufferLine
        vim.api.nvim_set_hl(0, "BufferLineBackground", { bg = "none" })
        vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "BufferLineTab", { bg = "none" })
        vim.api.nvim_set_hl(0, "BufferLineTabSelected", { bg = "none" })

        -- Alpha (dashboard)
        vim.api.nvim_set_hl(0, "AlphaHeader", { bg = "none" })
        vim.api.nvim_set_hl(0, "AlphaButtons", { bg = "none" })
        vim.api.nvim_set_hl(0, "AlphaShortcut", { bg = "none" })
        vim.api.nvim_set_hl(0, "AlphaFooter", { bg = "none" })

        -- Lualine (statusline)
        vim.api.nvim_set_hl(0, "lualine_a_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_a_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_insert", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_a_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_visual", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_a_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_command", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_a_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_replace", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_a_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_b_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_c_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_x_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_y_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_z_inactive", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_transitional_lualine_a_normal_to_lualine_b_normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "lualine_transitional_lualine_b_normal_to_lualine_c_normal", { bg = "none" })

        -- Snacks explorer
        vim.api.nvim_set_hl(0, "SnacksNormal", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksBorder", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksWinSeparator", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksTitle", { bg = "none" })
        vim.api.nvim_set_hl(0, "SnacksNotifierBorder", { bg = "none" })
      end

      -- Apply transparency immediately on startup
      apply_transparency()

      -- Re-apply transparency whenever colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("TransparencyOverride", { clear = true }),
        callback = apply_transparency,
        desc = "Apply transparent background after colorscheme loads",
      })
    end,
  },
}
