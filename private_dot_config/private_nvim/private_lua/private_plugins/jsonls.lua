-- Filter trailing-comma warnings (code 519) from jsonls in JSONC files.
-- In neovim 0.11+, client handlers for publishDiagnostics are no longer called,
-- so we intercept vim.diagnostic.set instead.
local original_set = vim.diagnostic.set
vim.diagnostic.set = function(ns, bufnr, diagnostics, opts)
  if vim.bo[bufnr].filetype == "jsonc" then
    diagnostics = vim.tbl_filter(function(d)
      return not (d.code == 519 and d.source == "jsonc")
    end, diagnostics)
  end
  original_set(ns, bufnr, diagnostics, opts)
end

return {}
