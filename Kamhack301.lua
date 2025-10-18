--[[
    🎃 Kamhack — Halloween Edition (Green Glow)
    Author: Copilot (for user) — Theme: green/black, translucent, glow, pumpkin accents
    Features:
      - UI: enhanced glassmorphism, green glow outlines, spooky gradients, improved animations
      - Aimbot: static FOV circle (green), sub-menu with Aim Wall Check
      - ESP: ESP Box (Green), ESP Name, ESP Skeleton (Green), ESP Line Friends (Green, lines between players who are friends with each other, excluding local player, persistent even when camera turns away)
      - Rage tab: TPWalk (like Infinity Yield), Float, sub-menu for features
      - Settings tab: UI scale adjustment
      - Modified: Draggable menu button, ESP tab with scrollable sub-menu, Rage sub-menu, modified ESP Line Friends to connect pairs of friends excluding local player and persist when camera turns away
    Script Name: Kamhack
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- === Theme colors (Halloween green glow) ===
local COLOR_GREEN = Color3.fromRGB(0, 255, 0) -- Bright green for glow
local COLOR_GREEN_DARK = Color3.fromRGB(0, 100, 0) -- Darker green for accents
local COLOR_BG = Color3.fromRGB(12, 10, 16) -- Background remains the same
local COLOR_ACCENT = Color3.fromRGB(150, 255, 150) -- Lighter green for text/buttons

-- Utility: Enhanced green neon outline (glow)
local function neonStroke(obj, color, thickness, glow)
    local stroke = Instance.new("UIStroke", obj)
    stroke.Color = color or COLOR_GREEN
    stroke.Thickness = thickness or 3
    stroke.Transparency = 0.05
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Enabled = true
    if glow then
        for i = 1, 2 do
            local n = Instance.new("UIStroke", obj)
            n.Color = color or COLOR_GREEN
            n.Thickness = (thickness or 3) + i * 2
            n.Transparency = 0.4 + 0.15 * i
            n.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            n.LineJoinMode = Enum.LineJoinMode.Round
        end
    end
end

-- Utility: Enhanced gradient (green-themed)
local function addGradient(obj, c1, c2, rot)
    local grad = Instance.new("UIGradient", obj)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1 or Color3.fromRGB(20, 40, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 100, 40)),
        ColorSequenceKeypoint.new(1, c2 or Color3.fromRGB(30, 80, 30))
    }
    grad.Rotation = rot or 45
    return grad
end

-- Soft drop shadow helper with enhanced depth
local function dropShadow(parent, size, pos, transparency)
    local img = Instance.new("ImageLabel")
    img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Position = pos or UDim2.new(0.5, 0, 0.5, 8)
    img.Size = size or UDim2.new(1, 60, 1, 60)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://1316045217"
    img.ImageColor3 = Color3.fromRGB(8, 4, 4)
    img.ImageTransparency = transparency or 0.85
    img.ZIndex = -1
    img.Parent = parent
    return img
end

-- === ScreenGui ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Kamhack"
screenGui.IgnoreGuiInset = false
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === Title Label (Kamhack) ===
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 220, 0, 60)
titleLabel.Position = UDim2.new(0.5, 0, 0.05, 0)
titleLabel.AnchorPoint = Vector2.new(0.5, 0)
titleLabel.Text = "Kamhack 🎃"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 32
titleLabel.BackgroundColor3 = COLOR_BG
titleLabel.BackgroundTransparency = 0.7
titleLabel.TextColor3 = COLOR_ACCENT
titleLabel.TextTransparency = 1
titleLabel.Visible = false
titleLabel.Parent = screenGui
Instance.new("UICorner", titleLabel).CornerRadius = UDim.new(0, 16)
neonStroke(titleLabel, COLOR_GREEN, 2.5, true)
addGradient(titleLabel)
dropShadow(titleLabel, UDim2.new(1, 50, 1, 50), UDim2.new(0.5, 0, 0.5, 8), 0.88)

local titleShowTween = TweenService:Create(titleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0, BackgroundTransparency = 0.7, Size = UDim2.new(0, 220, 0, 60)})
local titleHideTween = TweenService:Create(titleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 50)})

-- === Toggle Button (pumpkin) ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 140, 0, 50)
toggleBtn.Position = UDim2.new(0, 30, 0, 30)
toggleBtn.AnchorPoint = Vector2.new(0, 0)
toggleBtn.Text = "🎃 Menu"
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 20
toggleBtn.BackgroundColor3 = COLOR_BG
toggleBtn.BackgroundTransparency = 0.5
toggleBtn.TextColor3 = COLOR_ACCENT
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 20)
neonStroke(toggleBtn, COLOR_GREEN, 2, true)
addGradient(toggleBtn)
dropShadow(toggleBtn, UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 6), 0.9)

