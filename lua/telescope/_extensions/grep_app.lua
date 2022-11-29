local grepapp = require("grep_app.init")

return require("telescope").register_extension {
  setup = grepapp.setup,
  exports = {
    grep_app = grepapp.picker,
    live = grepapp.live_picker,
  },
}
