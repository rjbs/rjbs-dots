local TimerWidget = { }

local startPattern      = { times = 3, { rgb = "00FF00" } }
local slicePattern      = {            { rgb = "FF8800" } }
local startRestPattern  = { times = 3, { rgb = "FF00FF" } }
local timerEndPattern   = { times = 3, { rgb = "FF0000" } }
local cancelPattern     = { times = 2, { rgb = "FF0000", litTime = 0.1 },
                                       { rgb = "FF8800", litTime = 0.1 } }

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
--   { rgb, litTime, darkTime, n } ...
function TimerWidget:blinkPattern (pattern)
  local program = pattern.times or 1

  for i, subpattern in ipairs(pattern) do
    local rgb       = subpattern.rgb or error("no subpattern rgb")
    local litTime   = subpattern.litTime  or 0.3
    local darkTime  = subpattern.darkTime or 0.3
    local times     = subpattern.times    or 1

    -- You can't supply a 0s time for anything, or the server sticks in a
    -- default.  To deal with that, we use a 0.01 fade time, and here we shave
    -- it off the requested time, which is probably not perceptable, but let's
    -- try to be accurate.
    litTime  = litTime - 0.01
    darkTime = darkTime - 0.01

    -- The subprogram format is (targetRGB,fadeTime,led), where fadeTime is how
    -- long it takes to go from the current color to the target.  That means
    -- that if we want to sustain, we need a short fadeTime to dark, then a
    -- second instance of "fade black to black" for the sustain.
    local subprogram = string.format(",%s,0.01,0", rgb)
                    .. string.format(",%s,%.2f,0", rgb, litTime)
                    .. string.format(",000000,0.01,0")
                    .. string.format(",000000,%.2f,0", darkTime)

    program = program .. string.rep(subprogram, times)
  end

  local url = "http://raspberrypi.local:8000/blink1/pattern/play?pattern="
            .. program

  hs.http.doAsyncRequest(url, 'GET', nil, nil, function () end, 'ignoreLocalCache')
end

function TimerWidget:blink (rgb, count)
  rgb = rgb:gsub("^#","")
  self:blinkPattern({
    { rgb = rgb, litTime = 0.3, darkTime = 0.3, times = count }
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
