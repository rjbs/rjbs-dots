local Microphonist = { }

function Microphonist:new (obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  obj.options = {
    -- Maybe I should trim the name I get.  Whatever. -- rjbs, 2020-07-18
    { name = "C-Media USB Headphone Set  ", icon = "🎧", order = 1 },
    { name = "HD Pro Webcam C920",          icon = "🎙", order = 2 },
    { name = "MacBook Pro Microphone",      icon = "💻" },
  }

  obj.byName = {}
  obj.rotor = {}

  for k, v in pairs(obj.options) do
    if v.order then obj.rotor[v.order] = v end
    obj.byName[v.name] = v
  end

  obj.unknownIcon = "🧏🏽"

  return obj
end

-- hs.audiodevice.datasource:name() -> string
-- hs.audiodevice.datasource:setDefault() -> hs.audiodevice.datasource
-- hs.audiodevice.defaultOutputDevice() -> hs.audiodevice or nil

function Microphonist:currentInputProfile ()
  local active = hs.audiodevice.defaultInputDevice()

  if active == nil then return nil end

  local profile = self.byName[ active:name() ]

  if profile == nil then return nil end

  return profile
end

function Microphonist:redraw ()
  local profile = self:currentInputProfile()

  local icon = self.unknownIcon
  if profile and profile.icon then icon = profile.icon end

  self.micMenu:setTitle(icon)
end

function Microphonist:toggleInput ()
  local profile = self:currentInputProfile()
  local order = profile.order == nil and 1 or (profile.order + 1)

  local profile = self.rotor[ order ] or self.rotor[1]

  local input = hs.audiodevice.findInputByName(profile.name)
  if input == nil then return end

  input:setDefaultInputDevice()

  self:redraw()
end

function Microphonist:install ()
  self.micMenu = hs.menubar.new()

  self.micMenu:setClickCallback(function ()
    self:toggleInput()
  end)

  hs.audiodevice.watcher.setCallback(function (change)
    if change ~= "dIn " then return end
    self:redraw()
  end)

  hs.audiodevice.watcher.start()

  self:redraw()
end

return Microphonist
