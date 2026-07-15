-- yadm provisioning — headless nvim, invoked by `.config/yadm/bootstrap`:
--   nvim --headless -u <nvim>/init.lua -l <this>
--
-- Front-loads everything that would otherwise download on the first interactive
-- launch, so `nvim` comes up clean:
--   1. mason tools (LSP servers, linters, formatters, debug adapters)
--   2. treesitter parsers
-- then prints a `:checkhealth nodar` summary.
--
-- All output goes to stdout; the bootstrap tees it into
-- ~/.local/state/yadm/bootstrap.log for a single unified record. Idempotent.
--
-- Note on the *_TIMEOUT_MS values below: these are *maximum* waits, not fixed
-- sleeps. Each wait returns the instant the work completes; the timeout only
-- bounds a genuine hang so the bootstrap can't block forever.

local function log(msg)
  io.stdout:write(tostring(msg) .. '\n')
  io.stdout:flush()
end

local MASON_TIMEOUT_MS = 15 * 60 * 1000 -- ceiling only; returns as soon as mason is done
local TS_TIMEOUT_MS = 10 * 60 * 1000 -- ceiling only; returns as soon as parsers are done

log('')
log('========== nvim provisioning ==========')

--------------------------------------------------------------------------------
-- 1. mason tools
--------------------------------------------------------------------------------
-- mason-tool-installer's `run_on_start` auto-run (fired on VimEnter, which also
-- fires under `-l`) drives the install. We ONLY listen for completion; we do NOT
-- call :MasonToolsInstall, because a second trigger makes any package that is
-- already mid-install skip its `on_close` callback, so the completion counter
-- never reaches total and the wait would hang.
log('----- mason: waiting for tool installer -----')

local mason_done = false

vim.api.nvim_create_autocmd('User', {
  pattern = 'MasonToolsStartingInstall',
  callback = function()
    log('[mason] installing tools (this can take a few minutes)...')
  end,
})
vim.api.nvim_create_autocmd('User', {
  pattern = 'MasonToolsUpdateCompleted',
  callback = function()
    mason_done = true
  end,
})

-- returns early the moment `mason_done` is set; the timeout is just a hang guard
local mason_ok = vim.wait(MASON_TIMEOUT_MS, function()
  return mason_done
end, 500)
if not mason_ok then
  log('[mason] WARN: timed out after ' .. (MASON_TIMEOUT_MS / 1000) .. 's waiting for MasonToolsUpdateCompleted')
end

local ok_reg, mr = pcall(require, 'mason-registry')
if ok_reg then
  local names = mr.get_installed_package_names and mr.get_installed_package_names() or {}
  table.sort(names)
  log('[mason] installed packages (' .. #names .. '): ' .. table.concat(names, ', '))
  if #names == 0 then
    log('[mason] WARN: no packages installed — provisioning likely incomplete')
  end
else
  log('[mason] WARN: could not load mason-registry for summary')
end

--------------------------------------------------------------------------------
-- 2. treesitter parsers
--------------------------------------------------------------------------------
-- treesitter.lua kicks off an async install at startup; here we install the same
-- shared list and block until it finishes so no parser is left half-installed
-- (the startup pass alone is racy under headless `+qa`).
log('----- treesitter: installing parsers -----')

local langs = require('config/ts-langs')
local ok_ts, ts = pcall(require, 'nvim-treesitter')
if ok_ts then
  -- :wait() returns as soon as the install task completes; timeout is a ceiling
  local ok_wait, err = pcall(function()
    ts.install(langs):wait(TS_TIMEOUT_MS)
  end)
  if not ok_wait then
    log('[treesitter] WARN: install did not finish cleanly: ' .. tostring(err))
  end
else
  log('[treesitter] WARN: could not load nvim-treesitter')
end

local parser_dir = vim.fn.stdpath('data') .. '/site/parser'
local parsers = {}
for _, path in ipairs(vim.fn.glob(parser_dir .. '/*.so', false, true)) do
  table.insert(parsers, vim.fn.fnamemodify(path, ':t:r'))
end
table.sort(parsers)
log('[treesitter] installed parsers (' .. #parsers .. '): ' .. table.concat(parsers, ', '))
-- flag any configured language whose parser is missing
local have = {}
for _, p in ipairs(parsers) do
  have[p] = true
end
local missing = {}
for _, lang in ipairs(langs) do
  if not have[lang] then
    table.insert(missing, lang)
  end
end
if #missing > 0 then
  log('[treesitter] WARN: missing parsers: ' .. table.concat(missing, ', '))
end

--------------------------------------------------------------------------------
-- 3. health summary
--------------------------------------------------------------------------------
log('----- checkhealth nodar -----')
pcall(function()
  vim.cmd('checkhealth nodar')
  -- the nodar check is synchronous (version + executable() probes); a short
  -- settle just lets the health buffer finish rendering before we read it
  vim.wait(500, function()
    return false
  end)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, l in ipairs(lines) do
    log(l)
  end
end)

log('========== provisioning complete ==========')
log('')
vim.cmd('qa!')
