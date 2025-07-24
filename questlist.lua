-- ConsoleQuest questlist.lua
local frame = ConsoleQuest.frame
-- ConsoleQuest utilities.lua
local utils = ConsoleQuestUtilities

-- ScrollFrame and content container for quest lines
local scrollFrame = CreateFrame("ScrollFrame", nil, frame)
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local step = 20
    self:SetVerticalScroll(current - (delta * step))
end)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)
content.questLines = {}

ConsoleQuest.content = content  -- expose for event.lua focus management
ConsoleQuest.scrollFrame = scrollFrame  -- expose scrollFrame for event.lua scroll control

-- Hide default Blizzard tracker
function ConsoleQuest_HideDefaultTracker()
    if ObjectiveTrackerFrame then
        ObjectiveTrackerFrame:Hide()
        ObjectiveTrackerFrame:SetAlpha(0)
        ObjectiveTrackerFrame:UnregisterAllEvents()
        ObjectiveTrackerFrame:ClearAllPoints()
        ObjectiveTrackerFrame:SetPoint("TOP", UIParent, "TOP", 0, 2000)
        ObjectiveTrackerFrame.Show = function() end
    end
end

-- Quest icons from Blizzard's QuestFrame for better consistency
local QUEST_ICONS = {
    COMPLETE = "Interface\\QuestFrame\\UI-Quest-Complete",
    INCOMPLETE = "Interface\\QuestFrame\\UI-QuestIncomplete",
    DAILY = "Interface\\QuestFrame\\UI-QuestDaily",
    AVAILABLE = "Interface\\QuestFrame\\UI-QuestAvailable"
}

-- Get icon texture for quest status
local function GetQuestStatusIcon(questInfo)
    if questInfo.isComplete or C_QuestLog.IsComplete(questInfo.questID) then
        return QUEST_ICONS.COMPLETE
    elseif questInfo.isAutoComplete then
        return QUEST_ICONS.INCOMPLETE
    elseif questInfo.isDaily then
        return QUEST_ICONS.DAILY
    else
        return QUEST_ICONS.AVAILABLE
    end
end

-- Get colored quest title based on difficulty level
local function GetColoredQuestTitle(level, title)
    local color = ConsoleQuestDB and ConsoleQuestDB.colors and ConsoleQuestDB.colors.titleColor
    if not color then
        color = GetQuestDifficultyColor(level)
    end

    local hexColor = string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
    return string.format("|cff%s[%d] %s|r", hexColor, level, title)
end


-- Variables for section toggle
local offMapCollapsed = true
local offMapToggleButton = nil

local function CreateSectionHeader(text, yOffset)
    local header = content.sectionHeader
    if not header then
        header = CreateFrame("Button", nil, content)
        content.sectionHeader = header
        header.text = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header.text:SetPoint("LEFT", 5, 0)
        header:SetHeight(24)
        header:SetWidth(270)
        header:SetNormalFontObject("GameFontNormalLarge")
    end

    header:SetPoint("TOPLEFT", 0, yOffset)
    header.text:SetText(text)
    header:Show()

    return header
end

local function ToggleOffMapSection()
    offMapCollapsed = not offMapCollapsed
    if offMapToggleButton then
        offMapToggleButton.text:SetText((offMapCollapsed and "+ " or "- ") .. "Off-map Quests")
    end
    ConsoleQuest_UpdateQuestList(true)
end

local function CreateSimpleHeader(name, yOffset, text)
    local header = content[name]
    if not header then
        header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header:SetWidth(270)
        content[name] = header
    end
    header:SetPoint("TOPLEFT", 0, yOffset)
    header:SetText(text)
    header:Show()
    return header
end

local function IsWorldQuest(questInfo)
    return questInfo.isWorldQuest or C_QuestLog.IsWorldQuest(questInfo.questID)
end

