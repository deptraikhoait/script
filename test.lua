-- Kiểm tra nếu _G.Setting chưa có, thì dùng config mặc định
if not _G.Setting then
    _G.Setting = {
        ["Misc"] = {
            ["Lock Camera"] = true
        },
        ["Item"] = {
            ["Melee"] = {["Enable"] = true,
                ["Z"] = {["Enable"] = true, ["Hold Time"] = 1.5},
                ["X"] = {["Enable"] = true, ["Hold Time"] = 0.1},
                ["C"] = {["Enable"] = true, ["Hold Time"] = 0.1}
            }
        }
    }
end

--// Import CameraShaker
local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()
local lp = game:GetService("Players").LocalPlayer

--// Khóa Camera vào mục tiêu (nếu bật)
spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if _G.Setting.Misc["Lock Camera"] and enemy then
            local targetCharacter = enemy.Character
            if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
                game.Workspace.CurrentCamera.CFrame = CFrame.new(
                    game.Workspace.CurrentCamera.CFrame.Position, 
                    targetCharacter.HumanoidRootPart.Position
                )
            end
        end
    end)
end)

--// Hệ thống FastAttack
_G.FastAttack = true

if _G.FastAttack then
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")

    if Net then
        local RegisterAttack = Net:FindFirstChild("RE/RegisterAttack")
        local RegisterHit = Net:FindFirstChild("RE/RegisterHit")

        if RegisterAttack and RegisterHit and RegisterAttack:IsA("RemoteEvent") and RegisterHit:IsA("RemoteEvent") then
            local Player = game:GetService("Players").LocalPlayer

            local Settings = {
                AutoClick = true,
                ClickDelay = 0,
            }

            local Module = {}

            Module.FastAttack = (function()
                if _G.rz_FastAttack then
                    return _G.rz_FastAttack
                end

                local FastAttack = {
                    Distance = 100,
                    attackMobs = true,
                    attackPlayers = true,
                    Equipped = nil
                }

                local function IsAlive(character)
                    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
                end

                local function ProcessEnemies(OthersEnemies, Folder)
                    if Folder then
                        for _, Enemy in Folder:GetChildren() do
                            local Head = Enemy:FindFirstChild("Head")
                            if Head and IsAlive(Enemy) and Player:DistanceFromCharacter(Head.Position) < FastAttack.Distance then
                                if Enemy ~= Player.Character then
                                    table.insert(OthersEnemies, { Enemy, Head })
                                end
                            end
                        end
                    end
                end

                function FastAttack:Attack(BasePart, OthersEnemies)
                    if BasePart and #OthersEnemies > 0 then
                        RegisterAttack:FireServer(Settings.ClickDelay or 0)
                        RegisterHit:FireServer(BasePart, OthersEnemies)
                    end
                end

                function FastAttack:AttackNearest()
                    local OthersEnemies = {}
                    local Enemies = game:GetService("Workspace"):FindFirstChild("Enemies")
                    local Characters = game:GetService("Workspace"):FindFirstChild("Characters")

                    ProcessEnemies(OthersEnemies, Enemies)
                    ProcessEnemies(OthersEnemies, Characters)

                    if #OthersEnemies > 0 then
                        self:Attack(OthersEnemies[1][2], OthersEnemies)
                    end
                end

                function FastAttack:BladeHits()
                    local Equipped = IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool")
                    if Equipped and Equipped.ToolTip ~= "Gun" then
                        self:AttackNearest()
                    end
                end

                task.spawn(function()
                    while task.wait(Settings.ClickDelay) do
                        if Settings.AutoClick then
                            FastAttack:BladeHits()
                        end
                    end
                end)

                _G.rz_FastAttack = FastAttack
                return FastAttack
            end)()
        end
    end
end

--// Dùng skill (Z, X, C, V, F)
function UseSkill(skill, cooldown)
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, lp)
        task.wait(cooldown)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, lp)
    end)
end

--// Kiểm tra skill nào có thể dùng
function GetAvailableSkills()
    local SkillsGui = lp.PlayerGui.Main.Skills
    for _, v in pairs(lp.Character:GetChildren()) do 
        if v:IsA("Tool") and _G.Setting.Item[v.ToolTip] and _G.Setting.Item[v.ToolTip].Enable then
            for skill, setting in pairs(_G.Setting.Item[v.ToolTip]) do
                if skill ~= "Enable" and setting.Enable then
                    if SkillsGui:FindFirstChild(v.Name) and SkillsGui[v.Name]:FindFirstChild(skill) then
                        local SkillData = SkillsGui[v.Name][skill]
                        if SkillData.Cooldown.AbsoluteSize.X <= 0 then
                            return {skill, setting["Hold Time"]}
                        end
                    end
                end
            end
        end
    end
    return nil
end

--// Hệ thống dùng skill tự động
spawn(function()
    while wait(0.1) do
        local SkillData = GetAvailableSkills()
        if SkillData then
            UseSkill(SkillData[1], SkillData[2])
        end
    end
end)
