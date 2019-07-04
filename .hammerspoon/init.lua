function resizeChromes ()
  local chrome = hs.application.find("Chrome")
  if (chrome) then
    local windows = chrome:visibleWindows()
    for i, window in ipairs(windows) do
      if (string.len(window:title()) > 0) then
        window:move({
          x = 10 * (i - 1),
          y = 10 * (i - 1),
          w = 1200,
          h = 800
        })
      end
    end
  end
end

resizeMenu = hs.menubar.new()
resizeMenu:setTitle("⌧")
resizeMenu:setClickCallback(resizeChromes)
