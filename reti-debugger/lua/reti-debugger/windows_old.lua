local M = {}

M.buffers = {}
M.windows = {}

function M.create_windows(registers, eprom, uart, sram)
  -- get size of current editor
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  win_config = {
    anchor = "NW",
    focusable = true,
    width = math.floor(width / 4),
    height = height,
    zindex = 1,
  }

  -- registers window
  M.buffers.buf1_id = vim.api.nvim_create_buf(false, true)
  win_addtional = {
    relative = "editor",
    row = 0,
    col = 0
  } 
  M.windows.win1_id = vim.api.nvim_open_win(M.buffers.buf1_id, false, vim.tbl_extend("force", win_config, win_addtional))

  -- eprom window
  M.buffers.buf2_id = vim.api.nvim_create_buf(false, true)
  win_config.col = calculate_position(1, width)
  M.windows.win2_id = vim.api.nvim_open_win(M.buffers.buf2_id, true, win_config)

  -- uart window
  M.buffers.buf3_id = vim.api.nvim_create_buf(false, true)
  win_config.col = calculate_position(2, width)
  M.windows.win3_id = vim.api.nvim_open_win(M.buffers.buf3_id, false, win_config)

  -- sram window
  M.buffers.buf4_id = vim.api.nvim_create_buf(false, true)
  win_config.col = calculate_position(3, width)
  M.windows.win4_id = vim.api.nvim_open_win(M.buffers.buf4_id, false, win_config)
end

function M.update_buffers(registers, eprom, uart, sram)
  vim.api.nvim_buf_set_lines(M.buffers.buf1_id, 0, -1, true, registers)
  vim.api.nvim_buf_set_lines(M.buffers.buf2_id, 0, -1, true, eprom)
  vim.api.nvim_buf_set_lines(M.buffers.buf3_id, 0, -1, true, uart)
  vim.api.nvim_buf_set_lines(M.buffers.buf4_id, 0, -1, true, sram)
end

return M
