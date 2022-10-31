local function OnLoad(self, event, addOnName)
    if event == "ADDON_LOADED" and addOnName == "Tobeo_Achievements" then
        local Tobeo_Achievements_Settings = {};
        Tobeo_Achievements_Settings.TobeoSettings = CreateFrame( "Frame", "Tobeo Achievement Tracker", UIParent );
        Tobeo_Achievements_Settings.TobeoSettings.name = "Tobeo Achievement Tracker";
        ignoredCharactersCache = {};

        if(TobeoAchievementsTrackerDB) then
            if(TobeoAchievementsTrackerDB.ignoredCharacters) then
                ignoredCharactersCache = TobeoAchievementsTrackerDB.ignoredCharacters;
            end
        end

        local numberOfCharacters = 0;
        for _ in pairs(TobeoAchievementsTrackerDB) do numberOfCharacters = numberOfCharacters + 1 end

        local title = Tobeo_Achievements_Settings.TobeoSettings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
        title:SetPoint("TOPLEFT", 16, -16);
        title:SetText("Tobeo Achievement Tracker");

        local ignoredCharactersScrollBoxContentTitle = Tobeo_Achievements_Settings.TobeoSettings:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
        ignoredCharactersScrollBoxContentTitle:SetPoint("TOPLEFT", 16, -60);
        ignoredCharactersScrollBoxContentTitle:SetText("Ignored Characters");
        
        local ignoredCharactersScrollBoxContentDescription = Tobeo_Achievements_Settings.TobeoSettings:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        ignoredCharactersScrollBoxContentDescription:SetPoint("TOPLEFT", 16, -80);
        ignoredCharactersScrollBoxContentDescription:SetText("Characters that will be ignored when generating top progress.");

        local ignoredCharactersScrollBox = CreateFrame("ScrollFrame", "IgnoredCharacters", Tobeo_Achievements_Settings.TobeoSettings, "UIPanelScrollFrameTemplate");
        ignoredCharactersScrollBox:SetPoint("TOPLEFT", 16, -100);
        ignoredCharactersScrollBox:SetSize(600, 200);

        local ignoredCharactersScrollBoxContent = CreateFrame("Frame", "IgnoredCharactersContent", ignoredCharactersScrollBox);
        ignoredCharactersScrollBoxContent:SetSize(600, numberOfCharacters * 20);
        ignoredCharactersScrollBox:SetScrollChild(ignoredCharactersScrollBoxContent);

        local offset = 0;
        for key, value in pairs(TobeoAchievementsTrackerDB) do
            if key ~= "ignoredCharacters" then
                local ignoredCharacterName = ignoredCharactersScrollBoxContent:CreateFontString(nil, "ARTWORK", "GameFontNormal");
                ignoredCharacterName:SetPoint("TOPLEFT", 16, offset);
                ignoredCharacterName:SetText(key);
                ignoredCharacterName:SetTextColor(255,255,255,1);
    
    
                local ignoredCharacterCheckbox = CreateFrame("CheckButton", "IgnoredCharacter", ignoredCharactersScrollBoxContent, "ChatConfigCheckButtonTemplate");
                ignoredCharacterCheckbox:SetPoint("TOPRIGHT", -16, offset);
                ignoredCharacterCheckbox:SetSize(20, 20);
                ignoredCharacterCheckbox:SetChecked(ignoredCharactersCache[key]);
    
                ignoredCharacterCheckbox:SetScript("OnClick", function(self)
                    local tick = self:GetChecked();
                    if(tick) then
                        PlaySound(856);
                        ignoredCharactersCache[key] = true
                        TobeoAchievementsTrackerDB.ignoredCharacters = ignoredCharactersCache;
                    else
                        PlaySound(857);
                        ignoredCharactersCache[key] = false
                        TobeoAchievementsTrackerDB.ignoredCharacters = ignoredCharactersCache;
                    end
                end);
                local ignoreCharacterButton = CreateFrame("CheckButton", "IgnoreCharacterButton", ignoredCharactersScrollBoxContent, "UIPanelButtonTemplate");
                offset = offset - 20;
            end
        end
        InterfaceOptions_AddCategory(Tobeo_Achievements_Settings.TobeoSettings);
    end
end

SLASH_TOBEO1 = "/tobeo"
SlashCmdList["TOBEO"] = function(msg)
    InterfaceOptionsFrame_OpenToCategory("Tobeo Achievement Tracker");
end

local TobeoAddonSettings = CreateFrame("Frame")
TobeoAddonSettings:RegisterEvent("ADDON_LOADED")
TobeoAddonSettings:SetScript("OnEvent", OnLoad)


