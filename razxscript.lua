loadstring([[
local scriptIdentifier = "razxHub_v11_FinalFix" 
local player = game.Players.LocalPlayer

-- PAKSA BERSIHKAN LAMA AGAR BISA RE-EXECUTE
local oldGui = player.PlayerGui:FindFirstChild("razxHub")
if oldGui then 
    oldGui:Destroy() 
end
if _G[scriptIdentifier] then
    _G[scriptIdentifier]:Disconnect()
    _G[scriptIdentifier] = nil
end

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local mouse = player:GetMouse()
local character, humanoid, root
local flying = false
local minimized = false
local bodyVelocity, bodyGyro

-- ESP Variables
local ESP_Storage = {}

-- Fungsi Anti-Reset
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    if humanoid == nil or humanoid.Parent ~= char then
        humanoid = char:WaitForChild("Humanoid")
        root = char:WaitForChild("HumanoidRootPart")
    end
    return char
end

character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
root = character:WaitForChild("HumanoidRootPart")

-- UI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "razxHub"

-- Main Frame (Diperlebar untuk 2 kolom)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 320, 0, 350) -- Lebar 320, Tinggi 350
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -175) -- Posisi Tengah
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 

-- Judul
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "razxHub v2"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.ZIndex = 2

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 3
closeBtn.AutoButtonColor = false
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    _G[scriptIdentifier]:Disconnect()
    _G[scriptIdentifier] = nil
    screenGui:Destroy()
end)

-- Tombol Minimize (-)
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -70, 0, 5)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.TextSize = 25
minBtn.Font = Enum.Font.GothamBold
minBtn.ZIndex = 3
minBtn.AutoButtonColor = false
minBtn.Parent = mainFrame

-- Logo R (Visual)
local rLogoFrame = Instance.new("TextButton", mainFrame)
rLogoFrame.Size = UDim2.new(1, 0, 1, 0)
rLogoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rLogoFrame.Visible = false
rLogoFrame.ZIndex = 1
rLogoFrame.BorderSizePixel = 0
rLogoFrame.Text = ""
rLogoFrame.AutoButtonColor = false
rLogoFrame.Active = false 
rLogoFrame.Parent = mainFrame

local rLogoLabel = Instance.new("TextLabel", rLogoFrame)
rLogoLabel.Size = UDim2.new(1, 0, 1, 0)
rLogoLabel.Text = "R"
rLogoLabel.TextColor3 = Color3.new(1, 1, 1)
rLogoLabel.TextSize = 30
rLogoLabel.Font = Enum.Font.GothamBold
rLogoLabel.BackgroundTransparency = 1
rLogoLabel.ZIndex = 2
rLogoLabel.TextXAlignment = Enum.TextXAlignment.Center
rLogoLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Konten
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2

-- BAGI 2 KOLOM
local leftColumn = Instance.new("Frame", contentFrame)
leftColumn.Size = UDim2.new(0.5, 0, 1, 0)
leftColumn.Position = UDim2.new(0, 0, 0, 0)
leftColumn.BackgroundTransparency = 1
leftColumn.Name = "LeftCol"

local rightColumn = Instance.new("Frame", contentFrame)
rightColumn.Size = UDim2.new(0.5, 0, 1, 0)
rightColumn.Position = UDim2.new(0.5, 0, 0, 0)
rightColumn.BackgroundTransparency = 1
rightColumn.Name = "RightCol"

-- Fungsi Atur Minimize/Restore
local function setMinimize(isMinimized)
    minimized = isMinimized
    if minimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        title.Visible = false
        closeBtn.Visible = false
        minBtn.Visible = false
        contentFrame.Visible = false
        rLogoFrame.Visible = true
        rLogoLabel.Visible = true
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 320, 0, 350)}):Play()
        title.Visible = true
        closeBtn.Visible = true
        minBtn.Visible = true
        contentFrame.Visible = true
        rLogoFrame.Visible = false
        rLogoLabel.Visible = false
    end
end

minBtn.MouseButton1Click:Connect(function() setMinimize(true) end)
rLogoFrame.MouseButton1Click:Connect(function() setMinimize(false) end)

