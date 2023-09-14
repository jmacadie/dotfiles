return {
  'williamboman/mason.nvim',
  opts = {
    ensure_installed = {
      -- Python
      "pyright",
      "mypy",
      "ruff",
      "black",
      -- Rust
      "rust-analyzer",
    },
  },
}
