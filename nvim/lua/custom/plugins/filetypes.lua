-- Ansible files are plain YAML to Neovim, so ansiblels would never start.
-- Mark YAML under the usual Ansible directories as `yaml.ansible`:
-- treesitter still highlights it as YAML, and ansiblels attaches to it.
local function ansible_or_yaml(path)
  local dirs = { 'playbooks', 'roles', 'tasks', 'handlers' }
  for _, dir in ipairs(dirs) do
    if path:find('/' .. dir .. '/', 1, true) then return 'yaml.ansible' end
  end
  -- Top-level playbooks next to ansible.cfg (site.yml, deploy.yaml, ...)
  local dir = vim.fs.dirname(path)
  if vim.uv.fs_stat(dir .. '/ansible.cfg') and not path:match 'compose%.ya?ml$' then return 'yaml.ansible' end
  return 'yaml'
end

vim.filetype.add {
  extension = {
    yml = ansible_or_yaml,
    yaml = ansible_or_yaml,
  },
  pattern = {
    ['.*%.ya?ml%.j2'] = 'yaml', -- Ansible templates of YAML files
    ['.*%.tfvars'] = 'terraform-vars',
  },
}
