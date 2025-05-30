local uv = vim.uv

local M = {}

--- Get starting directory from buffer number or fallback to CWD
--- @param bufnr number|nil Optional buffer number
--- @return string
local function get_start_dir(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path ~= '' then
      return vim.fn.fnamemodify(path, ':p:h')
    end
  end
  return uv.cwd() or ''
end

--- Gets the directory where the first found file appears while walking up the directory tree.
--- @param filenames string[] List of filenames to search for in order.
--- @return string|nil Path of directory where the first found file was located, or nil if none found.
function M.find_root(filenames, bufnr)
  local dir = get_start_dir(bufnr)

  if dir == '' then
    return nil
  end

  -- Utility: move up one directory level
  local function updir(path)
    return path:match('(.+)/[^/]+$')
  end

  for _, filename in ipairs(filenames) do
    local current = dir
    while current do
      local path = current .. '/' .. filename
      if uv.fs_stat(path) then
        return current
      end
      current = updir(current)
    end
  end

  return nil -- none found
end

return M
