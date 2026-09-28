local FRAME_NAME = "ForeverClassicUIQuestLog"
local installed = false

local function WithLevel(row, text)
    local info = row.info
    if not info or info.isHeader or type(text) ~= "string" then return text end
    local level = info.difficultyLevel or info.level
    local title = info.title
    if type(level) ~= "number" or level <= 0 or not title or title == "" then return text end
    -- The log writes "  " .. party count .. title; the level goes just
    -- before the title. If the text is ever shaped differently, leave it.
    local cut = #text - #title
    if cut < 0 or text:sub(cut + 1) ~= title then return text end
    return text:sub(1, cut) .. "[" .. level .. "] " .. title
end

local function Wrap(row)
    local fontString = row.text
    local SetText = fontString.SetText
    fontString.SetText = function(self, text, ...)
        return SetText(self, WithLevel(row, text), ...)
    end
end

local function Install()
    local frame = _G[FRAME_NAME]
    if installed or not frame or not frame.listArea then return end
    for _, row in ipairs({ frame.listArea:GetChildren() }) do
        if row.text and row.check then
            Wrap(row)
            installed = true
        end
    end

    if installed and frame:IsShown() then
        local onEvent = frame:GetScript("OnEvent")
        if onEvent then onEvent(frame, "QUEST_LOG_UPDATE") end
    end
end

hooksecurefunc("CreateFrame", function(_, name)
    if not installed and name == FRAME_NAME then C_Timer.After(0, Install) end
end)

Install()