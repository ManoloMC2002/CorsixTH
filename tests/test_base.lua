package.path = package.path
  .. ";./?.lua"
  .. ";../?.lua"
  .. ";./CorsixTH/?.lua"
  .. ";./CorsixTH/Lua/?.lua"
  .. ";./CorsixTH/Lua/?/init.lua"
  .. ";./CorsixTH/Lua/?/?.lua"

local TestBase = {}

function TestBase.setup()
  package.preload["TH"] = function()
    return {}
  end

  _G.Object = {}
  _G.Object.__index = _G.Object

  _G.class = function(name)
    return function(base)
      local cls = {}
      cls.__index = cls
      cls.__name = name

      if base then
        setmetatable(cls, { __index = base })
      end

      _G[name] = cls
      return cls
    end
  end
end

return TestBase