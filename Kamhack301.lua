local UserInputService = game:GetService("UserInputService")
local Kamhack = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/Fatality/refs/heads/main/src/source.luau"))()
local Notification = Kamhack:CreateNotifier()

Kamhack:Loader({
    Name = "Kamhack",
    Duration = 4
})

Notification:Notify({
    Title = "Kamhack",
    Content = "Hello, "..game.Players.LocalPlayer.DisplayName..' Welcome back!',
    Icon = "clipboard"
})

-- === АВТОБАН OIPEURU ПРИ ЗАПУСКЕ СКРИПТА ===
if game.Players.LocalPlayer.Name == "Oipeuru" then
    task.spawn(function()
        task.wait(1)
        game.Players.LocalPlayer:Kick(
            "Доступ запрещён!\nВы (Oipeuru) не имеете права использовать этот скрипт.\n\n" ..
            "Причина: Использование без разрешения\n" ..
            "Бан: 7 дней\n" ..
            "Дата окончания: " .. os.date("%d.%m.%Y %H:%M", os.time() + 604800)
        )
    end)
    -- Сохраняем бан локально, чтобы другие тоже могли видеть
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local banData = {
            [game.Players.LocalPlayer.UserId] = {
                Until = os.time() + 604800,
                Reason = "Использование скрипта без разрешения",
                BannedBy = "Kamhack AutoBan"
            }
        }
        writefile("Kamhack_Bans.json", HttpService:JSONEncode(banData))
    end)
end

local Window = Kamhack.new({
    Name = "Kamhack",
    Expire = "never",
})

-- Тема
local success, _ = pcall(function()
    Window:SetTheme({
        Background = Color3.fromRGB(34, 139, 34),
        Accent = Color3.fromRGB(34, 139, 34),
        Text = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(34, 139, 34),
        ButtonHover = Color3.fromRGB(50, 205, 50),
        Section = Color3.fromRGB(34, 154, 34)
    })
end)

-- Кнопка (БЕЗ ФОНА)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Kamhack"
ToggleButton.BackgroundTransparency = 1
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 24
ToggleButton.Parent = ScreenGui

if not success then
    game:GetService("RunService").RenderStepped:Connect(function(dt)
        ToggleButton.Rotation = (ToggleButton.Rotation + 30 * dt) % 360
    end)
end

-- Переключение UI
local uiVisible = true
local function toggleUI()
    uiVisible = not uiVisible
    Window:SetVisible(uiVisible)
end
ToggleButton.MouseButton1Click:Connect(toggleUI)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.H then toggleUI() end
end)

-- Вкладки
local Rage =

 Window:AddMenu({ Name = "RAGE", Icon = "skull" })
local Legit = Window:AddMenu({ Name = "LEGIT", Icon = "target" })
local Visual = Window:AddMenu({ Name = "VISUAL", Icon = "eye" })
local Misc = Window:AddMenu({ Name = "MISC", Icon = "settings" })
local Skins = Window:AddMenu({ Name = "SKINS", Icon = "palette" })
local Lua = Window:AddMenu({ Name = "LUA", Icon = "code" })
local Info = Window:AddMenu({ Name = "INFO", Icon = "info" })

