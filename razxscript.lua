--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--// Variables
local UIS = UserInputService
local flying = false
local flySpeed = 50
local walkSpeed = 16
local noclipActive = false
local infJumpActive = false

--// Create UI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 200)
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
    local active = false
    toggle.MouseButton1Click:Connect(function()
        active = not active
        toggle.BackgroundColor3 = active and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(120,120,120)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local posX = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            handle.Size = UDim2.new(posX/slider.AbsoluteSize.X,0,1,0)
            local value = min + (posX/slider.AbsoluteSize.X)*(max-min)
            label.Text = name..": "..math.floor(value)
            if name == "Speed" then
                walkSpeed = value
            elseif name == "Fly" then
                flySpeed = value
            end
        end
    end)
end

-- Create Toggles
local noclipToggle = createToggle("Noclip", UDim2.new(0, 10, 0, 40))
local infJumpToggle = createToggle("Inf Jump", UDim2.new(0, 10, 0, 80))

-- Create Sliders
createSlider("Speed", UDim2.new(0, 10, 0, 120), 16, 200, 50)
createSlider("Fly", UDim2.new(0, 10, 0, 160), 10, 100, 50)

--// Functionality

-- Noclip
RunService.RenderStepped:Connect(function()
    if noclipToggle.BackgroundColor3 == Color3.fromRGB(0,255,0) then
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
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if infJumpToggle.BackgroundColor3 == Color3.fromRGB(0,255,0) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
