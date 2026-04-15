local utils = require "treesitter-sexp.utils"

local function update_selection(bufnr, range, mode)
  local start_row, start_col, end_row, end_col = unpack(range)
  -- end_col from treesitter is exclusive, visual selection needs inclusive
  if end_col > 0 then
    end_col = end_col - 1
  else
    end_row = end_row - 1
    end_col = #vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] - 1
  end
  vim.api.nvim_buf_set_mark(bufnr, "<", start_row + 1, start_col, {})
  vim.api.nvim_buf_set_mark(bufnr, ">", end_row + 1, end_col, {})
  vim.cmd("normal! gv")
end

---@type table<string, TSSexp.Textobject>
local M = {
  inner_elem = {
    desc = "Inner element",
    get_range = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        return { elem:range() }
      end
    end,
  },
  outer_elem = {
    desc = "Outer element",
    get_range = function()
      local elem = utils.get_elem()
      if elem ~= nil then
        return { utils.get_a_elem_range(elem) }
      end
    end,
  },
  inner_form = {
    desc = "Inner form",
    get_range = function()
      local form = utils.get_form()
      if form ~= nil then
        return { utils.get_i_form_range(form) }
      end
    end,
  },
  outer_form = {
    desc = "Outer form",
    get_range = function()
      local form = utils.get_form()
      if form ~= nil then
        return { form.outer:range() }
      end
    end,
  },
  inner_top_level = {
    desc = "Inner top level form",
    get_range = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        return { utils.get_i_form_range(form) }
      end
    end,
  },
  outer_top_level = {
    desc = "Outer top level form",
    get_range = function()
      local form = utils.get_top_level_form()
      if form ~= nil then
        return { form.outer:range() }
      end
    end,
  },
}

local metatable = {
  ---@param self TSSexp.Textobject
  __call = function(self)
    local range = self.get_range()
    if range ~= nil then
      update_selection(0, range, "v")
    end
  end,
}

for _, textobject in pairs(M) do
  setmetatable(textobject, metatable)
end

return M