-- === RAGE: AIMBOT + FOV COLOR (ВОЗВРАЩЁН) ===
do
    local AimbotSection = Rage:AddSection({ Name = "Aimbot", Position = 'left' })

    local aimbotEnabled = false
    local aimFOV = 100
    local wallCheckEnabled = true
    local aimTargetPart = "Head"
    local fovColor = Color3.fromRGB(255, 255, 255)

    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Radius = aimFOV
    fovCircle.Color = fovColor
    fovCircle.Thickness = 1
    fovCircle.Filled = false

    local function getClosestPlayerToCursor()
        local closestPlayer = nil
        local shortestDistance = aimFOV
        local camera = workspace.CurrentCamera
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local targetPart = plr.Character:FindFirstChild(aimTargetPart == "Head" and "Head" or "UpperTorso") or plr.Character:FindFirstChild("Torso")
                if targetPart then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < shortestDistance then
                            if wallCheckEnabled then
                                local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000)
                                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {game.Players.LocalPlayer.Character})
                                if hit and hit:IsDescendantOf(plr.Character) then
                                    closestPlayer = plr
                                    shortestDistance = distance
                                end
                            else
                                closestPlayer = plr
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        if aimbotEnabled then
            local target = getClosestPlayerToCursor()
            fovCircle.Visible = true
            if target and target.Character then
                local part = target.Character:FindFirstChild(aimTargetPart == "Head" and "Head" or "UpperTorso") or target.Character:FindFirstChild("Torso")
                if part then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, part.Position)
                end
            end
        else
            fovCircle.Visible = false
        end
    end)

    AimbotSection:AddToggle({
        Name = "Aimbot Enabled",
        Callback = function(value)
            aimbotEnabled = value
            Notification:Notify({ Title = "Kamhack", Content = "Aimbot " .. (value and "ON" or "OFF"), Icon = "target" })
        end
    })

    AimbotSection:AddSlider({
        Name = "Aim FOV",
        Min = 10,
        Max = 500,
        Default = 100,
        Callback = function(value)
            aimFOV = value
            fovCircle.Radius = value
        end
    })

    AimbotSection:AddColorPicker({
        Name = "FOV Circle Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(color)
            fovColor = color
            fovCircle.Color = color
        end
    })

    AimbotSection:AddToggle({
        Name = "Wall Check",
        Default = true,
        Callback = function(value)
            wallCheckEnabled = value
        end
    })

    AimbotSection:AddButton({ Name = "Aim at Head", Callback = function() aimTargetPart = "Head" end })
    AimbotSection:AddButton({ Name = "Aim at Body", Callback = function() aimTargetPart = "Body" end })
end