-- === Dragging for Toggle Button ===
local toggleDragging, toggleDragInput, toggleDragStart, toggleStartPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = toggleBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)
toggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        toggleDragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == toggleDragInput and toggleDragging then
        local delta = input.Position - toggleDragStart
        toggleBtn.Position = UDim2.new(
            toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

-- === Main Frame ===
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 780, 0, 520)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = COLOR_BG
main.BackgroundTransparency = 0.65
main.BorderSizePixel = 0
main.Visible = false
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 30)
neonStroke(main, COLOR_GREEN, 4, true)
addGradient(main)
dropShadow(main, UDim2.new(1, 90, 1, 90), UDim2.new(0.5, 0, 0.5, 24), 0.85)

local menuTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.65, Size = UDim2.new(0, 780, 0, 520)})
local menuTweenHide = TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 740, 0, 500)})

toggleBtn.MouseButton1Click:Connect(function()
    if not main.Visible then
        main.BackgroundTransparency = 1
        main.Size = UDim2.new(0, 740, 0, 500)
        main.Visible = true
        titleLabel.Visible = true
        menuTween:Play()
        titleShowTween:Play()
    else
        menuTweenHide:Play()
        titleHideTween:Play()
        wait(0.3)
        main.Visible = false
        titleLabel.Visible = false
    end
end)

-- === Dragging for Main Frame ===
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- === Sidebar + content ===
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 18, 20)
sidebar.BackgroundTransparency = 0.55
sidebar.BorderSizePixel = 0
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 24)
neonStroke(sidebar, COLOR_GREEN, 2, true)
addGradient(sidebar)
dropShadow(sidebar, UDim2.new(1, 50, 1, 50), UDim2.new(0.5, 0, 0.5, 12), 0.88)

local tabs = {"Aim", "ESP", "Rage", "Settings"}
local pages, buttons = {}, {}

local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 220, 0, 0)
content.Size = UDim2.new(1, -220, 1, 0)
content.BackgroundColor3 = Color3.fromRGB(18, 12, 14)
content.BackgroundTransparency = 0.65
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 20)
addGradient(content)

-- === Tab creation ===
for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -30, 0, 48)
    btn.Position = UDim2.new(0, 15, 0, (i-1)*60 + 30)
    btn.Text = tab
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 22
    btn.BackgroundColor3 = Color3.fromRGB(28, 18, 20)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(200, 255, 200)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    neonStroke(btn, COLOR_GREEN, 1.5, true)
    addGradient(btn)

    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1, -30, 1, -30)
    page.Position = UDim2.new(0, 15, 0, 15)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    pages[tab] = page
    buttons[tab] = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1, Size = UDim2.new(1, -20, 0, 50)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if not page.Visible then
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0.3, Size = UDim2.new(1, -30, 0, 48)}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for _, pg in pairs(pages) do pg.Visible = false end
        for _, b in pairs(buttons) do
            TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0.3, Size = UDim2.new(1, -30, 0, 48)}):Play()
        end
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05, Size = UDim2.new(1, -20, 0, 50)}):Play()
    end)
end

-- === Toggle Creator ===
local function createToggle(parent, text, posY, callback, default)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -30, 0, 50)
    frame.Position = UDim2.new(0, 0, 0, posY)
    frame.BackgroundTransparency = 0.8
    frame.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    neonStroke(frame, COLOR_GREEN, 1.5, true)
    addGradient(frame)

    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 255, 200)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 80, 0, 36)
    btn.Position = UDim2.new(1, -90, 0.5, -18)
    btn.Text = default and "On" or "Off"
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 18
    btn.BackgroundColor3 = default and COLOR_GREEN or Color3.fromRGB(45, 30, 25)
    btn.BackgroundTransparency = 0.15
    btn.TextColor3 = Color3.fromRGB(20, 8, 2)
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    addGradient(btn, COLOR_GREEN, Color3.fromRGB(80, 180, 80))
    neonStroke(btn, COLOR_GREEN, 1.5, true)

    local state = default or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "On" or "Off"
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and COLOR_GREEN or Color3.fromRGB(45, 30, 25),
            TextColor3 = Color3.fromRGB(30, 8, 2)
        }):Play()
        if callback then callback(state) end
    end)
    if callback then callback(state) end
    return function() return state end
end

-- === States ===
local aiming = false
local aimFov = 120
local espBoxEnabled = false
local espNameEnabled = false
local espSkeletonEnabled = false
local fovCircleVisible = false
local tpwalkEnabled = false
local originalWalkSpeed = 16
local tpwalkSpeed = 5
local floatEnabled = false
local floatHeight = 0
local uiScale = 1
local espBoxes = {}
local espNames = {}
local espSkeletons = {}
local espLineFriendsEnabled = false
local espFriendLines = {} -- Store {line, player1, player2} for friend pairs
local wallCheckEnabled = false