-- Helper: Creates or updates a quest line UI (icon + button/text)
local function UpdateQuestLine(line, questInfo, yOffset, interactive, alphaOverride)
    line.questID = questInfo.questID

    local alpha = alphaOverride or 1

    -- Icon
    if not line.icon then
        line.icon = content:CreateTexture(nil, "ARTWORK")
        line.icon:SetSize(16, 16)
    end
    line.icon:SetPoint("TOPLEFT", 0, yOffset - 2)
    line.icon:SetTexture(GetQuestStatusIcon(questInfo))
    line.icon:SetDesaturated(alpha < 1)
    line.icon:SetAlpha(alpha)
    line.icon:Show()

    local title = questInfo.title or ""
    local level = questInfo.level or 0
    local isComplete = questInfo.isComplete or C_QuestLog.IsComplete(questInfo.questID)
    local questText = string.format("%s %s", GetColoredQuestTitle(level, title), isComplete and "(Done)" or "")

    if interactive then
        if not line.button then
            line.button = CreateFrame("Button", nil, content)
            line.button:SetSize(240, 0)
            line.button:SetNormalFontObject("GameFontHighlight")
            line.button:RegisterForClicks("AnyUp")

            line.button.text = line.button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line.button.text:SetPoint("TOPLEFT", 0, 0)
            line.button.text:SetWidth(240)
            line.button.text:SetJustifyH("LEFT")
            line.button.text:SetWordWrap(true)

            line.button:SetScript("OnClick", function()
                C_QuestLog.SetSelectedQuest(questInfo.questID)
                C_SuperTrack.SetSuperTrackedQuestID(questInfo.questID)
                ConsoleQuest_UpdateQuestList(interactive)
                C_Timer.After(0.05, function()
                    ConsoleQuest.scrollFrame:SetVerticalScroll(0)
                    ConsoleQuest_ToggleLock()
                end)
            end)

            if ConsolePort and ConsolePort.AddFocusable then
                ConsolePort:AddFocusable(frame, line.button)
            end
        end

        line.button:SetPoint("TOPLEFT", line.icon, "TOPRIGHT", 5, 0)
        line.button.text:SetText(questText)
        line.button.text:SetTextColor(1, 1, 1, 1)
        line.button.text:SetAlpha(alpha)
        line.button:SetHeight(line.button.text:GetStringHeight() + 6)
        line.button:EnableMouse(true)
        line.button:Show()

        if line.text then line.text:Hide() end
    else
        if not line.text then
            line.text = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            line.text:SetJustifyH("LEFT")
            line.text:SetWidth(240)
            line.text:SetWordWrap(true)
        end
        line.text:SetPoint("TOPLEFT", line.icon, "TOPRIGHT", 5, 0)
        line.text:SetText(questText)
        line.text:SetTextColor(1, 1, 1, 1)
        line.text:SetAlpha(alpha)
        line.text:Show()

        if line.button then line.button:Hide() end
    end
end

-- Helper: Create or update objectives for a quest line, return new yOffset
local function UpdateObjectives(line, questID, yOffset, interactive)
    local objectives = C_QuestLog.GetQuestObjectives(questID)
    line.objectives = line.objectives or {}

    local baseHeight = 0
    if line.button and line.button.text:IsShown() then
        baseHeight = line.button.text:GetStringHeight()
    elseif line.text and line.text:IsShown() then
        baseHeight = line.text:GetStringHeight()
    end

    local objOffset = yOffset - line.icon:GetHeight() - baseHeight - 5

    for j, obj in ipairs(objectives or {}) do
        local objLine = line.objectives[j]
        if not objLine then
            objLine = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            objLine:SetWordWrap(true)
            objLine:SetWidth(240)
            line.objectives[j] = objLine
        end
        objLine:SetPoint("TOPLEFT", line.icon, "TOPRIGHT", 5, objOffset - yOffset + 15)
        objLine:SetJustifyH("LEFT")
        objLine:SetText("- " .. obj.text)
        objLine:SetTextColor(1, 1, 1, 1)
        objLine:SetAlpha(1)
        objLine:Show()

        objOffset = objOffset - (objLine:GetStringHeight() + 2)
    end

    return objOffset - 5
end