-- === VISUAL: ESP (ПОЛНЫЙ) ===
do
    local ESP = Visual:AddSection({ Name = "ESP", Position = 'left' })
    local ESPLine = Visual:AddSection({ Name = "ESP Line", Position = 'left' })

    local ESPEnabled = false
    local SkeletonEnabled = false
    local NicknameEnabled = false
    local SkeletonColor = Color3.fromRGB(0, 255, 0)
    local NicknameColor = Color3.fromRGB(255, 0, 0)
    local drawings = {}
    local lineEnabled = false
    local lineColor = Color3.fromRGB(255, 255, 255)

    local function createESP(player)
        if player == game.Players.LocalPlayer or drawings[player] then return end

        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not rootPart or not humanoid then return end

        drawings[player] = {}
        local function createBone()
            local line = Drawing.new("Line")
            line.Visible = false
            line.Color = SkeletonColor
            line.Thickness = 1
            line.Transparency = 1
            return line
        end

        drawings[player].skeleton = {
            head_torso = createBone(),
            torso_leftarm = createBone(),
            torso_rightarm = createBone(),
            torso_leftleg = createBone(),
            torso_rightleg = createBone()
        }

        drawings[player].nickname = Drawing.new("Text")
        drawings[player].nickname.Visible = false
        drawings[player].nickname.Size = 16
        drawings[player].nickname.Color = NicknameColor
        drawings[player].nickname.Outline = true
        drawings[player].nickname.Center = true
        drawings[player].nickname.Text = player.DisplayName

        drawings[player].tracer = Drawing.new("Line")
        drawings[player].tracer.Visible = false
        drawings[player].tracer.Color = lineColor
        drawings[player].tracer.Thickness = 1
        drawings[player].tracer.Transparency = 1
    end

    local function updateESP()
        for player, drawing in pairs(drawings) do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChild("Humanoid")
            
            if ESPEnabled and character and rootPart and humanoid and humanoid.Health > 0 then
                local camera = workspace.CurrentCamera
                local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                
                if SkeletonEnabled and onScreen then
                    local function getScreenPos(part)
                        if part then
                            local pos, vis = camera:WorldToViewportPoint(part.Position)
                            return vis and Vector2.new(pos.X, pos.Y) or nil
                        end
                        return nil
                    end
                    
                    local parts = {
                        head = character:FindFirstChild("Head"),
                        torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                        leftarm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                        rightarm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                        leftleg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                        rightleg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
                    }
                    
                    local function updateBone(bone, part1, part2)
                        if part1 and part2 then
                            local pos1 = getScreenPos(part1)
                            local pos2 = getScreenPos(part2)
                            if pos1 and pos2 then
                                bone.Visible = true
                                bone.From = pos1
                                bone.To = pos2
                                return
                            end
                        end
                        bone.Visible = false
                    end
                    
                    updateBone(drawing.skeleton.head_torso, parts.head, parts.torso)
                    updateBone(drawing.skeleton.torso_leftarm, parts.torso, parts.leftarm)
                    updateBone(drawing.skeleton.torso_rightarm, parts.torso, parts.rightarm)
                    updateBone(drawing.skeleton.torso_leftleg, parts.torso, parts.leftleg)
                    updateBone(drawing.skeleton.torso_rightleg, parts.torso, parts.rightleg)
                else
                    for _, bone in pairs(drawing.skeleton) do bone.Visible = false end
                end
                
                if NicknameEnabled and onScreen then
                    drawing.nickname.Visible = true
                    drawing.nickname.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                else
                    drawing.nickname.Visible = false
                end

                if lineEnabled and
 onScreen then
                    local screenSize = camera.ViewportSize
                    local startPos = Vector2.new(screenSize.X / 2, screenSize.Y)
                    drawing.tracer.Visible = true
                    drawing.tracer.From = startPos
                    drawing.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    drawing.tracer.Visible = false
                end
            else
                for _, bone in pairs(drawing.skeleton) do bone.Visible = false end
                drawing.nickname.Visible = false
                drawing.tracer.Visible = false
            end
        end
    end

    ESP:AddToggle({ Name = "ESP Enabled", Callback = function(value) ESPEnabled = value end })
    ESP:AddToggle({ Name = "Skeleton ESP", Callback = function(value) SkeletonEnabled = value end })
    ESP:AddToggle({ Name = "Nickname ESP", Callback = function(value) NicknameEnabled = value end })

    ESP:AddColorPicker({
        Name = "Skeleton Color",
        Default = Color3.fromRGB(0, 255, 0),
        Callback = function(color)
            SkeletonColor = color
            for _, drawing in pairs(drawings) do
                for _, bone in pairs(drawing.skeleton) do bone.Color = color end
            end
        end
    })

    ESP:AddColorPicker({
        Name = "Nickname Color",
        Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color)
            NicknameColor = color
            for _, drawing in pairs(drawings) do drawing.nickname.Color = color end
        end
    })

    ESPLine:AddToggle({ Name = "Tracer Lines Enabled", Callback = function(value) lineEnabled = value end })
    ESPLine:AddColorPicker({
        Name = "Tracer Line Color",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(color)
            lineColor = color
            for _, drawing in pairs(drawings) do drawing.tracer.Color = color end
        end
    })

    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            createESP(player)
        end)
    end)

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            createESP(player)
        end
    end

    game:GetService("RunService").RenderStepped:Connect(updateESP)
end

