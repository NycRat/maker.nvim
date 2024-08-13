local M = {}

function M.read_commands_json(filename)
  local file = io.open(filename, "r")
  if not file then
    return {}
  end
  local content = file:read("*a")
  file:close()
  local commands, err = vim.json.decode(content)
  if err then
    print("Error decoding JSON: " .. err)
    return {}
  end
  return commands or {}
end

function M.write_commands(filename, commands)
  local file = io.open(filename, "w")
  if not file then
    print("Error opening file for writing.")
    return
  end
  local content, err = vim.json.encode(commands)
  if err then
    print("Error encoding JSON: " .. err)
    return
  end
  file:write(content)
  file:close()
end

function M.read_command_types_list(filename)
  local cwd = vim.fn.getcwd()
  local commands = M.read_commands_json(filename)[cwd]
  local result = {}

  for key, value in pairs(commands) do
    table.insert(result, key .. ": " .. value)
  end

  return result
end

return M
