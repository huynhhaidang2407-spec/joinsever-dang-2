--!luau
-- Script join server VIP với error handling và retry mechanism
local Players: Players = game:GetService("Players")
local TeleportService: TeleportService = game:GetService("TeleportService")
local HttpService: HttpService = game:GetService("HttpService")

-- Config với type checking
type ServerHopConfig = {
    TargetPlaceId: number,
    ServerCode: string,
    MaxRetries: number,
    RetryDelay: number
}

local config: ServerHopConfig = {
    TargetPlaceId = 109983668079237, -- Place ID từ link VIP
    ServerCode = "410f15c668ff3d4096bb816294c7385d",
    MaxRetries = 5,
    RetryDelay = 3
}

-- Function để decode server code và lấy jobId
local function getServerJobId(): string?
    local success, result = pcall(function()
        -- Phân tích server code từ link
        local decoded = config.ServerCode
        if decoded and typeof(decoded) == "string" then
            print("🔗 Server code:", decoded)
            return decoded
        end
        return nil
    end)
    
    if success then
        return result
    else
        warn("❌ Failed to decode server code:", result)
        return nil
    end
end

-- Improved join function với teleport options
local function joinVIPServer(player: Player): boolean
    if not player then
        warn("❌ Player is nil")
        return false
    end
    
    local jobId: string? = getServerJobId()
    if not jobId then
        warn("❌ Could not get valid job ID")
        return false
    end
    
    print("🚀 Attempting to join VIP server...")
    print("📍 Place ID:", config.TargetPlaceId)
    print("🎯 Server Code:", jobId)
    
    for attempt = 1, config.MaxRetries do
        print(`🔄 Attempt {attempt}/{config.MaxRetries}...`)
        
        local success, result = pcall(function()
            -- Tạo teleport options với server code
            local teleportOptions = Instance.new("TeleportOptions")
            teleportOptions.ServerInstanceId = jobId
            
            -- Thực hiện teleport
            TeleportService:TeleportAsync(config.TargetPlaceId, {player}, teleportOptions)
        end)
        
        if success then
            print("✅ Successfully initiated teleport to VIP server!")
            return true
        else
            warn(`❌ Teleport attempt {attempt} failed:`, result)
            
            -- Nếu không phải lần thử cuối, chờ rồi thử lại
            if attempt < config.MaxRetries then
                print(`⏳ Waiting {config.RetryDelay} seconds before retry...`)
                task.wait(config.RetryDelay)
            end
        end
    end
    
    warn("❌ All teleport attempts failed")
    return false
end

-- Function hiển thị thông báo
local function showNotification(message: string, duration: number?)
    local notificationService = game:GetService("NotificationService")
    local success, result = pcall(function()
        notificationService:ShowNotification(
            "VIP Server Joiner",
            message,
            "rbxassetid://6026568195", -- Icon thông báo
            duration or 5
        )
    end)
    
    if not success then
        -- Fallback: in ra console
        print("📢 " .. message)
    end
end

-- Main execution với safety checks
local function main()
    local player: Player? = Players.LocalPlayer
    if not player then
        warn("❌ LocalPlayer not found")
        return false
    end
    
    -- Chờ character load nếu cần
    if not player.Character then
        print("⏳ Waiting for character to load...")
        player.CharacterAdded:Wait()
        task.wait(2) -- Thêm delay để đảm bảo character ready
    end
    
    showNotification("Đang kết nối đến server VIP...", 3)
    
    local joinSuccess = joinVIPServer(player)
    
    if joinSuccess then
        showNotification("✅ Đang vào server VIP...", 5)
    else
        showNotification("❌ Không thể vào server VIP. Vui lòng thử lại!", 5)
        
        -- Alternative method: Thử join qua link trực tiếp
        local alternativeSuccess = pcall(function()
            TeleportService:Teleport(config.TargetPlaceId, player)
        end)
        
        if alternativeSuccess then
            showNotification("🔄 Đang thử phương pháp thay thế...", 3)
        end
    end
    
    return joinSuccess
end

-- Execute script với error handling
local success, result = pcall(main)

if not success then
    warn("❌ Script execution failed:", result)
    showNotification("Lỗi khi thực thi script join server", 5)
end

return success
