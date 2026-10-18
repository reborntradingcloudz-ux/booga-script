-- gamesense | Booga Booga Reborn
-- server-safe movement and packet execution

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Config = {
    Farm = {
        AutoPlant = false, AutoHarvest = false, AutoBlink = false,
        PrioritizeBushes = false, BlinkType = "Tween", Speed = 20.5, MaxDist = 250
    },
    Perf = {
        HideBushes = false, NoCollision = false, HideWood = false,
        RemoveRes = false, FpsCap = 60
    },
    Fight = {
        AutoTrack = false, TrackTarget = nil, TrackDist = 5,
        HitLoop = false, HitRange = 20
    },
    UI = {
        CustomCursor = false, WindowSnap = true
    }
}

-- // Helper
local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- // Loader
local LoaderGui = New("ScreenGui", {Name = "Boot", Parent = CoreGui, ResetOnSpawn = false})
local LoadFrame = New("Frame", {Size = UDim2.new(0, 400, 0, 150), Position = UDim2.new(0.5, -200, 0.5, -75), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = LoaderGui})
New("UICorner", {CornerRadius = UDim.new(0, 6)}, LoadFrame)
New("UIStroke", {Color = Color3.fromRGB(40, 40, 40)}, LoadFrame)
local LoadText = New("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(0, 255, 0), Font = Enum.Font.Code, TextSize = 14, Parent = LoadFrame})

task.spawn(function()
    local msg = "init -> loading gamesense modules..."
    for i = 1, #msg do
        LoadText.Text = string.sub(msg, 1, i) .. " _"
        task.wait(0.03)
    end
    task.wait(0.5)
    LoadFrame:TweenPosition(UDim2.new(0.5, -200, 0.5, 100), "Out", "Quad", 0.4, true)
    task.wait(0.4)
    LoaderGui:Destroy()
    LoadKey()
end)

-- // Key System
function LoadKey()
    local KeyGui = New("ScreenGui", {Name = "Auth", Parent = CoreGui, ResetOnSpawn = false})
    local KFrame = New("Frame", {Size = UDim2.new(0, 300, 0, 160), Position = UDim2.new(0.5, -150, 0.5, -80), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = KeyGui})
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, KFrame)
    New("UIStroke", {Color = Color3.fromRGB(40, 40, 40)}, KFrame)
    New("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "gamesense | auth", TextColor3 = Color3.fromRGB(0, 255, 0), Font = Enum.Font.GothamBold, TextSize = 16, Parent = KFrame})
    
    local Box = New("TextBox", {Size = UDim2.new(0.8, 0, 0, 30), Position = UDim2.new(0.1, 0, 0.4, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 30), PlaceholderText = "Enter key...", Text = "", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Gotham, TextSize = 14, Parent = KFrame})
    New("UICorner", {CornerRadius = UDim.new(0, 4)}, Box)
    
    local Btn = New("TextButton", {Size = UDim2.new(0.8, 0, 0, 30), Position = UDim2.new(0.1, 0, 0.7, 0), BackgroundColor3 = Color3.fromRGB(0, 100, 0), Text = "authenticate", TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 14, Parent = KFrame})
    New("UICorner", {CornerRadius = UDim.new(0, 4)}, Btn)
    
    Btn.MouseButton1Click:Connect(function()
        if Box.Text == "BOOGA2026" then
            KeyGui:Destroy()
            LoadMain()
        else
            Box.Text = "invalid key"
            Box.TextColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1)
            Box.Text = ""
            Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
end

-- // Main UI
function LoadMain()
    local UI = New("ScreenGui", {Name = "Gamesense", Parent = CoreGui, ResetOnSpawn = false})
    local Main = New("Frame", {Size = UDim2.new(0, 580, 0, 400), Position = UDim2.new(0.5, -290, 0.5, -200), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Active = true, Draggable = true, Parent = UI})
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, Main)
    New("UIStroke", {Color = Color3.fromRGB(35, 35, 35)}, Main)
    
    local Side = New("Frame", {Size = UDim2.new(0, 130, 1, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Main})
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, Side)
    New("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "gamesense", TextColor3 = Color3.fromRGB(0, 255, 0), Font = Enum.Font.GothamBold, TextSize = 16, Parent = Side})
    
    local Content = New("Frame", {Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 130, 0, 0), BackgroundTransparency = 1, Parent = Main})
    local Pages, Active = {}, nil

    local function Tab(name)
        local B = New("TextButton", {Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 50 + (#Pages * 32)), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Side})
        local P = New("Frame", {Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Visible = false, Parent = Content})
        Pages[name] = P
        B.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            P.Visible = true
        end)
    end

    local function Tog(parent, text, tbl, key, cb)
        local F = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent})
        New("TextLabel", {Size = UDim2.new(1, -40, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = F})
        local B = New("TextButton", {Size = UDim2.new(0, 28, 0, 14), Position = UDim2.new(1, -28, 0.5, -7), BackgroundColor3 = tbl[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 50, 50), Text = "", Parent = F})
        New("UICorner", {CornerRadius = UDim.new(1, 0)}, B)
        local D = New("Frame", {Size = UDim2.new(0, 10, 0, 10), Position = tbl[key] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = B})
        New("UICorner", {CornerRadius = UDim.new(1, 0)}, D)
        B.MouseButton1Click:Connect(function()
            tbl[key] = not tbl[key]
            B.BackgroundColor3 = tbl[key] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 50, 50)
            D.Position = tbl[key] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            if cb then cb(tbl[key]) end
        end)
    end

    local function Drop(parent, text, opts, tbl, key)
        local F = New("Frame", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = parent})
        New("TextLabel", {Size = UDim2.new(1, -100, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = F})
        local B = New("TextButton", {Size = UDim2.new(0, 90, 0, 20), Position = UDim2.new(1, -90, 0.5, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Text = tbl[key] or "...", TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 12, Parent = F})
        local idx = 1
        B.MouseButton1Click:Connect(function()
            idx = idx + 1; if idx > #opts then idx = 1 end
            tbl[key] = opts[idx]; B.Text = tbl[key]
        end)
    end

    Tab("Farming")
    Tog(Pages["Farming"], "Auto Plant", Config.Farm, "AutoPlant")
    Tog(Pages["Farming"], "Auto Harvest", Config.Farm, "AutoHarvest")
    Tog(Pages["Farming"], "Auto Blink", Config.Farm, "AutoBlink")
    Drop(Pages["Farming"], "Blink Type", {"Tween", "Lerp"}, Config.Farm, "BlinkType")

    Tab("Combat")
    Tog(Pages["Combat"], "Auto Track", Config.Fight, "AutoTrack")
    local pList = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(pList, p.Name) end end
    Drop(Pages["Combat"], "Target", pList, Config.Fight, "TrackTarget")
    Tog(Pages["Combat"], "Hit Loop", Config.Fight, "HitLoop")

    Tab("Performance")
    Tog(Pages["Performance"], "Hide Bushes", Config.Perf, "HideBushes")
    Tog(Pages["Performance"], "Remove Resources", Config.Perf, "RemoveRes")
    Tog(Pages["Performance"], "No Collision", Config.Perf, "NoCollision")

    Tab("UI Settings")
    Tog(Pages["UI Settings"], "Custom Cursor", Config.UI, "CustomCursor")
    Tog(Pages["UI Settings"], "Window Snap", Config.UI, "WindowSnap")

    Pages["Farming"].Visible = true

    -- // Logic Loops
    local lastBlink, lastHit = 0, 0
    local Packets = RS:WaitForChild("Modules"):WaitForChild("Packets")

    RunService.Heartbeat:Connect(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Auto Track
        if Config.Fight.AutoTrack and Config.Fight.TrackTarget then
            local t = Players:FindFirstChild(Config.Fight.TrackTarget)
            if t and t.Character then
                local tr = t.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local goal = tr.Position + ((root.Position - tr.Position).Unit * Config.Fight.TrackDist)
                    root.CFrame = root.CFrame:Lerp(CFrame.new(goal, tr.Position), 0.15)
                end
            end
        end

        -- Auto Blink
        if Config.Farm.AutoBlink and tick() - lastBlink > 0.5 then
            lastBlink = tick()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj:HasTag("Pickup") or obj.Name:find("Tree")) then
                    local d = (root.Position - obj.Position).Magnitude
                    if d <= Config.Farm.MaxDist and d > 5 then
                        local goal = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        if Config.Farm.BlinkType == "Tween" then
                            TweenService:Create(root, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {CFrame = goal}):Play()
                        else
                            root.CFrame = root.CFrame:Lerp(goal, 0.5)
                        end
                        break
                    end
                end
            end
        end

        -- Hit Loop
        if Config.Fight.HitLoop and tick() - lastHit > 0.35 then
            lastHit = tick()
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local tr = p.Character:FindFirstChild("HumanoidRootPart")
                        if tr and (root.Position - tr.Position).Magnitude <= Config.Fight.HitRange then
                            local id = p.Character:GetAttribute("EntityID")
                            if id then
                                pcall(function()
                                    Packets.SwingTool.send({entityIDs = {id}, cframe = root.CFrame, timestamp = workspace:GetServerTimeNow()})
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
end
