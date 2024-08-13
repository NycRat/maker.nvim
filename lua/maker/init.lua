local M = {}

local helper = 
require("maker.helper")

local opts = {
  commands_file = vim.fn.stdpath("data") .. "/maker_commands.json",
  default_commands_file = vim.fn.stdpath("data") .. "/maker_default_commands.json",
}

local function create_commands()
  vim.api.nvim_create_user_command("Set", function()
    vim.ui.input({ prompt = "Enter command type (build, run, test, etc.): " }, function(type)
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
    end)
  end, {
    desc = "Prompt to set a command of type (build, run, test, etc.) for the current project",
  })

  -- Command to execute a command of a specific type
  vim.api.nvim_create_user_command("Run", function(optss)
    if optss.args ~= "" then
      local type = optss.args
      M.execute_command(type)
    else
      local options = helper.read_command_types_list(opts.commands_file)

      vim.ui.select(options, {
        prompt = "Select a command:",
      }, function(choice)
        M.execute_command(string.match(choice, "([^:]+)"))
      end)
    end
  end, {
    nargs = "?",
    desc = "Execute a command of type (build, run, test, etc.) for the current project, or select from list of commands if no type is provided",
  })
end

function M.setup(opts)
  create_commands()
end

function M.set_command(type, command)
  vim.api.nvim_command("redraw!")
  if not type or type == "" or not command or command == "" then
    return
  end
  local cwd = vim.fn.getcwd()

  local commands = helper.read_commands_json(opts.commands_file)
  commands[cwd] = commands[cwd] or {}
  commands[cwd][type] = command
  helper.write_commands(opts.commands_file, commands)
  print(type .. " command set for this project.")
end

function M.execute_command(type)
  vim.api.nvim_command("redraw!")
  local cwd = vim.fn.getcwd()
  local commands = helper.read_commands_json(opts.commands_file)
  local command = commands[cwd] and commands[cwd][type]
  if command then
    vim.cmd("! " .. command)
  else
    print("No " .. type .. " command defined for this project.")
  end
end

return M
