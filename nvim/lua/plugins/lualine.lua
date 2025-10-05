return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Get the default theme but modify it to be transparent
      local function transparent_theme()
        local theme = require("lualine.themes.auto")

        -- Make all sections transparent and improve text visibility
        for _, mode in pairs(theme) do
          if type(mode) == "table" then
            for _, section in pairs(mode) do
              if type(section) == "table" then
                section.bg = "none"
                section.fg = "#ffffff" -- Set text to white for better visibility
              end
            end
          end
        end

        return theme
      end

      -- Override the theme with transparent version
      opts.options.theme = transparent_theme()

      return opts
    end,
  },
}