-- Main update function
function ConsoleQuest_UpdateQuestList(interactive)
    -- Hide headers and toggle
    if content.worldQuestHeader then content.worldQuestHeader:Hide() end
    if content.trackedQuestHeader then content.trackedQuestHeader:Hide() end
    if content.onMapHeader then content.onMapHeader:Hide() end
    if offMapToggleButton then offMapToggleButton:Hide() end

    -- Clear quest lines
    for _, line in ipairs(content.questLines) do
        if line.button then line.button:Hide() end
        if line.text then line.text:Hide() end
        if line.icon then line.icon:Hide() end
        if line.objectives then
            for _, obj in ipairs(line.objectives) do obj:Hide() end
        end
    end
    wipe(content.questLines)

    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local yOffset = -10
    local index = 1
    local trackedQuestID = C_SuperTrack.GetSuperTrackedQuestID()
    local playerMap = C_Map.GetBestMapForUnit("player")

    local trackedQuest, worldQuest
    local onMapQuests, offMapQuests = {}, {}

    -- Collect quests by categories
    for i = 1, numEntries do
        local questInfo = C_QuestLog.GetInfo(i)
        if questInfo and not questInfo.isHeader and questInfo.questID then
            if questInfo.questID == trackedQuestID then
                trackedQuest = questInfo
            elseif IsWorldQuest(questInfo) and not worldQuest then
                worldQuest = questInfo
            else
                if questInfo.isOnMap then
                    table.insert(onMapQuests, questInfo)
                else
                    table.insert(offMapQuests, questInfo)
                end
            end
        end
    end

    -- Sort on-map quests by distance
    local function GetQuestDistance(quest)
        if not playerMap then return math.huge end
        local waypoint = C_QuestLog.GetNextWaypointForMap(quest.questID, playerMap)
        if not waypoint then return math.huge end
        local playerPos = C_Map.GetPlayerMapPosition(playerMap, "player")
        if not playerPos then return math.huge end
        local dx = waypoint.position.x - playerPos.x
        local dy = waypoint.position.y - playerPos.y
        return dx*dx + dy*dy
    end
    table.sort(onMapQuests, function(a,b) return GetQuestDistance(a) < GetQuestDistance(b) end)

    -- Render World Quest section
    if worldQuest then
        local header = CreateSimpleHeader("worldQuestHeader", yOffset, "Active World Quest")
        header:SetTextColor(0.4, 0.6, 1)
        yOffset = yOffset - header:GetHeight() - 5

        local line = content.questLines[index] or {}
        content.questLines[index] = line

        UpdateQuestLine(line, worldQuest, yOffset, interactive, 1)
        yOffset = UpdateObjectives(line, worldQuest.questID, yOffset, interactive)
        index = index + 1
    end

    -- Render Tracked Quest section
    if trackedQuest then
        local header = CreateSimpleHeader("trackedQuestHeader", yOffset, "Currently Tracked Quest")
        yOffset = yOffset - header:GetHeight() - 5

        local line = content.questLines[index] or {}
        content.questLines[index] = line

        UpdateQuestLine(line, trackedQuest, yOffset, interactive, 1)
        yOffset = UpdateObjectives(line, trackedQuest.questID, yOffset, interactive)
        index = index + 1
    end

    -- Render On-Map Quests section
    if #onMapQuests > 0 then
        local header = CreateSimpleHeader("onMapHeader", yOffset, "Quests on Current Map")
        yOffset = yOffset - header:GetHeight() - 5

        for _, questInfo in ipairs(onMapQuests) do
            local isTracked = (questInfo.questID == trackedQuestID)
            local alpha = isTracked and 1 or 0.5

            local line = content.questLines[index] or {}
            content.questLines[index] = line

            UpdateQuestLine(line, questInfo, yOffset, interactive, alpha)
            yOffset = UpdateObjectives(line, questInfo.questID, yOffset, interactive)
            index = index + 1
        end
    end

    -- Render Off-Map Quests collapsible section
    if #offMapQuests > 0 then
        -- Create toggle button if missing
        if not offMapToggleButton then
            offMapToggleButton = CreateFrame("Button", nil, content)
            offMapToggleButton:SetSize(270, 24)
            offMapToggleButton.text = offMapToggleButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            offMapToggleButton.text:SetPoint("LEFT", 0, 0)
            offMapToggleButton:SetNormalFontObject("GameFontNormalLarge")
            offMapToggleButton:SetHighlightFontObject("GameFontHighlightLarge")
            offMapToggleButton:SetScript("OnClick", function()
                if frame.isLocked then return end
                ToggleOffMapSection()
            end)
        end

        -- Create text label if missing
        if not offMapToggleText then
            offMapToggleText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            offMapToggleText:SetWidth(270)
            offMapToggleText:SetHeight(24)
            offMapToggleText:SetJustifyH("LEFT")
            offMapToggleText:SetJustifyV("MIDDLE")
            offMapToggleText:SetFontObject("GameFontNormalLarge")
        end

        if frame.isLocked then
            if offMapToggleButton then offMapToggleButton:Hide() end
            offMapToggleText:SetPoint("TOPLEFT", 0, yOffset)
            offMapToggleText:SetText((offMapCollapsed and "v " or "> ") .. "Off-map Quests")
            offMapToggleText:Show()
        else
            if offMapToggleText then offMapToggleText:Hide() end
            offMapToggleButton:SetPoint("TOPLEFT", 0, yOffset)
            offMapToggleButton.text:SetText((offMapCollapsed and "v " or "> ") .. "Off-map Quests")
            offMapToggleButton:Show()
        end


        local anchorPoint, relativeTo, relativePoint, xOffset, yOffsetPos = "TOPLEFT", content, "TOPLEFT", 0, yOffset
        offMapToggleButton:SetPoint(anchorPoint, relativeTo, relativePoint, xOffset, yOffsetPos)
        offMapToggleText:SetPoint(anchorPoint, relativeTo, relativePoint, xOffset, yOffsetPos)

        local toggleHeight = frame.isLocked and (offMapToggleText and offMapToggleText:GetHeight() or 24)
                                            or (offMapToggleButton and offMapToggleButton:GetHeight() or 24)
        yOffset = yOffset - toggleHeight - 5

        if not offMapCollapsed then
            for _, questInfo in ipairs(offMapQuests) do
                local isTracked = (questInfo.questID == trackedQuestID)
                local alpha = isTracked and 1 or 0.5

                local line = content.questLines[index] or {}
                content.questLines[index] = line

                UpdateQuestLine(line, questInfo, yOffset, interactive, alpha)
                yOffset = UpdateObjectives(line, questInfo.questID, yOffset, interactive)
                index = index + 1
            end
        end
    end


    -- Hide unused headers if empty sections
    if not worldQuest and content.worldQuestHeader then content.worldQuestHeader:Hide() end
    if not trackedQuest and content.trackedQuestHeader then content.trackedQuestHeader:Hide() end
    if #onMapQuests == 0 and content.onMapHeader then content.onMapHeader:Hide() end
    if #offMapQuests == 0 and offMapToggleButton then offMapToggleButton:Hide() end

    content:SetHeight(math.abs(yOffset) + 20)
    ConsoleQuest_HideDefaultTracker()
end

-- Make UpdateQuestList globally accessible for events.lua
ConsoleQuest_UpdateQuestList = ConsoleQuest_UpdateQuestList
