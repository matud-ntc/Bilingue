local _, ns = ...

local MAX_RESULTS = 12

local FOLD = {
  ["á"] = "a", ["é"] = "e", ["í"] = "i", ["ó"] = "o", ["ú"] = "u", ["ü"] = "u", ["ñ"] = "n",
  ["Á"] = "a", ["É"] = "e", ["Í"] = "i", ["Ó"] = "o", ["Ú"] = "u", ["Ü"] = "u", ["Ñ"] = "n",
}

local function Fold(s)
  return (s:gsub("\195[\128-\191]", FOLD):lower())
end

-- 3 exact, 2 prefix, 1 contains
local function Score(text, query)
  local f = Fold(text)
  if f == query then return 3 end
  local at = f:find(query, 1, true)
  if at == 1 then return 2 end
  return at and 1 or 0
end

local function ItemLink(id, name)
  return "|cffffffff|Hitem:" .. id .. "::::::::::::|h[" .. name .. "]|h|r"
end

local function Search(raw)
  local query = Fold(raw)
  local hits = {}
  local function Consider(own, other, display)
    local s = math.max(Score(own, query), Score(other, query))
    if s > 0 then table.insert(hits, { score = s, len = #own, own = display or own, other = other }) end
  end

  local D = ns.data
  for src, dst in pairs(D.name) do Consider(src, dst) end
  for id, dst in pairs(D.item) do
    local src = D.itemSrc[id]
    if src then Consider(src, dst, ItemLink(id, src)) end
  end
  for id, dst in pairs(D.quest) do
    local src = D.questSrc[id]
    if src then Consider(src, dst) end
  end

  table.sort(hits, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    return a.len < b.len
  end)

  if #hits == 0 then
    ns.Print("no encontré \"" .. raw .. "\" en ningún idioma.")
    return
  end
  local seen, shown = {}, 0
  for _, h in ipairs(hits) do
    local line = h.own .. "  " .. ns.COLOR .. h.other .. "|r"
    if not seen[line] then
      seen[line] = true
      DEFAULT_CHAT_FRAME:AddMessage(line)
      shown = shown + 1
      if shown >= MAX_RESULTS then break end
    end
  end
  if #hits > shown then
    DEFAULT_CHAT_FRAME:AddMessage("|cff808080y " .. (#hits - shown) .. " más; probá con un nombre más completo.|r")
  end
end

SLASH_BILINGUE1 = "/bil"
SLASH_BILINGUE2 = "/trad"
SlashCmdList.BILINGUE = function(msg)
  msg = strtrim(msg or "")
  local cmd, rest = msg:match("^(%S+)%s*(.-)$")
  cmd = cmd and cmd:lower()

  if cmd == "on" or cmd == "off" then
    BilingueDB.enabled = cmd == "on"
    ns.Print(BilingueDB.enabled and "activado." or "desactivado.")
  elseif cmd == "delay" and tonumber(rest) then
    BilingueDB.delay = math.max(0, math.min(5, tonumber(rest)))
    ns.Print(BilingueDB.delay == 0 and "la traducción aparece al instante."
      or ("la traducción aparece después de " .. BilingueDB.delay .. " s."))
  elseif msg ~= "" then
    Search(msg)
  else
    ns.Print("/bil <nombre> lo busca en inglés y en español, por ejemplo /bil flor de paz")
    ns.Print("/bil delay " .. BilingueDB.delay .. " cambia la espera · /bil " .. (BilingueDB.enabled and "off" or "on"))
  end
end
