loadstring([[
--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Variables
local UIS = UserInputService
local flying = false
local flySpeed = 50
local walkSpeed = 16
local noclipActive = false
local infJumpActive = false
local speedActive = false
local flyActive = false
local minimized = false

-- Create UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 250)
mainFrame.Position = UDim2.new(0, 100, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Close button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize button (logo R)
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -60, 0, 5)
minBtn.Text = "R"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)

minBtn.MouseButton1Click:Connect(function()
    if minimized then
        -- restore frame
        mainFrame.Size = UDim2.new(0, 250, 0, 250)
        minimized = false
    else
        -- minimize frame
        mainFrame.Size = UDim2.new(0, 40, 0, 40)
        minimized = true
    end
end)

-- Function to create toggle
local function createToggle(name, pos)
    local frame = Instance.new("Frame", mainFrame)
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 70, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Position = UDim2.new(1, -25, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    toggle.Text = ""
    toggle.Active = false
    toggle.MouseButton1Click:Connect(function()
        toggle.Active = not toggle.Active
        toggle.BackgroundColor3 = toggle.Active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(120,120,120)
    end)
    return toggle
end

-- Function to create slider
local function createSlider(name, pos, min, max, default)
    local frame = Instance.new("Frame", mainFrame)
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = name..": "..default
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local slider = Instance.new("Frame", frame)
    slider.Size = UDim2.new(1, -10, 0, 10)
    slider.Position = UDim2.new(0, 5, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(80,80,80)

    local handle = Instance.new("Frame", slider)
    handle.Size = UDim2.new(default/(max-min), 0, 1, 0)
    handle.BackgroundColor3 = Color3.fromRGB(0,255,0)

    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local posX = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            handle.Size = UDim2.new(posX/slider.AbsoluteSize.X,0,1,0)
            local value = min + (posX/slider.AbsoluteSize.X)*(max-min)
            label.Text = name..": "..math.floor(value)
        end
    end)
    return slider, handle
end

-- Create toggles
local noclipToggle = createToggle("Noclip", UDim2.new(0,10,0,40))
local infJumpToggle = createToggle("Inf Jump", UDim2.new(0,10,0,80))
local speedToggle = createToggle("Speed ON", UDim2.new(0,10,0,120))
local flyToggle = createToggle("Fly ON", UDim2.new(0,10,0,160))

-- Create sliders
local speedSlider, speedHandle = createSlider("Speed", UDim2.new(0,10,0,140),16,200,50)
local flySlider, flyHandle = createSlider("Fly", UDim2.new(0,10,0,180),10,100,50)

-- Variables for sliders
local currentSpeed = 50
local currentFlySpeed = 50

-- Fly variables
local bodyVelocity, bodyGyro

RunService.RenderStepped:Connect(function()
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

    -- Infinite Jump
    if infJumpToggle.Active then humanoid.JumpPower = 50 end

    -- Update sliders
    local speedX = speedHandle.Size.X.Scale
    local flyX = flyHandle.Size.X.Scale
    currentSpeed = 16 + (200-16)*speedX
    currentFlySpeed = 10 + (100-10)*flyX

    -- Apply Speed
    if speedToggle.Active then humanoid.WalkSpeed = currentSpeed else humanoid.WalkSpeed = 16 end

    -- Fly
    if flyToggle.Active then
        if not flying then
            flying = true
            bodyVelocity = Instance.new("BodyVelocity", root)
            bodyGyro = Instance.new("BodyGyro", root)
            bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        end
        local direction = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end
        if direction.Magnitude > 0 then direction = direction.Unit end
        bodyVelocity.Velocity = direction * currentFlySpeed
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    else
        if flying then
            flying = false
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end
end)
]])()
