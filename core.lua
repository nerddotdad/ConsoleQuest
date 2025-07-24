-- ConsoleQuest core.lua
BINDING_HEADER_CONSOLEQUEST = "ConsoleQuest"
BINDING_NAME_TOGGLE_CONSOLEQUEST = "Toggle ConsoleQuest Frame"
BINDING_NAME_TOGGLE_LOCK = "Toggle Quest Frame Lock"

ConsoleQuestDB = ConsoleQuestDB or {}
ConsoleQuestDB.resizeEnabled = ConsoleQuestDB.resizeEnabled or false
ConsoleQuestDB.steamDeckEnabled = ConsoleQuestDB.steamDeckEnabled or false

ConsoleQuest = {}

-- Create main frame
local frame = CreateFrame("Frame", "ConsoleQuestFrame", UIParent, "BackdropTemplate")
frame:SetSize(300, 400)
frame:SetPoint("CENTER")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetResizable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not self.isLocked then self:StartMoving() end
end)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

UIPanelWindows["ConsoleQuestFrame"] = { area = "left", pushable = 1, whileDead = 1 }

ConsoleQuest.frame = frame

C_Timer.After(0.1, function()
    if ConsoleQuestSteamDeck and ConsoleQuestSteamDeck.ApplyMode then
        ConsoleQuestSteamDeck:ApplyMode()
    end
end)