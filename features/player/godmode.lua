require 'features';

local feature = NewFeature("godmode", "Invulnerability");

feature.description = {
    "Ever wanted to never put attributes in Body? This feature is for you.",
    "Jokes aside - this feature denies all incoming player damage."
};

feature.needsEnabling = true;

feature.onInit = function()
    ObserveBefore("StatPoolsManager", "ApplyDamage;gameHitEventBoolarray<SDamageDealt>",
    ---@param hitEvent gameHitEvent
    function(hitEvent, _)
        if not feature.enabled then return end;

        if hitEvent.target:IsPlayer() then
            hitEvent.attackComputed:SetAttackValues({0});
        end
    end);
end

RegisterFeature("Player", feature);
