-- better yank
function BetterYank(opts)
        -- unpack is still correct in neovim
        local current_line = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_command(current_line .. "," .. (opts.count - (current_line - 1)) .. "y")
end

vim.api.nvim_create_user_command("BetterYank", BetterYank, { count = 1 })

-- better delete
function BetterDelete(opts)
        -- unpack is still correct in neovim
        local current_line = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_command(current_line .. "," .. (opts.count - (current_line - 1)) .. "d")
end

vim.api.nvim_create_user_command("BetterDelete", BetterDelete, { count = 1 })

function Get_git_root()
        local opts = {}
        local function is_git_repo()
                vim.fn.system("git rev-parse --is-inside-work-tree")
                return vim.v.shell_error == 0
        end
        if is_git_repo() then
                local dot_git_path = vim.fn.finddir(".git", ".;")
                local root = vim.fn.fnamemodify(dot_git_path, ":h")
                opts = {
                        cwd = root,
                }
        end
        return opts
end

function Live_grep_from_project_git_root()
        local opts = Get_git_root()
        require("telescope.builtin").live_grep(opts)
end

function DebugAction()
        --if vim.bo.filetype == "rust" then
        --  vim.cmd.RustLsp("debuggables")
        --else
        require("dap").continue()
        --end
end

function CodeAction()
        --if vim.bo.filetype == "rust" then
        --  vim.cmd.RustLsp('codeAction')
        --else
        vim.lsp.buf.code_action({
                context = {
                        only = {
                                "quickfix",
                                "quickfix.ltex",
                                "source",
                                "source.fixAll",
                                "source.organizeImports",
                                "",
                        },
                },
        })
        --end
end

function CodeRefactor()
        vim.lsp.buf.code_action({
                context = {
                        only = {
                                "refactor",
                                "refactor.inline",
                                "refactor.extract",
                                "refactor.rewrite",
                        },
                },
        })
end

vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<C-=>", function()
        change_scale_factor(1.25)
end)
vim.keymap.set("n", "<C-->", function()
        change_scale_factor(1 / 1.25)
end)
