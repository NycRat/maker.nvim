local M = {}

local command_file = vim.fn.stdpath("data") .. "/maker_commands.json"

function M.setup(opts)
  vim.api.nvim_create_user_command("Set", function()
    vim.ui.input(
      { prompt = "Enter command type (build, run, test, etc.): " },
      function(type)
        if not type or type == "" then
          print("Invalid command type.")
          return
        end
        vim.ui.input({
          prompt = "Enter command: ",
          completion = "shellcmd", -- Enable shell command completion
        }, function(command)
          if not command or command == "" then
            print("Invalid command.")
            return
          end
          M.set_command(type, command)
        end)
      end
    )
  end, {
    desc = "Prompt to set a command of type (build, run, test, etc.) for the current project",
  })

  -- Command to execute a command of a specific type
  vim.api.nvim_create_user_command("Run", function(optss)
    local type = optss.args
    M.execute_command(type)
  end, {
    nargs = 1,
    desc = "Execute a command of type (build, run, test, etc.) for the current project",
  })
end

local function read_commands()
  local file = io.open(command_file, "r")
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

local function write_commands(commands)
  local file = io.open(command_file, "w")
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

M.set_command = function(type, command)
  vim.api.nvim_command("redraw!")
  if not type or type == "" or not command or command == "" then
    print("Usage: Command <type> <command>")
    return
  end
  local cwd = vim.fn.getcwd()
  local commands = read_commands()
  commands[cwd] = commands[cwd] or {}
  commands[cwd][type] = command
  write_commands(commands)
  print(type .. " command set for this project.")
end

M.execute_command = function(type)
  vim.api.nvim_command("redraw!")
  local cwd = vim.fn.getcwd()
  local commands = read_commands()
  local command = commands[cwd] and commands[cwd][type]
  if command then
    vim.cmd("! " .. command)
  else
    print("No " .. type .. " command defined for this project.")
  end
end

return M