-- Function Create Toggle
local function createToggle(name, yPos, parentFrame)
    local container = Instance.new("Frame", parentFrame)
    container.Size = UDim2.new(1, -10, 0, 30)
    container.Position = UDim2.new(0, 5, 0, yPos)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextTruncate = Enum.TextTruncate.AtEnd

    local toggle = Instance.new("TextButton", container)
    toggle.Size = UDim2.new(0, 18, 0, 18)
    toggle.Position = UDim2.new(1, -20, 0.5, -9)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Active = false

    toggle.MouseButton1Click:Connect(function()
        toggle.Active = not toggle.Active
        if toggle.Active then
            toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)
    return toggle
end

-- Function Create Slider
local function createSlider(name, yPos, minVal, maxVal, defaultVal, parentFrame)
    local container = Instance.new("Frame", parentFrame)
    container.Size = UDim2.new(1, -10, 0, 50)
    container.Position = UDim2.new(0, 5, 0, yPos)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. defaultVal
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 1, -12)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    local handle = Instance.new("TextButton", sliderBg)
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new(0, -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.Text = ""
    handle.AutoButtonColor = false
    handle.ZIndex = 2

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        handle.Position = UDim2.new(pos, -6, 0.5, -6)
        local val = math.floor(minVal + (pos * (maxVal - minVal)))
        label.Text = name .. ": " .. val
        return val
    end

    handle.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    local startPos = (defaultVal - minVal) / (maxVal - minVal)
    sliderFill.Size = UDim2.new(startPos, 0, 1, 0)
    handle.Position = UDim2.new(startPos, -6, 0.5, -6)

    return {
        GetValue = function()
            local pos = sliderFill.Size.X.Scale
            return math.floor(minVal + (pos * (maxVal - minVal)))
        end
    }
end

-- Buat Toggles (Distribusi ke 2 Kolom)
local noclipToggle = createToggle("Noclip", 10, leftColumn)
local infJumpToggle = createToggle("Inf Jump", 50, leftColumn)
local speedToggle = createToggle("Speed", 90, leftColumn)
local flyToggle = createToggle("Fly", 130, leftColumn)

local chibiToggle = createToggle("Avatar Chibi", 10, rightColumn)
local holdToggle = createToggle("Instan Hold", 50, rightColumn)
local espToggle = createToggle("ESP Player & NPC", 90, rightColumn)
local jumpHighToggle = createToggle("Jump High", 130, rightColumn)

-- Buat Sliders
local speedSlider = createSlider("Speed Val", 170, 16, 500, 50, leftColumn)
local jumpSlider = createSlider("Jump H", 170, 0, 500, 100, rightColumn)
local flySlider = createSlider("Fly Speed", 230, 10, 500, 50, leftColumn)

-- Logic Avatar Chibi
chibiToggle.MouseButton1Click:Connect(function()
    if chibiToggle.Active then 
        chibiToggle.Active = false
        chibiToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        player:LoadCharacter() 
    else
        chibiToggle.Active = true
        chibiToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SmilerVinix/ChibiScript/adf59dcdf5015c3fca08a897b026151ab66dcd59/CHIBIOBFUSICATED"))(true)
        end)
    end
end)

-- Logic Instan Hold
local function applyPrompts()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

Workspace.DescendantAdded:Connect(function(desc)
    if holdToggle.Active and desc:IsA("ProximityPrompt") then
        desc.HoldDuration = 0
    end
end)

holdToggle.MouseButton1Click:Connect(function()
    if not holdToggle.Active then
        applyPrompts() 
    end
end)

-- Anti-Reset Logic
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    flying = false
    if chibiToggle.Active then
        chibiToggle.Active = false
        chibiToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    if holdToggle.Active then
        applyPrompts()
    end
end)

