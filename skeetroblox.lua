-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Stop loops/subscriptions left by a previous execution of this script
local ALIVE = true
local AUTOSAVE_HOOK = nil
local function cleanupOldRun()
    ALIVE = false
    pcall(function() RunService:UnbindFromRenderStep("SkeetroThirdPerson") end)
    if AUTOSAVE_HOOK then pcall(AUTOSAVE_HOOK) end
end
if type(__CLEANTAB_CLEANUP) == "function" then
    pcall(__CLEANTAB_CLEANUP)
end
__CLEANTAB_CLEANUP = cleanupOldRun

for _, name in ipairs({"CleanTabGUI", "CleanTabESP", "CleanTabRainGui", "CleanTabWatermark"}) do
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

---------------------------------------------------------------------
-- MAIN WINDOW
---------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanTabGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Parent = ScreenGui
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
Main.BorderColor3 = Color3.fromRGB(40, 40, 45)
Main.BorderSizePixel = 1
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.Size = UDim2.new(0, 520, 0, 360)
Main.ClipsDescendants = true
Main.Active = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 3)

local LeftTab = Instance.new("Frame")
LeftTab.Parent = Main
LeftTab.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
LeftTab.BorderSizePixel = 0
LeftTab.Position = UDim2.new(0, 0, 0, 3)
LeftTab.Size = UDim2.new(0, 70, 1, -3)

local Divider = Instance.new("Frame")
Divider.Parent = Main
Divider.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0, 70, 0, 3)
Divider.Size = UDim2.new(0, 1, 1, -3)

local Selector = Instance.new("Frame")
Selector.Parent = LeftTab
Selector.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
Selector.BorderSizePixel = 0
Selector.Size = UDim2.new(0, 3, 0, 36)
Selector.Position = UDim2.new(0, 0, 0, 15)

local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 2)
selectorCorner.Parent = Selector

local ContentArea = Instance.new("Frame")
ContentArea.Parent = Main
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 85, 0, 15)
ContentArea.Size = UDim2.new(1, -100, 1, -25)

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------
local tabs = {}

local function createTab(tabName)
    local tab = Instance.new("Frame")
    tab.Parent = ContentArea
    tab.BackgroundTransparency = 1
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.Visible = false

    local header = Instance.new("TextLabel")
    header.Parent = tab
    header.BackgroundTransparency = 1
    header.Position = UDim2.new(0, 5, 0, 0)
    header.Size = UDim2.new(1, -10, 0, 24)
    header.Font = Enum.Font.GothamBold
    header.Text = tabName:upper()
    header.TextColor3 = Color3.fromRGB(220, 220, 225)
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left

    local body = Instance.new("ScrollingFrame")
    body.Parent = tab
    body.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    body.BorderSizePixel = 0
    body.Position = UDim2.new(0, 0, 0, 30)
    body.Size = UDim2.new(1, 0, 1, -35)
    body.ScrollBarThickness = 3
    body.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    body.CanvasSize = UDim2.new(0, 0, 0, 0)
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = body

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(35, 35, 40)
    bs.Thickness = 1
    bs.Parent = body

    local layout = Instance.new("UIListLayout")
    layout.Parent = body
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local padding = Instance.new("UIPadding")
    padding.Parent = body
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)

    tabs[tabName] = {Frame = tab, Body = body, Header = header}
    return tabs[tabName]
end

local legitTab = createTab("Legit")
local rageTab = createTab("Rage")
local visualsTab = createTab("Visuals")
local miscTab = createTab("Misc")

local tabButtons = {
    {name = "Legit", icon = "rbxassetid://3797708309"},
    {name = "Rage", icon = "rbxassetid://3797238587"},
    {name = "Visuals", icon = "rbxassetid://3797979749"},
    {name = "Misc", icon = "rbxassetid://3797614110"}
}

local currentTab = "Legit"
local buttonInstances = {}

local function switchTab(tabName, targetY)
    currentTab = tabName
    for name, data in pairs(tabs) do
        data.Frame.Visible = (name == tabName)
    end
    for name, btn in pairs(buttonInstances) do
        local isActive = (name == tabName)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            ImageColor3 = isActive and Color3.fromRGB(240, 240, 255) or Color3.fromRGB(120, 120, 130)
        }):Play()
    end
    TweenService:Create(Selector, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, targetY)
    }):Play()
end

for i, tabInfo in ipairs(tabButtons) do
    local posY = 15 + (i - 1) * 52
    local btn = Instance.new("ImageButton")
    btn.Parent = LeftTab
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(0.5, -15, 0, posY + 3)
    btn.Image = tabInfo.icon
    btn.ImageColor3 = (tabInfo.name == "Legit") and Color3.fromRGB(240, 240, 255) or Color3.fromRGB(120, 120, 130)

    buttonInstances[tabInfo.name] = btn

    btn.MouseEnter:Connect(function()
        if currentTab ~= tabInfo.name then
            TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(180, 180, 195)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= tabInfo.name then
            TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(120, 120, 130)}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() switchTab(tabInfo.name, posY) end)
end

switchTab("Legit", 15)

---------------------------------------------------------------------
-- TOAST
---------------------------------------------------------------------
local toastHolder = Instance.new("Frame")
toastHolder.Parent = ScreenGui
toastHolder.BackgroundTransparency = 1
toastHolder.Position = UDim2.new(0.5, -130, 1, -60)
toastHolder.Size = UDim2.new(0, 260, 0, 40)
toastHolder.ZIndex = 500

local toastLayout = Instance.new("UIListLayout")
toastLayout.Parent = toastHolder
toastLayout.Padding = UDim.new(0, 6)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function toast(text, color)
    local t = Instance.new("TextLabel")
    t.Parent = toastHolder
    t.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    t.BackgroundTransparency = 0.1
    t.BorderSizePixel = 0
    t.Size = UDim2.new(0, 220, 0, 28)
    t.Font = Enum.Font.GothamBold
    t.Text = text
    t.TextColor3 = color or Color3.fromRGB(240, 240, 240)
    t.TextSize = 12
    t.ZIndex = 501

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = t

    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = 1
    s.Parent = t

    t.BackgroundTransparency = 1
    TweenService:Create(t, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()

    task.delay(1.8, function()
        local anim = TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1})
        anim:Play()
        anim.Completed:Connect(function() t:Destroy() end)
    end)
end

---------------------------------------------------------------------
-- GUI COLORS
---------------------------------------------------------------------
local guiColors = {
    Accent     = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(18, 18, 20),
    Panel      = Color3.fromRGB(14, 14, 16),
    Text       = Color3.fromRGB(230, 230, 235),
}

local function applyGuiColors()
    Main.BackgroundColor3 = guiColors.Background
    Main.BorderColor3     = guiColors.Panel
    TopBar.BackgroundColor3 = guiColors.Accent
    LeftTab.BackgroundColor3 = guiColors.Panel
    Selector.BackgroundColor3 = guiColors.Accent
end
applyGuiColors()

---------------------------------------------------------------------
-- SHARED STATE
---------------------------------------------------------------------
local espSettings = {
    Box = false,       BoxColor       = Color3.fromRGB(255, 255, 255),
    HeadHitbox = false, HeadColor     = Color3.fromRGB(255, 60, 60),
    Health = false,    HealthColor    = Color3.fromRGB(80, 220, 120),
    Avatar = false,    AvatarColor    = Color3.fromRGB(255, 255, 255),
    Name = false,      NameColor      = Color3.fromRGB(240, 240, 255),
    Skeleton = false,  SkeletonColor  = Color3.fromRGB(255, 255, 255),
    TeamCheck = false,
    SelfHead = false,
    TargetHUD = false,
    MaxDistance = 1000,
}

local worldState = {
    ColorEnabled = false,
    Color = Color3.fromRGB(255, 255, 255),
    RainEnabled = false,
    RainColor = Color3.fromRGB(180, 210, 255),
    NightEnabled = false,
}

local velocityEnabled = false
local velocitySpeed = 10
local maxSpeed = 100
local updateToggle, sliderValueLabel, sliderFill

local flyEnabled = false
local flySpeed = 60
local flyMaxSpeed = 400
local flyMethod = "CFrame"
local methodButtons = {}
local setFlyMethod, updateFlyToggle, flySpeedValue, flySliderFill

local aimbotSettings = {
    Enabled = false,
    VisibleCheck = true,
    TeamCheck = false,
    FOV = 150,
    Smoothness = 1,
    TargetPart = "Head",
    Keybind = nil,
    AimMode = "Normal",
}
local updateAimToggle, setVisCheck, updateBindLabel, fovValue, fovFill, fovMax
local smoothValue, smoothFill, updateSmoothUI, targetButtons, setTargetPart
local setAimTeam
local setAimMode
local aimFeedPos = nil
local aimbotTargetPlr = nil
local aimbotTargetAt = 0

-- triggerbot
local trigEnabled = false
local trigDelay = 100
local trigTeamCheck = true
local trigVisCheck = true
local updateTrigToggle, setTrigTeam, setTrigVis, trigDelayUI

-- spinbot
local spinEnabled = false
local spinSpeed = 360
local updateSpinToggle, spinSpeedUI

-- anti-aim
local aaEnabled = false
local aaMode = "Back"
local aaJitter = 60
local aaRate = 10
local updateAAToggle, setAAMode, aaUI

-- ghost
local ghostEnabled = false
local ghostDepth = 4
local ghostBaseY = nil
local updateGhostToggle, ghostDepthUI

-- generic keybinds + deferred restore
local keybindFeatures = nil
local refreshKeybindLabels = nil
local applyConfigData = nil
local RESTORE_DATA = nil

local tpEnabled = false
local tpDistance = 12
local tpMinDistance, tpMaxDistance = 3, 50
local updateTPToggle, tpValueLabel, tpSliderFill, updateTPDistanceUI

local checkboxSetters = {}
local colorPickerSetters = {}
local espObjects = {}
local avatarCache = {}

---------------------------------------------------------------------
-- UI HELPERS
---------------------------------------------------------------------
local function createCheckbox(parent, labelText, defaultState, callback)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 38)

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local rs = Instance.new("UIStroke")
    rs.Color = Color3.fromRGB(36, 36, 42)
    rs.Thickness = 1
    rs.Parent = row

    local label = Instance.new("TextLabel")
    label.Parent = row
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = guiColors.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextButton")
    box.Parent = row
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    box.BorderSizePixel = 0
    box.Position = UDim2.new(1, -40, 0.5, -10)
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Text = ""
    box.AutoButtonColor = false

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = box

    local bs = Instance.new("UIStroke")
    bs.Color = Color3.fromRGB(60, 60, 70)
    bs.Thickness = 1
    bs.Parent = box

    local check = Instance.new("Frame")
    check.Parent = box
    check.BackgroundColor3 = guiColors.Accent
    check.BorderSizePixel = 0
    check.AnchorPoint = Vector2.new(0.5, 0.5)
    check.Position = UDim2.new(0.5, 0, 0.5, 0)
    check.Size = UDim2.new(0, 10, 0, 10)
    check.Visible = defaultState

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 2)
    cc.Parent = check

    local state = defaultState
    local function setState(newState)
        state = newState
        check.Visible = state
        TweenService:Create(box, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(45, 55, 90) or Color3.fromRGB(35, 35, 40)
        }):Play()
        callback(state)
    end

    box.MouseButton1Click:Connect(function() setState(not state) end)
    callback(state)
    checkboxSetters[labelText] = setState
    return row
end

local PALETTE = {
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(230, 70, 70),
    Color3.fromRGB(80, 220, 120),  Color3.fromRGB(80, 105, 240),
    Color3.fromRGB(80, 220, 220),  Color3.fromRGB(240, 220, 80),
    Color3.fromRGB(240, 150, 60),  Color3.fromRGB(240, 120, 200),
    Color3.fromRGB(170, 80, 240),  Color3.fromRGB(150, 150, 150),
    Color3.fromRGB(60, 60, 60),    Color3.fromRGB(15, 15, 15),
}

