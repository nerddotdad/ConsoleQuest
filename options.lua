-- ConsoleQuest options.lua
local optionsPanel = CreateFrame("Frame", "ConsoleQuestOptionsPanel", UIParent)
optionsPanel.name = "ConsoleQuest"

function optionsPanel.okay()
    print("ConsoleQuest settings saved.")
end

function optionsPanel.cancel()
    print("ConsoleQuest settings canceled.")
end

function optionsPanel.default()
    print("ConsoleQuest settings reset to default.")
end

local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("ConsoleQuest Settings")

local resetButton = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
resetButton:SetSize(160, 24)
resetButton:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
resetButton:SetText("Reset Quest Frame")
resetButton:SetScript("OnClick", function()
    if _G["ConsoleQuestFrame"] then
        ConsoleQuestFrame:ClearAllPoints()
        ConsoleQuestFrame:SetPoint("CENTER")
        print("ConsoleQuest frame position has been reset.")
    end
end)

local resizeCheckbox = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
resizeCheckbox:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", 0, -10)
resizeCheckbox.Text:SetText("Enable Resize Mode")

local subText = resizeCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subText:SetPoint("TOPLEFT", resizeCheckbox.Text, "BOTTOMLEFT", 0, -2)
subText:SetText("Enable or Disable the resize handle when unlocking the quest tracker.")
subText:SetWidth(250)
subText:SetJustifyH("LEFT")

resizeCheckbox:SetChecked(ConsoleQuestDB.resizeEnabled)
resizeCheckbox:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    ConsoleQuestDB.resizeEnabled = checked
    ConsoleQuestFrame.resizeButton:SetShown(checked and not ConsoleQuestFrame.isLocked)
    print("ConsoleQuest resize mode " .. (checked and "enabled." or "disabled."))
end)

if Settings and Settings.RegisterAddOnCategory then
    local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "ConsoleQuest")
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(optionsPanel)
end

local steamDeckCheckbox = CreateFrame("CheckButton", nil, optionsPanel, "InterfaceOptionsCheckButtonTemplate")
steamDeckCheckbox:SetPoint("TOPLEFT", resizeCheckbox, "BOTTOMLEFT", 0, -20)
steamDeckCheckbox.Text:SetText("Enable Steam Deck Layout")

local steamSubText = steamDeckCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
steamSubText:SetPoint("TOPLEFT", steamDeckCheckbox.Text, "BOTTOMLEFT", 0, -2)
steamSubText:SetText("Applies a larger, controller-friendly layout.")
steamSubText:SetWidth(250)
steamSubText:SetJustifyH("LEFT")

steamDeckCheckbox:SetChecked(ConsoleQuestDB.steamDeckEnabled)
steamDeckCheckbox:SetScript("OnClick", function(self)
    local enabled = self:GetChecked()
    ConsoleQuestDB.steamDeckEnabled = enabled
    if ConsoleQuestSteamDeck and ConsoleQuestSteamDeck.ApplyMode then
        ConsoleQuestSteamDeck:ApplyMode()
    end
end)

function optionsPanel.default()
    ConsoleQuestDB.resizeEnabled = false
    ConsoleQuestDB.steamDeckEnabled = false

    optionsPanel.refresh()

    if ConsoleQuestSteamDeck and ConsoleQuestSteamDeck.ApplyMode then
        ConsoleQuestSteamDeck:ApplyMode()
    end

    if ConsoleQuestFrame and ConsoleQuestFrame.resizeButton then
        ConsoleQuestFrame.resizeButton:SetShown(false)
    end

    print("ConsoleQuest settings reset to default.")
end

function optionsPanel.refresh()
    resizeCheckbox:SetChecked(ConsoleQuestDB.resizeEnabled)
    steamDeckCheckbox:SetChecked(ConsoleQuestDB.steamDeckEnabled)
end

optionsPanel:SetScript("OnShow", function()
    resizeCheckbox:SetChecked(ConsoleQuestDB.resizeEnabled)
    steamDeckCheckbox:SetChecked(ConsoleQuestDB.steamDeckEnabled)
end)

InterfaceOptions_AddCategory(optionsPanel)