-- === TAB: AIM ===
local aimPage = pages["Aim"]
createToggle(aimPage, "Enable Aimbot", 10, function(on) aiming = on end)
createToggle(aimPage, "Show FOV Circle", 70, function(on) fovCircleVisible = on end)
local fovSlider = Instance.new("TextButton", aimPage)
fovSlider.Size = UDim2.new(1, -30, 0, 48)
fovSlider.Position = UDim2.new(0, 15, 0, 130)
fovSlider.Text = "Aimbot FOV: " .. aimFov
fovSlider.Font = Enum.Font.GothamBlack
fovSlider.TextSize = 20
fovSlider.BackgroundColor3 = Color3.fromRGB(40, 20, 18)
fovSlider.BackgroundTransparency = 0.1
fovSlider.TextColor3 = Color3.fromRGB(200, 255, 200)
fovSlider.AutoButtonColor = false
Instance.new("UICorner", fovSlider).CornerRadius = UDim.new(0, 10)
addGradient(fovSlider)
neonStroke(fovSlider, COLOR_GREEN, 1.5, true)
fovSlider.MouseButton1Click:Connect(function()
    aimFov = aimFov + 50
    if aimFov > 500 then aimFov = 50 end
    fovSlider.Text = "Aimbot FOV: " .. aimFov
end)

-- Sub-menu button for Aim tab
local aimSubMenuBtn = Instance.new("TextButton", aimPage)
aimSubMenuBtn.Size = UDim2.new(1, -30, 0, 48)
aimSubMenuBtn.Position = UDim2.new(0, 15, 0, 190)
aimSubMenuBtn.Text = "Advanced Aimbot Settings"
aimSubMenuBtn.Font = Enum.Font.GothamBlack
aimSubMenuBtn.TextSize = 20
aimSubMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 18)
aimSubMenuBtn.BackgroundTransparency = 0.1
aimSubMenuBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
aimSubMenuBtn.AutoButtonColor = false
Instance.new("UICorner", aimSubMenuBtn).CornerRadius = UDim.new(0, 10)
addGradient(aimSubMenuBtn)
neonStroke(aimSubMenuBtn, COLOR_GREEN, 1.5, true)

-- Sub-menu frame for Aim
local aimSubMenu = Instance.new("Frame", aimPage)
aimSubMenu.Size = UDim2.new(0, 300, 0, 100)
aimSubMenu.Position = UDim2.new(0, 15, 0, 250)
aimSubMenu.BackgroundColor3 = COLOR_BG
aimSubMenu.BackgroundTransparency = 0.65
aimSubMenu.BorderSizePixel = 0
aimSubMenu.Visible = false
Instance.new("UICorner", aimSubMenu).CornerRadius = UDim.new(0, 15)
neonStroke(aimSubMenu, COLOR_GREEN, 2, true)
addGradient(aimSubMenu)
dropShadow(aimSubMenu, UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 10), 0.88)

-- Add Aim Wall Check toggle to sub-menu
createToggle(aimSubMenu, "Aimbot Wall Check", 10, function(on) wallCheckEnabled = on end)

-- Sub-menu toggle logic for Aim
local aimSubMenuTweenShow = TweenService:Create(aimSubMenu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.65, Size = UDim2.new(0, 300, 0, 100)})
local aimSubMenuTweenHide = TweenService:Create(aimSubMenu, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 90)})

aimSubMenuBtn.MouseButton1Click:Connect(function()
    if not aimSubMenu.Visible then
        aimSubMenu.BackgroundTransparency = 1
        aimSubMenu.Size = UDim2.new(0, 280, 0, 90)
        aimSubMenu.Visible = true
        aimSubMenuTweenShow:Play()
    else
        aimSubMenuTweenHide:Play()
        wait(0.3)
        aimSubMenu.Visible = false
    end
end)

-- === TAB: ESP ===
local espPage = pages["ESP"]

-- Sub-menu button for ESP tab
local espSubMenuBtn = Instance.new("TextButton", espPage)
espSubMenuBtn.Size = UDim2.new(1, -30, 0, 48)
espSubMenuBtn.Position = UDim2.new(0, 15, 0, 10)
espSubMenuBtn.Text = "ESP Settings"
espSubMenuBtn.Font = Enum.Font.GothamBlack
espSubMenuBtn.TextSize = 20
espSubMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 18)
espSubMenuBtn.BackgroundTransparency = 0.1
espSubMenuBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
espSubMenuBtn.AutoButtonColor = false
Instance.new("UICorner", espSubMenuBtn).CornerRadius = UDim.new(0, 10)
addGradient(espSubMenuBtn)
neonStroke(espSubMenuBtn, COLOR_GREEN, 1.5, true)

-- Sub-menu frame for ESP
local espSubMenu = Instance.new("Frame", espPage)
espSubMenu.Size = UDim2.new(0, 300, 0, 200)
espSubMenu.Position = UDim2.new(0, 15, 0, 70)
espSubMenu.BackgroundColor3 = COLOR_BG
espSubMenu.BackgroundTransparency = 0.65
espSubMenu.BorderSizePixel = 0
espSubMenu.Visible = false
Instance.new("UICorner", espSubMenu).CornerRadius = UDim.new(0, 15)
neonStroke(espSubMenu, COLOR_GREEN, 2, true)
addGradient(espSubMenu)
dropShadow(espSubMenu, UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 10), 0.88)

