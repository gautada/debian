# Linting Reference

This document summarizes the build linting errors resolved in issue #7
and how to configure the related tools.

## GitHub Status API 403 Error

**Cause:** `super-linter` calls the GitHub Status API to post per-linter
status checks. This requires `statuses: write` permission.

**Fix:** Add to the calling workflow:
```yaml
permissions:
  contents: read
  statuses: write
```
Or suppress individual statuses by setting `MULTI_STATUS: false` in the
super-linter environment.

## NATURAL_LANGUAGE Linter (textlint)

**What it is:** textlint — a pluggable natural-language linting tool for
prose and documentation.

**Recommendation:** Suppress for container repos with minimal documentation.
Add to super-linter environment:
```yaml
env:
  VALIDATE_NATURAL_LANGUAGE: false
```

**Configuration file:** `.textlintrc.json` at the repo root (included in
this repo with empty rules — allows textlint to run without errors if
enabled in future).

## Neovim Integration

To add textlint/vale to Neovim (with `nvim-lint`):
```lua
-- ~/.config/nvim/lua/plugins/linting.lua
return {
  "mfussenegger/nvim-lint",
  lazy = false,
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = { markdown = { "vale" } }
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function() lint.try_lint() end,
    })
  end,
}
```

Install vale: `brew install vale`. Create `.vale.ini` in the project root
to configure style rules.
