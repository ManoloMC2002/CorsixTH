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
    local cls = {}
    cls.__index = cls
    cls.__name = name
    setmetatable(cls, { __index = _G.Object })
    _G[name] = cls

    -- Supporte les deux syntaxes :
    --   class "Foo"           (vrai code du jeu, retourne la classe directement)
    --   class("Foo")(base)    (ancienne syntaxe des tests)
    return function(base)
      if base then
        setmetatable(cls, { __index = base })
      end
      return cls
    end
  end
end

return TestBase