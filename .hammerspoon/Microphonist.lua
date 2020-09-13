local Microphonist = { }

function Microphonist:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.options = {
    {
      input  = "External Microphone",
      output = "External Headphones",
      icon   = "🎧",
      order  = 1
    },
    {
      input  = "HD Pro Webcam C920",
      output = "CalDigit USB-C Pro Audio",
      icon   = "🎙",
      order  = 2
    },
    {
      input  = "MacBook Pro Microphone",
      output = "MacBook Pro Speakers",
      icon    = "💻"
    },
  }

  obj.byInput  = {}
  obj.byOutput = {}
  obj.rotor    = {}

  for k, v in pairs(obj.options) do
    if v.order then obj.rotor[v.order] = v end
  end

  obj.unknownIcon = "🧏🏽"

  return obj
end

-- hs.audiodevice.datasource:name() -> string
-- hs.audiodevice.datasource:setDefault() -> hs.audiodevice.datasource
-- hs.audiodevice.defaultOutputDevice() -> hs.audiodevice or nil

function Microphonist:currentAudioProfile ()
  local activeInput  = hs.audiodevice.defaultInputDevice()
  local activeOutput = hs.audiodevice.defaultOutputDevice()

  print("Input : " .. activeInput:name())
  print("Output: " .. activeOutput:name())

  if (activeInput == nil) or (activeOutput == nil) then return nil end

  local profile = nil

  for k, v in pairs(self.options) do
    if (v.output == activeOutput:name()) and (v.input == activeInput:name()) then
      profile = v
      break
    end
  end

  if profile == nil then return nil end

  return profile
end

function Microphonist:redraw ()
  local profile = self:currentAudioProfile()

  local icon = self.unknownIcon
  if profile and profile.icon then icon = profile.icon end

  self.micMenu:setTitle(icon)
end

function Microphonist:toggleAudio ()
  local profile = self:currentAudioProfile()
  local order = 1

  if (profile and (profile.order ~= nil)) then order = profile.order + 1 end

  local profile = self.rotor[ order ] or self.rotor[1]

  local input = hs.audiodevice.findInputByName(profile.input)
  if input == nil then return end

  local output = hs.audiodevice.findOutputByName(profile.output)
  if output == nil then return end

  input:setDefaultInputDevice()
  output:setDefaultOutputDevice()

  self:redraw()
end

function Microphonist:install ()
  self.micMenu = hs.menubar.new()

  self.micMenu:setClickCallback(function ()
    self:toggleAudio()
  end)

  hs.audiodevice.watcher.setCallback(function (change)
    if (change ~= "dIn ") and (change ~= "dOut") then return end
    self:redraw()
  end)

  hs.audiodevice.watcher.start()

  hs.timer.doEvery(30, function () self:redraw() end)

  self:redraw()
end

return Microphonist
