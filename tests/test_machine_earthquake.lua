local lu = require("luaunit")

local TestBase = require("tests.test_base")
TestBase.setup()

require("CorsixTH.Lua.entities.machine")

local Machine = _G["Machine"]

TestMachineEarthquake = {}

--- Vérifie qu'un tremblement de terre incrémente times_used mais pas total_usage.
---
--- Cas testé : incrementUsageCounts(false, true) → times_used = 1, total_usage = 0
function TestMachineEarthquake:testEarthquakeDoesNotIncrementTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(false, true)

  lu.assertEquals(fake_machine.times_used, 1)
  lu.assertEquals(fake_machine.total_usage, 0)
end

--- Vérifie qu'une utilisation normale incrémente à la fois times_used et total_usage.
---
--- Cas testé : incrementUsageCounts(false, false) → times_used = 1, total_usage = 1
function TestMachineEarthquake:testNormalUsageIncrementsTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(false, false)

  lu.assertEquals(fake_machine.times_used, 1)
  lu.assertEquals(fake_machine.total_usage, 1)
end

--- Vérifie que le mode total_usage_only incrémente total_usage mais pas times_used.
---
--- Cas testé : incrementUsageCounts(true, false) → times_used = 0, total_usage = 1
function TestMachineEarthquake:testTotalUsageOnlyDoesNotIncrementTimesUsed()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(true, false)

  lu.assertEquals(fake_machine.times_used, 0)
  lu.assertEquals(fake_machine.total_usage, 1)
end

--- Vérifie qu'un tremblement de terre n'altère pas un total_usage déjà existant.
---
--- Cas testé : incrementUsageCounts(false, true) avec times_used=5, total_usage=10 → times_used = 6, total_usage = 10
function TestMachineEarthquake:testEarthquakeKeepsExistingTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 5
  fake_machine.total_usage = 10

  fake_machine:incrementUsageCounts(false, true)

  lu.assertEquals(fake_machine.times_used, 6)
  lu.assertEquals(fake_machine.total_usage, 10)
end

os.exit(lu.LuaUnit.run())