local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local player = game.Players.LocalPlayer

-- Tối ưu hóa Lighting
lighting.GlobalShadows = false -- Tắt bóng toàn cục
lighting.FogEnd = 50 -- Giảm khoảng cách render
lighting.Brightness = 0 -- Giảm độ sáng
lighting.ClockTime = 14 -- Đặt thời gian để ánh sáng ổn định
lighting.Technology = Enum.Technology.Compatibility -- Chọn chế độ ánh sáng đơn giản hơn
lighting.EnvironmentDiffuseScale = 0 -- Giảm tán xạ ánh sáng
lighting.EnvironmentSpecularScale = 0 -- Tắt độ bóng ánh sáng

-- Tối ưu địa hình (Terrain)
local function optimizeTerrain()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        terrain.WaterWaveSize = 0 -- Tắt sóng nước
        terrain.WaterWaveSpeed = 0 -- Tắt chuyển động nước
        terrain.WaterTransparency = 1 -- Làm nước trong suốt
        terrain.WaterReflectance = 0 -- Tắt phản chiếu nước
    end
end

-- Tối ưu đối tượng cụ thể
local function optimizeObject(obj)
    if obj:IsA("ParticleEmitter") then
        obj.Rate = 0 -- Tắt hoàn toàn particle
    elseif obj:IsA("Beam") or obj:IsA("Trail") then
        obj.Enabled = false -- Tắt Beam và Trail
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Enabled = false -- Tắt ánh sáng
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy() -- Xóa decal và texture
    elseif obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
        obj.Material = Enum.Material.SmoothPlastic -- Giảm chất liệu
        obj.Color = Color3.new(0.5, 0.5, 0.5) -- Màu xám
    end
end

-- Tối ưu Workspace
local function optimizeWorkspace()
    local descendants = workspace:GetDescendants()
    for i, obj in ipairs(descendants) do
        if i % 100 == 0 then
            task.wait() -- Chờ một frame sau mỗi 100 đối tượng để giảm lag
        end
        optimizeObject(obj)
    end
end

-- Tối ưu nhân vật (Character)
local function optimizeCharacter(character)
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Clothing") or obj:IsA("Accessory") or obj:IsA("Decal") then
            obj:Destroy() -- Loại bỏ quần áo, phụ kiện và decal
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false -- Tắt hiệu ứng particle và trail
        end
    end
end

-- Lắng nghe sự kiện nhân vật spawn lại
player.CharacterAdded:Connect(optimizeCharacter)
if player.Character then
    optimizeCharacter(player.Character)
end

-- Chạy tối ưu hóa khi bắt đầu
optimizeTerrain() -- Tối ưu hóa địa hình
optimizeWorkspace() -- Tối ưu hóa toàn bộ Workspace

print("Đồ họa đã được giảm xuống mức thấp nhất.")