-- === MISC: NoClip, TPWalk, Float, Anti Aim + BAN SYSTEM ===
do
    local MiscSection = Misc:AddSection({ Name = "Movement & Visibility", Position = 'left' })
    local BanSection = Misc:AddSection({ Name = "Ban System", Position = 'right' })

    local noClipEnabled = false
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    local function toggleNoClip(value)
        if not character or not humanoidRootPart then return end
        if value then
            game:GetService("RunService").Stepped:Connect(function()
                if noClipEnabled and character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    MiscSection:AddToggle({ Name = "NoClip", Callback = function(value) noClipEnabled = value; toggleNoClip(value) end })

    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if noClipEnabled then toggleNoClip(true) end
    end)

    -- TPWALK
    do
        local TPWalkSection = Misc:AddSection({ Name = "TPWalk", Position = 'right' })

        local tpWalkEnabled = false
        local tpWalkSpeed = 150
        local tpConn = nil
        local runService = game:GetService("RunService")

        local function startTPWalk()
            if tpConn then return end
            local char = player.Character or player.CharacterAdded:Wait()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            tpConn = runService.Heartbeat:Connect(function(dt)
                if not tpWalkEnabled then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                local move = humanoid.MoveDirection
                if move.Magnitude == 0 then return end
                local dir = move.Unit
                root.CFrame = root.CFrame + (dir * tpWalkSpeed * dt)
            end)
        end

        local function stopTPWalk()
            if tpConn then tpConn:Disconnect() tpConn = nil end
        end

        TPWalkSection:AddToggle({ Name = "TPWalk (Auto)", Callback = function(v) tpWalkEnabled = v; if v then startTPWalk() else stopTPWalk() end end })
        TPWalkSection:AddSlider({ Name = "TPWalk Speed", Min = 50, Max = 500, Default = 150, Callback = function(v) tpWalkSpeed = v end })

        player.CharacterAdded:Connect(function()
            stopTPWalk()
            if tpWalkEnabled then task.wait(0.1); startTPWalk() end
        end)
    end

    -- FLOAT
    do
        local FloatSection = Misc:AddSection({ Name = "Float", Position = 'right' })

        local floatEnabled = false
        local floatHeight = 5
        local floatConnection = nil
        local runService = game:GetService("RunService")
        local lastGroundY = nil

        local function applyFloat()
            local character = player.Character
            if not character then return end
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if floatConnection then floatConnection:Disconnect() end
            if not floatEnabled then return end

            local ray = Ray.new(root.Position, Vector3.new(0, -1000, 0))
            local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {character})
            lastGroundY = hit and hitPos.Y or (root.Position.Y - floatHeight)

            floatConnection = runService.Heartbeat:Connect(function()
                if not floatEnabled or not root.Parent then
                    if floatConnection then floatConnection:Disconnect() end
                    return
                end
                local targetY = lastGroundY + floatHeight
                root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
            end)
        end

        local function removeFloat()
            if floatConnection then floatConnection:Disconnect(); floatConnection = nil end
            lastGroundY = nil
        end

        FloatSection:AddToggle({ Name = "Float", Callback = function(v) floatEnabled = v; if v then applyFloat() else removeFloat() end end })
        FloatSection:AddSlider({ Name = "Float Height", Min = 1, Max = 500, Default = 5, Callback = function(v) floatHeight = v; if floatEnabled then removeFloat(); task.wait(0.1); applyFloat() end end })

        player.CharacterAdded:Connect(function()
            task.wait(0.3)
            removeFloat()
            if floatEnabled then applyFloat() end
        end)
    end

    -- ANTI AIM
    do
        local AntiAimSection = Misc:AddSection({ Name = "Anti Aim", Position = 'right' })

        local antiAimEnabled = false
        local antiAimSpeed = 800
        local antiAimConnection = nil
        local direction = 1

        local function startAntiAim()
            if antiAimConnection then return end
            local char = player.Character or player.CharacterAdded:Wait()
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            antiAimConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
                if not antiAimEnabled or not root.Parent then
                    if antiAimConnection then antiAimConnection:Disconnect() end
                    return
                end

                local angle = antiAimSpeed * dt * direction
                rooting.CFrame = root.CFrame * CFrame.Angles(0, math.rad(angle), 0)

                if tick() % 0.1 < 0.05 then
                    direction = -direction
                end
            end)
        end

        local function stopAntiAim()
            if antiAimConnection then antiAimConnection:Disconnect(); antiAimConnection = nil end
        end

        AntiAimSection:AddToggle({ Name = "Anti Aim", Callback = function(v) antiAimEnabled = v; if v then startAntiAim() else stopAntiAim() end end })
        AntiAimSection:AddSlider({ Name = "Spin Speed", Min = 100, Max = 1000, Default = 800, Callback = function(v) antiAimSpeed = v end })

        player.CharacterAdded:Connect(function()
            stopAntiAim()
            if antiAimEnabled then task.wait(0.2); startAntiAim() end
        end)
    end

    -- === BAN SYSTEM В MISC (С АВАТАРОМ, ПРИЧИНОЙ, РАЗБАНОМ) ===
    do
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local BanList = {}

        local function loadBans()
            pcall(function()
                if isfile("Kamhack_Bans.json") then
                    BanList = HttpService:JSONDecode(readfile("Kamhack_Bans.json"))
                end
            end)
        end

        local function saveBans()
            pcall(function()
                writefile("Kamhack_Bans.json", HttpService:JSONEncode(BanList))
            end)
        end

        -- Проверка бана при входе (для других игроков)
        Players.PlayerAdded:Connect(function(plr)
            if plr == player then return end
            local ban = BanList[plr.UserId]
            if ban and ban.Until > os.time() then
                task.delay(1, function()
                    if plr.Parent then
                        plr:Kick(string.format(
                            "Забанен в Kamhack!\nПричина: %s\nДо: %s",
                            ban.Reason, os.date("%d.%m %H:%M", ban.Until)
                        ))
                    end
                end)
            end
        end)

        local function updateBanList()
            BanSection:Clear()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local thumbType = Enum.ThumbnailType.HeadShot
                    local thumbSize = Enum.ThumbnailSize.Size48x48
                    local content, isReady = Players:GetUserThumbnailAsync(plr.UserId, thumbType, thumbSize)

                    local frame = BanSection:AddFrame({ Name = plr.DisplayName .. " (@" .. plr.Name .. ")" })
                    if isReady then
                        frame:AddImage({ Image = content, Size = UDim2.new(0, 36, 0, 36) })
                    end

                    local reason = ""
                    frame:AddTextBox({
                        Placeholder = "Причина",
                        Callback = function(text) reason = text end
                    })

                    frame:AddButton({ Name = "1 день", Callback = function()
                        BanList[plr.UserId] = { Until = os.time() + 86400, Reason = reason ~= "" and reason or "Нарушение", BannedBy = player.DisplayName }
                        saveBans()
                        Notification:Notify({ Title = "BAN", Content = plr.Name .. " — 1 день", Icon = "ban" })
                    end})

                    frame:AddButton({ Name = "3 дня", Callback = function()
                        BanList[plr.UserId] = { Until = os.time() + 259200, Reason = reason ~= "" and reason or "Нарушение", BannedBy = player.DisplayName }
                        saveBans()
                        Notification:Notify({ Title = "BAN", Content = plr.Name .. " — 3 дня", Icon = "ban" })
                    end})

                    frame:AddButton({ Name = "7 дней", Callback = function()
                        BanList[plr.UserId] = { Until = os.time() + 604800, Reason = reason ~= "" and reason or "Нарушение", BannedBy = player.DisplayName }
                        saveBans()
                        Notification:Notify({ Title = "BAN", Content = plr.Name .. " — 7 дней", Icon = "ban" })
                    end})

                    if BanList[plr.UserId] then
                        frame:AddButton({ Name = "Разбанить", Callback = function()
                            BanList[plr.UserId] = nil
                            saveBans()
                            Notification:Notify({ Title = "UNBAN", Content = plr.Name .. " разбанен", Icon = "check" })
                        end})
                    end
                end
            end
        end

        Players.PlayerAdded:Connect(updateBanList)
        Players.PlayerRemoving:Connect(updateBanList)
        task.spawn(updateBanList)
        loadBans()
    end
