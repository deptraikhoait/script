local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local player = game.Players.LocalPlayer

-- Tối ưu hóa Lighting
lighting.GlobalShadows = false
lighting.FogEnd = math.huge -- Loại bỏ hoàn toàn sương mù
lighting.FogStart = math.huge -- Đảm bảo sương mù không xuất hiện
lighting.Brightness = 0
lighting.ClockTime = 14
lighting.Technology = Enum.Technology.Compatibility
lighting.EnvironmentDiffuseScale = 0
lighting.EnvironmentSpecularScale = 0

-- Tối ưu địa hình
local function optimizeTerrain()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterTransparency = 1
        terrain.WaterReflectance = 0
    end
end

-- Tối ưu đối tượng
local function optimizeObject(obj)
    if obj:IsA("ParticleEmitter") then
        obj.Rate = 0
    elseif obj:IsA("Beam") or obj:IsA("Trail") then
        obj.Enabled = false
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Color = Color3.new(0.5, 0.5, 0.5)
    end
end

-- Tối ưu nhân vật
local function optimizeCharacter(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Clothing") or obj:IsA("Accessory") or obj:IsA("Decal") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
end

-- Tối ưu Workspace
local function optimizeWorkspace()
    local descendants = workspace:GetDescendants()
    for i, obj in ipairs(descendants) do
        if i % 100 == 0 then
            task.wait() -- Tránh làm game bị đứng khi duyệt qua nhiều đối tượng
        end
        optimizeObject(obj)
    end
end

-- Tắt dịch vụ không cần thiết
local function disableUnnecessaryServices()
    local servicesToDisable = {
        "PathfindingService",
        "CollectionService",
        "PhysicsService",
        "Chat",
    }
    for _, serviceName in ipairs(servicesToDisable) do
        local service = game:GetService(serviceName)
        if service then
            service:SetAttribute("Enabled", false)
        end
    end
end

-- Tích hợp tất cả tối ưu
player.CharacterAdded:Connect(optimizeCharacter)
if player.Character then
    optimizeCharacter(player.Character)
end
optimizeTerrain()
optimizeWorkspace()
disableUnnecessaryServices()

print("Đồ họa đã được giảm xuống mức thấp nhất.")