local function createColorPicker(parent, labelText, initialColor, callback)
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 0, 70)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = container

    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(36, 36, 42)
    cs.Thickness = 1
    cs.Parent = container

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 14, 0, 6)
    label.Size = UDim2.new(1, -50, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = guiColors.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame")
    preview.Parent = container
    preview.Position = UDim2.new(1, -34, 0, 5)
    preview.Size = UDim2.new(0, 22, 0, 22)
    preview.BackgroundColor3 = initialColor
    preview.BorderSizePixel = 0

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(1, 0)
    pc.Parent = preview

    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(90, 90, 100)
    ps.Thickness = 1
    ps.Parent = preview

    local paletteRow = Instance.new("Frame")
    paletteRow.Parent = container
    paletteRow.BackgroundTransparency = 1
    paletteRow.Position = UDim2.new(0, 12, 0, 34)
    paletteRow.Size = UDim2.new(1, -24, 0, 26)

    local pLayout = Instance.new("UIListLayout")
    pLayout.Parent = paletteRow
    pLayout.FillDirection = Enum.FillDirection.Horizontal
    pLayout.Padding = UDim.new(0, 5)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local selected = initialColor
    local swatches = {}

    local function updateSelected()
        for _, sw in ipairs(swatches) do
            if sw.Color == selected then
                sw.Stroke.Color = Color3.fromRGB(255, 255, 255)
                sw.Stroke.Thickness = 2
            else
                sw.Stroke.Color = Color3.fromRGB(60, 60, 70)
                sw.Stroke.Thickness = 1
            end
        end
        preview.BackgroundColor3 = selected
    end

    for _, col in ipairs(PALETTE) do
        local sw = Instance.new("TextButton")
        sw.Parent = paletteRow
        sw.Size = UDim2.new(0, 18, 0, 18)
        sw.BackgroundColor3 = col
        sw.BorderSizePixel = 0
        sw.Text = ""
        sw.AutoButtonColor = false

        local swc = Instance.new("UICorner")
        swc.CornerRadius = UDim.new(1, 0)
        swc.Parent = sw

        local sws = Instance.new("UIStroke")
        sws.Color = Color3.fromRGB(60, 60, 70)
        sws.Thickness = 1
        sws.Parent = sw

        sw.MouseButton1Click:Connect(function()
            selected = col
            updateSelected()
            callback(col)
        end)

        table.insert(swatches, {Color = col, Button = sw, Stroke = sws})
    end

    updateSelected()

    colorPickerSetters[labelText] = function(c)
        selected = c
        updateSelected()
        callback(c)
    end
    return container
end

---------------------------------------------------------------------
-- KEYBIND SERIALIZATION HELPERS
---------------------------------------------------------------------
local function serializeKeybind(kb)
    if kb == nil then return "" end
    if typeof(kb) == "EnumItem" then
        if kb.EnumType == Enum.KeyCode then return "KC:" .. kb.Name end
        if kb.EnumType == Enum.UserInputType then return "UI:" .. kb.Name end
    end
    return ""
end

local function deserializeKeybind(str)
    if not str or str == "" then return nil end
    local prefix, name = str:match("^(%w+):(.+)$")
    if not prefix or not name then return nil end
    if prefix == "KC" then
        for _, kc in ipairs(Enum.KeyCode:GetEnumItems()) do
            if kc.Name == name then return kc end
        end
    elseif prefix == "UI" then
        for _, ui in ipairs(Enum.UserInputType:GetEnumItems()) do
            if ui.Name == name then return ui end
        end
    end
    return nil
end

---------------------------------------------------------------------
-- VELOCITY CARD (Rage)
---------------------------------------------------------------------
do
    local speedCard = Instance.new("Frame")
    speedCard.Parent = rageTab.Body
    speedCard.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    speedCard.BorderSizePixel = 0
    speedCard.Size = UDim2.new(1, 0, 0, 110)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = speedCard

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = speedCard

    local title = Instance.new("TextLabel")
    title.Parent = speedCard
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Velocity Speed"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = speedCard
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc2 = Instance.new("UICorner")
    cc2.CornerRadius = UDim.new(1, 0)
    cc2.Parent = circle

    updateToggle = function(state)
        velocityEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function() updateToggle(not velocityEnabled) end)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = speedCard
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Position = UDim2.new(0, 14, 0, 46)
    sliderLabel.Size = UDim2.new(0, 120, 0, 18)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.Text = "Amount"
    sliderLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    sliderLabel.TextSize = 12
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    sliderValueLabel = Instance.new("TextLabel")
    sliderValueLabel.Parent = speedCard
    sliderValueLabel.BackgroundTransparency = 1
    sliderValueLabel.Position = UDim2.new(1, -64, 0, 46)
    sliderValueLabel.Size = UDim2.new(0, 50, 0, 18)
    sliderValueLabel.Font = Enum.Font.GothamMedium
    sliderValueLabel.Text = tostring(velocitySpeed)
    sliderValueLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    sliderValueLabel.TextSize = 12
    sliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton")
    track.Parent = speedCard
    track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 14, 0, 75)
    track.Size = UDim2.new(1, -28, 0, 8)
    track.Text = ""
    track.AutoButtonColor = false

    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = track

    sliderFill = Instance.new("Frame")
    sliderFill.Parent = track
    sliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(velocitySpeed / maxSpeed, 0, 1, 0)

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = sliderFill

    local knob = Instance.new("Frame")
    knob.Parent = sliderFill
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    knob.BorderSizePixel = 0
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local dragging = false
    local function setVal(inputX)
        local relX = math.clamp(inputX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct = relX / track.AbsoluteSize.X
        local val = math.clamp(math.round(pct * maxSpeed), 1, maxSpeed)
        velocitySpeed = val
        sliderValueLabel.Text = tostring(val)
        TweenService:Create(sliderFill, TweenInfo.new(0.08), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setVal(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setVal(input.Position.X) end
    end)

    RunService.Heartbeat:Connect(function()
        if not ALIVE then return end
        if not velocityEnabled then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if hum.MoveDirection.Magnitude > 0 then
            local md = hum.MoveDirection.Unit
            local baseSpeed = math.max(hum.WalkSpeed, 16)
            local target = baseSpeed + velocitySpeed * 1.5
            hrp.AssemblyLinearVelocity = Vector3.new(md.X * target, hrp.AssemblyLinearVelocity.Y, md.Z * target)
        end
    end)
end

---------------------------------------------------------------------
-- AIMBOT CARD (Legit)
---------------------------------------------------------------------
do
    local card = Instance.new("Frame")
    card.Parent = legitTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 294)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Aimbot"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle

    updateAimToggle = function(state)
        aimbotSettings.Enabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    end

    toggleBtn.MouseButton1Click:Connect(function() updateAimToggle(not aimbotSettings.Enabled) end)

    -- Visible check
    local visRow = Instance.new("Frame")
    visRow.Parent = card
    visRow.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    visRow.BorderSizePixel = 0
    visRow.Position = UDim2.new(0, 14, 0, 42)
    visRow.Size = UDim2.new(0.5, -17, 0, 26)

    local vrc = Instance.new("UICorner")
    vrc.CornerRadius = UDim.new(0, 4)
    vrc.Parent = visRow

    local visLbl = Instance.new("TextLabel")
    visLbl.Parent = visRow
    visLbl.BackgroundTransparency = 1
    visLbl.Position = UDim2.new(0, 10, 0, 0)
    visLbl.Size = UDim2.new(1, -40, 1, 0)
    visLbl.Font = Enum.Font.Gotham
    visLbl.Text = "Visible Check"
    visLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    visLbl.TextSize = 12
    visLbl.TextXAlignment = Enum.TextXAlignment.Left

    local visBox = Instance.new("TextButton")
    visBox.Parent = visRow
    visBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    visBox.BorderSizePixel = 0
    visBox.Position = UDim2.new(1, -28, 0.5, -8)
    visBox.Size = UDim2.new(0, 16, 0, 16)
    visBox.Text = ""
    visBox.AutoButtonColor = false

    local vbc = Instance.new("UICorner")
    vbc.CornerRadius = UDim.new(0, 3)
    vbc.Parent = visBox

    local visCheck = Instance.new("Frame")
    visCheck.Parent = visBox
    visCheck.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    visCheck.BorderSizePixel = 0
    visCheck.AnchorPoint = Vector2.new(0.5, 0.5)
    visCheck.Position = UDim2.new(0.5, 0, 0.5, 0)
    visCheck.Size = UDim2.new(0, 8, 0, 8)
    visCheck.Visible = true

    local vcc = Instance.new("UICorner")
    vcc.CornerRadius = UDim.new(0, 2)
    vcc.Parent = visCheck

    setVisCheck = function(state)
        aimbotSettings.VisibleCheck = state
        visCheck.Visible = state
        visBox.BackgroundColor3 = state and Color3.fromRGB(45, 55, 90) or Color3.fromRGB(35, 35, 40)
    end
    setVisCheck(true)
    visBox.MouseButton1Click:Connect(function() setVisCheck(not aimbotSettings.VisibleCheck) end)

    -- Team check (aim)
    local teamRow = Instance.new("Frame")
    teamRow.Parent = card
    teamRow.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    teamRow.BorderSizePixel = 0
    teamRow.Position = UDim2.new(0.5, 3, 0, 42)
    teamRow.Size = UDim2.new(0.5, -17, 0, 26)

    local tmrc = Instance.new("UICorner")
    tmrc.CornerRadius = UDim.new(0, 4)
    tmrc.Parent = teamRow

    local teamLbl = Instance.new("TextLabel")
    teamLbl.Parent = teamRow
    teamLbl.BackgroundTransparency = 1
    teamLbl.Position = UDim2.new(0, 10, 0, 0)
    teamLbl.Size = UDim2.new(1, -40, 1, 0)
    teamLbl.Font = Enum.Font.Gotham
    teamLbl.Text = "Team Check"
    teamLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    teamLbl.TextSize = 11
    teamLbl.TextXAlignment = Enum.TextXAlignment.Left

    local teamBox = Instance.new("TextButton")
    teamBox.Parent = teamRow
    teamBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    teamBox.BorderSizePixel = 0
    teamBox.Position = UDim2.new(1, -28, 0.5, -8)
    teamBox.Size = UDim2.new(0, 16, 0, 16)
    teamBox.Text = ""
    teamBox.AutoButtonColor = false

    local tmbc = Instance.new("UICorner")
    tmbc.CornerRadius = UDim.new(0, 3)
    tmbc.Parent = teamBox

    local teamMark = Instance.new("Frame")
    teamMark.Parent = teamBox
    teamMark.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    teamMark.BorderSizePixel = 0
    teamMark.AnchorPoint = Vector2.new(0.5, 0.5)
    teamMark.Position = UDim2.new(0.5, 0, 0.5, 0)
    teamMark.Size = UDim2.new(0, 8, 0, 8)
    teamMark.Visible = false

    local tmmc = Instance.new("UICorner")
    tmmc.CornerRadius = UDim.new(0, 2)
    tmmc.Parent = teamMark

    setAimTeam = function(state)
        aimbotSettings.TeamCheck = state
        teamMark.Visible = state
        teamBox.BackgroundColor3 = state and Color3.fromRGB(45, 55, 90) or Color3.fromRGB(35, 35, 40)
    end
    setAimTeam(false)
    teamBox.MouseButton1Click:Connect(function() setAimTeam(not aimbotSettings.TeamCheck) end)

    -- Keybind
    local keyRow = Instance.new("Frame")
    keyRow.Parent = card
    keyRow.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    keyRow.BorderSizePixel = 0
    keyRow.Position = UDim2.new(0, 14, 0, 74)
    keyRow.Size = UDim2.new(1, -28, 0, 26)

    local krc = Instance.new("UICorner")
    krc.CornerRadius = UDim.new(0, 4)
    krc.Parent = keyRow

    local keyLbl = Instance.new("TextLabel")
    keyLbl.Parent = keyRow
    keyLbl.BackgroundTransparency = 1
    keyLbl.Position = UDim2.new(0, 10, 0, 0)
    keyLbl.Size = UDim2.new(1, -110, 1, 0)
    keyLbl.Font = Enum.Font.Gotham
    keyLbl.Text = "Toggle Keybind"
    keyLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    keyLbl.TextSize = 12
    keyLbl.TextXAlignment = Enum.TextXAlignment.Left

    local bindBtn = Instance.new("TextButton")
    bindBtn.Parent = keyRow
    bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    bindBtn.BorderSizePixel = 0
    bindBtn.Position = UDim2.new(1, -96, 0.5, -10)
    bindBtn.Size = UDim2.new(0, 86, 0, 20)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Text = "NONE"
    bindBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    bindBtn.TextSize = 11
    bindBtn.AutoButtonColor = false

    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 4)
    bbc.Parent = bindBtn

    local bindReset = Instance.new("TextButton")
    bindReset.Parent = keyRow
    bindReset.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    bindReset.BorderSizePixel = 0
    bindReset.Position = UDim2.new(1, -8, 0.5, -8)
    bindReset.Size = UDim2.new(0, 16, 0, 16)
    bindReset.Font = Enum.Font.GothamBold
    bindReset.Text = "x"
    bindReset.TextColor3 = Color3.fromRGB(240, 200, 200)
    bindReset.TextSize = 11
    bindReset.AutoButtonColor = false

    local brc = Instance.new("UICorner")
    brc.CornerRadius = UDim.new(0, 3)
    brc.Parent = bindReset

    local bindMode = false
    local bindCooldown = 0

    updateBindLabel = function()
        if aimbotSettings.Keybind == nil then
            bindBtn.Text = "NONE"
        elseif typeof(aimbotSettings.Keybind) == "EnumItem" then
            if aimbotSettings.Keybind.EnumType == Enum.KeyCode then
                bindBtn.Text = aimbotSettings.Keybind.Name
            elseif aimbotSettings.Keybind.EnumType == Enum.UserInputType then
                local names = {
                    [Enum.UserInputType.MouseButton1] = "M1",
                    [Enum.UserInputType.MouseButton2] = "M2",
                    [Enum.UserInputType.MouseButton3] = "M3",
                }
                bindBtn.Text = names[aimbotSettings.Keybind] or aimbotSettings.Keybind.Name
            else
                bindBtn.Text = aimbotSettings.Keybind.Name
            end
        else
            bindBtn.Text = "?"
        end
    end

    bindBtn.MouseButton1Click:Connect(function()
        bindMode = not bindMode
        if bindMode then
            bindBtn.Text = "..."
            bindBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 90)
            bindCooldown = tick() + 0.25  -- не даём сразу же забиндить M1 от этого клика
        else
            updateBindLabel()
            bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        end
    end)

    bindReset.MouseButton1Click:Connect(function()
        aimbotSettings.Keybind = nil
        bindMode = false
        bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        updateBindLabel()
    end)

    -- Bind capture + Toggle logic
    UserInputService.InputBegan:Connect(function(input, gp)
        if not ALIVE then return end
        -- Режим бинда
        if bindMode then
            if tick() < bindCooldown then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                aimbotSettings.Keybind = input.KeyCode
                bindMode = false
                bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                updateBindLabel()
                toast("Bind: " .. input.KeyCode.Name, Color3.fromRGB(120, 220, 120))
            elseif input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.MouseButton2
                or input.UserInputType == Enum.UserInputType.MouseButton3 then
                aimbotSettings.Keybind = input.UserInputType
                bindMode = false
                bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                updateBindLabel()
                toast("Bind: " .. input.UserInputType.Name, Color3.fromRGB(120, 220, 120))
            end
            return
        end

        -- Toggle logic: если есть бинд — нажатие переключает аимбот
        local kb = aimbotSettings.Keybind
        if kb == nil then return end

        local matched = false
        if typeof(kb) == "EnumItem" then
            if kb.EnumType == Enum.KeyCode and input.KeyCode == kb then
                matched = true
            elseif kb.EnumType == Enum.UserInputType and input.UserInputType == kb then
                matched = true
            end
        end

        if matched then
            updateAimToggle(not aimbotSettings.Enabled)
        end
    end)

    -- FOV slider
    local fovLbl = Instance.new("TextLabel")
    fovLbl.Parent = card
    fovLbl.BackgroundTransparency = 1
    fovLbl.Position = UDim2.new(0, 14, 0, 106)
    fovLbl.Size = UDim2.new(0, 120, 0, 16)
    fovLbl.Font = Enum.Font.Gotham
    fovLbl.Text = "FOV (px)"
    fovLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    fovLbl.TextSize = 11
    fovLbl.TextXAlignment = Enum.TextXAlignment.Left

    fovValue = Instance.new("TextLabel")
    fovValue.Parent = card
    fovValue.BackgroundTransparency = 1
    fovValue.Position = UDim2.new(1, -64, 0, 106)
    fovValue.Size = UDim2.new(0, 50, 0, 16)
    fovValue.Font = Enum.Font.GothamMedium
    fovValue.Text = tostring(aimbotSettings.FOV)
    fovValue.TextColor3 = Color3.fromRGB(240, 240, 240)
    fovValue.TextSize = 11
    fovValue.TextXAlignment = Enum.TextXAlignment.Right

    local fovTrack = Instance.new("TextButton")
    fovTrack.Parent = card
    fovTrack.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    fovTrack.BorderSizePixel = 0
    fovTrack.Position = UDim2.new(0, 14, 0, 124)
    fovTrack.Size = UDim2.new(1, -28, 0, 4)
    fovTrack.Text = ""
    fovTrack.AutoButtonColor = false

    local ftc = Instance.new("UICorner")
    ftc.CornerRadius = UDim.new(1, 0)
    ftc.Parent = fovTrack

    fovMax = 400
    fovFill = Instance.new("Frame")
    fovFill.Parent = fovTrack
    fovFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    fovFill.BorderSizePixel = 0
    fovFill.Size = UDim2.new(aimbotSettings.FOV / fovMax, 0, 1, 0)

    local ffc = Instance.new("UICorner")
    ffc.CornerRadius = UDim.new(1, 0)
    ffc.Parent = fovFill

    local fovDragging = false
    local function setFov(inputX)
        local relX = math.clamp(inputX - fovTrack.AbsolutePosition.X, 0, fovTrack.AbsoluteSize.X)
        local pct = relX / fovTrack.AbsoluteSize.X
        local val = math.clamp(math.round(pct * fovMax), 20, fovMax)
        aimbotSettings.FOV = val
        fovValue.Text = tostring(val)
        TweenService:Create(fovFill, TweenInfo.new(0.08), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
    end
    fovTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            fovDragging = true
            setFov(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then fovDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if fovDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFov(input.Position.X)
        end
    end)

    -- Target body part
    local partLbl = Instance.new("TextLabel")
    partLbl.Parent = card
    partLbl.BackgroundTransparency = 1
    partLbl.Position = UDim2.new(0, 14, 0, 140)
    partLbl.Size = UDim2.new(0, 160, 0, 16)
    partLbl.Font = Enum.Font.Gotham
    partLbl.Text = "Aim At"
    partLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    partLbl.TextSize = 11
    partLbl.TextXAlignment = Enum.TextXAlignment.Left

    local partRow = Instance.new("Frame")
    partRow.Parent = card
    partRow.BackgroundTransparency = 1
    partRow.Position = UDim2.new(0, 12, 0, 158)
    partRow.Size = UDim2.new(1, -24, 0, 26)

    local prLayout = Instance.new("UIListLayout")
    prLayout.Parent = partRow
    prLayout.FillDirection = Enum.FillDirection.Horizontal
    prLayout.Padding = UDim.new(0, 6)
    prLayout.SortOrder = Enum.SortOrder.LayoutOrder

    targetButtons = {}
    local PART_CHOICES = {
        {key = "Head",  label = "HEAD"},
        {key = "Torso", label = "TORSO"},
        {key = "Root",  label = "ROOT"},
    }
    setTargetPart = function(key)
        aimbotSettings.TargetPart = key
        for k, btn in pairs(targetButtons) do
            if k == key then
                btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                btn.TextColor3 = Color3.fromRGB(30, 30, 30)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end
    end
    for _, choice in ipairs(PART_CHOICES) do
        local pb = Instance.new("TextButton")
        pb.Parent = partRow
        pb.Size = UDim2.new(1 / 3, -14, 1, 0)
        pb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        pb.BorderSizePixel = 0
        pb.Font = Enum.Font.GothamBold
        pb.Text = choice.label
        pb.TextColor3 = Color3.fromRGB(200, 200, 210)
        pb.TextSize = 11
        pb.AutoButtonColor = false
        local pbc = Instance.new("UICorner")
        pbc.CornerRadius = UDim.new(0, 4)
        pbc.Parent = pb
        targetButtons[choice.key] = pb
        pb.MouseButton1Click:Connect(function() setTargetPart(choice.key) end)
    end
    setTargetPart(aimbotSettings.TargetPart)

    -- Smoothness slider
    local smoothLbl = Instance.new("TextLabel")
    smoothLbl.Parent = card
    smoothLbl.BackgroundTransparency = 1
    smoothLbl.Position = UDim2.new(0, 14, 0, 194)
    smoothLbl.Size = UDim2.new(0, 140, 0, 16)
    smoothLbl.Font = Enum.Font.Gotham
    smoothLbl.Text = "Smoothness"
    smoothLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    smoothLbl.TextSize = 11
    smoothLbl.TextXAlignment = Enum.TextXAlignment.Left

    smoothValue = Instance.new("TextLabel")
    smoothValue.Parent = card
    smoothValue.BackgroundTransparency = 1
    smoothValue.Position = UDim2.new(1, -64, 0, 194)
    smoothValue.Size = UDim2.new(0, 50, 0, 16)
    smoothValue.Font = Enum.Font.GothamMedium
    smoothValue.TextColor3 = Color3.fromRGB(240, 240, 240)
    smoothValue.TextSize = 11
    smoothValue.TextXAlignment = Enum.TextXAlignment.Right

    local smoothTrack = Instance.new("TextButton")
    smoothTrack.Parent = card
    smoothTrack.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    smoothTrack.BorderSizePixel = 0
    smoothTrack.Position = UDim2.new(0, 14, 0, 218)
    smoothTrack.Size = UDim2.new(1, -28, 0, 8)
    smoothTrack.Text = ""
    smoothTrack.AutoButtonColor = false

    local smc = Instance.new("UICorner")
    smc.CornerRadius = UDim.new(1, 0)
    smc.Parent = smoothTrack

    smoothFill = Instance.new("Frame")
    smoothFill.Parent = smoothTrack
    smoothFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    smoothFill.BorderSizePixel = 0
    smoothFill.Size = UDim2.new(1, 0, 1, 0)

    local smfc = Instance.new("UICorner")
    smfc.CornerRadius = UDim.new(1, 0)
    smfc.Parent = smoothFill

    updateSmoothUI = function(tween)
        local pct = math.clamp((aimbotSettings.Smoothness - 0.05) / 0.95, 0, 1)
        smoothValue.Text = tostring(math.floor(aimbotSettings.Smoothness * 100 + 0.5)) .. "%"
        if tween then
            TweenService:Create(smoothFill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        else
            smoothFill.Size = UDim2.new(pct, 0, 1, 0)
        end
    end
    local function setSmooth(inputX)
        local relX = math.clamp(inputX - smoothTrack.AbsolutePosition.X, 0, smoothTrack.AbsoluteSize.X)
        local pct = relX / math.max(smoothTrack.AbsoluteSize.X, 1)
        aimbotSettings.Smoothness = math.clamp(0.05 + pct * 0.95, 0.05, 1)
        updateSmoothUI(false)
    end
    local smoothDragging = false
    smoothTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            smoothDragging = true
            setSmooth(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then smoothDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if smoothDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setSmooth(input.Position.X)
        end
    end)
    updateSmoothUI(false)

    -- Aim type
    local typeLbl = Instance.new("TextLabel")
    typeLbl.Parent = card
    typeLbl.BackgroundTransparency = 1
    typeLbl.Position = UDim2.new(0, 14, 0, 234)
    typeLbl.Size = UDim2.new(0, 160, 0, 16)
    typeLbl.Font = Enum.Font.Gotham
    typeLbl.Text = "Aim Type"
    typeLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    typeLbl.TextSize = 11
    typeLbl.TextXAlignment = Enum.TextXAlignment.Left

    local modeRow = Instance.new("Frame")
    modeRow.Parent = card
    modeRow.BackgroundTransparency = 1
    modeRow.Position = UDim2.new(0, 12, 0, 252)
    modeRow.Size = UDim2.new(1, -24, 0, 26)

    local mLayout = Instance.new("UIListLayout")
    mLayout.Parent = modeRow
    mLayout.FillDirection = Enum.FillDirection.Horizontal
    mLayout.Padding = UDim.new(0, 6)
    mLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local modeButtons = {}
    setAimMode = function(mode)
        aimbotSettings.AimMode = mode
        for k, btn in pairs(modeButtons) do
            if k == mode then
                btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                btn.TextColor3 = Color3.fromRGB(30, 30, 30)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end
    end
    for _, choice in ipairs({{key = "Normal", label = "NORMAL"}, {key = "Smooth", label = "SMOOTH"}, {key = "Prediction", label = "PREDICTION"}}) do
        local mb = Instance.new("TextButton")
        mb.Parent = modeRow
        mb.Size = UDim2.new(1/3, -12, 1, 0)
        mb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        mb.BorderSizePixel = 0
        mb.Font = Enum.Font.GothamBold
        mb.Text = choice.label
        mb.TextColor3 = Color3.fromRGB(200, 200, 210)
        mb.TextSize = 11
        mb.AutoButtonColor = false
        local mbc = Instance.new("UICorner")
        mbc.CornerRadius = UDim.new(0, 4)
        mbc.Parent = mb
        modeButtons[choice.key] = mb
        mb.MouseButton1Click:Connect(function() setAimMode(choice.key) end)
    end
    setAimMode(aimbotSettings.AimMode)

    -- Which body part to aim at
    local function resolveAimPart(char, which)
        if which == "Torso" then
            return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        elseif which == "Root" then
            return char:FindFirstChild("HumanoidRootPart")
        end
        return char:FindFirstChild("Head")
    end

    local function isAimTeammate(plr)
        return aimbotSettings.TeamCheck and plr.Team ~= nil and player.Team ~= nil and plr.Team == player.Team
    end

    -- Raycast
    local aimRayParams = RaycastParams.new()
    aimRayParams.FilterType = Enum.RaycastFilterType.Exclude
    local aimIgnore = {}

    local function isTargetVisible(fromPos, toPos, targetChar)
        table.clear(aimIgnore)
        if player.Character then table.insert(aimIgnore, player.Character) end
        if targetChar then table.insert(aimIgnore, targetChar) end
        aimRayParams.FilterDescendantsInstances = aimIgnore
        local ray = workspace:Raycast(fromPos, toPos - fromPos, aimRayParams)
        return ray == nil
    end

    -- Aimbot loop
    RunService.RenderStepped:Connect(function()
        if not ALIVE then return end
        aimFeedPos = nil
        aimbotTargetPlr = nil
        if not aimbotSettings.Enabled then return end
        if bindMode then return end

        local char = player.Character
        if not char then return end
        local cam = workspace.CurrentCamera
        if not cam then return end

        local camPos = cam.CFrame.Position
        local viewportCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local bestTarget = nil
        local bestDist = aimbotSettings.FOV

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not isAimTeammate(plr) then
                local tchar = plr.Character
                if tchar then
                    local tpart = resolveAimPart(tchar, aimbotSettings.TargetPart)
                    local thum = tchar:FindFirstChildOfClass("Humanoid")
                    if tpart and thum and thum.Health > 0 then
                        local aimPos = tpart.Position
                        local sp, onScreen = cam:WorldToViewportPoint(aimPos)
                        if onScreen and sp.Z > 0 then
                            local screenPos = Vector2.new(sp.X, sp.Y)
                            local screenDist = (screenPos - viewportCenter).Magnitude
                            if screenDist <= bestDist then
                                if not aimbotSettings.VisibleCheck or isTargetVisible(camPos, aimPos, tchar) then
                                    bestDist = screenDist
                                    bestTarget = tpart
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestTarget then
            aimbotTargetPlr = Players:GetPlayerFromCharacter(bestTarget.Parent)
            aimbotTargetAt = os.clock()
            local aimPt = bestTarget.Position
            if aimbotSettings.AimMode == "Prediction" then
                aimPt = aimPt + (bestTarget.AssemblyLinearVelocity * 0.15)
            end
            if tpEnabled then
                aimFeedPos = aimPt
            else
                local desired = CFrame.new(camPos, aimPt)
                local aimMode = aimbotSettings.AimMode or "Normal"
                local t = (aimMode == "Smooth") and aimbotSettings.Smoothness or 1
                if t >= 1 then
                    cam.CFrame = desired
                else
                    cam.CFrame = cam.CFrame:Lerp(desired, t)
                end
            end
        end
    end)
end

---------------------------------------------------------------------
-- TRIGGERBOT (Legit)
---------------------------------------------------------------------
do
    local card = Instance.new("Frame")
    card.Parent = legitTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 126)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Triggerbot"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle

    updateTrigToggle = function(state)
        trigEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    end
    updateTrigToggle(false)
    toggleBtn.MouseButton1Click:Connect(function() updateTrigToggle(not trigEnabled) end)

    -- half-width checkbox (Team / Visible)
    local function halfCheck(xScale, xOff, labelText, getV, setV)
        local row = Instance.new("Frame")
        row.Parent = card
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        row.BorderSizePixel = 0
        row.Position = UDim2.new(xScale, xOff, 0, 42)
        row.Size = UDim2.new(0.5, -17, 0, 26)

        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 4)
        rc.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Size = UDim2.new(1, -40, 1, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextButton")
        box.Parent = row
        box.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        box.BorderSizePixel = 0
        box.Position = UDim2.new(1, -28, 0.5, -8)
        box.Size = UDim2.new(0, 16, 0, 16)
        box.Text = ""
        box.AutoButtonColor = false

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 3)
        bc.Parent = box

        local mark = Instance.new("Frame")
        mark.Parent = box
        mark.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        mark.BorderSizePixel = 0
        mark.AnchorPoint = Vector2.new(0.5, 0.5)
        mark.Position = UDim2.new(0.5, 0, 0.5, 0)
        mark.Size = UDim2.new(0, 8, 0, 8)
        mark.Visible = getV()

        local mc = Instance.new("UICorner")
        mc.CornerRadius = UDim.new(0, 2)
        mc.Parent = mark

        local setter = function(state)
            mark.Visible = state
            box.BackgroundColor3 = state and Color3.fromRGB(45, 55, 90) or Color3.fromRGB(35, 35, 40)
        end
        setter(getV())
        box.MouseButton1Click:Connect(function()
            setV(not getV())
            setter(getV())
        end)
        return setter
    end

    setTrigTeam = halfCheck(0, 14, "Team Check", function() return trigTeamCheck end, function(v) trigTeamCheck = v end)
    setTrigVis = halfCheck(0.5, 3, "Visible Check", function() return trigVisCheck end, function(v) trigVisCheck = v end)

    -- delay slider (0-500 ms)
    local delayLbl = Instance.new("TextLabel")
    delayLbl.Parent = card
    delayLbl.BackgroundTransparency = 1
    delayLbl.Position = UDim2.new(0, 14, 0, 78)
    delayLbl.Size = UDim2.new(0, 140, 0, 16)
    delayLbl.Font = Enum.Font.Gotham
    delayLbl.Text = "Delay"
    delayLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    delayLbl.TextSize = 11
    delayLbl.TextXAlignment = Enum.TextXAlignment.Left

    trigDelayValue = Instance.new("TextLabel")
    trigDelayValue.Parent = card
    trigDelayValue.BackgroundTransparency = 1
    trigDelayValue.Position = UDim2.new(1, -74, 0, 78)
    trigDelayValue.Size = UDim2.new(0, 60, 0, 16)
    trigDelayValue.Font = Enum.Font.GothamMedium
    trigDelayValue.TextColor3 = Color3.fromRGB(240, 240, 240)
    trigDelayValue.TextSize = 11
    trigDelayValue.TextXAlignment = Enum.TextXAlignment.Right

    local delayTrack = Instance.new("TextButton")
    delayTrack.Parent = card
    delayTrack.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    delayTrack.BorderSizePixel = 0
    delayTrack.Position = UDim2.new(0, 14, 0, 102)
    delayTrack.Size = UDim2.new(1, -28, 0, 8)
    delayTrack.Text = ""
    delayTrack.AutoButtonColor = false

    local dtc = Instance.new("UICorner")
    dtc.CornerRadius = UDim.new(1, 0)
    dtc.Parent = delayTrack

    trigDelayFill = Instance.new("Frame")
    trigDelayFill.Parent = delayTrack
    trigDelayFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    trigDelayFill.BorderSizePixel = 0
    trigDelayFill.Size = UDim2.new(0, 0, 1, 0)

    local dfc = Instance.new("UICorner")
    dfc.CornerRadius = UDim.new(1, 0)
    dfc.Parent = trigDelayFill

    local TRIG_MAX_DELAY = 500
    trigDelayUI = function(tween)
        trigDelayValue.Text = tostring(math.floor(trigDelay + 0.5)) .. "ms"
        local pct = math.clamp(trigDelay / TRIG_MAX_DELAY, 0, 1)
        if tween then
            TweenService:Create(trigDelayFill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        else
            trigDelayFill.Size = UDim2.new(pct, 0, 1, 0)
        end
    end

    local delayDragging = false
    local function setDelay(inputX)
        local relX = math.clamp(inputX - delayTrack.AbsolutePosition.X, 0, delayTrack.AbsoluteSize.X)
        local pct = relX / math.max(delayTrack.AbsoluteSize.X, 1)
        trigDelay = math.floor(pct * TRIG_MAX_DELAY + 0.5)
        trigDelayUI(false)
    end
    delayTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            delayDragging = true
            setDelay(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then delayDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if delayDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setDelay(input.Position.X)
        end
    end)
    trigDelayUI(false)

    -- shooting: tap LMB whenever the crosshair sits on an enemy (any distance)
    local trigNextShot = 0
    local trigParams = RaycastParams.new()
    trigParams.FilterType = Enum.RaycastFilterType.Exclude
    local trigIgnore = {}

    local function trigClick()
        if typeof(mouse1click) == "function" then
            mouse1click()
        elseif typeof(keypress) == "function" and typeof(keyrelease) == "function" then
            keypress(1)
            task.defer(function() keyrelease(1) end)
        end
    end

    local function trigIsEnemy(plr)
        if plr == nil or plr == player then return false end
        if trigTeamCheck and plr.Team and player.Team and plr.Team == player.Team then return false end
        return true
    end

    local function trigPlayerOf(inst)
        local m = inst
        while m and m ~= workspace do
            if m:IsA("Model") then
                local plr = Players:GetPlayerFromCharacter(m)
                if plr then return plr, m end
            end
            m = m.Parent
        end
        return nil
    end

    RunService.RenderStepped:Connect(function()
        if not ALIVE then return end
        if not trigEnabled then return end
        local now = tick()
        if now < trigNextShot then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local char = player.Character
        trigIgnore[1] = char
        trigParams.FilterDescendantsInstances = trigIgnore

        local found = false
        if trigVisCheck then
            -- first thing under the crosshair must be an enemy body part
            local hit = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 3000, trigParams)
            if hit then
                local plr, ch = trigPlayerOf(hit.Instance)
                if plr and trigIsEnemy(plr) then
                    local hum = ch:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then found = true end
                end
            end
        else
            -- no visibility needed: enemy projected around the screen centre
            local vs = cam.ViewportSize
            local cx, cy = vs.X * 0.5, vs.Y * 0.5
            local proj = (vs.Y * 0.5) / math.tan(math.rad(cam.FieldOfView) * 0.5)
            for _, plr in ipairs(Players:GetPlayers()) do
                if not found and trigIsEnemy(plr) then
                    local ch = plr.Character
                    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                    if ch and hum and hum.Health > 0 then
                        for _, pn in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
                            local part = ch:FindFirstChild(pn)
                            if part then
                                local sp, on = cam:WorldToViewportPoint(part.Position)
                                if on and sp.Z > 0 then
                                    local dx, dy = sp.X - cx, sp.Y - cy
                                    local radius = math.max(8, part.Size.X * 0.6 / sp.Z * proj)
                                    if dx * dx + dy * dy <= radius * radius then
                                        found = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if found then
            trigClick()
            trigNextShot = now + trigDelay / 1000
        end
    end)
