Drifter.kHoverHeight = 1

local function ScanForNearbyEnemy(self)
    -- Check for nearby enemy units. Uncloak if we find any.
    self.lastDetectedTime = self.lastDetectedTime or 0
    if self.lastDetectedTime + kDetectInterval < Shared.GetTime() then
        local done = false

        -- Drifters are in the "SmallStructures" physics group, so CloakableMixin's OnCapsuleTraceHit does not trigger since the player movement masks excludes aforementioned group.
        if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), Drifter.kTouchRange) > 0 then
            self:TriggerUncloak()
            done = true
        end

        -- Check shades in range, and stop if a shade is in range and is cloaked.
        if not done then
            local shades = GetEntitiesForTeam("Shade", self:GetTeamNumber())
            for _, shade in ipairs(shades) do
                if shade:GetIsCloaked() and self:GetOrigin():GetDistance(shade:GetOrigin()) <= shade:GetCloakRadius() then
                    done = true
                    break
                end
            end
            -- for _, shade in ipairs(GetEntitiesForTeamWithinRange("Shade", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius)) do
            --     if shade:GetIsCloaked() then
            --         done = true
            --         break
            --     end
            -- end
        end

        -- Finally check if the cysts have players in range.
        if not done then
            if #GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), kDrifterDetectRange) > 0 then
                self:TriggerUncloak()
                done = true
            end
        end

        self.lastDetectedTime = Shared.GetTime()
    end
end

debug.setupvaluex(Drifter.OnUpdate, "ScanForNearbyEnemy", ScanForNearbyEnemy)
