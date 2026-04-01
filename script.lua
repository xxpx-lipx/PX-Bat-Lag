local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local batLagEnabled = false
local speedOn = false
local speedConn = nil
local isExecuting = false

local function CleanAcc(char)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") then v:Destroy() end
    end
end

local function MonitorPlayer(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        CleanAcc(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Accessory") then task.defer(function() child:Destroy() end) end
        end)
    end)
    if p.Character then CleanAcc(p.Character) end
end

for _, p in pairs(Players:GetPlayers()) do MonitorPlayer(p) end
Players.PlayerAdded:Connect(MonitorPlayer)

task.spawn(function()
    while true do
        task.wait(0.05)
        if batLagEnabled and isExecuting then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local backpack = player:FindFirstChild("Backpack")
                local bat = (backpack and backpack:FindFirstChild("Bat")) or char:FindFirstChild("Bat")
                if bat and hum then
                    hum:EquipTool(bat)
                    task.wait(0.05)
                    hum:UnequipTools()
                end
            end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PX_BatLag_UI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(15, 40, 25)
Frame.BackgroundTransparency = 0.2
Frame.Size = UDim2.new(0, 200, 0, 185)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local mStroke = Instance.new("UIStroke", Frame)
mStroke.Thickness = 2
mStroke.Color = Color3.fromRGB(255, 255, 255)
mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local mGrad = Instance.new("UIGradient", mStroke)
mGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 152, 118)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(113, 255, 158))
}

RS.RenderStepped:Connect(function(dt)
    mGrad.Rotation = (mGrad.Rotation + 120 * dt) % 360
end)

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 80, 60)
TopBar.BorderSizePixel = 0
local TopBarGrad = Instance.new("UIGradient", TopBar)
TopBarGrad.Color = mGrad.Color
TopBarGrad.Rotation = 45
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PX Bat Lag"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local ToggleGuiButton = Instance.new("TextButton", TopBar)
ToggleGuiButton.Size = UDim2.new(0, 24, 0, 24)
ToggleGuiButton.Position = UDim2.new(1, -32, 0, 8)
ToggleGuiButton.Text = "－"
ToggleGuiButton.BackgroundColor3 = Color3.fromRGB(30, 60, 45)
ToggleGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiButton.Font = Enum.Font.GothamBold
ToggleGuiButton.TextSize = 14
Instance.new("UICorner", ToggleGuiButton).CornerRadius = UDim.new(0, 6)

local InnerFrame = Instance.new("Frame", Frame)
InnerFrame.Position = UDim2.new(0, 0, 0, 40)
InnerFrame.Size = UDim2.new(1, 0, 1, -40)
InnerFrame.BackgroundTransparency = 1

local function createToggle(name, yPos, parent)
    local container = Instance.new("Frame", parent)
    container.Size, container.Position, container.BackgroundTransparency = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, yPos), 1
    local label = Instance.new("TextLabel", container)
    label.Size, label.Position, label.BackgroundTransparency = UDim2.new(0, 100, 1, 0), UDim2.new(0, 15, 0, 0), 1
    label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment = name, Color3.new(1,1,1), Enum.Font.GothamMedium, 14, 0
    local switchBg = Instance.new("TextButton", container)
    switchBg.Size, switchBg.Position, switchBg.BackgroundColor3, switchBg.BackgroundTransparency, switchBg.Text = UDim2.new(0, 45, 0, 22), UDim2.new(1, -60, 0.5, -11), Color3.fromRGB(40, 40, 40), 0.3, ""
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", switchBg)
    knob.Size, knob.Position, knob.BackgroundColor3 = UDim2.new(0, 18, 0, 18), UDim2.new(0, 2, 0.5, -9), Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    switchBg.MouseButton1Click:Connect(function()
        if name == "Bat Lag" then
            batLagEnabled = not batLagEnabled
        elseif name == "Speed Boost" then
            speedOn = not speedOn
            if speedOn then
                speedConn = RS.RenderStepped:Connect(function()
                    local char = player.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hum or not hrp then return end
                    local dir = hum.MoveDirection
                    if dir.Magnitude > 0.05 then
                        hrp.AssemblyLinearVelocity = Vector3.new(dir.X * 24.5, hrp.AssemblyLinearVelocity.Y, dir.Z * 24.5)
                    end
                end)
            else
                if speedConn then speedConn:Disconnect(); speedConn = nil end
            end
        end
        
        local s = (name == "Bat Lag" and batLagEnabled) or (name == "Speed Boost" and speedOn)
        TS:Create(knob, TweenInfo.new(0.2), {Position = s and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = s and Color3.fromRGB(113, 255, 158) or Color3.fromRGB(200, 200, 200)}):Play()
        TS:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = s and Color3.fromRGB(30, 100, 60) or Color3.fromRGB(40, 40, 40)}):Play()
    end)
end

createToggle("Speed Boost", 5, InnerFrame)
createToggle("Bat Lag", 45, InnerFrame)

local ExecuteBtn = Instance.new("TextButton", InnerFrame)
ExecuteBtn.Position, ExecuteBtn.Size, ExecuteBtn.BackgroundColor3 = UDim2.new(0.1, 0, 0, 95) , UDim2.new(0.8, 0, 0, 35), Color3.fromRGB(30, 80, 50)
ExecuteBtn.Text, ExecuteBtn.TextColor3, ExecuteBtn.Font, ExecuteBtn.TextSize = "Execute", Color3.new(1,1,1), Enum.Font.GothamBold, 14
Instance.new("UICorner", ExecuteBtn).CornerRadius = UDim.new(0, 8)
local BtnStroke = Instance.new("UIStroke", ExecuteBtn)
BtnStroke.Thickness, BtnStroke.Color, BtnStroke.ApplyStrokeMode = 2, Color3.fromRGB(113, 255, 158), Enum.ApplyStrokeMode.Border

ExecuteBtn.MouseButton1Click:Connect(function()
    if batLagEnabled then
        isExecuting = true
        ExecuteBtn.Text = "Executed!"
        task.wait(1)
        ExecuteBtn.Text = "Execute"
    else
        ExecuteBtn.Text = "Ready Bat Lag first"
        task.wait(1)
        ExecuteBtn.Text = "Execute"
    end
end)

local isOpened = true
ToggleGuiButton.MouseButton1Click:Connect(function()
    isOpened = not isOpened
    ToggleGuiButton.Text = isOpened and "－" or "＋"
    TS:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = isOpened and UDim2.new(0, 200, 0, 185) or UDim2.new(0, 200, 0, 40)}):Play()
    InnerFrame.Visible = isOpened
end)

local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging, dragStart, startPos = true, i.Position, obj.Position end end)
    obj.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end
makeDraggable(Frame)
