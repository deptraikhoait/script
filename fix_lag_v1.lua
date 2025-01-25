local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Tối ưu hóa Lighting
local function optimizeLighting()
    lighting.GlobalShadows = false -- Tắt bóng toàn cầu
    lighting.FogEnd = 100000 -- Loại bỏ sương mù
    lighting.Brightness = 1 -- Giảm độ sáng
    lighting.ClockTime = 14 -- Đặt thời gian để ánh sáng ổn định
end

-- Giảm đồ họa cho từng đối tượng cụ thể
local function optimizeObject(obj)
    if obj:IsA("ParticleEmitter") then
        obj.Rate = 0 -- Tắt hoàn toàn particle
    elseif obj:IsA("Beam") or obj:IsA("Trail") then
        obj.Enabled = false -- Tắt Beam và Trail
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false -- Tắt ánh sáng
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy() -- Xóa decal và texture
    elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") or obj:IsA("Part") then
        obj.Material = Enum.Material.SmoothPlastic -- Giảm chất liệu
        obj.CastShadow = false -- Tắt bóng
        obj.Color = Color3.new(0.5, 0.5, 0.5) -- Màu xám
    end
end

-- Giảm chi tiết địa hình (Terrain)
local function optimizeTerrain()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0 -- Không có sóng
        terrain.WaterWaveSpeed = 0 -- Không có chuyển động
        terrain.WaterTransparency = 1 -- Làm nước trong suốt
        terrain.WaterReflectance = 0 -- Không có phản chiếu
        terrain.WaterColor = Color3.new(0, 0.5, 1) -- Màu xanh dương nhạt
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
    character = newCharacter
    character:WaitForChild("Humanoid") -- Đợi Humanoid xuất hiện
    optimizeWorkspace() -- Tối ưu hóa toàn bộ Workspace
end

-- Lắng nghe sự kiện nhân vật spawn lại
player.CharacterAdded:Connect(onCharacterAdded)

-- Chạy tối ưu hóa khi bắt đầu
optimizeLighting() -- Tối ưu hóa ánh sáng
optimizeTerrain() -- Tối ưu hóa địa hình
optimizeWorkspace() -- Tối ưu hóa toàn bộ Workspace

print("Đã giảm đồ họa xuống mức thấp nhất.")