-- ScrollingFrame inside sub-menu
local espScrollingFrame = Instance.new("ScrollingFrame", espSubMenu)
espScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
espScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
espScrollingFrame.BackgroundTransparency = 1
espScrollingFrame.ScrollBarThickness = 6
espScrollingFrame.ScrollBarImageColor3 = COLOR_GREEN
espScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
espScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 250)

local espListLayout = Instance.new("UIListLayout", espScrollingFrame)
espListLayout.SortOrder = Enum.SortOrder.LayoutOrder
espListLayout.Padding = UDim.new(0, 10)

-- Add ESP toggles to scrolling frame
createToggle(espScrollingFrame, "Enable ESP Box (Green)", 0, function(on)
    espBoxEnabled = on
    for _, drawing in pairs(espBoxes) do
        for _, element in pairs(drawing) do
            element.Visible = on
        end
    end
end)
createToggle(espScrollingFrame, "Enable ESP Names", 60, function(on)
    espNameEnabled = on
    for _, name in pairs(espNames) do
        name.Visible = on
    end
end)
createToggle(espScrollingFrame, "Enable ESP Skeleton (Green)", 120, function(on)
    espSkeletonEnabled = on
    for _, skeleton in pairs(espSkeletons) do
        for _, line in pairs(skeleton) do
            line.Visible = on
        end
    end
end)
createToggle(espScrollingFrame, "Enable ESP Line Friends (Green)", 180, function(on)
    espLineFriendsEnabled = on
    for _, data in pairs(espFriendLines) do
        data.line.Visible = on and data.player1.Character and data.player1.Character:FindFirstChild("HumanoidRootPart") and data.player2.Character and data.player2.Character:FindFirstChild("HumanoidRootPart")
    end
end)

-- Sub-menu toggle logic for ESP
local espSubMenuTweenShow = TweenService:Create(espSubMenu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.65, Size = UDim2.new(0, 300, 0, 200)})
local espSubMenuTweenHide = TweenService:Create(espSubMenu, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 180)})

espSubMenuBtn.MouseButton1Click:Connect(function()
    if not espSubMenu.Visible then
        espSubMenu.BackgroundTransparency = 1
        espSubMenu.Size = UDim2.new(0, 280, 0, 180)
        espSubMenu.Visible = true
        espSubMenuTweenShow:Play()
    else
        espSubMenuTweenHide:Play()
        wait(0.3)
        espSubMenu.Visible = false
    end
end)

-- === TAB: Rage ===
local ragePage = pages["Rage"]

-- Sub-menu button for Rage tab
local rageSubMenuBtn = Instance.new("TextButton", ragePage)
rageSubMenuBtn.Size = UDim2.new(1, -30, 0, 48)
rageSubMenuBtn.Position = UDim2.new(0, 15, 0, 10)
rageSubMenuBtn.Text = "Rage Settings"
rageSubMenuBtn.Font = Enum.Font.GothamBlack
rageSubMenuBtn.TextSize = 20
rageSubMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 18)
rageSubMenuBtn.BackgroundTransparency = 0.1
rageSubMenuBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
rageSubMenuBtn.AutoButtonColor = false
Instance.new("UICorner", rageSubMenuBtn).CornerRadius = UDim.new(0, 10)
addGradient(rageSubMenuBtn)
neonStroke(rageSubMenuBtn, COLOR_GREEN, 1.5, true)

-- Sub-menu frame for Rage
local rageSubMenu = Instance.new("Frame", ragePage)
rageSubMenu.Size = UDim2.new(0, 300, 0, 250)
rageSubMenu.Position = UDim2.new(0, 15, 0, 70)
rageSubMenu.BackgroundColor3 = COLOR_BG
rageSubMenu.BackgroundTransparency = 0.65
rageSubMenu.BorderSizePixel = 0
rageSubMenu.Visible = false
Instance.new("UICorner", rageSubMenu).CornerRadius = UDim.new(0, 15)
neonStroke(rageSubMenu, COLOR_GREEN, 2, true)
addGradient(rageSubMenu)
dropShadow(rageSubMenu, UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 10), 0.88)

-- ScrollingFrame inside sub-menu for Rage
local rageScrollingFrame = Instance.new("ScrollingFrame", rageSubMenu)
rageScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
rageScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
rageScrollingFrame.BackgroundTransparency = 1
rageScrollingFrame.ScrollBarThickness = 6
rageScrollingFrame.ScrollBarImageColor3 = COLOR_GREEN
rageScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
rageScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)

local rageListLayout = Instance.new("UIListLayout", rageScrollingFrame)
rageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
rageListLayout.Padding = UDim.new(0, 10)

-- Add Rage features to scrolling frame
local tpwalkToggle = createToggle(rageScrollingFrame, "Enable TPWalk", 0, function(on)
    tpwalkEnabled = on
    if not on and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed
    end
end, false)