end
---------------------------------------------------------------------
-- FLY CARD (Rage)
---------------------------------------------------------------------
do
    local flyBodyVelocity = nil
    local flyBodyForce = nil

    local function cleanupFlyAttachments()
        if flyBodyVelocity then pcall(function() flyBodyVelocity:Destroy() end); flyBodyVelocity = nil end
        if flyBodyForce then pcall(function() flyBodyForce:Destroy() end); flyBodyForce = nil end
    end

    local function resetFlyState()
        cleanupFlyAttachments()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() hrp.Anchored = false end)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end

    local card = Instance.new("Frame")
    card.Parent = rageTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 160)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Fly"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle

    updateFlyToggle = function(state)
        flyEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        if not state then resetFlyState() end
    end

    toggleBtn.MouseButton1Click:Connect(function() updateFlyToggle(not flyEnabled) end)

    local methodLabel = Instance.new("TextLabel")
    methodLabel.Parent = card
    methodLabel.BackgroundTransparency = 1
    methodLabel.Position = UDim2.new(0, 14, 0, 44)
    methodLabel.Size = UDim2.new(0, 120, 0, 16)
    methodLabel.Font = Enum.Font.Gotham
    methodLabel.Text = "Exploit Method"
    methodLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    methodLabel.TextSize = 11
    methodLabel.TextXAlignment = Enum.TextXAlignment.Left

    local methodRow = Instance.new("Frame")
    methodRow.Parent = card
    methodRow.BackgroundTransparency = 1
    methodRow.Position = UDim2.new(0, 12, 0, 64)
    methodRow.Size = UDim2.new(1, -24, 0, 26)

    local mLayout = Instance.new("UIListLayout")
    mLayout.Parent = methodRow
    mLayout.FillDirection = Enum.FillDirection.Horizontal
    mLayout.Padding = UDim.new(0, 6)
    mLayout.SortOrder = Enum.SortOrder.LayoutOrder

    setFlyMethod = function(name)
        flyMethod = name
        cleanupFlyAttachments()
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() hrp.Anchored = false end)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
        for methodName, btn in pairs(methodButtons) do
            if methodName == name then
                btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                btn.TextColor3 = Color3.fromRGB(30, 30, 30)
            else
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            end
        end
    end

    for _, methodName in ipairs({"CFrame", "Velocity", "BodyVelocity"}) do
        local mb = Instance.new("TextButton")
        mb.Parent = methodRow
        mb.Size = UDim2.new(0, 100, 0, 26)
        mb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        mb.BorderSizePixel = 0
        mb.Font = Enum.Font.GothamBold
        mb.Text = methodName
        mb.TextColor3 = Color3.fromRGB(200, 200, 210)
        mb.TextSize = 11
        mb.AutoButtonColor = false

        local mbc = Instance.new("UICorner")
        mbc.CornerRadius = UDim.new(0, 4)
        mbc.Parent = mb

        mb.MouseButton1Click:Connect(function() setFlyMethod(methodName) end)
        methodButtons[methodName] = mb
    end
    setFlyMethod("CFrame")

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Parent = card
    speedLabel.BackgroundTransparency = 1
    speedLabel.Position = UDim2.new(0, 14, 0, 100)
    speedLabel.Size = UDim2.new(0, 120, 0, 16)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Text = "Fly Speed"
    speedLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    speedLabel.TextSize = 11
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left

    flySpeedValue = Instance.new("TextLabel")
    flySpeedValue.Parent = card
    flySpeedValue.BackgroundTransparency = 1
    flySpeedValue.Position = UDim2.new(1, -64, 0, 100)
    flySpeedValue.Size = UDim2.new(0, 50, 0, 16)
    flySpeedValue.Font = Enum.Font.GothamMedium
    flySpeedValue.Text = tostring(flySpeed)
    flySpeedValue.TextColor3 = Color3.fromRGB(240, 240, 240)
    flySpeedValue.TextSize = 11
    flySpeedValue.TextXAlignment = Enum.TextXAlignment.Right

    local flyTrack = Instance.new("TextButton")
    flyTrack.Parent = card
    flyTrack.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    flyTrack.BorderSizePixel = 0
    flyTrack.Position = UDim2.new(0, 14, 0, 128)
    flyTrack.Size = UDim2.new(1, -28, 0, 8)
    flyTrack.Text = ""
    flyTrack.AutoButtonColor = false

    local ftc = Instance.new("UICorner")
    ftc.CornerRadius = UDim.new(1, 0)
    ftc.Parent = flyTrack

    flySliderFill = Instance.new("Frame")
    flySliderFill.Parent = flyTrack
    flySliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    flySliderFill.BorderSizePixel = 0
    flySliderFill.Size = UDim2.new(flySpeed / flyMaxSpeed, 0, 1, 0)

    local ffc = Instance.new("UICorner")
    ffc.CornerRadius = UDim.new(1, 0)
    ffc.Parent = flySliderFill

    local knob = Instance.new("Frame")
    knob.Parent = flySliderFill
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    knob.BorderSizePixel = 0
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local flyDragging = false
    local function setFlyVal(inputX)
        local relX = math.clamp(inputX - flyTrack.AbsolutePosition.X, 0, flyTrack.AbsoluteSize.X)
        local pct = relX / flyTrack.AbsoluteSize.X
        local val = math.clamp(math.round(pct * flyMaxSpeed), 5, flyMaxSpeed)
        flySpeed = val
        flySpeedValue.Text = tostring(val)
        TweenService:Create(flySliderFill, TweenInfo.new(0.08), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
    end
    flyTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            flyDragging = true
            setFlyVal(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then flyDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if flyDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFlyVal(input.Position.X)
        end
    end)

    local CFrameBonus = 1.35
    RunService.RenderStepped:Connect(function(dt)
        if not ALIVE then return end
        if not flyEnabled then return end
        local char = player.Character
        if not char then resetFlyState(); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then resetFlyState(); return end
        if not hum.PlatformStand then hum.PlatformStand = true end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit end

        if flyMethod == "CFrame" then
            if not hrp.Anchored then hrp.Anchored = true end
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            if flyBodyVelocity or flyBodyForce then cleanupFlyAttachments() end
            char:PivotTo(char:GetPivot() + dir * flySpeed * CFrameBonus * dt)
        elseif flyMethod == "Velocity" then
            if hrp.Anchored then hrp.Anchored = false end
            if not flyBodyForce or flyBodyForce.Parent ~= hrp then
                if flyBodyForce then flyBodyForce:Destroy() end
                flyBodyForce = Instance.new("BodyForce")
                flyBodyForce.Parent = hrp
            end
            flyBodyForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
            if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = dir * flySpeed
        elseif flyMethod == "BodyVelocity" then
            if hrp.Anchored then hrp.Anchored = false end
            if flyBodyForce then flyBodyForce:Destroy(); flyBodyForce = nil end
            if not flyBodyVelocity or flyBodyVelocity.Parent ~= hrp then
                if flyBodyVelocity then flyBodyVelocity:Destroy() end
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyVelocity.P = 1250
                flyBodyVelocity.Parent = hrp
            end
            flyBodyVelocity.Velocity = dir * flySpeed
        end
    end)
end

---------------------------------------------------------------------
-- SPINBOT + ANTI-AIM (Rage)
---------------------------------------------------------------------
do
    local spinAngle = 0
    local aaClock = 0
    local aaOffset = 180

    local function refreshAutoRotate()
        local ch = player.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = not (spinEnabled or aaEnabled) end
    end

    local function newCard(height)
        local card = Instance.new("Frame")
        card.Parent = rageTab.Body
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        card.BorderSizePixel = 0
        card.Size = UDim2.new(1, 0, 0, height)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = card
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(36, 36, 42)
        s.Thickness = 1
        s.Parent = card
        return card
    end

    local function newTitle(card, text)
        local t = Instance.new("TextLabel")
        t.Parent = card
        t.BackgroundTransparency = 1
        t.Position = UDim2.new(0, 14, 0, 12)
        t.Size = UDim2.new(1, -90, 0, 20)
        t.Font = Enum.Font.GothamMedium
        t.Text = text
        t.TextColor3 = Color3.fromRGB(230, 230, 235)
        t.TextSize = 14
        t.TextXAlignment = Enum.TextXAlignment.Left
        return t
    end

    local function newToggle(card, onState)
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Parent = card
        toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        toggleBtn.BorderSizePixel = 0
        toggleBtn.Position = UDim2.new(1, -54, 0, 12)
        toggleBtn.Size = UDim2.new(0, 42, 0, 22)
        toggleBtn.Text = ""
        toggleBtn.AutoButtonColor = false
        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(1, 0)
        tc.Parent = toggleBtn
        local circle = Instance.new("Frame")
        circle.Parent = toggleBtn
        circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        circle.BorderSizePixel = 0
        circle.Position = UDim2.new(0, 3, 0.5, -8)
        circle.Size = UDim2.new(0, 16, 0, 16)
        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(1, 0)
        cc.Parent = circle
        local current = false
        local function apply(state)
            local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        end
        toggleBtn.MouseButton1Click:Connect(function()
            current = not current
            apply(current)
            onState(current)
        end)
        return function(state)
            current = state
            apply(state)
            onState(state)
        end
    end

    local function makeSlider(card, yPos, minV, maxV, getV, setV)
        local track = Instance.new("TextButton")
        track.Parent = card
        track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        track.BorderSizePixel = 0
        track.Position = UDim2.new(0, 14, 0, yPos)
        track.Size = UDim2.new(1, -28, 0, 8)
        track.Text = ""
        track.AutoButtonColor = false
        local trc = Instance.new("UICorner")
        trc.CornerRadius = UDim.new(1, 0)
        trc.Parent = track
        local fill = Instance.new("Frame")
        fill.Parent = track
        fill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        fill.BorderSizePixel = 0
        fill.Size = UDim2.new(0, 0, 1, 0)
        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(1, 0)
        fc.Parent = fill
        local dragging = false
        local function apply(animated)
            local pct = math.clamp((getV() - minV) / (maxV - minV), 0, 1)
            if animated then
                TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            else
                fill.Size = UDim2.new(pct, 0, 1, 0)
            end
        end
        local function setFromX(inputX)
            local relX = math.clamp(inputX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local pct = relX / math.max(track.AbsoluteSize.X, 1)
            setV(minV + pct * (maxV - minV))
            apply(false)
        end
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                setFromX(input.Position.X)
            end
        end)
        apply(false)
        return apply
    end

    local function makeValueLabel(card, yPos, width)
        local v = Instance.new("TextLabel")
        v.Parent = card
        v.BackgroundTransparency = 1
        v.Position = UDim2.new(1, -(width + 14), 0, yPos)
        v.Size = UDim2.new(0, width, 0, 16)
        v.Font = Enum.Font.GothamMedium
        v.TextColor3 = Color3.fromRGB(240, 240, 240)
        v.TextSize = 11
        v.TextXAlignment = Enum.TextXAlignment.Right
        return v
    end

    local function makeLabel(card, yPos, text)
        local l = Instance.new("TextLabel")
        l.Parent = card
        l.BackgroundTransparency = 1
        l.Position = UDim2.new(0, 14, 0, yPos)
        l.Size = UDim2.new(0, 160, 0, 16)
        l.Font = Enum.Font.Gotham
        l.Text = text
        l.TextColor3 = Color3.fromRGB(150, 150, 160)
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        return l
    end

    -- Spinbot card
    local spinCard = newCard(100)
    newTitle(spinCard, "Spinbot")
    updateSpinToggle = newToggle(spinCard, function(state)
        spinEnabled = state
        refreshAutoRotate()
    end)
    updateSpinToggle(false)

    makeLabel(spinCard, 46, "Speed")
    spinSpeedValue = makeValueLabel(spinCard, 46, 70)
    local applySpinSlider = makeSlider(spinCard, 72, 60, 1080,
        function() return spinSpeed end,
        function(v) spinSpeed = math.floor(v + 0.5) end)

    spinSpeedUI = function(tween)
        spinSpeedValue.Text = tostring(spinSpeed) .. "d/s"
        applySpinSlider(tween)
    end
    spinSpeedUI(false)

    -- Anti-Aim card
    local aaCard = newCard(156)
    newTitle(aaCard, "Anti Aim")
    updateAAToggle = newToggle(aaCard, function(state)
        aaEnabled = state
        refreshAutoRotate()
    end)
    updateAAToggle(false)

    local modeRow = Instance.new("Frame")
    modeRow.Parent = aaCard
    modeRow.BackgroundTransparency = 1
    modeRow.Position = UDim2.new(0, 12, 0, 42)
    modeRow.Size = UDim2.new(1, -24, 0, 26)

    local mLayout = Instance.new("UIListLayout")
    mLayout.Parent = modeRow
    mLayout.FillDirection = Enum.FillDirection.Horizontal
    mLayout.Padding = UDim.new(0, 6)
    mLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local modeBtns = {}
    setAAMode = function(mode)
        aaMode = mode
        if mode == "Back" then aaOffset = 180
        elseif mode == "Left" then aaOffset = 90
        elseif mode == "Right" then aaOffset = -90
        end
        for k, btn in pairs(modeBtns) do
            local on = (k == mode)
            btn.BackgroundColor3 = on and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
            btn.TextColor3 = on and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(200, 200, 210)
        end
    end

    for _, m in ipairs({{k = "Back", l = "BACK"}, {k = "Left", l = "LEFT"}, {k = "Right", l = "RIGHT"}, {k = "Jitter", l = "JIT"}, {k = "Random", l = "RAND"}}) do
        local mb = Instance.new("TextButton")
        mb.Parent = modeRow
        mb.Size = UDim2.new(0, 66, 0, 26)
        mb.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        mb.BorderSizePixel = 0
        mb.Font = Enum.Font.GothamBold
        mb.Text = m.l
        mb.TextColor3 = Color3.fromRGB(200, 200, 210)
        mb.TextSize = 11
        mb.AutoButtonColor = false
        local mbc = Instance.new("UICorner")
        mbc.CornerRadius = UDim.new(0, 4)
        mbc.Parent = mb
        modeBtns[m.k] = mb
        mb.MouseButton1Click:Connect(function() setAAMode(m.k) end)
    end
    setAAMode("Back")

    makeLabel(aaCard, 76, "Jitter Angle")
    aaJitterValue = makeValueLabel(aaCard, 76, 60)
    local applyJitter = makeSlider(aaCard, 96, 10, 180,
        function() return aaJitter end,
        function(v) aaJitter = math.floor(v + 0.5) end)

    makeLabel(aaCard, 114, "Jitter Rate")
    aaRateValue = makeValueLabel(aaCard, 114, 60)
    local applyRate = makeSlider(aaCard, 134, 1, 30,
        function() return aaRate end,
        function(v) aaRate = math.floor(v + 0.5) end)

    aaUI = function(tween)
        aaJitterValue.Text = tostring(aaJitter) .. "d"
        aaRateValue.Text = tostring(aaRate) .. "/s"
        applyJitter(tween)
        applyRate(tween)
    end
    aaUI(false)

    -- rotation handler
    RunService.RenderStepped:Connect(function(dt)
        if not ALIVE then return end
        if not (spinEnabled or aaEnabled) then return end
        local ch = player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0) then return end
        if hum.AutoRotate then hum.AutoRotate = false end
        dt = math.min(tonumber(dt) or 0.016, 0.1)
        if spinEnabled then
            spinAngle = (spinAngle + spinSpeed * dt) % 360
        end
        if aaEnabled then
            aaClock = aaClock + dt
            if aaClock >= 1 / math.max(aaRate, 1) then
                aaClock = 0
                if aaMode == "Jitter" then
                    aaOffset = (math.random(0, 1) == 0) and aaJitter or -aaJitter
                elseif aaMode == "Random" then
                    aaOffset = math.random(-180, 180)
                elseif aaMode == "Left" then
                    aaOffset = 90
                elseif aaMode == "Right" then
                    aaOffset = -90
                else
                    aaOffset = 180
                end
            end
        end
        local total = (spinEnabled and spinAngle or 0) + (aaEnabled and aaOffset or 0)
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(total % 360), 0)
    end)
