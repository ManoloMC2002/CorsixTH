local lu = require("luaunit")
local TestBase = require("tests.test_base")
TestBase.setup()

require("CorsixTH.Lua.ui.move_room")
local UIMoveRoom = _G["UIMoveRoom"]

--- Crée un objet simulé de déplacement de salle, héritant de UIMoveRoom.
--- Utilisé pour tester ou simuler la logique de déplacement sans affecter le vrai monde du jeu.
---
--- @param room      table   La salle à déplacer.
--- @param origin_x  number  Position X de départ. Par défaut : room.x
--- @param origin_y  number  Position Y de départ. Par défaut : room.y
--- @return table    Un objet fake_mr prêt à l'emploi.
local function make_move_room(room, origin_x, origin_y)
  local fake_mr = setmetatable({}, { __index = UIMoveRoom })

  local fake_world = {
    addObjectToTile = function() end,
    removeObjectFromTile = function() end,
    getRoom = function() return nil end,
    mode_deplacement = false,
  }

  local fake_ui = {
    setCursor = function() end,
    default_cursor = "default",
  }

  fake_mr.world = fake_world
  fake_mr.ui = fake_ui
  fake_mr.room = room
  fake_mr.origin_x = origin_x or room.x
  fake_mr.origin_y = origin_y or room.y
  fake_mr.lifted_objects = {}
  fake_mr.preview_tiles = {}

  return fake_mr
end

TestUIMoveRoom = {}

--- Vérifie que `_restoreObjects` replace les objets à la bonne position absolue
--- en ajoutant leur position relative (rel_x, rel_y) à la position de destination.
---
--- Cas testé : objet à (rel_x=1, rel_y=2) avec destination (5,5) → attendu (6,7)
function TestUIMoveRoom:test_restore_objects_places_objects_at_correct_relative_position()
  local room = { x = 5, y = 5, width = 3, height = 3, objects = {} }
  local fake_mr = make_move_room(room, 5, 5)

  local placed_x, placed_y = nil, nil
  local fake_obj = {
    setTile = function(_, x, y) placed_x, placed_y = x, y end,
  }

  fake_mr.lifted_objects = {
    { object = fake_obj, rel_x = 1, rel_y = 2 },
  }

  fake_mr:_restoreObjects(5, 5)

  lu.assertEquals(placed_x, 6)
  lu.assertEquals(placed_y, 7)
end

--- Vérifie que l'annulation d'un déplacement replace les objets à leur position d'origine
--- et non à la position actuelle de la salle.
---
--- Cas testé : salle à (8,8), origine à (3,4) → les objets doivent retourner en (3,4)
function TestUIMoveRoom:test_cancel_move_restores_objects_to_origin()
  local room = { x = 8, y = 8, width = 2, height = 2, objects = {} }
  local fake_mr = make_move_room(room, 3, 4)

  local placed_x, placed_y = nil, nil
  local fake_obj = {
    setTile = function(_, x, y) placed_x, placed_y = x, y end,
  }

  fake_mr.lifted_objects = {
    { object = fake_obj, rel_x = 0, rel_y = 0 },
  }

  local closed = false
  fake_mr.close = function() closed = true end

  fake_mr:cancelMove()

  lu.assertEquals(placed_x, 3)
  lu.assertEquals(placed_y, 4)
  lu.assertTrue(closed)
end

--- Vérifie que `canMoveRoomTo` retourne false et affiche une erreur
--- si un humanoïde se trouve à l'intérieur de la salle au moment du déplacement.
---
--- Cas testé : humanoïde présent sur la tuile (2,2) dans une salle 2x2 → résultat false + erreur affichée
function TestUIMoveRoom:test_can_move_room_to_returns_false_if_humanoid_inside()
  local room = { x = 2, y = 2, width = 2, height = 2 }

  local error_shown = false
  local fake_world = setmetatable({}, {})
  fake_world.map = { th = {
    getCellFlags = function(_, x, y, flags) flags.hospital = true end,
  }}
  fake_world.entity_map = {
    getHumanoidsAtCoordinate = function(_, x, y)
      -- Simule un humanoïde sur la tuile (2,2) = intérieur de la pièce
      if x == 2 and y == 2 then return { "humanoid" } end
      return {}
    end,
  }
  fake_world.showError = function() error_shown = true end
  fake_world.app = { world = fake_world }

  -- On appelle canMoveRoomTo directement via la classe World mockée
  -- en injectant la méthode comme fonction standalone
  require("CorsixTH.Lua.world")
  local World = _G["World"]
  local fake_w = setmetatable(fake_world, { __index = World })

  local result = fake_w:canMoveRoomTo(room, 5, 5, false)

  lu.assertFalse(result)
  lu.assertTrue(error_shown)
end

os.exit(lu.LuaUnit.run())