local addonName, ns = ...

local DEFAULTS = { enabled = true, delay = 1.5 }

ns.locale = GetLocale()
ns.isEnglishClient = ns.locale == "enUS" or ns.locale == "enGB"
ns.data = { item = {}, itemSrc = {}, quest = {}, questSrc = {}, npc = {}, name = {} }

-- Each Data_*.lua asks this before building its tables, so only one language stays in memory.
function ns.LoadsData(...)
  for i = 1, select("#", ...) do
    if select(i, ...) == ns.locale then return true end
  end
  return false
end

local COLOR = "|cff8ccfff"
ns.COLOR = COLOR

local function StripMarkup(s)
  return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""))
end

function ns.CleanName(s)
  if not s then return nil end
  s = StripMarkup(s)
  s = s:gsub("%s*%(%d+%-?%d*%)$", "")   -- " (10-20)" level range on map labels
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  return s ~= "" and s or nil
end

function ns.Name(s)
  s = ns.CleanName(s)
  return s and ns.data.name[s]
end

function ns.Item(id)
  return id and ns.data.item[id]
end

function ns.Quest(id)
  return id and ns.data.quest[id]
end

function ns.Npc(id)
  return id and ns.data.npc[id]
end

function ns.Delay()
  return BilingueDB.delay
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
  if name ~= addonName then return end
  self:UnregisterEvent("ADDON_LOADED")
  BilingueDB = BilingueDB or {}
  for k, v in pairs(DEFAULTS) do
    if BilingueDB[k] == nil then BilingueDB[k] = v end
  end
  for _, init in ipairs(ns.inits) do init() end
end)

ns.inits = {}
function ns.OnLoad(fn)
  table.insert(ns.inits, fn)
end

function ns.Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(COLOR .. "Bilingüe|r " .. msg)
end
