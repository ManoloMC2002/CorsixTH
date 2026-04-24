local lu = require("luaunit")

local TestBase = require("tests.test_base")
TestBase.setup()

require("CorsixTH.Lua.entities.machine")

local Machine = _G["Machine"]

TestMachineEarthquake = {}

-- Vérifie qu’un tremblement de terre n’incrémente pas total_usage
-- mais incrémente bien times_used
function TestMachineEarthquake:testEarthquakeDoesNotIncrementTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(false, true)

  lu.assertEquals(fake_machine.times_used, 1)
  lu.assertEquals(fake_machine.total_usage, 0)
end

-- Vérifie qu’une utilisation normale (pas tremblement de terre) incrémente tous les compteurs
function TestMachineEarthquake:testNormalUsageIncrementsTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(false, false)

  lu.assertEquals(fake_machine.times_used, 1)
  lu.assertEquals(fake_machine.total_usage, 1)
end

-- Vérifie que total_usage_only n’incrémente pas times_used mais incrémente total_usage
function TestMachineEarthquake:testTotalUsageOnlyDoesNotIncrementTimesUsed()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 0
  fake_machine.total_usage = 0

  fake_machine:incrementUsageCounts(true, false)

  lu.assertEquals(fake_machine.times_used, 0)
  lu.assertEquals(fake_machine.total_usage, 1)
end

-- Vérifie qu’un tremblement de terre incrémente times_used sans modifier total_usage
function TestMachineEarthquake:testEarthquakeKeepsExistingTotalUsage()
  local fake_machine = setmetatable({}, { __index = Machine })

  fake_machine.times_used = 5
  fake_machine.total_usage = 10

  fake_machine:incrementUsageCounts(false, true)

  lu.assertEquals(fake_machine.times_used, 6)
  lu.assertEquals(fake_machine.total_usage, 10)
end

os.exit(lu.LuaUnit.run())