-- ESP Logic Functions
local function createHighlight(obj, color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "RazxESP_Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = obj
    return highlight
end

local function createTag(head, text)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RazxESP_Tag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = screenGui

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = text
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    
    return billboard
end

-- PERBAIKAN ESP UPDATE
local function updateESP()
    if not espToggle.Active then
        -- Clear logic
        for _, data in pairs(ESP_Storage) do
            if data.Highlight then data.Highlight:Destroy() end
            if data.Tag then data.Tag:Destroy() end
        end
        ESP_Storage = {}
        return
    end

    -- 1. Update Players (FIX: Head Loading & New Player)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            
            -- Init Storage
            if not ESP_Storage[char] then
                ESP_Storage[char] = {
                    Highlight = createHighlight(char, Color3.fromRGB(0, 255, 0)), -- Hijau
                    Tag = nil,
                    Name = p.DisplayName,
                    Type = "Player"
                }
            end

            -- Try to create Tag if Head is missing (Loading check)
            if not ESP_Storage[char].Tag then
                local head = char:FindFirstChild("Head")
                if head then
                    ESP_Storage[char].Tag = createTag(head, ESP_Storage[char].Name)
                end
            end

            -- Update Distance & Text
            if ESP_Storage[char].Tag then
                local dist = math.floor((root.Position - char.HumanoidRootPart.Position).Magnitude)
                ESP_Storage[char].Tag.TextLabel.Text = ESP_Storage[char].Name .. " ["..dist.."m]"
            end
        end
    end

    -- 2. Update NPCs (FIX: Head Loading)
    for _, obj in pairs(Workspace:GetDescendants()) do -- Pindah ke GetDescendants untuk lebih akurat, atau GetChildren jika ingin performa
        -- Kita pakai GetChildren() Workspace agar tidak lag scan seluruh descendants
    end
    
    -- Kita stick ke GetChildren Workspace untuk performa tapi logicnya diperbaiki
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= character and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            -- Cek apakah ini Player (Double check)
            local isPlayer = false
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character == obj then
                    isPlayer = true
                    break
                end
            end
            
            if not isPlayer then
                if not ESP_Storage[obj] then
                    ESP_Storage[obj] = {
                        Highlight = createHighlight(obj, Color3.fromRGB(255, 0, 0)), -- Merah
                        Tag = nil,
                        Name = "NPC",
                        Type = "NPC"
                    }
                end

                -- NPC Tag Loading
                if not ESP_Storage[obj].Tag then
                    local head = obj:FindFirstChild("Head")
                    if head then
                        ESP_Storage[obj].Tag = createTag(head, "NPC")
                    end
                end

                if ESP_Storage[obj].Tag then
                    local humRoot = obj:FindFirstChild("HumanoidRootPart")
                    if humRoot then
                        local dist = math.floor((root.Position - humRoot.Position).Magnitude)
                        ESP_Storage[obj].Tag.TextLabel.Text = "NPC ["..dist.."m]"
                    end
                end
            end
        end
    end

    -- 3. Cleanup Dead/Removed
    for char, data in pairs(ESP_Storage) do
        if not char or not char.Parent then
            if data.Highlight then data.Highlight:Destroy() end
            if data.Tag then data.Tag:Destroy() end
            ESP_Storage[char] = nil
        end
    end
end

-- Main Loop
_G[scriptIdentifier] = RunService.RenderStepped:Connect(function()
    if not character or not humanoid or not root then return end

    -- Jalankan Update ESP
    updateESP()

    -- Noclip
    if noclipToggle.Active then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end

    -- Inf Jump
    if infJumpToggle.Active then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- Speed (FIX LOMPAT: Default MaxSlopeAngle diganti ke 89)
    if speedToggle.Active then
        humanoid.WalkSpeed = speedSlider.GetValue()
        humanoid.MaxSlopeAngle = 89 
    else
        humanoid.WalkSpeed = 16
        humanoid.MaxSlopeAngle = 89
    end

    -- Jump High Logic
    if jumpHighToggle.Active then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpSlider.GetValue()
    else
        humanoid.JumpPower = 50
    end

    -- Fly
    if flyToggle.Active then
        if not flying then
            flying = true
            bodyVelocity = Instance.new("BodyVelocity")
            bodyGyro = Instance.new("BodyGyro")
            bodyVelocity.Parent = root
            bodyGyro.Parent = root
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.P = 10000
        end
        
        local speedVal = flySlider.GetValue()
        local direction = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0,1,0) end

        if direction.Magnitude > 0 then direction = direction.Unit end
        bodyVelocity.Velocity = direction * speedVal
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    else
        if flying then
            flying = false
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            root.Velocity = Vector3.new(0,0,0)
        end
    end
end)
]])()
