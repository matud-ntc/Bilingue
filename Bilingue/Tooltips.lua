local _, ns = ...

-- Only tooltips the player actually sees: other addons scan items with hidden tooltips
-- and an extra line there could confuse them.
local WATCHED = {
  "GameTooltip", "ItemRefTooltip",
  "ShoppingTooltip1", "ShoppingTooltip2", "ItemRefShoppingTooltip1", "ItemRefShoppingTooltip2",
}

local function LineText(tooltip, i)
  local fs = _G[tooltip:GetName() .. "TextLeft" .. i]
  return fs and fs:GetText()
end

local function NpcID(guid)
  if not guid then return nil end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind == "Creature" or kind == "Vehicle" then return tonumber(id) end
end

local function Translate(tooltip, data)
  local T = Enum.TooltipDataType
  local first = LineText(tooltip, 1)

  if data.type == T.Item and data.id then
    local tr = ns.Item(data.id) or ns.Name(first)
    return "i" .. data.id, { tr }
  end

  if data.type == T.Unit then
    local guid = data.guid
    local tr = ns.Npc(NpcID(guid)) or ns.Name(first)
    local lines = { tr }
    -- NPC title ("Weaponsmith", "Flight Master") sits on line 2.
    local title = ns.Name(LineText(tooltip, 2))
    if title then table.insert(lines, title) end
    return "u" .. (guid or first or ""), lines
  end

  if data.type == T.Quest and data.id then
    return "q" .. data.id, { ns.Quest(data.id) }
  end

  -- Spells, talents, auras, objects (herbs, veins, chests), macros of spells...
  local tr = ns.Name(first)
  if tr then return "n" .. first, { tr } end
end

ns.OnLoad(function()
  if not TooltipDataProcessor then return end
  local watched = {}
  for _, name in ipairs(WATCHED) do
    if _G[name] then watched[_G[name]] = true end
  end
  TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
    if not watched[tooltip] or not data then return end
    local key, lines = Translate(tooltip, data)
    ns.Reveal(tooltip, key, lines)
  end)
end)
