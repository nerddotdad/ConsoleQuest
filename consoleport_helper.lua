-- ConsoleQuest consoleport_helper.lua
ConsolePortHelper = {}

-- Cache ConsolePort global
local CP = _G.ConsolePort

function ConsolePortHelper.IsAvailable()
    return CP ~= nil
end

function ConsolePortHelper.SetFocus(frameOrButton)
    if CP and CP.SetFocus then
        CP:SetFocus(frameOrButton)
    end
end

function ConsolePortHelper.ClearFocus()
    if CP and CP.ClearFocus then
        CP:ClearFocus()
    end
end

function ConsolePortHelper.SetCursorNodeIfActive(node)
    if CP and CP.SetCursorNodeIfActive then
        CP:SetCursorNodeIfActive(node)
    end
end

function ConsolePortHelper.SetCursorNode(node)
    if CP and CP.SetCursorNode then
        CP:SetCursorNode(node)
    end
end

function ConsolePortHelper.ForceKeyboardFocus(frame)
    if CP and CP.ForceKeyboardFocus then
        CP:ForceKeyboardFocus(frame)
    end
end

function ConsolePortHelper.IsCursorActive()
    if CP and CP.IsCursorActive then
        return CP:IsCursorActive()
    end
    return false
end
