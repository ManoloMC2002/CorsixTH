local lu = require("luaunit")
local TestBase = require("tests.test_base")
TestBase.setup()

require("CorsixTH.Lua.research_department")
local ResearchDepartment = _G["ResearchDepartment"]

local function make_research_dept(cure_frac, diagnosis_frac, drugs_frac, improvements_frac, specialisation_frac)
  local fake_rd = setmetatable({}, { __index = ResearchDepartment })
  local drain = { dummy = true }
  fake_rd.drain = drain
  fake_rd.research_policy = {
    cure           = { frac = cure_frac,          current = drain },
    diagnosis      = { frac = diagnosis_frac,      current = drain },
    drugs          = { frac = drugs_frac,          current = drain },
    improvements   = { frac = improvements_frac,   current = drain },
    specialisation = { frac = specialisation_frac, current = drain },
    total          = cure_frac + diagnosis_frac + drugs_frac + improvements_frac + specialisation_frac,
  }
  return fake_rd
end

TestRedistributeResearchPoints = {}

-- Vérifie que la spécialisation ne reçoit pas de points lors d'une redistribution
function TestRedistributeResearchPoints:test_specialisation_frac_unchanged_after_redistribution()
  local fake_rd = make_research_dept(20, 20, 20, 20, 20)

  fake_rd.research_policy.cure.current = nil
  fake_rd.research_policy.cure.frac = 0
  fake_rd:redistributeResearchPoints()

  lu.assertEquals(fake_rd.research_policy.specialisation.frac, 20)
end

-- Vérifie que le total ne dépasse pas 100 après une redistribution
function TestRedistributeResearchPoints:test_total_does_not_exceed_100_after_redistribution()
  local fake_rd = make_research_dept(20, 20, 20, 20, 20)

  fake_rd.research_policy.diagnosis.current = nil
  fake_rd.research_policy.diagnosis.frac = 0
  fake_rd:redistributeResearchPoints()
  local total = fake_rd.research_policy.cure.frac + fake_rd.research_policy.diagnosis.frac
    + fake_rd.research_policy.drugs.frac + fake_rd.research_policy.improvements.frac
    + fake_rd.research_policy.specialisation.frac

  lu.assertTrue(total <= 100)
end

-- Vérifie que les points redistribués vont uniquement aux catégories éligibles
function TestRedistributeResearchPoints:test_points_redistributed_only_to_eligible_categories()
  local fake_rd = make_research_dept(0, 40, 40, 0, 20)

  fake_rd.research_policy.cure.current = nil
  fake_rd.research_policy.improvements.current = nil
  fake_rd:redistributeResearchPoints()

  lu.assertEquals(fake_rd.research_policy.cure.frac,           0)
  lu.assertEquals(fake_rd.research_policy.improvements.frac,   0)
  lu.assertEquals(fake_rd.research_policy.specialisation.frac, 20)
end

os.exit(lu.LuaUnit.run())