end
---------------------------------------------------------------------
-- DRAG / INSERT
---------------------------------------------------------------------
do
    local dragging = false
    local dragStart, startPos

    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local isOpen = true
    local isTweening = false

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert and not isTweening then
            isTweening = true
            isOpen = not isOpen
            if isOpen then
                Main.Visible = true
                Main.Size = UDim2.new(0, 480, 0, 330)
                local anim = TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 360)})
                anim:Play()
                anim.Completed:Connect(function() isTweening = false end)
            else
                local anim = TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 480, 0, 330)})
                anim:Play()
                anim.Completed:Connect(function() Main.Visible = false; isTweening = false end)
            end
        end
    end)
end

---------------------------------------------------------------------
-- ESP
---------------------------------------------------------------------
do
    local EspGui = Instance.new("ScreenGui")
    EspGui.Name = "CleanTabESP"
    EspGui.ResetOnSpawn = false
    EspGui.IgnoreGuiInset = true
    EspGui.DisplayOrder = 1000
    EspGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    EspGui.Parent = playerGui

    local ESP_HEALTH_BG = Color3.fromRGB(20, 20, 24)

    local R15_BONES = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    }
    local R6_BONES = {
        {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
        {"Torso","Left Leg"},{"Torso","Right Leg"},
    }
    local BONE_NAMES = {
        "Head","UpperTorso","LowerTorso","Torso",
        "LeftUpperArm","LeftLowerArm","LeftHand",
        "RightUpperArm","RightLowerArm","RightHand",
        "LeftUpperLeg","LeftLowerLeg","LeftFoot",
        "RightUpperLeg","RightLowerLeg","RightFoot",
        "Left Arm","Right Arm","Left Leg","Right Leg"
    }

    local function createLine(parent)
        local line = Instance.new("Frame")
        line.BackgroundColor3 = espSettings.SkeletonColor
        line.BorderSizePixel = 0
        line.Visible = false
        line.ZIndex = 2
        line.Parent = parent
        return line
    end

    local function createEspFor(plr)
        if espObjects[plr] then return end

        local container = Instance.new("Frame")
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.Size = UDim2.new(1, 0, 1, 0)
        container.ZIndex = 2
        container.Parent = EspGui

        local box = Instance.new("Frame")
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.ZIndex = 2
        box.Parent = container

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = espSettings.BoxColor
        boxStroke.Thickness = 1
        boxStroke.Parent = box

        local headBox = Instance.new("Frame")
        headBox.BackgroundTransparency = 1
        headBox.BorderSizePixel = 0
        headBox.Visible = false
        headBox.ZIndex = 2
        headBox.Parent = container

        local headBoxStroke = Instance.new("UIStroke")
        headBoxStroke.Color = espSettings.HeadColor
        headBoxStroke.Thickness = 1
        headBoxStroke.Parent = headBox

        local healthBg = Instance.new("Frame")
        healthBg.BackgroundColor3 = ESP_HEALTH_BG
        healthBg.BorderSizePixel = 0
        healthBg.Visible = false
        healthBg.ZIndex = 3
        healthBg.Parent = container

        local hbs = Instance.new("UIStroke")
        hbs.Color = Color3.fromRGB(0, 0, 0)
        hbs.Thickness = 1
        hbs.Parent = healthBg

        local healthFill = Instance.new("Frame")
        healthFill.BackgroundColor3 = espSettings.HealthColor
        healthFill.BorderSizePixel = 0
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.ZIndex = 4
        healthFill.Parent = healthBg

        local healthText = Instance.new("TextLabel")
        healthText.BackgroundTransparency = 1
        healthText.Font = Enum.Font.GothamBold
        healthText.TextSize = 11
        healthText.TextColor3 = Color3.fromRGB(240, 240, 255)
        healthText.TextStrokeTransparency = 0.4
        healthText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthText.Visible = false
        healthText.ZIndex = 4
        healthText.Parent = container

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = espSettings.NameColor
        nameLabel.TextStrokeTransparency = 0.4
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Text = plr.Name
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Visible = false
        nameLabel.ZIndex = 4
        nameLabel.Parent = container

        local avatar = Instance.new("ImageLabel")
        avatar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        avatar.BorderSizePixel = 0
        avatar.Visible = false
        avatar.ZIndex = 4
        avatar.Image = ""
        avatar.ScaleType = Enum.ScaleType.Crop
        avatar.Parent = container

        local ac = Instance.new("UICorner")
        ac.CornerRadius = UDim.new(1, 0)
        ac.Parent = avatar

        local as = Instance.new("UIStroke")
        as.Color = espSettings.AvatarColor
        as.Thickness = 1
        as.Parent = avatar

        local skeleton = Instance.new("Frame")
        skeleton.BackgroundTransparency = 1
        skeleton.BorderSizePixel = 0
        skeleton.Visible = false
        skeleton.Size = UDim2.new(1, 0, 1, 0)
        skeleton.ZIndex = 2
        skeleton.Parent = container

        local skeletonLines = {}
        for i = 1, 20 do skeletonLines[i] = createLine(skeleton) end

        espObjects[plr] = {
            Container = container, Box = box, BoxStroke = boxStroke,
            HeadBox = headBox, HeadBoxStroke = headBoxStroke,
            HealthBg = healthBg, HealthFill = healthFill, HealthText = healthText,
            NameLabel = nameLabel, Avatar = avatar, AvatarStroke = as,
            Skeleton = skeleton, SkeletonLines = skeletonLines,
            CachedChar = nil, BoneParts = {},
        }
    end

    local function removeEspFor(plr)
        local data = espObjects[plr]
        if data and data.Container then data.Container:Destroy() end
        espObjects[plr] = nil
    end

    local function getAvatar(plr)
        if avatarCache[plr.UserId] then return avatarCache[plr.UserId] end
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and url then
            avatarCache[plr.UserId] = url
            return url
        end
        return nil
    end

    local function worldToViewport(pos)
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local sp = cam:WorldToViewportPoint(pos)
        if sp.Z <= 0 then return nil end
        return Vector2.new(sp.X, sp.Y)
    end

    local function drawLine(line, p1, p2)
        local delta = p2 - p1
        local length = delta.Magnitude
        if length < 0.5 then line.Visible = false; return end
        local center = (p1 + p2) * 0.5
        line.Visible = true
        line.Position = UDim2.new(0, center.X, 0, center.Y)
        line.Size = UDim2.new(0, length, 0, 1)
        line.Rotation = math.deg(math.atan(delta.Y, delta.X))
    end

    local function getPartScreenBounds(part)
        local cf = part.CFrame
        local half = part.Size * 0.5
        local corners = {
            cf * Vector3.new(-half.X,  half.Y, -half.Z), cf * Vector3.new( half.X,  half.Y, -half.Z),
            cf * Vector3.new(-half.X,  half.Y,  half.Z), cf * Vector3.new( half.X,  half.Y,  half.Z),
            cf * Vector3.new(-half.X, -half.Y, -half.Z), cf * Vector3.new( half.X, -half.Y, -half.Z),
            cf * Vector3.new(-half.X, -half.Y,  half.Z), cf * Vector3.new( half.X, -half.Y,  half.Z),
        }
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local any = false
        for i = 1, 8 do
            local v = worldToViewport(corners[i])
            if v then
                any = true
                if v.X < minX then minX = v.X end
                if v.Y < minY then minY = v.Y end
                if v.X > maxX then maxX = v.X end
                if v.Y > maxY then maxY = v.Y end
            end
        end
        if not any then return nil end
        return minX, minY, maxX, maxY
    end

    local function getBonePairs(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        if hum.RigType == Enum.HumanoidRigType.R15 then return R15_BONES end
        return R6_BONES
    end

    local function refreshBoneCache(data, char)
        data.CachedChar = char
        data.BoneParts = {}
        for _, name in ipairs(BONE_NAMES) do
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then data.BoneParts[name] = p end
        end
    end

    local function updateEspFor(plr)
        local data = espObjects[plr]
        if not data then return end
        if plr == player then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        local char = plr.Character
        if not char then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        local cam = workspace.CurrentCamera
        if not cam then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        local dist = (cam.CFrame.Position - hrp.Position).Magnitude
        if dist > espSettings.MaxDistance then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        if espSettings.TeamCheck and plr.Team and player.Team and plr.Team == player.Team then
            if data.Container.Visible then data.Container.Visible = false end
            return
        end
        data.Container.Visible = true

        local cf, size = char:GetBoundingBox()
        local half = size * 0.5
        local corners = {
            cf * Vector3.new(-half.X,  half.Y, -half.Z), cf * Vector3.new( half.X,  half.Y, -half.Z),
            cf * Vector3.new(-half.X,  half.Y,  half.Z), cf * Vector3.new( half.X,  half.Y,  half.Z),
            cf * Vector3.new(-half.X, -half.Y, -half.Z), cf * Vector3.new( half.X, -half.Y, -half.Z),
            cf * Vector3.new(-half.X, -half.Y,  half.Z), cf * Vector3.new( half.X, -half.Y,  half.Z),
        }
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local anyVisible = false
        for i = 1, 8 do
            local v = worldToViewport(corners[i])
            if v then
                anyVisible = true
                if v.X < minX then minX = v.X end
                if v.Y < minY then minY = v.Y end
                if v.X > maxX then maxX = v.X end
                if v.Y > maxY then maxY = v.Y end
            end
        end
        if not anyVisible then
            data.Container.Visible = false
            return
        end
        local boxW = math.max(maxX - minX, 1)
        local boxH = math.max(maxY - minY, 1)

        if espSettings.Box then
            data.Box.Visible = true
            data.Box.Position = UDim2.new(0, minX, 0, minY)
            data.Box.Size = UDim2.new(0, boxW, 0, boxH)
        else
            data.Box.Visible = false
        end

        if espSettings.HeadHitbox then
            local headPart = char:FindFirstChild("Head")
            if headPart and headPart:IsA("BasePart") then
                local hx1, hy1, hx2, hy2 = getPartScreenBounds(headPart)
                if hx1 then
                    data.HeadBox.Visible = true
                    data.HeadBox.Position = UDim2.new(0, hx1, 0, hy1)
                    data.HeadBox.Size = UDim2.new(0, math.max(hx2 - hx1, 1), 0, math.max(hy2 - hy1, 1))
                else
                    data.HeadBox.Visible = false
                end
            else
                data.HeadBox.Visible = false
            end
        else
            data.HeadBox.Visible = false
        end

        if espSettings.Health then
            local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            local barW = 3
            data.HealthBg.Visible = true
            data.HealthBg.Position = UDim2.new(0, minX - (barW + 5), 0, minY)
            data.HealthBg.Size = UDim2.new(0, barW, 0, boxH)
            data.HealthFill.Size = UDim2.new(1, 0, hp, 0)
            data.HealthFill.Position = UDim2.new(0, 0, 1 - hp, 0)
            data.HealthFill.BackgroundColor3 = Color3.fromRGB(230, 70, 70):Lerp(espSettings.HealthColor, hp)
            data.HealthText.Visible = true
            data.HealthText.Text = tostring(math.floor(hum.Health))
            data.HealthText.Position = UDim2.new(0, minX - (barW + 5), 0, minY - 14)
            data.HealthText.Size = UDim2.new(0, 40, 0, 12)
        else
            data.HealthBg.Visible = false
            data.HealthText.Visible = false
        end

        local AV_SIZE = 18
        local rowY = minY - AV_SIZE - 3
        local avatarShown = false
        if espSettings.Avatar then
            local url = getAvatar(plr)
            if url and boxH > 6 then
                data.Avatar.Visible = true
                data.Avatar.Image = url
                data.Avatar.Position = UDim2.new(0, minX - 1, 0, rowY)
                data.Avatar.Size = UDim2.new(0, AV_SIZE, 0, AV_SIZE)
                avatarShown = true
            else
                data.Avatar.Visible = false
            end
        else
            data.Avatar.Visible = false
        end

        if espSettings.Name then
            data.NameLabel.Visible = true
            data.NameLabel.Text = plr.Name
            if avatarShown then
                data.NameLabel.Position = UDim2.new(0, minX + AV_SIZE + 5, 0, rowY)
                data.NameLabel.Size = UDim2.new(0, math.max(boxW - AV_SIZE - 5, 40), 0, AV_SIZE)
            else
                data.NameLabel.Position = UDim2.new(0, minX, 0, rowY)
                data.NameLabel.Size = UDim2.new(0, boxW, 0, AV_SIZE)
            end
        else
            data.NameLabel.Visible = false
        end

        if espSettings.Skeleton then
            if data.CachedChar ~= char then refreshBoneCache(data, char) end
            local pairsList = getBonePairs(char)
            if pairsList then
                data.Skeleton.Visible = true
                local screenPos = {}
                for name, part in pairs(data.BoneParts) do
                    local v = worldToViewport(part.Position)
                    if v then screenPos[name] = v end
                end
                local idx = 1
                for _, pair in ipairs(pairsList) do
                    local a = screenPos[pair[1]]
                    local b = screenPos[pair[2]]
                    local line = data.SkeletonLines[idx]
                    if a and b and line then drawLine(line, a, b)
                    elseif line then line.Visible = false end
                    idx = idx + 1
                    if idx > #data.SkeletonLines then break end
                end
                for i = idx, #data.SkeletonLines do data.SkeletonLines[i].Visible = false end
            else
                data.Skeleton.Visible = false
            end
        else
            if data.Skeleton.Visible then
                data.Skeleton.Visible = false
                for _, l in ipairs(data.SkeletonLines) do l.Visible = false end
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do createEspFor(plr) end
    Players.PlayerAdded:Connect(function(plr)
        if not ALIVE then return end
        createEspFor(plr)
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if not ALIVE then return end
        removeEspFor(plr)
    end)

    RunService.RenderStepped:Connect(function()
        if not ALIVE then return end
        local removeList = nil
        for plr, _ in pairs(espObjects) do
            if plr.Parent then
                updateEspFor(plr)
            else
                removeList = removeList or {}
                table.insert(removeList, plr)
            end
        end
        if removeList then
            for _, plr in ipairs(removeList) do removeEspFor(plr) end
        end
    end)
end

---------------------------------------------------------------------
-- VISUALS sub-tabs (ESP / WORLD)
---------------------------------------------------------------------
do
    local visualsFrame = visualsTab.Frame
    local espBody = visualsTab.Body

    local worldBody = Instance.new("ScrollingFrame")
    worldBody.Parent = visualsFrame
    worldBody.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    worldBody.BorderSizePixel = 0
    worldBody.Position = UDim2.new(0, 0, 0, 30)
    worldBody.Size = UDim2.new(1, 0, 1, -35)
    worldBody.ScrollBarThickness = 3
    worldBody.ScrollBarImageColor3 = guiColors.Accent
    worldBody.CanvasSize = UDim2.new(0, 0, 0, 0)
    worldBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
    worldBody.Visible = false

    local wbc = Instance.new("UICorner")
    wbc.CornerRadius = UDim.new(0, 6)
    wbc.Parent = worldBody

    local wbs = Instance.new("UIStroke")
    wbs.Color = Color3.fromRGB(35, 35, 40)
    wbs.Thickness = 1
    wbs.Parent = worldBody

    local wbl = Instance.new("UIListLayout")
    wbl.Parent = worldBody
    wbl.Padding = UDim.new(0, 10)
    wbl.SortOrder = Enum.SortOrder.LayoutOrder

    local wbp = Instance.new("UIPadding")
    wbp.Parent = worldBody
    wbp.PaddingTop = UDim.new(0, 12)
    wbp.PaddingBottom = UDim.new(0, 12)
    wbp.PaddingLeft = UDim.new(0, 12)
    wbp.PaddingRight = UDim.new(0, 12)

    local subESP = Instance.new("TextButton")
    subESP.Parent = visualsTab.Header
    subESP.Position = UDim2.new(1, -125, 0, 2)
    subESP.Size = UDim2.new(0, 55, 0, 20)
    subESP.Font = Enum.Font.GothamBold
    subESP.TextSize = 11
    subESP.Text = "ESP"
    subESP.BackgroundColor3 = guiColors.Accent
    subESP.TextColor3 = Color3.fromRGB(30, 30, 30)
    subESP.BorderSizePixel = 0
    subESP.AutoButtonColor = false

    local sec = Instance.new("UICorner")
    sec.CornerRadius = UDim.new(0, 4)
    sec.Parent = subESP

    local subWorld = Instance.new("TextButton")
    subWorld.Parent = visualsTab.Header
    subWorld.Position = UDim2.new(1, -65, 0, 2)
    subWorld.Size = UDim2.new(0, 55, 0, 20)
    subWorld.Font = Enum.Font.GothamBold
    subWorld.TextSize = 11
    subWorld.Text = "WORLD"
    subWorld.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    subWorld.TextColor3 = Color3.fromRGB(150, 150, 160)
    subWorld.BorderSizePixel = 0
    subWorld.AutoButtonColor = false

    local swc = Instance.new("UICorner")
    swc.CornerRadius = UDim.new(0, 4)
    swc.Parent = subWorld

    local function switchVisualSub(name)
        if name == "ESP" then
            espBody.Visible = true
            worldBody.Visible = false
            subESP.BackgroundColor3 = guiColors.Accent
            subESP.TextColor3 = Color3.fromRGB(30, 30, 30)
            subWorld.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            subWorld.TextColor3 = Color3.fromRGB(150, 150, 160)
        else
            espBody.Visible = false
            worldBody.Visible = true
            subESP.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            subESP.TextColor3 = Color3.fromRGB(150, 150, 160)
            subWorld.BackgroundColor3 = guiColors.Accent
            subWorld.TextColor3 = Color3.fromRGB(30, 30, 30)
        end
    end
    subESP.MouseButton1Click:Connect(function() switchVisualSub("ESP") end)
    subWorld.MouseButton1Click:Connect(function() switchVisualSub("WORLD") end)

    -- Self Head ESP: red outline highlight on local head
    local selfHeadHighlight = nil
    local function refreshSelfHead()
        local head = player.Character and player.Character:FindFirstChild("Head")
        if espSettings.SelfHead then
            if head and (not selfHeadHighlight or selfHeadHighlight.Parent ~= head) then
                if selfHeadHighlight then pcall(function() selfHeadHighlight:Destroy() end) end
                local h = Instance.new("Highlight")
                h.DepthMode = Enum.HighlightDepthMode.Occluded
                h.FillTransparency = 1
                h.OutlineColor = Color3.fromRGB(255, 90, 90)
                h.OutlineTransparency = 0
                h.Parent = head
                selfHeadHighlight = h
            end
        else
            if selfHeadHighlight then
                pcall(function() selfHeadHighlight:Destroy() end)
                selfHeadHighlight = nil
            end
        end
    end
    local function setSelfHead(v)
        espSettings.SelfHead = v
        refreshSelfHead()
    end
    RunService.Heartbeat:Connect(function()
        if not ALIVE then return end
        refreshSelfHead()
    end)

    -- Target HUD: name, avatar, hp follow the aimbot lock or crosshair hover
    local targetHudFrame = Instance.new("Frame")
    targetHudFrame.Parent = ScreenGui
    targetHudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    targetHudFrame.BorderSizePixel = 0
    targetHudFrame.Size = UDim2.new(0, 220, 0, 70)
    targetHudFrame.Position = UDim2.new(0.5, -110, 1, -160)
    targetHudFrame.Visible = false

    local thf = Instance.new("UICorner")
    thf.CornerRadius = UDim.new(0, 8)
    thf.Parent = targetHudFrame

    local ths = Instance.new("UIStroke")
    ths.Color = guiColors.Accent
    ths.Thickness = 1
    ths.Parent = targetHudFrame

    local hudAvatar = Instance.new("ImageLabel")
    hudAvatar.Parent = targetHudFrame
    hudAvatar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    hudAvatar.BorderSizePixel = 0
    hudAvatar.Position = UDim2.new(0, 7, 0, 7)
    hudAvatar.Size = UDim2.new(0, 56, 0, 56)
    hudAvatar.BackgroundTransparency = 0

    local hac = Instance.new("UICorner")
    hac.CornerRadius = UDim.new(0, 4)
    hac.Parent = hudAvatar

    local hudName = Instance.new("TextLabel")
    hudName.Parent = targetHudFrame
    hudName.BackgroundTransparency = 1
    hudName.Position = UDim2.new(0, 72, 0, 7)
    hudName.Size = UDim2.new(1, -80, 0, 18)
    hudName.Font = Enum.Font.GothamBold
    hudName.Text = "---"
    hudName.TextColor3 = Color3.fromRGB(235, 235, 240)
    hudName.TextSize = 13
    hudName.TextXAlignment = Enum.TextXAlignment.Left

    local hudHpBack = Instance.new("Frame")
    hudHpBack.Parent = targetHudFrame
    hudHpBack.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    hudHpBack.BorderSizePixel = 0
    hudHpBack.Position = UDim2.new(0, 72, 0, 32)
    hudHpBack.Size = UDim2.new(1, -80, 0, 14)

    local hhbc = Instance.new("UICorner")
    hhbc.CornerRadius = UDim.new(0, 3)
    hhbc.Parent = hudHpBack

    local hudHpFill = Instance.new("Frame")
    hudHpFill.Parent = hudHpBack
    hudHpFill.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
    hudHpFill.BorderSizePixel = 0
    hudHpFill.Size = UDim2.new(1, 0, 1, 0)

    local hhfc = Instance.new("UICorner")
    hhfc.CornerRadius = UDim.new(0, 3)
    hhfc.Parent = hudHpFill

    local hudHpText = Instance.new("TextLabel")
    hudHpText.Parent = hudHpBack
    hudHpText.BackgroundTransparency = 1
    hudHpText.Size = UDim2.new(1, 0, 1, 0)
    hudHpText.Font = Enum.Font.GothamBold
    hudHpText.Text = "100 / 100"
    hudHpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hudHpText.TextSize = 10
    hudHpText.TextXAlignment = Enum.TextXAlignment.Center

    local targetHudEnabled = false
    local hudRay = RaycastParams.new()
    local hudIgnore = {}
    RunService.Heartbeat:Connect(function()
        if not ALIVE then return end
        if not targetHudEnabled then
            targetHudFrame.Visible = false
            return
        end
        local now = os.clock()
        local plr = nil
        if aimbotTargetPlr and (now - aimbotTargetAt) <= 1 then
            plr = aimbotTargetPlr
        end
        if not plr then
            local cam = workspace.CurrentCamera
            if cam and game:GetService("Players") then
                hudRay.FilterType = Enum.RaycastFilterType.Exclude
                hudIgnore[1] = player.Character
                hudRay.FilterDescendantsInstances = hudIgnore
                local hit = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 800, hudRay)
                if hit then
                    local ch = hit.Instance:FindFirstAncestorOfClass("Model")
                    if ch then
                        local p = Players:GetPlayerFromCharacter(ch)
                        if p and p ~= player then
                            aimbotTargetPlr = p
                            aimbotTargetAt = now
                            plr = p
                        end
                    end
                end
            end
        end
        if not plr then
            targetHudFrame.Visible = false
            return
        end
        local ch = plr.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then
            targetHudFrame.Visible = false
            return
        end
        targetHudFrame.Visible = true
        hudName.Text = plr.Name
        local hp = math.floor(hum.Health + 0.5)
        local mh = math.floor(hum.MaxHealth + 0.5)
        local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        hudHpFill.Size = UDim2.new(ratio, 0, 1, 0)
        hudHpFill.BackgroundColor3 = Color3.fromRGB(230, 70, 70):Lerp(Color3.fromRGB(120, 220, 120), ratio)
        hudHpText.Text = tostring(hp) .. " / " .. tostring(mh)
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and url then hudAvatar.Image = url end
    end)

    createCheckbox(espBody, "Self Head ESP", false, function(v) setSelfHead(not not v) end)
    createCheckbox(espBody, "Target HUD", false, function(v) targetHudEnabled = not not v; espSettings.TargetHUD = not not v end)

    createCheckbox(espBody, "Box ESP", false, function(v) espSettings.Box = v end)
    createCheckbox(espBody, "Head Hitbox ESP", false, function(v) espSettings.HeadHitbox = v end)
    createCheckbox(espBody, "Health ESP", false, function(v) espSettings.Health = v end)
    createCheckbox(espBody, "Avatar ESP", false, function(v) espSettings.Avatar = v end)
    createCheckbox(espBody, "Name ESP", false, function(v) espSettings.Name = v end)
    createCheckbox(espBody, "Skeleton ESP", false, function(v) espSettings.Skeleton = v end)
    createCheckbox(espBody, "Team Check", false, function(v) espSettings.TeamCheck = v end)

    createColorPicker(espBody, "Box Color", espSettings.BoxColor, function(c)
        espSettings.BoxColor = c
        for _, d in pairs(espObjects) do if d.BoxStroke then d.BoxStroke.Color = c end end
    end)
    createColorPicker(espBody, "Head Hitbox Color", espSettings.HeadColor, function(c)
        espSettings.HeadColor = c
        for _, d in pairs(espObjects) do if d.HeadBoxStroke then d.HeadBoxStroke.Color = c end end
    end)
    createColorPicker(espBody, "Skeleton Color", espSettings.SkeletonColor, function(c)
        espSettings.SkeletonColor = c
        for _, d in pairs(espObjects) do
            for _, l in ipairs(d.SkeletonLines) do l.BackgroundColor3 = c end
        end
    end)
    createColorPicker(espBody, "Name Color", espSettings.NameColor, function(c)
        espSettings.NameColor = c
        for _, d in pairs(espObjects) do if d.NameLabel then d.NameLabel.TextColor3 = c end end
    end)
    createColorPicker(espBody, "Health Color", espSettings.HealthColor, function(c) espSettings.HealthColor = c end)
    createColorPicker(espBody, "Avatar Color", espSettings.AvatarColor, function(c)
        espSettings.AvatarColor = c
        for _, d in pairs(espObjects) do if d.AvatarStroke then d.AvatarStroke.Color = c end end
    end)

    createColorPicker(worldBody, "World Color", worldState.Color, function(c)
        worldState.Color = c
        worldState.ColorEnabled = true
        if worldState.ColorEnabled then
            Lighting.Ambient = c
            Lighting.OutdoorAmbient = c
        end
    end)
    createCheckbox(worldBody, "Rain", false, function(v) worldState.RainEnabled = v end)
    local nightApplied = false
    createCheckbox(worldBody, "Night Mode", false, function(v)
        worldState.NightEnabled = v
        if v then
            nightApplied = true
            Lighting.ClockTime = 0
            Lighting.Brightness = 0.5
        elseif nightApplied then
            nightApplied = false
            Lighting.ClockTime = 14
            Lighting.Brightness = 2
        end
    end)
end

---------------------------------------------------------------------
-- THIRD PERSON (forced, works even if the game blocks it)
---------------------------------------------------------------------
do
    local card = Instance.new("Frame")
    card.Parent = miscTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 104)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Third Person"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle

    local hint = Instance.new("TextLabel")
    hint.Parent = card
    hint.BackgroundTransparency = 1
    hint.Position = UDim2.new(0, 14, 0, 38)
    hint.Size = UDim2.new(1, -28, 0, 14)
    hint.Font = Enum.Font.Gotham
    hint.Text = "forces the camera even if the game blocks it (wheel = distance)"
    hint.TextColor3 = Color3.fromRGB(110, 110, 120)
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left

    local distLbl = Instance.new("TextLabel")
    distLbl.Parent = card
    distLbl.BackgroundTransparency = 1
    distLbl.Position = UDim2.new(0, 14, 0, 58)
    distLbl.Size = UDim2.new(0, 120, 0, 16)
    distLbl.Font = Enum.Font.Gotham
    distLbl.Text = "Distance"
    distLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    distLbl.TextSize = 11
    distLbl.TextXAlignment = Enum.TextXAlignment.Left

    tpValueLabel = Instance.new("TextLabel")
    tpValueLabel.Parent = card
    tpValueLabel.BackgroundTransparency = 1
    tpValueLabel.Position = UDim2.new(1, -64, 0, 58)
    tpValueLabel.Size = UDim2.new(0, 50, 0, 16)
    tpValueLabel.Font = Enum.Font.GothamMedium
    tpValueLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    tpValueLabel.TextSize = 11
    tpValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton")
    track.Parent = card
    track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 14, 0, 84)
    track.Size = UDim2.new(1, -28, 0, 8)
    track.Text = ""
    track.AutoButtonColor = false

    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = track

    tpSliderFill = Instance.new("Frame")
    tpSliderFill.Parent = track
    tpSliderFill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    tpSliderFill.BorderSizePixel = 0
    tpSliderFill.Size = UDim2.new(0, 0, 1, 0)

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = tpSliderFill

    updateTPDistanceUI = function(tween)
        local pct = math.clamp((tpDistance - tpMinDistance) / (tpMaxDistance - tpMinDistance), 0, 1)
        tpValueLabel.Text = tostring(math.floor(tpDistance + 0.5))
        if tween then
            TweenService:Create(tpSliderFill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        else
            tpSliderFill.Size = UDim2.new(pct, 0, 1, 0)
        end
    end
    local function setTPDistance(v)
        tpDistance = math.clamp(v, tpMinDistance, tpMaxDistance)
        updateTPDistanceUI(true)
    end
    local function setFromInput(inputX)
        local relX = math.clamp(inputX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct = relX / math.max(track.AbsoluteSize.X, 1)
        tpDistance = tpMinDistance + pct * (tpMaxDistance - tpMinDistance)
        updateTPDistanceUI(false)
    end
    local tpDragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tpDragging = true
            setFromInput(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then tpDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tpDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromInput(input.Position.X)
        end
    end)
    updateTPDistanceUI(false)

    -- forced camera -------------------------------------------------
    local BIND = "SkeetroThirdPerson"
    local CAM_PRIO = 9000
    local yaw, pitch = 0, 0
    local SENS = 0.0035
    local SHOULDER = 2.6
    local curLook = Vector3.new(0, 0, -1)
    local UP_V = Vector3.new(0, 1, 0)
    local function rightOf(l)
        local r = l:Cross(UP_V)
        if r.Magnitude < 0.0001 then
            return Vector3.new(1, 0, 0)
        end
        return r.Unit
    end
    local function camPosOf(l, focus)
        return focus - l * tpDistance + rightOf(l) * SHOULDER
    end
    local tpLastChar = nil
    local tpCachedParts = {}

    local function angLerp(a, b, t)
        local d = (b - a) % (2 * math.pi)
        if d > math.pi then d = d - 2 * math.pi end
        return a + d * t
    end

    local function stopCamera()
        pcall(function() RunService:UnbindFromRenderStep(BIND) end)
        pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
        local cam = workspace.CurrentCamera
        if cam then pcall(function() cam.CameraType = Enum.CameraType.Custom end) end
    end

    updateTPToggle = function(state)
        tpEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        if not state then
            stopCamera()
            return
        end
        local cam = workspace.CurrentCamera
        if cam then
            local look = cam.CFrame.LookVector
            yaw = math.atan(-look.X, -look.Z)
            pitch = math.asin(math.clamp(look.Y, -1, 1))
            curLook = look
        end
        pcall(function() RunService:UnbindFromRenderStep(BIND) end)
        pcall(function()
            RunService:BindToRenderStep(BIND, CAM_PRIO, function()
                if not ALIVE or not tpEnabled then return end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local c = workspace.CurrentCamera
                if not (c and hum and hrp and hum.Health > 0) then return end
                -- runs after the game camera, so it always wins
                if c.CameraType ~= Enum.CameraType.Scriptable then
                    c.CameraType = Enum.CameraType.Scriptable
                end
                if c.CameraSubject ~= hum then
                    c.CameraSubject = hum
                end
                -- the engine thinks we are in first person and hides the model:
                -- cache the part list once per character instead of allocating
                -- the whole descendants table on every render frame
                if tpLastChar ~= char then
                    tpLastChar = char
                    tpCachedParts = {}
                    for _, d in ipairs(char:GetDescendants()) do
                        if d:IsA("BasePart") then
                            table.insert(tpCachedParts, d)
                        end
                    end
                end
                for _, part in ipairs(tpCachedParts) do
                    if part.LocalTransparencyModifier ~= 0 then
                        part.LocalTransparencyModifier = 0
                    end
                end

                local focus = hrp.Position + Vector3.new(0, 2, 0)

                local aiming = aimbotSettings.Enabled and aimFeedPos ~= nil

                if aiming then
                    -- aim FROM the over-the-shoulder camera: the crosshair
                    -- lands exactly on the target, no yaw/pitch feedback loop
                    local solved = curLook
                    for _ = 1, 4 do
                        solved = (aimFeedPos - camPosOf(solved, focus)).Unit
                    end
                    local aimMode = aimbotSettings.AimMode or "Normal"
                    local t = (aimMode == "Smooth") and aimbotSettings.Smoothness or 1
                    if t >= 1 then
                        -- exact snap: final direction from the actual shoulder cam
                        curLook = (aimFeedPos - camPosOf(solved, focus)).Unit
                    else
                        local mixed = curLook:Lerp(solved, t)
                        if mixed.Magnitude > 0.001 then
                            curLook = mixed.Unit
                        else
                            curLook = solved
                        end
                    end
                    -- keep stored angles in sync for a smooth mouse handover
                    pitch = math.asin(math.clamp(curLook.Y, -1, 1))
                    yaw = math.atan(-curLook.X, -curLook.Z)
                else
                    local delta = UserInputService:GetMouseDelta()
                    if delta.X ~= 0 or delta.Y ~= 0 then
                        yaw = yaw - delta.X * SENS
                        pitch = math.clamp(pitch - delta.Y * SENS, -1.4, 1.4)
                    end
                    local cp, sp = math.cos(pitch), math.sin(pitch)
                    curLook = Vector3.new(-math.sin(yaw) * cp, sp, -math.cos(yaw) * cp)
                end

                local camPos = camPosOf(curLook, focus)
                c.CFrame = CFrame.new(camPos, camPos + curLook)
                if player.CameraMode ~= Enum.CameraMode.Classic then
                    pcall(function() player.CameraMode = Enum.CameraMode.Classic end)
                end
                if player.CameraMaxZoomDistance ~= tpDistance then
                    pcall(function()
                        player.CameraMinZoomDistance = tpDistance
                        player.CameraMaxZoomDistance = tpDistance
                    end)
                end
            end)
        end)
    end


    UserInputService.InputChanged:Connect(function(input)
        if not ALIVE or not tpEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            setTPDistance(tpDistance - input.Position.Z * 1.5)
        end
    end)

    -- hold RMB to spin the camera (locks the cursor so rotation never stops)
    UserInputService.InputBegan:Connect(function(input)
        if not ALIVE or not tpEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter end)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            pcall(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function() updateTPToggle(not tpEnabled) end)
end

---------------------------------------------------------------------
-- GHOST (Misc): under the map, head hidden, no fall
---------------------------------------------------------------------
do
    local card = Instance.new("Frame")
    card.Parent = miscTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 104)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Ghost"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(1, 0)
    cc.Parent = circle

    updateGhostToggle = function(state)
        ghostEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
        if state then
            local ch = player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then ghostBaseY = hrp.Position.Y end
        else
            -- pop back up onto the floor
            local ch = player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp and ghostBaseY then
                hrp.CFrame = CFrame.new(hrp.Position.X, ghostBaseY, hrp.Position.Z)
            end
            ghostBaseY = nil
        end
    end
    updateGhostToggle(false)
    toggleBtn.MouseButton1Click:Connect(function() updateGhostToggle(not ghostEnabled) end)

    local depthLbl = Instance.new("TextLabel")
    depthLbl.Parent = card
    depthLbl.BackgroundTransparency = 1
    depthLbl.Position = UDim2.new(0, 14, 0, 46)
    depthLbl.Size = UDim2.new(0, 160, 0, 16)
    depthLbl.Font = Enum.Font.Gotham
    depthLbl.Text = "Depth"
    depthLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    depthLbl.TextSize = 11
    depthLbl.TextXAlignment = Enum.TextXAlignment.Left

    ghostDepthValue = Instance.new("TextLabel")
    ghostDepthValue.Parent = card
    ghostDepthValue.BackgroundTransparency = 1
    ghostDepthValue.Position = UDim2.new(1, -84, 0, 46)
    ghostDepthValue.Size = UDim2.new(0, 70, 0, 16)
    ghostDepthValue.Font = Enum.Font.GothamMedium
    ghostDepthValue.TextColor3 = Color3.fromRGB(240, 240, 240)
    ghostDepthValue.TextSize = 11
    ghostDepthValue.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton")
    track.Parent = card
    track.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    track.BorderSizePixel = 0
    track.Position = UDim2.new(0, 14, 0, 72)
    track.Size = UDim2.new(1, -28, 0, 8)
    track.Text = ""
    track.AutoButtonColor = false

    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = track

    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0, 0, 1, 0)

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    ghostDepthUI = function(tween)
        ghostDepthValue.Text = tostring(ghostDepth) .. " st"
        local pct = math.clamp((ghostDepth - 1) / 19, 0, 1)
        if tween then
            TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        else
            fill.Size = UDim2.new(pct, 0, 1, 0)
        end
    end

    local dragging = false
    local function setDepthFromX(inputX)
        local relX = math.clamp(inputX - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct = relX / math.max(track.AbsoluteSize.X, 1)
        ghostDepth = math.floor(1 + pct * 19 + 0.5)
        ghostDepthUI(false)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setDepthFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setDepthFromX(input.Position.X)
        end
    end)
    ghostDepthUI(false)

    -- lock Y just under the map so you walk there "on the floor" instead of falling
    local lastChar = nil
    RunService.Heartbeat:Connect(function()
        if not ALIVE then return end
        if not ghostEnabled then
            lastChar = nil
            return
        end
        local ch = player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0) then return end
        if ch ~= lastChar then
            lastChar = ch
            ghostBaseY = hrp.Position.Y
        end
        if ghostBaseY == nil then ghostBaseY = hrp.Position.Y end
        local y = ghostBaseY - ghostDepth
        local ori = hrp.Orientation
        hrp.CFrame = CFrame.new(hrp.Position.X, y, hrp.Position.Z) * CFrame.Angles(0, math.rad(ori.Y), 0)
        local lv = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(lv.X, 0, lv.Z)
    end)