-- TPWalk speed input
local tpwalkSpeedFrame = Instance.new("Frame", rageScrollingFrame)
tpwalkSpeedFrame.Size = UDim2.new(1, -30, 0, 50)
tpwalkSpeedFrame.Position = UDim2.new(0, 0, 0, 60)
tpwalkSpeedFrame.BackgroundTransparency = 0.8
tpwalkSpeedFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Instance.new("UICorner", tpwalkSpeedFrame).CornerRadius = UDim.new(0, 12)
neonStroke(tpwalkSpeedFrame, COLOR_GREEN, 1.5, true)
addGradient(tpwalkSpeedFrame)

local tpwalkSpeedLabel = Instance.new("TextLabel", tpwalkSpeedFrame)
tpwalkSpeedLabel.Text = "TPWalk Speed:"
tpwalkSpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
tpwalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
tpwalkSpeedLabel.Font = Enum.Font.GothamBold
tpwalkSpeedLabel.TextSize = 20
tpwalkSpeedLabel.BackgroundTransparency = 1
tpwalkSpeedLabel.TextColor3 = Color3.fromRGB(200, 255, 200)

local tpwalkSpeedBox = Instance.new("TextBox", tpwalkSpeedFrame)
tpwalkSpeedBox.Size = UDim2.new(0, 100, 0, 36)
tpwalkSpeedBox.Position = UDim2.new(1, -110, 0.5, -18)
tpwalkSpeedBox.Text = tostring(tpwalkSpeed)
tpwalkSpeedBox.Font = Enum.Font.GothamBlack
tpwalkSpeedBox.TextSize = 18
tpwalkSpeedBox.BackgroundColor3 = Color3.fromRGB(45, 30, 25)
tpwalkSpeedBox.BackgroundTransparency = 0.15
tpwalkSpeedBox.TextColor3 = Color3.fromRGB(200, 255, 200)
Instance.new("UICorner", tpwalkSpeedBox).CornerRadius = UDim.new(0, 10)
addGradient(tpwalkSpeedBox, COLOR_GREEN, Color3.fromRGB(80, 180, 80))
neonStroke(tpwalkSpeedBox, COLOR_GREEN, 1.5, true)

tpwalkSpeedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(tpwalkSpeedBox.Text)
        if num and num > 0 then
            tpwalkSpeed = num
        end
        tpwalkSpeedBox.Text = tostring(tpwalkSpeed)
    end
end)

local floatToggle = createToggle(rageScrollingFrame, "Enable Float", 120, function(on)
    floatEnabled = on
    if on then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            floatHeight = root.Position.Y
            floatHeightBox.Text = tostring(floatHeight)
        end
    else
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and root:FindFirstChild("FloatBP") then
            root.FloatBP:Destroy()
        end
    end
end, false)

-- Float height input
local floatHeightFrame = Instance.new("Frame", rageScrollingFrame)
floatHeightFrame.Size = UDim2.new(1, -30, 0, 50)
floatHeightFrame.Position = UDim2.new(0, 0, 0, 180)
floatHeightFrame.BackgroundTransparency = 0.8
floatHeightFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Instance.new("UICorner", floatHeightFrame).CornerRadius = UDim.new(0, 12)
neonStroke(floatHeightFrame, COLOR_GREEN, 1.5, true)
addGradient(floatHeightFrame)

local floatHeightLabel = Instance.new("TextLabel", floatHeightFrame)
floatHeightLabel.Text = "Float Height:"
floatHeightLabel.Size = UDim2.new(0.6, 0, 1, 0)
floatHeightLabel.TextXAlignment = Enum.TextXAlignment.Left
floatHeightLabel.Font = Enum.Font.GothamBold
floatHeightLabel.TextSize = 20
floatHeightLabel.BackgroundTransparency = 1
floatHeightLabel.TextColor3 = Color3.fromRGB(200, 255, 200)

local floatHeightBox = Instance.new("TextBox", floatHeightFrame)
floatHeightBox.Size = UDim2.new(0, 100, 0, 36)
floatHeightBox.Position = UDim2.new(1, -110, 0.5, -18)
floatHeightBox.Text = tostring(floatHeight)
floatHeightBox.Font = Enum.Font.GothamBlack
floatHeightBox.TextSize = 18
floatHeightBox.BackgroundColor3 = Color3.fromRGB(45, 30, 25)
floatHeightBox.BackgroundTransparency = 0.15
floatHeightBox.TextColor3 = Color3.fromRGB(200, 255, 200)
Instance.new("UICorner", floatHeightBox).CornerRadius = UDim.new(0, 10)
addGradient(floatHeightBox, COLOR_GREEN, Color3.fromRGB(80, 180, 80))
neonStroke(floatHeightBox, COLOR_GREEN, 1.5, true)

floatHeightBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(floatHeightBox.Text)
        if num then
            floatHeight = num
        end
        floatHeightBox.Text = tostring(floatHeight)
    end
end)

-- Sub-menu toggle logic for Rage
local rageSubMenuTweenShow = TweenService:Create(rageSubMenu, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.65, Size = UDim2.new(0, 300, 0, 250)})
local rageSubMenuTweenHide = TweenService:Create(rageSubMenu, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 280, 0, 230)})

