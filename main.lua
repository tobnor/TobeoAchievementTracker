local function OnLoad(self, event, addOnName)
    if event == "ADDON_LOADED" or event == "PLAYER_LEAVING_WORLD" and addOnName == "Tobeo_Achievements" then
        if TobeoAchievementsTrackerDB == nil then
            TobeoAchievementsTrackerDB = {}
        end

        if TobeoAchievementsTrackerDB.ignoredCharacters == nil then
            TobeoAchievementsTrackerDB.ignoredCharacters = {}
        end

        local charName = UnitName("player") .. "-" .. GetRealmName()
        local list = GetCategoryList()
        thisCharDb = {}
        thisCharDb.level = UnitLevel("player")
        thisCharDb.name = charName

        if TobeoAchievementsTrackerDB[charName] == nil then
            TobeoAchievementsTrackerDB[charName] = {}
        end

        if TobeoAchievementsTrackerDB[charName].achievements ~= nil or (TobeoAchievementsTrackerDB[charName].checked ~= nil and TobeoAchievementsTrackerDB[charName].checked <= time() - 86400)  then
            thisCharDb.achievements = TobeoAchievementsTrackerDB[charName].achievements
        else
            local achievements = {}
            for i = 1, #list do
                local categoryId = list[i]
                local numAchievements = GetCategoryNumAchievements(categoryId)
                local category = GetCategoryInfo(categoryId)
                for l = 1, numAchievements do
                    local achievementId, achievementName, _, achievementCompleted = GetAchievementInfo(categoryId, l)
                    if achievementCompleted ~= true then 
                        local numberOfCriterias = GetAchievementNumCriteria(achievementId)
                        local completedCriterias = 0
                        local criterias = {}
                        if numberOfCriterias ~= 0 then 
                            for j = 1, numberOfCriterias do
                                local criteriaString, criteriaType, criteriaCompleted, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementId, j)
                                local criteriaName = criteriaString
                                criterias[criteriaName] = {
                                    completed = criteriaCompleted,
                                    quantity = quantity,
                                    reqQuantity = reqQuantity,
                                    criteriaType = criteriaType
                                }
                                if criteriaCompleted == true then
                                    completedCriterias = completedCriterias + 1
                                end
                            end
                            local thisAchievement = { id=achievementId, achievementName = achievementName, numberOfCriterias=numberOfCriterias, completedCriterias=completedCriterias, criterias=criterias }
                            achievements[achievementId] = thisAchievement
                        end
                    end 
                end
                thisCharDb.achievements = achievements
            end
            thisCharDb.checked = time()
        end


        TobeoAchievementsTrackerDB[charName] = thisCharDb
        TobeoAchievementsTrackerDB.ignoredCharacters = ignoredCharactersCache
    end
end

local function LoadTooltip(self, event, addOnName)
    if event == "ADDON_LOADED" and addOnName == "Tobeo_Achievements" then
        TobeoAchievementTooltipFrame:SetSize(100, 100)
        achievementFrameWidth = AchievementFrame.GetWidth(AchievementFrame)
        TobeoAchievementTooltipFrame:SetPoint("LEFT", "AchievementFrame", "LEFT", achievementFrameWidth, 0) -- or wherever you want the default anchor to be
        TobeoAchievementTooltipFrame:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Background-Dark", edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, edgeSize = 10, tileSize = 10, insets = { left = 1, right = 1, top = 1, bottom = 1, }, })
        TobeoAchievementTooltipFrame.Label = TobeoAchievementTooltipFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
        TobeoAchievementTooltipFrame.Label:SetPoint("TOP", TobeoAchievementTooltipFrame, "TOP", 0, -10)
        TobeoAchievementTooltipFrame.Label:SetText("Top Progress")
        TobeoAchievementTooltipFrame:Hide();
    end
end

local function GenerateTopProgress(achievementId)
    local numberOfCriterias = 0
    local completedCriterias = 0
    local topChars = {}
    for key, value in pairs(TobeoAchievementsTrackerDB) do
        if ignoredCharactersCache[key] ~= true then
            if key ~= "ignoredCharacters" then
                if value.achievements[achievementId] ~= nil then
                    local thisAchievement = value.achievements[achievementId]
                    if numberOfCriterias == 0 then
                        numberOfCriterias = thisAchievement.numberOfCriterias
                    end
                    if thisAchievement.completedCriterias > completedCriterias then
                        completedCriterias = thisAchievement.completedCriterias
                        topChars = {}
                        topChars[key] = thisAchievement
                    end
                    if thisAchievement.completedCriterias == completedCriterias then
                        topChars[key] = thisAchievement
                    end
                end
            end
        end
    end
    return topChars
end

local TobeoAddonFrame = CreateFrame("Frame")
TobeoAddonFrame:RegisterEvent("ADDON_LOADED")
TobeoAddonFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
TobeoAddonFrame:SetScript("OnEvent", OnLoad)

function AchievementTemplateMixin:OnEnter()
	self.Highlight:Show();
    EventRegistry:TriggerEvent("AchievementFrameAchievement.OnEnter", self, self.id);
    if self.completed ~= true then
        local topProgress = GenerateTopProgress(self.id)
        local text = ""
        for key, value in pairs(topProgress) do
            local thisEntry = topProgress[key]
            local entryId = thisEntry.id
            local cleanedName = key.gsub(key, "% ", "")
            local completedCriterias = thisEntry.completedCriterias
            local numberOfCriterias = thisEntry.numberOfCriterias
            if thisEntry.numberOfCriterias == 1 then
                k, v = next(thisEntry.criterias)
                completedCriterias = v.quantity
                numberOfCriterias = v.reqQuantity
                logVCriteria = v
                logKCriteria = k
            end
            text = text .. cleanedName .. ": " .. completedCriterias .. "/" .. numberOfCriterias .. "\n"
        end
        tooltipFontString:SetText(text)
        TobeoAchievementTooltipFrame:SetWidth(tooltipFontString:GetStringWidth() + 40)
        TobeoAchievementTooltipFrame:SetHeight(tooltipFontString:GetStringHeight() + 40)
        TobeoAchievementTooltipFrame:Show();
        if text == "" then
            TobeoAchievementTooltipFrame:Hide();
        end
    end
end

function AchievementTemplateMixin:OnLeave()
	if not self:IsSelected() then
		self.Highlight:Hide();
	end
    EventRegistry:TriggerEvent("AchievementFrameAchievement.OnLeave", self);
    TobeoAchievementTooltipFrame:Hide();
end

TobeoAchievementTooltipFrame = CreateFrame("Frame", "TobeoAchievementTooltipFrame", UIParent, "BackdropTemplate")
TobeoAchievementTooltipFrame:RegisterEvent("ADDON_LOADED")
TobeoAchievementTooltipFrame:SetScript("OnEvent", LoadTooltip)
tooltipFontString = TobeoAchievementTooltipFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
tooltipFontString:SetPoint("TOP", TobeoAchievementTooltipFrame, "TOP", 0, -20)