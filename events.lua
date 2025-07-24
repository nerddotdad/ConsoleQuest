-- ConsoleQuest events.lua
local frame = ConsoleQuest.frame
local UpdateQuestList = ConsoleQuest_UpdateQuestList or function() end  -- dummy fallback

function ConsoleQuest_ToggleLock()
    frame.isLocked = not frame.isLocked
    frame:EnableMouse(not frame.isLocked)
    frame.resizeButton:SetShown(ConsoleQuestDB.resizeEnabled and not frame.isLocked)
    UpdateQuestList(not frame.isLocked)

    if offMapToggleButton then
        offMapToggleButton:EnableMouse(not frame.isLocked)

        if frame.isLocked then
            -- Force reset ConsolePort focus to the main frame or first quest button
            if ConsolePortHelper.IsAvailable() then
                C_Timer.After(0.05, function()
                    local firstLine = ConsoleQuest.content and ConsoleQuest.content.questLines[1]
                    if firstLine and firstLine.button and firstLine.button:IsShown() then
                        ConsolePortHelper.SetCursorNode(firstLine.button)
                        ConsolePortHelper.ForceKeyboardFocus(frame)
                    else
                        ConsolePortHelper.SetCursorNode(frame)
                        ConsolePortHelper.ForceKeyboardFocus(frame)
                    end
                end)
            end
        end
    end

    if not frame.isLocked and ConsolePortHelper.IsAvailable() then
        C_Timer.After(0.1, function()
            local firstLine = ConsoleQuest.content and ConsoleQuest.content.questLines[1]
            if firstLine and firstLine.button and firstLine.button:IsShown() then
                ConsolePortHelper.SetCursorNode(firstLine.button)
                ConsolePortHelper.ForceKeyboardFocus(frame)
            else
                ConsolePortHelper.SetCursorNode(frame)
                ConsolePortHelper.ForceKeyboardFocus(frame)
            end
        end)
    end
end


function ConsoleQuest_ToggleFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        UpdateQuestList(not frame.isLocked)
    end
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_REMOVED")
frame:RegisterEvent("QUEST_WATCH_UPDATE")

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        frame.isLocked = true
        C_Timer.After(0.5, function()
            ConsoleQuest_HideDefaultTracker()
        end)
        UpdateQuestList(false)
        frame:Show()
    else
        C_Timer.After(0.1, function()
            ConsoleQuest_HideDefaultTracker()
        end)
        UpdateQuestList(not frame.isLocked)
    end
end)

frame:SetScript("OnShow", function()
    if frame.isLocked then
        ConsolePortHelper.ClearFocus()
        UpdateQuestList(false)
        return
    end
    UpdateQuestList(true)
    if ConsolePortHelper.IsAvailable() then
        C_Timer.After(0.1, function()
            local firstLine = ConsoleQuest.content and ConsoleQuest.content.questLines[1]
            if firstLine and firstLine.button and firstLine.button:IsShown() then
                ConsolePortHelper.SetFocus(firstLine.button)
            else
                ConsolePortHelper.SetFocus(frame)
            end
        end)
    end
end)

frame:SetScript("OnHide", function()
    ConsolePortHelper.ClearFocus()
end)
