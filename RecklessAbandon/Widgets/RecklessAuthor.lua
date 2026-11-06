local E = unpack(select(2, ...)) --Import: Engine

-- A label that shows the author's mains in a tooltip while the mouse is over it.
local Type, Version = "RecklessAuthor", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

-- Exit if a current or newer version is loaded.
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
    return
end

local GameTooltip = GameTooltip

local function Frame_OnEnter(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
    E:FillAuthorTooltip(GameTooltip)
    GameTooltip:Show()
end

local function Frame_OnLeave()
    GameTooltip:Hide()
end

-- Same approach as AceGUI's InteractiveLabel: take over a plain Label and give its frame mouse scripts.
local function Constructor()
    local label = AceGUI:Create("Label")
    label.type = Type

    local frame = label.frame
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)

    return label
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
