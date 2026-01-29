loadstring([[
local scriptIdentifier = "razxHub_Reloaded" -- ID unik agar bisa dimatikan total

-- Cek apakah script sudah berjalan, jika ya matikan yang lama
if _G[scriptIdentifier] then
    _G[scriptIdentifier]:Disconnect()
    _G[scriptIdentifier] = nil
    local oldUI = game.Players.LocalPlayer.PlayerGui:FindFirstChild("razxHub")
    if oldUI then oldUI:Destroy() end
    return
end

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character, humanoid, root
local flying = false
local minimized = false
local bodyVelocity, bodyGyro

-- Fungsi untuk mendapatkan character terbaru (Anti-Reset)
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    if humanoid == nil or humanoid.Parent ~= char then
        humanoid = char:WaitForChild("Humanoid")
        root = char:WaitForChild("HumanoidRootPart")
    end
    return char
end

-- Initial setup
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
root = character:WaitForChild("HumanoidRootPart")

-- UI Setup
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false
screenGui.Name = "razxHub"

-- Main Frame (Hitam)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 280, 0, 330)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -165)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Judul
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "razxHub"
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

closeBtn.MouseButton1Click:Connect(function()
    -- HENTIKAN SCRIPT TOTAL (Script + Panel Ilang)
    if _G[scriptIdentifier] then
        _G[scriptIdentifier]:Disconnect()
        _G[scriptIdentifier] = nil
    end
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

-- Logo R (Tersembunyi awalnya)
local rLogoFrame = Instance.new("Frame", mainFrame)
rLogoFrame.Size = UDim2.new(1, 0, 1, 0)
rLogoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rLogoFrame.Visible = false
rLogoFrame.ZIndex = 1
rLogoFrame.BorderSizePixel = 0
rLogoFrame.Parent = mainFrame

local rLogoLabel = Instance.new("TextLabel", rLogoFrame)
rLogoLabel.Size = UDim2.new(1, 0, 1, 0)
rLogoLabel.Text = "R"
rLogoLabel.TextColor3 = Color3.new(1, 1, 1)
rLogoLabel.TextSize = 30
rLogoLabel.Font = Enum.Font.GothamBold
rLogoLabel.BackgroundTransparency = 1
rLogoLabel.ZIndex = 2

-- Event klik Minimize (-)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Ubah ukuran jadi kotak kecil (40x40)
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        title.Visible = false
        closeBtn.Visible = false
        minBtn.Visible = false
        rLogoFrame.Visible = true
        rLogoLabel.Visible = true
    else
        -- Kembalikan ukuran asli
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 330)}):Play()
        title.Visible = true
        closeBtn.Visible = true
        minBtn.Visible = true
        rLogoFrame.Visible = false
        rLogoLabel.Visible = false
        minimized = false
    end
end)

-- Konten (Toggle & Slider)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1

-- Function Toggle
local function createToggle(name, yPos)
    local container = Instance.new("Frame", contentFrame)
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 16

    local toggle = Instance.new("TextButton", container)
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -20, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Active = false

    toggle.MouseButton1Click:Connect(function()
        toggle.Active = not toggle.Active
        if toggle.Active then
            toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Hijau
        else
            toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60) -- Abu
        end
    end)
    return toggle
end

-- Function Slider
local function createSlider(name, yPos, minVal, maxVal, defaultVal)
    local container = Instance.new("Frame", contentFrame)
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. defaultVal
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local sliderBg = Instance.new("Frame", container)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 1, -12)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    local handle = Instance.new("TextButton", sliderBg)
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new(0, -6, 0.5, -6) -- Center
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.Text = ""
    handle.AutoButtonColor = false
    handle.ZIndex = 2

    -- Logic Slider
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
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            return updateSlider(input)
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

-- Buat Toggles
local noclipToggle = createToggle("Noclip", 10)
local infJumpToggle = createToggle("Inf Jump", 50)
local speedToggle = createToggle("Speed", 90)
local flyToggle = createToggle("Fly", 130)

-- Buat Sliders (Speed 16-500, Fly 10-100)
local speedSlider = createSlider("Speed", 170, 16, 500, 50)
local flySlider = createSlider("Fly Speed", 230, 10, 100, 50)

-- Character Re-assignment (Anti-Reset)
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    flying = false -- Reset fly state on death
end)

-- Main Loop (RenderStepped)
_G[scriptIdentifier] = RunService.RenderStepped:Connect(function()
    if not character or not humanoid or not root then return end

    -- Noclip Logic
    if noclipToggle.Active then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end

    -- Inf Jump Logic
    if infJumpToggle.Active then
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- Speed Logic
    if speedToggle.Active then
        humanoid.WalkSpeed = speedSlider.GetValue()
    else
        humanoid.WalkSpeed = 16
    state = "Running"
    end

    -- Fly Logic
    if flyToggle.Active then
        if not flying then
            flying = true
            bodyVelocity = Instance.new("BodyVelocity")
            bodyGyro = Instance.new("BodyGyro")
            bodyVelocity.Parent = root
            bodyGyro.Parent = root
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        
        local speedVal = flySlider.GetValue()
        local direction = Vector3.new(0,0,0)
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
        
        -- Fly Up/Down
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0,1,0) end

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
