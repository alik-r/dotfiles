-- Treesitter parsers installed up front (used by init.lua and custom/bootstrap.lua).
-- Parsers for any other filetype are installed automatically the first time you open one.
return {
  'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  'go', 'gomod', 'gosum', 'gowork', 'hcl', 'terraform', 'yaml', 'json', 'toml', 'dockerfile',
  'python', 'make', 'jinja', 'jinja_inline', 'gitcommit', 'git_rebase', 'gitignore', 'sql',
}
