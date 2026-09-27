return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      prettier = {
        -- single quotes by default, but a project .prettierrc still wins
        prepend_args = { "--config-precedence", "prefer-file", "--single-quote" },
      },
    },
  },
}
