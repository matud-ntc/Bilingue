local _, ns = ...

local function Collect(...)
  local lines, seen = {}, {}
  for i = 1, select("#", ...) do
    local tr = select(i, ...)
    if tr and not seen[tr] then
      seen[tr] = true
      table.insert(lines, tr)
    end
  end
  return lines
end

local function HookMinimap()
  local button = (MinimapCluster and MinimapCluster.ZoneTextButton) or MinimapZoneTextButton
  if not button then return end
  ns.HoverOwner(button, function()
    return Collect(ns.Name(GetZoneText()), ns.Name(GetSubZoneText()))
  end)
end

local function HookQuestLog()
  if not QuestLogListScrollFrame then return end
  for i = 1, QUESTS_DISPLAYED or 0 do
    local row = _G["QuestLogTitle" .. i]
    if row then
      ns.HoverOwner(row, function(self)
        local index = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
        local title, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(index)
        if isHeader then return Collect(ns.Name(title)) end
        return Collect(ns.Quest(questID))
      end)
    end
  end
end

ns.OnLoad(function()
  HookMinimap()
  HookQuestLog()
end)
