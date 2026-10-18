-- gamesense | Booga Booga Reborn
print("[olliE] Payload executing...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local function Protect(gui)
    gui.Name = tostring(math.random(100000, 999999))
    if syn and syn.protect_gui then syn.protect_gui(gui) 
    elseif protect_gui then protect_gui(gui) end
end
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local Config = {
    Farm = { AutoPlant = false, AutoHarvest = false, AutoBlink = false, BlinkType = "Tween", MaxDist = 250 },
    Perf = { HideBushes = false, NoCollision = false, RemoveRes = false },
    Fight = { AutoTrack = false, TrackTarget = nil, TrackDist = 5, HitLoop = false, HitRange = 20 }
}

local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- // Loader UI
print("[olliE] Creating Boot UI...")
local LoaderGui = New("ScreenGui", {Name = "Boot", Parent = CoreGui, ResetOnSpawn = false, DisplayOrder = 999})
local LoadFrame = New("Frame", {Size = UDim2.new(0, 400, 0, 150), Position = UDim2.new(0.5, -200, 0.5, -75), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Parent = LoaderGui})
New("UICorner", {CornerRadius = UDim.new(0, 6)}, LoadFrame)
local LoadText = New("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "init...", TextColor3 = Color3.fromRGB(0, 255, 0), Font = Enum.Font.Code, TextSize = 14, Parent = LoadFrame})

-- // Persistence Loop (stops the game from deleting the UI)
task.spawn(function()
    while task.wait(1) do
        if not LoaderGui.Parent then
            print("[olliE] UI was wiped! Re-parenting...")
            LoaderGui.Parent = CoreGui
        end
    end
end)

task.spawn(function()
    local msg = "init -> loading gamesense modules..."
    for i = 1, #msg do
        LoadText.Text = string.sub(msg, 1, i) .. " _"
        task.wait(0.03)
    end
    task.wait(0.5)
    print("[olliE] Boot complete, loading auth...")
    LoaderGui:Destroy()
    LoadKey()
end)

-- // Auth UI
function LoadKey()
    print("[olliE] Creating Auth UI...")
    local KeyGui = New("ScreenGui", {Name = "Auth", Parent = CoreGui, ResetOnSpawn = false, DisplayOrder = 999})
    local KFrame = New("Frame", {Size = UDim2.new(0, 300, 0, 160), Position = UDim2.new(0.5, -150, 0.5, -80), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = KeyGui})
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, KFrame)
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
    print("[olliE] Creating Main UI...")
    local UI = New("ScreenGui", {Name = "Gamesense", Parent = CoreGui, ResetOnSpawn = false, DisplayOrder = 999})
    local Main = New("Frame", {Size = UDim2.new(0, 580, 0, 400), Position = UDim2.new(0.5, -290, 0.5, -200), BackgroundColor3 = Color3.fromRGB(15, 15, 15), Active = true, Draggable = true, Parent = UI})
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, Main)
    New("UIStroke", {Color = Color3.fromRGB(35, 35, 35)}, Main)
    
    local Side = New("Frame", {Size = UDim2.new(0, 130, 1, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Parent = Main})
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, Side)
    New("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "gamesense", TextColor3 = Color3.fromRGB(0, 255, 0), Font = Enum.Font.GothamBold, TextSize = 16, Parent = Side})
    
    local Content = New("Frame", {Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 130, 0, 0), BackgroundTransparency = 1, Parent = Main})
    local Pages = {}

    local function Tab(name)
        local B = New("TextButton", {Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 50 + (#Pages * 32)), BackgroundColor3 = Color3.fromRGB(20, 20, 20), Text = name, TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Side})
        local P = New("Frame", {Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Visible = false, Parent = Content})
        Pages[name] = P
        B.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            P.Visible = true
        end)
    end

    local function Tog(parent, text, tbl, key)
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
        end)
    end

    Tab("Farming")
    Tog(Pages["Farming"], "Auto Plant", Config.Farm, "AutoPlant")
    Tog(Pages["Farming"], "Auto Harvest", Config.Farm, "AutoHarvest")
    Tog(Pages["Farming"], "Auto Blink", Config.Farm, "AutoBlink")

    Tab("Combat")
    Tog(Pages["Combat"], "Auto Track", Config.Fight, "AutoTrack")
    Tog(Pages["Combat"], "Hit Loop", Config.Fight, "HitLoop")

    Tab("Performance")
    Tog(Pages["Performance"], "Hide Bushes", Config.Perf, "HideBushes")
    Tog(Pages["Performance"], "No Collision", Config.Perf, "NoCollision")

    Pages["Farming"].Visible = true
    print("[olliE] Main UI fully loaded.")
    
    -- (Logic loops go here, same as before)
end
