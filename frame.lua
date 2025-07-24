-- ConsoleQuest frame.lua
local frame = ConsoleQuest.frame

-- frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
-- frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
-- frame.title:SetText("Console Quest Tracker")

frame.resizeButton = CreateFrame("Button", nil, frame)
frame.resizeButton:SetSize(16, 16)
frame.resizeButton:SetPoint("BOTTOMRIGHT")
frame.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
frame.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
frame.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
frame.resizeButton:SetScript("OnMouseDown", function()
    if not frame.isLocked then
        frame:StartSizing("BOTTOMRIGHT")
    end
end)
frame.resizeButton:SetScript("OnMouseUp", function()
    frame:StopMovingOrSizing()
end)
frame.resizeButton:SetShown(ConsoleQuestDB.resizeEnabled)