rageSubMenuBtn.MouseButton1Click:Connect(function()
    if not rageSubMenu.Visible then
        rageSubMenu.BackgroundTransparency = 1
        rageSubMenu.Size = UDim2.new(0, 280, 0, 230)
        rageSubMenu.Visible = true
        rageSubMenuTweenShow:Play()
    else
        rageSubMenuTweenHide:Play()
        wait(0.3)
        rageSubMenu.Visible = false
    end
end)

-- === TAB: Settings ===
local settingsPage = pages["Settings"]
local uiScaleFrame = Instance.new("Frame", settingsPage)
uiScaleFrame.Size = UDim2.new(1, -30, 0, 50)
uiScaleFrame.Position = UDim2.new(0, 15, 0, 10)
uiScaleFrame.BackgroundTransparency = 0.8
uiScaleFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Instance.new("UICorner", uiScaleFrame).CornerRadius = UDim.new(0, 12)
neonStroke(uiScaleFrame, COLOR_GREEN, 1.5, true)
addGradient(uiScaleFrame)

local uiScaleLabel = Instance.new("TextLabel", uiScaleFrame)
uiScaleLabel.Text = "UI Scale:"
uiScaleLabel.Size = UDim2.new(0.6, 0, 1, 0)
uiScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
uiScaleLabel.Font = Enum.Font.GothamBold
uiScaleLabel.TextSize = 20
uiScaleLabel.BackgroundTransparency = 1
uiScaleLabel.TextColor3 = Color3.fromRGB(200, 255, 200)

local uiScaleBox = Instance.new("TextBox", uiScaleFrame)
uiScaleBox.Size = UDim2.new(0, 100, 0, 36)
uiScaleBox.Position = UDim2.new(1, -110, 0.5, -18)
uiScaleBox.Text = tostring(uiScale)
uiScaleBox.Font = Enum.Font.GothamBlack
uiScaleBox.TextSize = 18
uiScaleBox.BackgroundColor3 = Color3.fromRGB(45, 30, 25)
uiScaleBox.BackgroundTransparency = 0.15
uiScaleBox.TextColor3 = Color3.fromRGB(200, 255, 200)
Instance.new("UICorner", uiScaleBox).CornerRadius = UDim.new(0, 10)
addGradient(uiScaleBox, COLOR_GREEN, Color3.fromRGB(80, 180, 80))
neonStroke(uiScaleBox, COLOR_GREEN, 1.5, true)

uiScaleBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(uiScaleBox.Text)
        if num and num >= 0.5 and num <= 2 then
            uiScale = num
            main.Size = UDim2.new(0, 780 * uiScale, 0, 520 * uiScale)
            titleLabel.Size = UDim2.new(0, 220 * uiScale, 0, 60 * uiScale)
            titleLabel.TextSize = 32 * uiScale
            toggleBtn.Size = UDim2.new(0, 140 * uiScale, 0, 50 * uiScale)
            toggleBtn.TextSize = 20 * uiScale
        end
        uiScaleBox.Text = tostring(uiScale)
    end
end)

-- === Aimbot helpers ===
local function canSee(targetPart)
    if not wallCheckEnabled then return true end
    if not targetPart or not Camera then return false end
    local camPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local ray = workspace:Raycast(camPos, (targetPos - camPos).Unit * (targetPos - camPos).Magnitude, rayParams)
    if ray then
        return ray.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function getClosest()
    local closest, dist
    local scrCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if vis then
                local diff = Vector2.new(pos.X, pos.Y) - scrCenter
                local mag = diff.Magnitude
                local head = plr.Character:FindFirstChild("Head")
                local visible = head and canSee(head)
                if mag < aimFov and (not dist or mag < dist) and visible then
                    closest = plr
                    dist = mag
                end
            end
        end
    end
    return closest
end

local currentTarget = nil

RunService.RenderStepped:Connect(function()
    if aiming then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(camPos, headPos)
            currentTarget = target
        else
            currentTarget = nil
        end
    else
        currentTarget = nil
    end
end)

-- === FOV Circle (green) ===
local Drawing = Drawing or getgenv().Drawing
local fovCircle = Drawing and Drawing.new("Circle")
if fovCircle then
    fovCircle.Visible = false
    fovCircle.Color = COLOR_GREEN
    fovCircle.Thickness = 3
    fovCircle.NumSides = 80
    fovCircle.Filled = false
    fovCircle.Transparency = 0.4
    fovCircle.Radius = aimFov
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Visible = fovCircleVisible
        fovCircle.Radius = aimFov
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        fovCircle.Color = currentTarget and Color3.fromRGB(150, 255, 150) or COLOR_GREEN
        fovCircle.Transparency = fovCircleVisible and 0.4 or 0
    end
end)

