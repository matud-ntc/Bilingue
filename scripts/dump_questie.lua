-- lua5.4 dump_questie.lua <QuestieDB dir> <kind: npc|quest|object|item> <locale>
-- Prints "id\tname[\tsubname]" lines. locale "enUS" reads the base DB, others the l10n lookup.
local root, kind, locale = arg[1], arg[2], arg[3]
loadstring = loadstring or load

local db, l10n = {}, {
  npcNameLookup = {}, questLookup = {}, objectLookup = {}, itemLookup = {},
}
QuestieLoader = { ImportModule = function(_, name) return name == "l10n" and l10n or db end }
GetLocale = function() return locale end

local function run(path)
  local chunk = assert(loadfile(path))
  chunk()
end

local function rows(t)
  local ids = {}
  for id in pairs(t) do ids[#ids + 1] = id end
  table.sort(ids)
  local i = 0
  return function()
    i = i + 1
    local id = ids[i]
    if id then return id, t[id] end
  end
end

local function clean(s)
  return (s or ""):gsub("[\t\r\n]", " ")
end

if locale == "enUS" then
  local file = ({ npc = "foreverNpcDB", quest = "foreverQuestDB", object = "foreverObjectDB", item = "foreverItemDB" })[kind]
  run(root .. "/data/Forever/" .. file .. ".lua")
  local data = assert(loadstring(db[kind .. "Data"]))()
  local keys = db[kind .. "Keys"]
  for id, row in rows(data) do
    local sub = kind == "npc" and keys.subName and row[keys.subName] or nil
    io.write(id, "\t", clean(row[keys.name]), sub and ("\t" .. clean(sub)) or "", "\n")
  end
else
  local dir = ({ npc = "lookupNpcs", quest = "lookupQuests", object = "lookupObjects", item = "lookupItems" })[kind]
  run(root .. "/l10n/Forever/" .. dir .. "/" .. locale .. ".lua")
  local field = ({ npc = "npcNameLookup", quest = "questLookup", object = "objectLookup", item = "itemLookup" })[kind]
  local v = l10n[field][locale]
  if type(v) == "function" then v = v() end
  for id, row in rows(v) do
    if type(row) == "table" then
      local name = kind == "quest" and row[1] or row[1]
      local sub = kind == "npc" and row[2] or nil
      io.write(id, "\t", clean(name), sub and ("\t" .. clean(sub)) or "", "\n")
    else
      io.write(id, "\t", clean(row), "\n")
    end
  end
end
