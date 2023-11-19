local E, L = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

local Type, Version = "ExclusionTable", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

-- Exit if a current or newer version is loaded.
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
    return
end

local max, floor, pairs = math.max, math.floor, pairs
local CreateFrame, UIParent = CreateFrame, UIParent

-- Frame:OnEnter()
local function Frame_OnEnter(self)
    self.obj:Fire("OnEnter")
end

-- Frame:OnLeave()
local function Frame_OnLeave(self)
    self.obj:Fire("OnLeave")
end

local NUM_COLUMNS = 3
local CELL_WIDTH = 100
local CELL_HEIGHT = 20
local data = {}

local function UpdateData(tbl)
    wipe(data)
    data = tbl
end

local function CreateRow(parent, i)
    local row = CreateFrame("Frame", "RecklessAbandon_ExclusionListRow" .. i, parent)
    row.columns = {} -- creating columns for the row

    for j = 1, 3 do
        row.columns[j] = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        row.columns[j]:SetPoint("LEFT", (j - 1) * CELL_WIDTH, 0)
    end

    return row
end

local Methods = {
    OnAcquire = function(self)
        self.resizing = true

        self:SetDisabled(true)
        self:SetLabel()
        self:SetText()
        self:SetFullWidth(true)

        self.resizing = nil
    end,
    OnWidthSet = function(self)
    end,
    SetDisabled = function(self, Disabled)
        self.disabled = Disabled
        local frame = self.frame

        if Disabled then
            frame:SetScript("OnEnter", nil)
            frame:SetScript("OnLeave", nil)
        else
            frame:SetScript("OnEnter", Frame_OnEnter)
            frame:SetScript("OnLeave", Frame_OnLeave)
        end
    end,
    UpdateList = function(self)
        local content = self.content

        for i = 1, #data do
            -- Create a row if not created yet (buttons[i] is a whole row; buttons[i].columns[j] are columns)
            if not content.rows[i] then
                content.rows[i] = CreateRow(content, i)
                content.rows[i]:SetSize(CELL_WIDTH * NUM_COLUMNS, CELL_HEIGHT)
                content.rows[i]:SetPoint("TOPLEFT", 0, -(i - 1) * CELL_HEIGHT)
            end

            -- Style a header row (always the first index)
            if i == 1 then
                content.rows[i].bottom = content.rows[i]:CreateTexture(nil, "BORDER")
                content.rows[i].bottom:SetPoint("BOTTOMLEFT", content.rows[i], "BOTTOMLEFT", -1, -1)
                content.rows[i].bottom:SetPoint("TOPRIGHT", content.rows[i], "BOTTOMRIGHT", 1, -2)
                content.rows[i].bottom:SetColorTexture(1, 1, 1, 1)
            end

            -- Update the contents of the row
            for j = 1, 3 do
                local header = i == 1
                local orphaned = data[i][4]
                local format = header and "|cFFF2E699%s|r" or orphaned and "|cFFFF6B6B%s|r" or "|cFFFFFFFF%s|r"

                content.rows[i].columns[j]:SetFormattedText(format, data[i][j])
            end

            -- Show the row that has data
            content.rows[i]:Show()
        end

        -- Hide all extra rows (if list shrunk, hiding leftover)
        for i = #data + 1, #content.rows do
            content.rows[i]:Hide()
        end
    end,
    SetLabel = function(self, Text)
    end,
    GetText = function(self)
    end,
    SetText = function(self, Text)
        if Text ~= nil then
            local tbl = E:StringToTable(Text)
            UpdateData(tbl)
            self:UpdateList()
        end
    end,
    SetFontObject = function(self, fontObject)
    end
}

local function Constructor()
    -- Container Frame
    local Frame = CreateFrame("Frame", "RecklessAbandon_ExclusionListFrame", UIParent)
    Frame:SetSize(CELL_WIDTH * NUM_COLUMNS + 40, 300)
    Frame:SetPoint("CENTER")

    Frame.scrollFrame = CreateFrame("ScrollFrame", "RecklessAbandon_ExclusionListScrollFrame", Frame, "UIPanelScrollFrameTemplate")
    Frame.scrollFrame:SetPoint("TOPLEFT", 12, -8)
    Frame.scrollFrame:SetPoint("BOTTOMRIGHT", -34, 8)

    Frame.scrollFrame.scrollChild = CreateFrame("Frame", "RecklessAbandon_ExclusionListScrollChildFrame", Frame.scrollFrame)
    Frame.scrollFrame.scrollChild:SetSize(100, 100)
    Frame.scrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
    Frame.scrollFrame:SetScrollChild(Frame.scrollFrame.scrollChild)

    local content = Frame.scrollFrame.scrollChild
    content.rows = {}

    local Widget = {
        type = Type,
        frame = Frame,
        content = content
    }

    for method, func in pairs(Methods) do
        Widget[method] = func
    end

    Frame.obj = Widget

    return AceGUI:RegisterAsWidget(Widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