end
local blinkEnabled = false
local updateBlinkToggle = nil

---------------------------------------------------------------------
-- BLINK (Misc)
---------------------------------------------------------------------
do
    local card = Instance.new("Frame")
    card.Parent = miscTab.Body
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1, 0, 0, 78)

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(36, 36, 42)
    s.Thickness = 1
    s.Parent = card

    local title = Instance.new("TextLabel")
    title.Parent = card
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 20)
    title.Font = Enum.Font.GothamMedium
    title.Text = "Blink"
    title.TextColor3 = Color3.fromRGB(230, 230, 235)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = card
    toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Position = UDim2.new(1, -54, 0, 12)
    toggleBtn.Size = UDim2.new(0, 42, 0, 22)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggleBtn

    local circle = Instance.new("Frame")
    circle.Parent = toggleBtn
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
    circle.BorderSizePixel = 0
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.Size = UDim2.new(0, 16, 0, 16)

    local ccv2 = Instance.new("UICorner")
    ccv2.CornerRadius = UDim.new(1, 0)
    ccv2.Parent = circle

    updateBlinkToggle = function(state)
        blinkEnabled = state
        local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local targetBg = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 40)
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    end
    updateBlinkToggle(false)
    toggleBtn.MouseButton1Click:Connect(function() updateBlinkToggle(not blinkEnabled) end)

    local hint = Instance.new("TextLabel")
    hint.Parent = card
    hint.BackgroundTransparency = 1
    hint.Position = UDim2.new(0, 14, 0, 44)
    hint.Size = UDim2.new(1, -28, 0, 26)
    hint.Font = Enum.Font.Gotham
    hint.Text = "Press B to teleport to whatever the cursor is pointing at. Have fun."
    hint.TextColor3 = Color3.fromRGB(120, 120, 135)
    hint.TextSize = 10
    hint.TextWrapped = true
    hint.TextXAlignment = Enum.TextXAlignment.Left

    local blinkRay = RaycastParams.new()
    blinkRay.FilterType = Enum.RaycastFilterType.Exclude
    local blinkIgnore = {}

    UserInputService.InputBegan:Connect(function(input, gp)
        if not ALIVE or not blinkEnabled then return end
        if input.KeyCode == Enum.KeyCode.B then
            local cam = workspace.CurrentCamera
            if not cam then return end
            local mouseLoc = UserInputService:GetMouseLocation()
            local mRay = cam:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
            blinkIgnore[1] = player.Character
            blinkRay.FilterDescendantsInstances = blinkIgnore
            local hit = workspace:Raycast(mRay.Origin, mRay.Direction * 1000, blinkRay)
            local targetPos = hit and hit.Position or (mRay.Origin + mRay.Direction * 1000)
            local ch = player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                -- restore full collider position relative to hit
                local lv = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(lv.X, 0, lv.Z)
            end
        end
    end)
