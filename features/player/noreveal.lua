require 'features';

local feature = NewFeature("noreveal", "No reveal");

feature.description = {
    "Disables enemy reveal. (when in stealth)",
    "MaxTac can still reveal you.",
    "Feature suggested by Sunray14"
};

feature.needsEnabling = true;

feature.onInit = function()
    Override("NPCPuppet", "RevealPlayerPositionIfNeeded;ScriptedPuppetEntityIDBool",
    ---@param ownerPuppet ScriptedPuppet
    ---@param playerID EntityID
    ---@param isPrevention boolean
    function(ownerPuppet, playerID, isPrevention, wrappedMethod)
        if not feature.enabled then
            return wrappedMethod(ownerPuppet, playerID, isPrevention);
        end

        return isPrevention or false;
    end);
end;

RegisterFeature("Player", feature);
