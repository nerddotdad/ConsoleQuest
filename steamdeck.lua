-- ConsoleQuest steamdeck.lua
ConsoleQuestSteamDeck = {}

-- Ensure DB table exists
ConsoleQuestDB = ConsoleQuestDB or {}
ConsoleQuestDB.steamDeckEnabled = ConsoleQuestDB.steamDeckEnabled or false

function ConsoleQuestSteamDeck:IsEnabled()
    return ConsoleQuestDB.steamDeckEnabled
end

function ConsoleQuestSteamDeck:Toggle()
    ConsoleQuestDB.steamDeckEnabled = not ConsoleQuestDB.steamDeckEnabled
    print("Steam Deck mode " .. (ConsoleQuestDB.steamDeckEnabled and "enabled." or "disabled."))
    self:ApplyMode()
end

function ConsoleQuestSteamDeck:ApplyMode()
    if not ConsoleQuest or not ConsoleQuest.frame then return end

    print("Applying Steam Deck Mode, enabled =", ConsoleQuestDB.steamDeckEnabled)

    if ConsoleQuestDB.steamDeckEnabled then
        ConsoleQuest.frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = false,
            tileSize = 0,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        ConsoleQuest.frame:SetBackdropColor(0, 0, 0, 0.9)
        ConsoleQuest.frame:SetBackdropBorderColor(1, 1, 1, 1)
    else
        ConsoleQuest.frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = nil,
            tile = false,
            tileSize = 0,
            edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        ConsoleQuest.frame:SetBackdropColor(0, 0, 0, 0) -- transparent background
    end
end