end

---------------------------------------------------------------------
-- MISC: CONFIGS
---------------------------------------------------------------------
do
    local CONFIG_FOLDER = "CleanTabConfigs"

    local function fsSupported()
        return typeof(writefile) == "function"
            and typeof(readfile) == "function"
            and typeof(makefolder) == "function"
    end

    if fsSupported() then pcall(function() makefolder(CONFIG_FOLDER) end) end

    local function serialize(val)
        if typeof(val) == "Color3" then
            return string.format("Color3.fromRGB(%d,%d,%d)", math.floor(val.R*255), math.floor(val.G*255), math.floor(val.B*255))
        end
        if typeof(val) == "Vector3" then
            return string.format("Vector3.new(%f,%f,%f)", val.X, val.Y, val.Z)
        end
        local t = type(val)
        if t == "number" then return tostring(val) end
        if t == "boolean" then return tostring(val) end
        if t == "string" then return string.format("%q", val) end
        if t == "table" then
            local parts = {"{"}
            for k, v in pairs(val) do
                local key
                if type(k) == "string" and k:match("^[%a_][%w_]*$") then key = k .. "="
                else key = "[" .. serialize(k) .. "]=" end
                table.insert(parts, key .. serialize(v) .. ",")
            end
            table.insert(parts, "}")
            return table.concat(parts)
        end
        return "nil"
    end

    local AUTOSAVE_FILE = "_autosave"

    local function buildConfigData()
        local keybindsOut = {}
        if keybindFeatures then
            for _, f in ipairs(keybindFeatures) do
                if f.key then
                    keybindsOut[f.id] = (typeof(f.key) == "EnumItem") and f.key.Name or tostring(f.key)
                end
            end
        end
        return {
            ESP = espSettings,
            World = worldState,
            GUI = guiColors,
            Velocity = { Enabled = velocityEnabled, Speed = velocitySpeed },
            Fly = { Enabled = flyEnabled, Speed = flySpeed, Method = flyMethod },
            Aimbot = {
                Enabled = aimbotSettings.Enabled,
                VisibleCheck = aimbotSettings.VisibleCheck,
                FOV = aimbotSettings.FOV,
                Smoothness = aimbotSettings.Smoothness,
                AimMode = aimbotSettings.AimMode,
                TargetPart = aimbotSettings.TargetPart,
                Keybind = serializeKeybind(aimbotSettings.Keybind),
            },
            ThirdPerson = { Enabled = tpEnabled, Distance = tpDistance },
            Trigger = { Enabled = trigEnabled, Delay = trigDelay, TeamCheck = trigTeamCheck, VisibleCheck = trigVisCheck },
            Spin = { Enabled = spinEnabled, Speed = spinSpeed },
            AntiAim = { Enabled = aaEnabled, Mode = aaMode, Jitter = aaJitter, Rate = aaRate },
            Ghost = { Enabled = ghostEnabled, Depth = ghostDepth },

            Blink = { Enabled = blinkEnabled },
            Keybinds = keybindsOut,
        }
    end

            applyConfigData = function(loaded)
                if loaded.ESP then
                    for k, v in pairs(loaded.ESP) do
                        if espSettings[k] ~= nil then espSettings[k] = v end
                    end
                end
                if loaded.World then
                    for k, v in pairs(loaded.World) do
                        if worldState[k] ~= nil then worldState[k] = v end
                    end
                end
                if loaded.GUI then
                    for k, v in pairs(loaded.GUI) do
                        if guiColors[k] ~= nil then guiColors[k] = v end
                    end
                end
                if loaded.Velocity then
                    velocityEnabled = not not loaded.Velocity.Enabled
                    velocitySpeed = math.clamp(tonumber(loaded.Velocity.Speed) or velocitySpeed, 1, maxSpeed)
                end
                if loaded.Fly then
                    flyEnabled = not not loaded.Fly.Enabled
                    flySpeed = math.clamp(tonumber(loaded.Fly.Speed) or flySpeed, 5, flyMaxSpeed)
                    if loaded.Fly.Method and methodButtons[loaded.Fly.Method] then setFlyMethod(loaded.Fly.Method) end
                end
                if loaded.Aimbot then
                    updateAimToggle(not not loaded.Aimbot.Enabled)
                    setVisCheck(not not loaded.Aimbot.VisibleCheck)
                    aimbotSettings.FOV = math.clamp(tonumber(loaded.Aimbot.FOV) or aimbotSettings.FOV, 20, fovMax)
                    fovValue.Text = tostring(aimbotSettings.FOV)
                    TweenService:Create(fovFill, TweenInfo.new(0.1), {Size = UDim2.new(aimbotSettings.FOV / fovMax, 0, 1, 0)}):Play()
                    if loaded.Aimbot.Smoothness ~= nil then
                        aimbotSettings.Smoothness = math.clamp(tonumber(loaded.Aimbot.Smoothness) or aimbotSettings.Smoothness, 0.05, 1)
                    end
                    if updateSmoothUI then updateSmoothUI(true) end
                    if type(loaded.Aimbot.TargetPart) == "string" and targetButtons and targetButtons[loaded.Aimbot.TargetPart] then
                        if setTargetPart then setTargetPart(loaded.Aimbot.TargetPart) end
                    end
                    if loaded.Aimbot.TeamCheck ~= nil and setAimTeam then
                        setAimTeam(not not loaded.Aimbot.TeamCheck)
                    end
                    if loaded.Aimbot.AimMode == "Normal" or loaded.Aimbot.AimMode == "Smooth" or loaded.Aimbot.AimMode == "Prediction" then
                        if setAimMode then setAimMode(loaded.Aimbot.AimMode) end
                    end
                    aimbotSettings.Keybind = deserializeKeybind(loaded.Aimbot.Keybind)
                    updateBindLabel()
                end
                if loaded.ThirdPerson then
                    tpEnabled = not not loaded.ThirdPerson.Enabled
                    tpDistance = math.clamp(tonumber(loaded.ThirdPerson.Distance) or tpDistance, tpMinDistance, tpMaxDistance)
                    if updateTPDistanceUI then updateTPDistanceUI(true) end
                    if updateTPToggle then updateTPToggle(tpEnabled) end
                end
                if loaded.Trigger then
                    trigEnabled = not not loaded.Trigger.Enabled
                    trigDelay = math.clamp(tonumber(loaded.Trigger.Delay) or trigDelay, 0, 500)
                    trigTeamCheck = not not loaded.Trigger.TeamCheck
                    trigVisCheck = not not loaded.Trigger.VisibleCheck
                    if updateTrigToggle then updateTrigToggle(trigEnabled) end
                    if setTrigTeam then setTrigTeam(trigTeamCheck) end
                    if setTrigVis then setTrigVis(trigVisCheck) end
                    if trigDelayUI then trigDelayUI(true) end
                end
                if loaded.Spin then
                    spinEnabled = not not loaded.Spin.Enabled
                    spinSpeed = math.clamp(tonumber(loaded.Spin.Speed) or spinSpeed, 60, 1080)
                    if updateSpinToggle then updateSpinToggle(spinEnabled) end
                    if spinSpeedUI then spinSpeedUI(true) end
                end
                if loaded.AntiAim then
                    aaEnabled = not not loaded.AntiAim.Enabled
                    aaJitter = math.clamp(tonumber(loaded.AntiAim.Jitter) or aaJitter, 10, 180)
                    aaRate = math.clamp(tonumber(loaded.AntiAim.Rate) or aaRate, 1, 30)
                    if type(loaded.AntiAim.Mode) == "string" and setAAMode then setAAMode(loaded.AntiAim.Mode) end
                    if updateAAToggle then updateAAToggle(aaEnabled) end
                    if aaUI then aaUI(true) end
                end
                if loaded.Ghost then
                    ghostEnabled = not not loaded.Ghost.Enabled
                    ghostDepth = math.clamp(tonumber(loaded.Ghost.Depth) or ghostDepth, 1, 20)
                    if updateGhostToggle then updateGhostToggle(ghostEnabled) end
                    if ghostDepthUI then ghostDepthUI(true) end
                end

                if loaded.Blink then
                    blinkEnabled = not not loaded.Blink.Enabled
                    if updateBlinkToggle then updateBlinkToggle(blinkEnabled) end
                end
                if type(loaded.Keybinds) == "table" and keybindFeatures then
                    for _, f in ipairs(keybindFeatures) do
                        local kn = loaded.Keybinds[f.id]
                        if type(kn) == "string" then
                            local kc
                            pcall(function() kc = Enum.KeyCode[kn] end)
                            if kc == nil then pcall(function() kc = Enum.UserInputType[kn] end) end
                            f.key = kc
                        end
                    end
                    if refreshKeybindLabels then refreshKeybindLabels() end
                end

                if checkboxSetters["Box ESP"] then checkboxSetters["Box ESP"](espSettings.Box) end
                if checkboxSetters["Head Hitbox ESP"] then checkboxSetters["Head Hitbox ESP"](espSettings.HeadHitbox) end
                if checkboxSetters["Health ESP"] then checkboxSetters["Health ESP"](espSettings.Health) end
                if checkboxSetters["Avatar ESP"] then checkboxSetters["Avatar ESP"](espSettings.Avatar) end
                if checkboxSetters["Name ESP"] then checkboxSetters["Name ESP"](espSettings.Name) end
                if checkboxSetters["Skeleton ESP"] then checkboxSetters["Skeleton ESP"](espSettings.Skeleton) end
                if checkboxSetters["Team Check"] then checkboxSetters["Team Check"](espSettings.TeamCheck) end
                if checkboxSetters["Self Head ESP"] then checkboxSetters["Self Head ESP"](espSettings.SelfHead) end
                if checkboxSetters["Target HUD"] then checkboxSetters["Target HUD"](espSettings.TargetHUD) end
                if checkboxSetters["Rain"] then checkboxSetters["Rain"](worldState.RainEnabled) end
                if checkboxSetters["Night Mode"] then checkboxSetters["Night Mode"](worldState.NightEnabled) end

                if colorPickerSetters["Box Color"] then colorPickerSetters["Box Color"](espSettings.BoxColor) end
                if colorPickerSetters["Head Hitbox Color"] then colorPickerSetters["Head Hitbox Color"](espSettings.HeadColor) end
                if colorPickerSetters["Skeleton Color"] then colorPickerSetters["Skeleton Color"](espSettings.SkeletonColor) end
                if colorPickerSetters["Name Color"] then colorPickerSetters["Name Color"](espSettings.NameColor) end
                if colorPickerSetters["Health Color"] then colorPickerSetters["Health Color"](espSettings.HealthColor) end
                if colorPickerSetters["Avatar Color"] then colorPickerSetters["Avatar Color"](espSettings.AvatarColor) end
                if colorPickerSetters["World Color"] then colorPickerSetters["World Color"](worldState.Color) end
                if colorPickerSetters["Accent Color"] then colorPickerSetters["Accent Color"](guiColors.Accent) end
                if colorPickerSetters["Background Color"] then colorPickerSetters["Background Color"](guiColors.Background) end
                if colorPickerSetters["Panel Color"] then colorPickerSetters["Panel Color"](guiColors.Panel) end
                if colorPickerSetters["Text Color"] then colorPickerSetters["Text Color"](guiColors.Text) end

                applyGuiColors()

                sliderValueLabel.Text = tostring(velocitySpeed)
                TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(velocitySpeed / maxSpeed, 0, 1, 0)}):Play()
                updateToggle(velocityEnabled)

                flySpeedValue.Text = tostring(flySpeed)
                TweenService:Create(flySliderFill, TweenInfo.new(0.1), {Size = UDim2.new(flySpeed / flyMaxSpeed, 0, 1, 0)}):Play()
                updateFlyToggle(flyEnabled)
            end

    AUTOSAVE_HOOK = function()
        if not fsSupported() then return false end
        local ok, payload = pcall(function() return "return " .. serialize(buildConfigData()) end)
        if not ok or type(payload) ~= "string" then return false end
        return (pcall(function()
            makefolder(CONFIG_FOLDER)
            writefile(CONFIG_FOLDER .. "/" .. AUTOSAVE_FILE .. ".cfg", payload)
        end))
    end

    -- background save: writes only when something actually changed
    task.spawn(function()
        local last = ""
        while ALIVE do
            task.wait(10)
            if not ALIVE then break end
            if fsSupported() then
                local ok, payload = pcall(function() return "return " .. serialize(buildConfigData()) end)
                if ok and type(payload) == "string" and payload ~= last then
                    last = payload
                    pcall(function()
                        makefolder(CONFIG_FOLDER)
                        writefile(CONFIG_FOLDER .. "/" .. AUTOSAVE_FILE .. ".cfg", payload)
                    end)
                end
            end
        end
    end)

    -- applied at the very end of the script, after every widget exists
    if fsSupported() then
        for _, cand in ipairs({CONFIG_FOLDER .. "/" .. AUTOSAVE_FILE .. ".cfg", CONFIG_FOLDER .. "\\" .. AUTOSAVE_FILE .. ".cfg"}) do
            local ok, res = pcall(readfile, cand)
            if ok and type(res) == "string" and #res > 0 then
                RESTORE_DATA = res
                break
            end
        end
    end