-- === ESP Implementation ===
local function createESP(player)
    if player == LocalPlayer then return end

    -- ESP Box (Green)
    local box = {
        Top = Drawing and Drawing.new("Line"),
        Bottom = Drawing and Drawing.new("Line"),
        Left = Drawing and Drawing.new("Line"),
        Right = Drawing and Drawing.new("Line")
    }
    for _, line in pairs(box) do
        line.Color = COLOR_GREEN
        line.Thickness = 2
        line.Transparency = 0.7
        line.Visible = espBoxEnabled
    end
    espBoxes[player] = box

    -- ESP Name
    local name = Drawing and Drawing.new("Text")
    if name then
        name.Text = player.Name
        name.Size = 20
        name.Color = COLOR_GREEN
        name.Outline = true
        name.OutlineColor = Color3.fromRGB(0, 0, 0)
        name.Center = true
        name.Visible = espNameEnabled
        espNames[player] = name
    end

    -- ESP Skeleton (Green)
    local skeleton = {
        HeadToTorso = Drawing and Drawing.new("Line"),
        TorsoToLeftArm = Drawing and Drawing.new("Line"),
        TorsoToRightArm = Drawing and Drawing.new("Line"),
        TorsoToLeftLeg = Drawing and Drawing.new("Line"),
        TorsoToRightLeg = Drawing and Drawing.new("Line"),
        LeftArm = Drawing and Drawing.new("Line"),
        RightArm = Drawing and Drawing.new("Line"),
        LeftLeg = Drawing and Drawing.new("Line"),
        RightLeg = Drawing and Drawing.new("Line")
    }
    for _, line in pairs(skeleton) do
        line.Color = COLOR_GREEN
        line.Thickness = 2
        line.Transparency = 0.7
        line.Visible = espSkeletonEnabled
    end
    espSkeletons[player] = skeleton
end

-- Function to update friend pairs and lines
local function updateFriendLines()
    -- Clear existing lines
    for _, data in pairs(espFriendLines) do
        data.line:Remove()
    end
    espFriendLines = {}

    -- Get all players excluding local
    local players = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player)
        end
    end

    -- Create lines for each pair of players who are friends with each other
    for i = 1, #players - 1 do
        local player1 = players[i]
        for j = i + 1, #players do
            local player2 = players[j]
            -- Check if player1 and player2 are friends with each other
            if player1:IsFriendsWith(player2.UserId) and player2:IsFriendsWith(player1.UserId) then
                local line = Drawing.new("Line")
                line.Color = COLOR_GREEN
                line.Thickness = 2
                line.Transparency = 0.7
                line.Visible = espLineFriendsEnabled
                table.insert(espFriendLines, {line = line, player1 = player1, player2 = player2})
            end
        end
    end
end

-- Initial update
updateFriendLines()

