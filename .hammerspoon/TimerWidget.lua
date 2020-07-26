local TimerWidget = { }

local startPattern      = { { rgb = "00FF00", times = 3 } }
local slicePattern      = { { rgb = "FF8800" } }
local startRestPattern  = { { rgb = "FF00FF", times = 3 } }
local timerEndPattern   = { { rgb = "FF0000", times = 3 } }
local cancelPattern     = { times = 2, { rgb = "FF0000", litTime = 100 },
                                       { rgb = "FF8800", litTime = 100 } }

function TimerWidget:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.state = "idle"

  return obj
end

function TimerWidget:timeLeft ()
  local remaining = math.floor(self.doneAt - hs.timer.secondsSinceEpoch())
  return string.format(
    "%.0f:%02.0f",
    (remaining - (remaining % 60)) / 60,
    remaining % 60
  )
end

function TimerWidget:redraw ()
  if self.state == "running" then
    local remaining = self.doneAt - hs.timer.secondsSinceEpoch()
    self.timerMenu:setTitle(self:timeLeft() .. " ⏳")
    return
  end

  if self.state == "resting" then
    local remaining = self.doneAt - hs.timer.secondsSinceEpoch()
    self.timerMenu:setTitle(self:timeLeft() .. " 💤")
    return
  end

  self.timerMenu:setTitle("🍅")
end

function TimerWidget:startPomodoro (runSeconds, restSeconds)
  self.state = "running"

  self.runSeconds  = runSeconds
  self.restSeconds = restSeconds

  hs.sound.getByFile("/Users/rjbs/Dropbox/music/3-2-1-lets-jam.mp3"):play()
  self:blinkPattern( startPattern )
  self.doneAt  = hs.timer.secondsSinceEpoch() + self.runSeconds
  self.timer = hs.timer.doEvery(1, function () self:tick() end)
  self.blinkSlice = { numerator = 4, denomenator = 5, total = self.runSeconds }
  self:redraw()
end

function TimerWidget:startRest ()
  self.state = "resting"
  self:blinkPattern( startRestPattern )
  hs.speech.new():speak("Time to take a break.")
  hs.notify.new(nil, {
    autoWithdraw  = true,
    title         = "It's over.",
    setIdImage    = "/Users/rjbs/Dropbox/images/tomato-icon.png"
  }):send()
  self.doneAt = hs.timer.secondsSinceEpoch() + self.restSeconds
  self.timer = hs.timer.doEvery(1, function () self:tick() end)
  self:redraw()
end

function TimerWidget:clearTimer ()
  if self.timer then
    self.timer:stop()
    self.timer = nil
  end

  self.blinkSlice = nil
  self.doneAt = nil
  self.state = "idle"
  self.runSeconds = nil
  self.restSeconds = nil

  self:redraw()
end

function TimerWidget:cancelTimer ()
  self:clearTimer()
  self:blinkPattern(cancelPattern)
end

-- What is a tolerable subset of pattern semantics?
--   { rgb, litTime, darkTime, times } ...
function TimerWidget:blinkPattern (pattern)
  local program = {}

  for i = 1, pattern.times or 1 do
    for j, subpattern in ipairs(pattern) do
      local rgb       = subpattern.rgb or error("no subpattern rgb")
      local litTime   = subpattern.litTime  or 300
      local darkTime  = subpattern.darkTime or 300
      local times     = subpattern.times    or 1

      for k = 1, times do
        table.insert(program, { cmd = "set", color = rgb })
        table.insert(program, { cmd = "sleep", ms = litTime })
        table.insert(program, { cmd = "off" })
        table.insert(program, { cmd = "sleep", ms = darkTime })
      end
    end
  end

  local url = "http://raspberrypi.local:5000/"

  local json = hs.json.encode(program)
  hs.http.doAsyncRequest(url, 'POST', json, nil, function () end, 'ignoreLocalCache')
end

function TimerWidget:blink (rgb, count)
  rgb = rgb:gsub("^#","")
  self:blinkPattern({
    { rgb = rgb, times = count }
  })
end

function TimerWidget:tick ()
  local remaining = self.doneAt - hs.timer.secondsSinceEpoch()

  if remaining <= 0 then
    if (self.state == "running") and (self.restSeconds > 0) then
      self.timer:stop()
      self:startRest()
    else
      self:blinkPattern(timerEndPattern)
      self:clearTimer()
    end
  else
    if self.state == "running" then
      local bs = self.blinkSlice
      local nextBlink = bs.total / bs.denomenator * bs.numerator

      if remaining < nextBlink then
        local sliceBlink = { table.unpack(slicePattern) }
        sliceBlink.times = bs.numerator
        self:blinkPattern(sliceBlink)
        bs.numerator = bs.numerator - 1
      end
    end
  end

  self:redraw()
end

function TimerWidget:provideMenu ()
  if self.state == "running" then
    return {
      { title = "Cancel Pomodoro", fn = function () self:cancelTimer() end }
    }
  end

  if self.state == "resting" then
    return {
      { title = "Cancel Rest", fn = function () self:cancelTimer() end }
    }
  end

  if self.state == "idle" then
    return {
      {
        title = "Start Pomodoro (25/5)",
        fn    = function () self:startPomodoro(25 * 60, 5 * 60) end
      },
      {
        title = "Start Pomodoro (30/0)",
        fn    = function () self:startPomodoro(30 * 60, 0) end
      },
      {
        title = "Start Test (30s/5)",
        fn    = function () self:startPomodoro(30, 5) end
      },
    }
  end

  return {
    { title = "Something is Broken!", disabled = true }
  }
end

function TimerWidget:install ()
  self.timerMenu = hs.menubar.new()

  self.timerMenu:setMenu(function ()
    return self:provideMenu()
  end)

  self:redraw()
end

return TimerWidget