end
---------------------------------------------------------------------
-- MISC: GUI COLORS
---------------------------------------------------------------------
do
    local sec = Instance.new("Frame")
    sec.Parent = miscTab.Body
    sec.BackgroundTransparency = 1
    sec.Size = UDim2.new(1, 0, 0, 24)

    local lbl = Instance.new("TextLabel")
    lbl.Parent = sec
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = "GUI COLORS"
    lbl.TextColor3 = Color3.fromRGB(200, 200, 205)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    createColorPicker(miscTab.Body, "Accent Color",     guiColors.Accent,     function(c) guiColors.Accent = c; applyGuiColors() end)
    createColorPicker(miscTab.Body, "Background Color", guiColors.Background, function(c) guiColors.Background = c; applyGuiColors() end)
    createColorPicker(miscTab.Body, "Panel Color",      guiColors.Panel,      function(c) guiColors.Panel = c; applyGuiColors() end)
    createColorPicker(miscTab.Body, "Text Color",       guiColors.Text,       function(c) guiColors.Text = c; applyGuiColors() end)
end

---------------------------------------------------------------------
-- RAIN
---------------------------------------------------------------------
do
    local RainGui = Instance.new("ScreenGui")
    RainGui.Name = "CleanTabRainGui"
    RainGui.ResetOnSpawn = false
    RainGui.IgnoreGuiInset = true
    RainGui.DisplayOrder = 5
    RainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    RainGui.Parent = playerGui

    local RAIN_COUNT = 120
    local drops = {}

    for i = 1, RAIN_COUNT do
        local d = Instance.new("Frame")
        d.BackgroundColor3 = worldState.RainColor
        d.BackgroundTransparency = 0.35
        d.BorderSizePixel = 0
        d.ZIndex = 1
        d.Visible = false
        d.Size = UDim2.new(0, 1, 0, math.random(8, 22))
        d.Position = UDim2.new(0, math.random(0, 2000), 0, math.random(-1000, 0))
        d.Parent = RainGui
        drops[i] = {Frame = d, Speed = math.random(700, 1400) / 10}
    end

    RunService.RenderStepped:Connect(function(dt)
        if not ALIVE then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vps = cam.ViewportSize
        for i = 1, RAIN_COUNT do
            local drop = drops[i]
            local frame = drop.Frame
            if not worldState.RainEnabled then
                if frame.Visible then frame.Visible = false end
            else
                if not frame.Visible then
                    frame.Visible = true
                    frame.Position = UDim2.new(0, math.random(0, vps.X), 0, math.random(-vps.Y, 0))
                    frame.BackgroundColor3 = worldState.RainColor
                end
                local newY = frame.Position.Y.Offset + drop.Speed * dt * 10
                local newX = frame.Position.X.Offset - 1.2
                if newY > vps.Y + 40 then
                    newY = -math.random(20, 200)
                    newX = math.random(0, vps.X)
                end
                frame.Position = UDim2.new(0, newX, 0, newY)
                frame.BackgroundTransparency = 0.25 + math.random() * 0.3
            end
        end
    end)
