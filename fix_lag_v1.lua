local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local player = game.Players.LocalPlayer

-- Tối ưu hóa Lighting
local function optimizeLighting()
    lighting.GlobalShadows = false
    lighting.FogEnd = 100000
    lighting.Brightness = 1
    lighting.ClockTime = 14
end

-- Giảm đồ họa cho từng đối tượng cụ thể
local function optimizeObject(obj)
    if obj:IsA("ParticleEmitter") then
        obj.Rate = 0
    elseif obj:IsA("Beam") or obj:IsA("Trail") then
        obj.Enabled = false
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        pcall(function()
            obj:Destroy()
        end)
    elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Part") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    end
end

-- Giảm chi tiết địa hình (Terrain)
local function optimizeTerrain()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterTransparency = 1
        terrain.WaterReflectance = 0
        terrain.WaterColor = Color3.new(0, 0.5, 1)
    end
end

-- Quét toàn bộ Workspace và tối ưu hóa
local function optimizeWorkspace()
    for _, obj in pairs(workspace:GetDescendants()) do
        optimizeObject(obj)
    end
end

-- Thực hiện tối ưu khi nhân vật spawn lại
local function onCharacterAdded(newCharacter)
    newCharacter:WaitForChild("Humanoid")
    optimizeWorkspace()
end

-- Lắng nghe sự kiện nhân vật spawn lại
player.CharacterAdded:Connect(onCharacterAdded)

-- Chạy tối ưu hóa khi bắt đầu
optimizeLighting()
optimizeTerrain()
optimizeWorkspace()

print("Đã giảm đồ họa xuống mức thấp nhất.")
