--!luau
-- Type annotations at top
local Players: Players = game:GetService("Players")
local TeleportService: TeleportService = game:GetService("TeleportService")

-- Config với type checking
type ServerHopConfig = {
    TargetPlaceId: number,
    MaxPlayers: number?,
    Priority: string?
}

local config: ServerHopConfig = {
    TargetPlaceId = 123456789, -- Thay bằng place ID thực
    MaxPlayers = 10
}

-- Main function với type annotations
local function joinServer(player: Player): boolean
    if not player then
        return false
    end
    
    local success, result = pcall(function()
        TeleportService:Teleport(config.TargetPlaceId, player)
    end)
    
    return success
end

-- Safe execution
local player = Players.LocalPlayer
if player then
    joinServer(player)
end

return true