end

---------------------------------------------------------------------
-- WATERMARK
---------------------------------------------------------------------
do
    local WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name = "CleanTabWatermark"
    WatermarkGui.ResetOnSpawn = false
    WatermarkGui.IgnoreGuiInset = true
    WatermarkGui.DisplayOrder = 1500
    WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WatermarkGui.Parent = playerGui

    local wm = Instance.new("Frame")
    wm.Parent = WatermarkGui
    wm.AnchorPoint = Vector2.new(0.5, 0)
    wm.Position = UDim2.new(0.5, 0, 0, 10)
    wm.Size = UDim2.new(0, 340, 0, 26)
    wm.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    wm.BackgroundTransparency = 0.05
    wm.BorderSizePixel = 0

    local wmc = Instance.new("UICorner")
    wmc.CornerRadius = UDim.new(0, 4)
    wmc.Parent = wm

    local wms = Instance.new("UIStroke")
    wms.Color = Color3.fromRGB(30, 30, 36)
    wms.Thickness = 1
    wms.Parent = wm

    local accentBar = Instance.new("Frame")
    accentBar.Parent = wm
    accentBar.BackgroundColor3 = guiColors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 3, 1, 0)

    local abc = Instance.new("UICorner")
    abc.CornerRadius = UDim.new(0, 4)
    abc.Parent = accentBar

    local wmName = Instance.new("TextLabel")
    wmName.Parent = wm
    wmName.BackgroundTransparency = 1
    wmName.Position = UDim2.new(0, 10, 0, 0)
    wmName.Size = UDim2.new(1, -110, 1, 0)
    wmName.Font = Enum.Font.GothamBold
    wmName.TextSize = 12
    wmName.TextXAlignment = Enum.TextXAlignment.Left
    wmName.TextYAlignment = Enum.TextYAlignment.Center
    wmName.TextColor3 = Color3.fromRGB(235, 235, 245)
    wmName.Text = "https://t.me/qwenixclient"

    local sep1 = Instance.new("Frame")
    sep1.Parent = wm
    sep1.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sep1.BorderSizePixel = 0
    sep1.AnchorPoint = Vector2.new(0.5, 0.5)
    sep1.Position = UDim2.new(1, -105, 0.5, 0)
    sep1.Size = UDim2.new(0, 1, 0, 14)

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Parent = wm
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Position = UDim2.new(1, -100, 0, 0)
    fpsLabel.Size = UDim2.new(0, 45, 1, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 12
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.TextYAlignment = Enum.TextYAlignment.Center
    fpsLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
    fpsLabel.Text = "-- FPS"

    local sep2 = Instance.new("Frame")
    sep2.Parent = wm
    sep2.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sep2.BorderSizePixel = 0
    sep2.AnchorPoint = Vector2.new(0.5, 0.5)
    sep2.Position = UDim2.new(1, -54, 0.5, 0)
    sep2.Size = UDim2.new(0, 1, 0, 14)

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Parent = wm
    pingLabel.BackgroundTransparency = 1
    pingLabel.Position = UDim2.new(1, -50, 0, 0)
    pingLabel.Size = UDim2.new(0, 46, 1, 0)
    pingLabel.Font = Enum.Font.GothamBold
    pingLabel.TextSize = 12
    pingLabel.TextXAlignment = Enum.TextXAlignment.Center
    pingLabel.TextYAlignment = Enum.TextYAlignment.Center
    pingLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
    pingLabel.Text = "-- MS"

    local frames, fpsTime, currentFPS = 0, 0, 0

    RunService.RenderStepped:Connect(function(dt)
        if not ALIVE then return end
        frames = frames + 1
        fpsTime = fpsTime + dt
        if fpsTime >= 0.5 then
            currentFPS = math.floor(frames / fpsTime + 0.5)
            frames = 0
            fpsTime = 0
        end
    end)

    local function getPing()
        local ok, ping = pcall(function() return player:GetNetworkPing() * 1000 end)
        if ok and ping then return math.floor(ping) end
        local ok2, stats = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok2 and stats then return math.floor(stats) end
        return 0
    end

    task.spawn(function()
        while ALIVE do
            local ping = getPing()
            fpsLabel.Text = tostring(currentFPS) .. " FPS"
            pingLabel.Text = tostring(ping) .. " MS"
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while ALIVE do
            accentBar.BackgroundColor3 = guiColors.Accent
            task.wait(0.3)
        end
    end)
end

---------------------------------------------------------------------
-- KEYBINDS (bind any function) + final restore
---------------------------------------------------------------------
do
    keybindFeatures = {
        {id = "aimbot", label = "Aimbot",
            get = function() return aimbotSettings.Enabled end,
            set = function(v) if updateAimToggle then updateAimToggle(v) end end},
        {id = "trigger", label = "Triggerbot",
            get = function() return trigEnabled end,
            set = function(v) if updateTrigToggle then updateTrigToggle(v) end end},
        {id = "spin", label = "Spinbot",
            get = function() return spinEnabled end,
            set = function(v) if updateSpinToggle then updateSpinToggle(v) end end},
        {id = "antiaim", label = "Anti Aim",
            get = function() return aaEnabled end,
            set = function(v) if updateAAToggle then updateAAToggle(v) end end},
        {id = "ghost", label = "Ghost",
            get = function() return ghostEnabled end,
            set = function(v) if updateGhostToggle then updateGhostToggle(v) end end},

        {id = "blink", label = "Blink",
            get = function() return blinkEnabled end,
            set = function(v) if updateBlinkToggle then updateBlinkToggle(v) end end},
        {id = "fly", label = "Fly",
            get = function() return flyEnabled end,
            set = function(v) if updateFlyToggle then updateFlyToggle(v) end end},
        {id = "speed", label = "Speed",
            get = function() return velocityEnabled end,
            set = function(v) if updateToggle then updateToggle(v) end end},
        {id = "thirdperson", label = "Third Person",
            get = function() return tpEnabled end,
            set = function(v) if updateTPToggle then updateTPToggle(v) end end},
        {id = "esp", label = "ESP",
            get = function() return espSettings.Box or espSettings.Name or espSettings.Health end,
            set = function(v)
                for _, k in ipairs({"Box ESP", "Head Hitbox ESP", "Health ESP", "Name ESP", "Skeleton ESP", "Avatar ESP"}) do
                    if checkboxSetters[k] then checkboxSetters[k](v) end
                end
            end},
        {id = "rain", label = "Rain",
            get = function() return worldState.RainEnabled end,
            set = function(v) if checkboxSetters["Rain"] then checkboxSetters["Rain"](v) end end},
        {id = "night", label = "Night Mode",
            get = function() return worldState.NightEnabled end,
            set = function(v) if checkboxSetters["Night Mode"] then checkboxSetters["Night Mode"](v) end end},
    }

    local sec = Instance.new("Frame")
    sec.Parent = miscTab.Body
    sec.BackgroundTransparency = 1
    sec.Size = UDim2.new(1, 0, 0, 24)

    local secLabel = Instance.new("TextLabel")
    secLabel.Parent = sec
    secLabel.BackgroundTransparency = 1
    secLabel.Size = UDim2.new(1, 0, 1, 0)
    secLabel.Font = Enum.Font.GothamBold
    secLabel.Text = "KEYBINDS"
    secLabel.TextColor3 = Color3.fromRGB(200, 200, 205)
    secLabel.TextSize = 12
    secLabel.TextXAlignment = Enum.TextXAlignment.Left

    local listeningFeature = nil

    local function keyName(k)
        if k == nil then return "NONE" end
        if typeof(k) == "EnumItem" then return k.Name end
        return tostring(k)
    end

    refreshKeybindLabels = function()
        for _, f in ipairs(keybindFeatures) do
            if f.btn then
                f.btn.Text = keyName(f.key)
                f.btn.BackgroundColor3 = f.key and Color3.fromRGB(45, 55, 90) or Color3.fromRGB(35, 35, 40)
            end
        end
    end

    for _, f in ipairs(keybindFeatures) do
        local row = Instance.new("Frame")
        row.Parent = miscTab.Body
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, 30)

        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 6)
        rc.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Parent = row
        lbl.BackgroundTransparency = 1
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -120, 1, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.Text = f.label
        lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton")
        btn.Parent = row
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(1, -96, 0.5, -11)
        btn.Size = UDim2.new(0, 84, 0, 22)
        btn.Font = Enum.Font.GothamBold
        btn.Text = "NONE"
        btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        btn.TextSize = 11
        btn.AutoButtonColor = false

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 4)
        bc.Parent = btn

        f.btn = btn
        btn.MouseButton1Click:Connect(function()
            listeningFeature = f
            btn.Text = "..."
            btn.BackgroundColor3 = Color3.fromRGB(90, 70, 30)
        end)
    end
    refreshKeybindLabels()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not ALIVE then return end
        if listeningFeature then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Escape then
                    listeningFeature.key = nil
                else
                    listeningFeature.key = input.KeyCode
                end
            else
                listeningFeature.key = input.UserInputType
            end
            listeningFeature = nil
            refreshKeybindLabels()
            return
        end
        if gameProcessed then return end
        for _, f in ipairs(keybindFeatures) do
            local k = f.key
            if k ~= nil and typeof(k) == "EnumItem" then
                local hit = (k.EnumType == Enum.KeyCode and input.KeyCode == k)
                    or (k.EnumType == Enum.UserInputType and input.UserInputType == k)
                if hit then
                    pcall(f.set, not f.get())
                    break
                end
            end
        end
    end)

    -- apply the saved state now that every widget exists
    if RESTORE_DATA and applyConfigData then
        local okL, fn = pcall(loadstring, RESTORE_DATA)
        if okL and fn then
            local ok3, loaded = pcall(fn)
            if ok3 and type(loaded) == "table" and pcall(applyConfigData, loaded) then
                pcall(toast, "Settings restored", Color3.fromRGB(120, 220, 120))
            end
        end
    end
end