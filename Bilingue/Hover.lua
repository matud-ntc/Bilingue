local _, ns = ...

-- Tooltips get rebuilt while you hover (bags and action bars refresh every 0.2s), so we keep
-- "what is shown and since when" per tooltip and append the translation on every rebuild
-- once the delay has passed.
local state = {}

local function HasLine(tooltip, text)
  local name = tooltip:GetName()
  for i = 1, tooltip:NumLines() do
    local fs = _G[name .. "TextLeft" .. i]
    if fs and fs:GetText() == text then return true end
  end
  return false
end

local function AddLines(tooltip, lines)
  local added = false
  for _, line in ipairs(lines) do
    local text = ns.COLOR .. line .. "|r"
    if not HasLine(tooltip, text) then
      tooltip:AddLine(text, nil, nil, nil, true)
      added = true
    end
  end
  return added
end

local function Get(tooltip)
  local s = state[tooltip]
  if not s then
    s = {}
    state[tooltip] = s
    tooltip:HookScript("OnHide", function()
      s.key = nil
      if s.timer then s.timer:Cancel(); s.timer = nil end
    end)
  end
  return s
end

-- key identifies what the tooltip shows; nil means "nothing to translate here".
function ns.Reveal(tooltip, key, lines)
  local s = Get(tooltip)
  if not BilingueDB.enabled or not key or not lines or #lines == 0 then
    s.key = nil
    if s.timer then s.timer:Cancel(); s.timer = nil end
    return
  end

  local delay = ns.Delay()
  if s.key ~= key then
    s.key, s.since = key, GetTime()
    if s.timer then s.timer:Cancel(); s.timer = nil end
    if delay > 0 then
      s.timer = C_Timer.NewTimer(delay, function()
        s.timer = nil
        if tooltip:IsShown() and s.key == key and AddLines(tooltip, lines) then
          tooltip:Show()
        end
      end)
      return
    end
  end

  if GetTime() - s.since >= delay - 0.01 and AddLines(tooltip, lines) then
    tooltip:Show()
  end
end

-- For hovers that don't go through tooltip data (minimap zone, quest log rows):
-- after the delay, append to the owner's tooltip or open one if Blizzard didn't.
function ns.HoverOwner(owner, getLines)
  local timer, ownTooltip
  owner:HookScript("OnEnter", function(self)
    if not BilingueDB.enabled then return end
    if timer then timer:Cancel() end
    timer = C_Timer.NewTimer(math.max(ns.Delay(), 0.05), function()
      timer = nil
      if not self:IsMouseOver() then return end
      local lines = getLines(self)
      if not lines or #lines == 0 then return end
      if GameTooltip:IsOwned(self) and GameTooltip:IsShown() then
        if AddLines(GameTooltip, lines) then GameTooltip:Show() end
      else
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        AddLines(GameTooltip, lines)
        GameTooltip:Show()
        ownTooltip = true
      end
    end)
  end)
  owner:HookScript("OnLeave", function(self)
    if timer then timer:Cancel(); timer = nil end
    if ownTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    ownTooltip = nil
  end)
end
