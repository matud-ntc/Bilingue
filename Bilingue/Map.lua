local _, ns = ...

-- The world map draws the hovered zone/POI name in AreaLabelFrame (Name + Description).
-- We don't touch Blizzard's label: we read it and draw our own line below it.

local function FindLabel(map)
  for provider in pairs(map.dataProviders or {}) do
    local label = provider.Label
    if label and label.Name and label.Description and label.SetLabel then return label end
  end
end

local function Attach(map)
  local label, fs, holder
  local current, since = nil, 0
  local elapsed = 0

  local ticker = CreateFrame("Frame", nil, map)
  ticker:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 0.05 then return end
    elapsed = 0

    if not label then
      label = FindLabel(map)
      if not label then return end
      holder = CreateFrame("Frame", nil, label)
      holder:SetAllPoints(label)
      fs = holder:CreateFontString(nil, "OVERLAY")
      fs:SetFontObject(label.Description:GetFontObject() or GameFontNormal)
      fs:SetPoint("TOP", label.Description, "BOTTOM", 0, -4)
      fs:SetTextColor(0.55, 0.81, 1)
    end

    local name = BilingueDB.enabled and label:IsVisible() and ns.CleanName(label.Name:GetText())
    if name ~= current then
      current, since = name, GetTime()
      fs:Hide()
      return
    end
    if not name or fs:IsShown() then return end
    if GetTime() - since >= ns.Delay() then
      local tr = ns.data.name[name]
      if tr then
        fs:SetText(tr)
        fs:Show()
      end
    end
  end)
end

ns.OnLoad(function()
  if WorldMapFrame then Attach(WorldMapFrame) end
  -- The zone map (Shift+M) is load-on-demand.
  if BattlefieldMapFrame then
    Attach(BattlefieldMapFrame)
  else
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, _, name)
      if name == "Blizzard_BattlefieldMap" and BattlefieldMapFrame then
        Attach(BattlefieldMapFrame)
        self:UnregisterEvent("ADDON_LOADED")
      end
    end)
  end
end)
