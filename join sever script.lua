local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PLACE_ID = 109983668079237
local ACCESS_CODE = "410f15c668ff3d4096bb816294c7385d"
local REMOTE_NAME = "RequestJoinPrivateServer"

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME) or (function()
    local r = Instance.new("RemoteEvent")
    r.Name = REMOTE_NAME
    r.Parent = ReplicatedStorage
    return r
end)()

local function canRequestTeleport(player) return true end

remote.OnServerEvent:Connect(function(player)
    if not canRequestTeleport(player) then return end
    local ok, err = pcall(function()
        TeleportService:TeleportToPrivateServer(PLACE_ID, ACCESS_CODE, {player})
    end)
    if not ok then warn("Teleport failed for", player.Name, err) end
end)