local function updateESP()
    for player, box in pairs(espBoxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if vis then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 1000
                local width, height = 2 * scale, 3 * scale
                local screenPos = Vector2.new(pos.X, pos.Y)

                -- Update Box
                box.Top.From = Vector2.new(screenPos.X - width, screenPos.Y - height)
                box.Top.To = Vector2.new(screenPos.X + width, screenPos.Y - height)
                box.Bottom.From = Vector2.new(screenPos.X - width, screenPos.Y + height)
                box.Bottom.To = Vector2.new(screenPos.X + width, screenPos.Y + height)
                box.Left.From = Vector2.new(screenPos.X - width, screenPos.Y - height)
                box.Left.To = Vector2.new(screenPos.X - width, screenPos.Y + height)
                box.Right.From = Vector2.new(screenPos.X + width, screenPos.Y - height)
                box.Right.To = Vector2.new(screenPos.X + width, screenPos.Y + height)

                for _, line in pairs(box) do
                    line.Visible = espBoxEnabled
                end

                -- Update Name
                local name = espNames[player]
                if name then
                    name.Position = Vector2.new(screenPos.X, screenPos.Y - height - 30)
                    name.Visible = espNameEnabled
                end

                -- Update Skeleton
                local skeleton = espSkeletons[player]
                if skeleton then
                    local head = player.Character:FindFirstChild("Head")
                    local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
                    local leftArm = player.Character:FindFirstChild("LeftUpperArm") or player.Character:FindFirstChild("Left Arm")
                    local rightArm = player.Character:FindFirstChild("RightUpperArm") or player.Character:FindFirstChild("Right Arm")
                    local leftLeg = player.Character:FindFirstChild("LeftUpperLeg") or player.Character:FindFirstChild("Left Leg")
                    local rightLeg = player.Character:FindFirstChild("RightUpperLeg") or player.Character:FindFirstChild("Right Leg")
                    local lowerTorso = player.Character:FindFirstChild("LowerTorso")

                    if head and torso and leftArm and rightArm and leftLeg and rightLeg and lowerTorso then
                        local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
                        local torsoPos, torsoVis = Camera:WorldToViewportPoint(torso.Position)
                        local leftArmPos, leftArmVis = Camera:WorldToViewportPoint(leftArm.Position)
                        local rightArmPos, rightArmVis = Camera:WorldToViewportPoint(rightArm.Position)
                        local leftLegPos, leftLegVis = Camera:WorldToViewportPoint(leftLeg.Position)
                        local rightLegPos, rightLegVis = Camera:WorldToViewportPoint(rightLeg.Position)
                        local lowerTorsoPos, lowerTorsoVis = Camera:WorldToViewportPoint(lowerTorso.Position)

                        if headVis and torsoVis and leftArmVis and rightArmVis and leftLegVis and rightLegVis and lowerTorsoVis then
                            skeleton.HeadToTorso.From = Vector2.new(headPos.X, headPos.Y)
                            skeleton.HeadToTorso.To = Vector2.new(torsoPos.X, torsoPos.Y)
                            skeleton.TorsoToLeftArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            skeleton.TorsoToLeftArm.To = Vector2.new(leftArmPos.X, leftArmPos.Y)
                            skeleton.TorsoToRightArm.From = Vector2.new(torsoPos.X, torsoPos.Y)
                            skeleton.TorsoToRightArm.To = Vector2.new(rightArmPos.X, rightArmPos.Y)
                            skeleton.TorsoToLeftLeg.From = Vector2.new(lowerTorsoPos.X, lowerTorsoPos.Y)
                            skeleton.TorsoToLeftLeg.To = Vector2.new(leftLegPos.X, leftLegPos.Y)
                            skeleton.TorsoToRightLeg.From = Vector2.new(lowerTorsoPos.X, lowerTorsoPos.Y)
                            skeleton.TorsoToRightLeg.To = Vector2.new(rightLegPos.X, rightLegPos.Y)
                            skeleton.LeftArm.From = Vector2.new(leftArmPos.X, leftArmPos.Y)
                            skeleton.LeftArm.To = Vector2.new(leftArmPos.X, leftArmPos.Y + scale)
                            skeleton.RightArm.From = Vector2.new(rightArmPos.X, rightArmPos.Y)
                            skeleton.RightArm.To = Vector2.new(rightArmPos.X, rightArmPos.Y + scale)
                            skeleton.LeftLeg.From = Vector2.new(leftLegPos.X, leftLegPos.Y)
                            skeleton.LeftLeg.To = Vector2.new(leftLegPos.X, leftLegPos.Y + scale)
                            skeleton.RightLeg.From = Vector2.new(rightLegPos.X, rightLegPos.Y)
                            skeleton.RightLeg.To = Vector2.new(rightLegPos.X, rightLegPos.Y + scale)

                            for _, line in pairs(skeleton) do
                                line.Visible = espSkeletonEnabled
                            end
                        else
                            for _, line in pairs(skeleton) do
                                line.Visible = false
                            end
                        end
                    else
                        for _, line in pairs(skeleton) do
                            line.Visible = false
                        end
                    end
                end
            else
                for _, line in pairs(box) do
                    line.Visible = false
                end
                if espNames[player] then
                    espNames[player].Visible = false
                end
                if espSkeletons[player] then
                    for _, line in pairs(espSkeletons[player]) do
                        line.Visible = false
                    end
                end
            end
        else
            for _, line in pairs(box) do
                line.Visible = false
            end
            if espNames[player] then
                espNames[player].Visible = false
            end
            if espSkeletons[player] then
                for _, line in pairs(espSkeletons[player]) do
                    line.Visible = false
                end
            end
        end
    end

    -- Update friend pair lines
    if espLineFriendsEnabled then
        for _, data in pairs(espFriendLines) do
            local player1 = data.player1
            local player2 = data.player2
            local line = data.line
            local root1 = player1.Character and player1.Character:FindFirstChild("HumanoidRootPart")
            local root2 = player2.Character and player2.Character:FindFirstChild("HumanoidRootPart")
            if root1 and root2 then
                local pos1 = Camera:WorldToViewportPoint(root1.Position)
                local pos2 = Camera:WorldToViewportPoint(root2.Position)
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        end
    end
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    createESP(player)
    updateFriendLines()
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        for _, line in pairs(espBoxes[player]) do
            line:Remove()
        end
        espBoxes[player] = nil
    end
    if espNames[player] then
        espNames[player]:Remove()
        espNames[player] = nil
    end
    if espSkeletons[player] then
        for _, line in pairs(espSkeletons[player]) do
            line:Remove()
        end
        espSkeletons[player] = nil
    end
    updateFriendLines()
end)

-- Initial createESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

-- Update ESP every frame
RunService.RenderStepped:Connect(updateESP)

-- === Float implementation ===
RunService.RenderStepped:Connect(function()
    if floatEnabled then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if not root:FindFirstChild("FloatBP") then
                local bp = Instance.new("BodyPosition")
                bp.Name = "FloatBP"
                bp.MaxForce = Vector3.new(0, math.huge, 0)
                bp.P = 9000
                bp.D = 500
                bp.Parent = root
            end
            root.FloatBP.Position = Vector3.new(root.Position.X, floatHeight, root.Position.Z)
        end
    end
end)

-- === TPWalk implementation ===
RunService.Stepped:Connect(function(_, delta)
    if tpwalkEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * tpwalkSpeed * delta)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if floatEnabled then
        local root = char:WaitForChild("HumanoidRootPart")
        floatHeight = root.Position.Y
        floatHeightBox.Text = tostring(floatHeight)
    end
end)
