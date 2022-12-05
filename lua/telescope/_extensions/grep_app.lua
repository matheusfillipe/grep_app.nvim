local grepapp = require("grep_app.init")

return require("telescope").register_extension {
  setup = grepapp.setup,
  exports = {
    grep_app = grepapp.picker,
    live = grepapp.live_picker,
    open_repo = grepapp.open_repo,
    open_line = grepapp.open_line,
    copy_repo_url = grepapp.copy_repo_url,
    copy_line_url = grepapp.copy_line_url,
  },
}
