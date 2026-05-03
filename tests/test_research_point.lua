local lu = require("luaunit")
local TestBase = require("tests.test_base")
TestBase.setup()

require("CorsixTH.Lua.research_department")
local ResearchDepartment = _G["ResearchDepartment"]

--- Crée un objet simulé de département de recherche, héritant de ResearchDepartment.
--- Utilisé pour tester la logique de politique de recherche sans infrastructure réelle.
---
--- @param cure_frac           number  Fraction allouée à la recherche de remèdes.
--- @param diagnosis_frac      number  Fraction allouée au diagnostic.
--- @param drugs_frac          number  Fraction allouée aux médicaments.
--- @param improvements_frac   number  Fraction allouée aux améliorations.
--- @param specialisation_frac number  Fraction allouée à la spécialisation.
--- @return table  Un objet fake_rd avec une research_policy préconfigurée.
---                Le total est calculé automatiquement comme la somme des fractions.
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

--- Vérifie que la fraction de spécialisation reste inchangée après une redistribution,
--- même si une autre catégorie (cure) est vidée et mise à 0.
---
--- Cas testé : toutes les fractions à 20, cure désactivée → specialisation reste à 20
function TestRedistributeResearchPoints:test_specialisation_frac_unchanged_after_redistribution()
  local fake_rd = make_research_dept(20, 20, 20, 20, 20)

  fake_rd.research_policy.cure.current = nil
  fake_rd.research_policy.cure.frac = 0
  fake_rd:redistributeResearchPoints()

  lu.assertEquals(fake_rd.research_policy.specialisation.frac, 20)
end

--- Vérifie que la somme de toutes les fractions ne dépasse pas 100 après une redistribution.
---
--- Cas testé : toutes les fractions à 20, diagnosis désactivée → total des fractions ≤ 100
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

--- Vérifie que les points ne sont redistribués qu'aux catégories éligibles (current ~= nil).
--- Les catégories désactivées (current = nil) ne reçoivent aucun point et restent à 0.
---
--- Cas testé : cure et improvements désactivées → leurs fractions restent à 0, specialisation reste à 20
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