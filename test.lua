local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ⚙️ Cấu hình
local TweenSpeed = 300 -- Tốc độ di chuyển
local NoClip = true -- Không va chạm khi di chuyển
local ChangeTargetTime = 5 -- Thời gian đổi mục tiêu nếu không gây sát thương

local LastHitTime = tick() -- Thời điểm cuối cùng gây sát thương
local CurrentTarget = nil -- Lưu player đang tấn công

-- 🟢 NoClip để không bị kẹt
RunService.Stepped:Connect(function()
    if NoClip then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- 🟢 Tìm player gần nhất
local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Distance = (HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            if Distance < ShortestDistance then
                ClosestPlayer = Player
                ShortestDistance = Distance
            end
        end
    end

    return ClosestPlayer
end

-- 🟢 Equip vũ khí
local function EquipWeapon()
    local Tool = LocalPlayer.Backpack:FindFirstChild(Setting["Melee_Use"])
    if Tool then
        Character.Humanoid:EquipTool(Tool)
    end
end

-- 🟢 Kiểm tra xem có gây sát thương không
local function AttackTarget(Target)
    local Humanoid = Target.Character and Target.Character:FindFirstChild("Humanoid")
    if not Humanoid then return end

    local StartHealth = Humanoid.Health -- Lấy máu ban đầu

    EquipWeapon() -- Cầm vũ khí trước khi đánh

    -- Attack bằng Fast Attack
    local FastAttack = _G.FastAttack and _G.FastAttack.FastAttack
    if FastAttack then
        FastAttack:BladeHits() -- Gọi Fast Attack để tấn công
    end

    wait(0.1) -- Chờ kiểm tra sát thương

    if Humanoid.Health < StartHealth then
        LastHitTime = tick() -- **Đã gây sát thương → Reset timer**
        UseSkills() -- **Gây sát thương xong là dùng skill ngay**
        print("🔴 Đã đánh trúng! Dùng skill ngay.")
    else
        print("⚠️ Chưa gây sát thương!")
    end
end

-- 🟢 Hướng về mục tiêu & sử dụng skill
local function UseSkills()
    if not CurrentTarget then return end

    local Skills = { "Z", "X", "C" } -- Skill cần dùng
    for _, Key in pairs(Skills) do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[Key], false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[Key], false, game)
    end
end

-- 🟢 Tween liên tục đến player
local function MoveToTarget(Target)
    if not Target or not Target.Character then return end
    CurrentTarget = Target

    while Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") do
        local TargetRoot = Target.Character.HumanoidRootPart
        local Distance = (TargetRoot.Position - HumanoidRootPart.Position).Magnitude
        local TimeToReach = Distance / TweenSpeed

        local TweenInfo = TweenInfo.new(TimeToReach, Enum.EasingStyle.Linear)
        local Goal = {CFrame = TargetRoot.CFrame}

        local Tween = TweenService:Create(HumanoidRootPart, TweenInfo, Goal)
        Tween:Play()

        wait(0.05) -- Giảm delay để cập nhật nhanh hơn

        -- 🟢 Kiểm tra nếu player mất hoặc chết, dừng lại
        if not Target.Character or Target.Character:FindFirstChild("Humanoid").Health <= 0 then
            return
        end
    end
end

-- 🟢 Main Loop
while wait(0.1) do
    local ClosestPlayer = GetClosestPlayer()

    if ClosestPlayer and ClosestPlayer.Character then
        if tick() - LastHitTime > ChangeTargetTime then
            print("⚠️ Không gây sát thương trong 5 giây! Đổi mục tiêu...")
            CurrentTarget = nil -- Đổi target
        end

        MoveToTarget(ClosestPlayer) -- Di chuyển liên tục
        AttackTarget(ClosestPlayer) -- Attack khi đến gần
    end
end
