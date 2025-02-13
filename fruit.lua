repeat
    wait()
until game:IsLoaded() and (game:GetService("Players").LocalPlayer or game:GetService("Players").PlayerAdded:Wait()) and 
    (game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait())

local l = true
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    while wait(3) do
        if l then
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end
end)

local CoreGui = game:GetService("StarterGui")
CoreGui:SetCore("SendNotification", {
    Title = "Fruit Finder [Free]",
    Text = "By _shinichi. discord.gg/wWX6EAYzrA",
    Icon = "rbxthumb://type=Asset&id=15485121479&w=150&h=150",
    Duration = math.huge,
})

if getgenv().Ran then return else getgenv().Ran = true end

local player = game:GetService("Players").LocalPlayer
if player.PlayerGui:WaitForChild("Main", 9e9):FindFirstChild("ChooseTeam") then
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
    wait(3)
end

local character = player.Character or player.CharacterAdded:Wait()
local tweenService = game:GetService("TweenService")
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVelocity.Velocity = Vector3.new()
bodyVelocity.Name = "bV"

local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
bodyAngularVelocity.AngularVelocity = Vector3.new()
bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyAngularVelocity.Name = "bAV"

for _, fruit in ipairs(workspace:GetChildren()) do
    if fruit.Name:find("Fruit") and (fruit:IsA("Tool") or fruit:IsA("Model")) then
        repeat
            local velClone = bodyVelocity:Clone()
            velClone.Parent = character.HumanoidRootPart
            local angClone = bodyAngularVelocity:Clone()
            angClone.Parent = character.HumanoidRootPart
            
            local moveTween = tweenService:Create(
                character.HumanoidRootPart,
                TweenInfo.new((player:DistanceFromCharacter(fruit.Handle.Position) - 150) / 300, Enum.EasingStyle.Linear),
                {CFrame = fruit.Handle.CFrame + Vector3.new(0, fruit.Handle.Size.Y, 0)}
            )
            moveTween:Play()
            moveTween.Completed:Wait()
            
            character.HumanoidRootPart.CFrame = fruit.Handle.CFrame
            velClone:Destroy()
            angClone:Destroy()
            wait(1)
        until fruit.Parent ~= workspace
        
        wait(1)
        local foundFruit = character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool").Name:find("Fruit") and character:FindFirstChildOfClass("Tool")
        if not foundFruit then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item.Name:find("Fruit") then
                    foundFruit = item
                    break
                end
            end
        end
        
        if foundFruit then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", foundFruit:GetAttribute("OriginalName"), foundFruit)
        end
    end
end

spawn(function()
    pcall(function()
        while wait(0.1) do
            if _G.AutoStoreFruit then
                for _, fruit in pairs(workspace:GetChildren()) do
                    if fruit:IsA("Tool") and string.find(fruit.Name, "Fruit") then
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruit.Name)
                    end
                end
            end
        end
    end)
end)

local jobId = game.JobId
repeat
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    local placeId = game.PlaceId
    local serversUrl = Api..placeId.."/servers/Public?sortOrder=Asc&limit=100"

    local function ListServers(cursor)
        local raw = game:HttpGet(serversUrl .. ((cursor and "&cursor="..cursor) or ""))
        return HttpService:JSONDecode(raw)
    end

    local server, nextPageCursor
    repeat
        local servers = ListServers(nextPageCursor)
        server = servers.data[1]
        nextPageCursor = servers.nextPageCursor
    until server
    
    TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
    wait()
until game.JobId ~= jobId