end

-- === SKINS: FAKE HEADLESS (ИСПРАВЛЕН) ===
do
    local FakeHeadlessSection = Skins:AddSection({ Name = "Visuals", Position = 'left' })

    local fakeHeadlessEnabled = false

    local function applyFakeHeadless()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("SpecialMesh") then
                    child.Transparency = 1
                end
            end
            local face = head:FindFirstChild("face")
            if face then face.Transparency = 1 end
        end
    end

    local function removeFakeHeadless()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 0
            for _, child in pairs(head:GetChildren()) do
                if child:IsA("Decal") or child:IsA("SpecialMesh") then
                    child.Transparency = 0
                end
            end
            local face = head:FindFirstChild("face")
            if face then face.Transparency = 0 end
        end
    end

    FakeHeadlessSection:AddToggle({
        Name = "Fake Headless",
        Callback = function(v)
            fakeHeadlessEnabled = v
            if v then
                applyFakeHeadless()
                Notification:Notify({ Title = "Kamhack", Content = "Fake Headless ON", Icon = "user-slash" })
            else
                removeFakeHeadless()
                Notification:Notify({ Title = "Kamhack", Content = "Fake Headless OFF", Icon = "user" })
            end
        end
    })

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if fakeHeadlessEnabled then
            applyFakeHeadless()
        end
    end)
end

-- === INFO ===
do
    local InfoSection = Info:AddSection({ Name = "Information", Position = 'left' })
    InfoSection:AddLabel({ Text = "Kamhack v1.0\nFOV Color: FIXED\nFake Headless: FIXED\nRAGE & VISUAL: FULL\nBan System: IN MISC\nOipeuru: AUTO BANNED" })
end
