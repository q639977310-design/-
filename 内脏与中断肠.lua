local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local lp      = Players.LocalPlayer

local G = (type(getgenv) == "function") and getgenv() or _G
local CFG = G.MYQF_AutoShoot
if type(CFG) ~= "table" then CFG = {} end
G.MYQF_AutoShoot = CFG

local DEFAULTS = {

    Master        = false,
    AttackPlayers = true,
    AttackZombies = true,
    TeamCheck     = true,
    WallCheck     = true,
    AttackFriend  = true,
    SkipFriends   = nil,
    AimPart       = "Head",
    AimMode       = "Crosshair",
    MaxDistance   = 1500,
    MaxCandidates = 8,
    MaxShotsPerFrame = 4,
    SecondArgMode = "fixed",
    SecondArg     = 2.504495313930741,
    LockBeforeFire = true,
    LockFireDelay  = 0.03,

    AdvancedUI       = false,
    LockMaxCount     = 12,
    LockHoldTime     = 1.5,
    LockMaxDistance  = 400,
    LockScaleX       = 3.6,
    LockScaleY       = 4.8,
    LockBoxW         = 96,
    LockBoxH         = 128,
    LockInset        = 40,
    LockArmLong      = 0.34,
    LockArmShort     = 0.22,
    LockThickness    = 3,
    LockAlpha        = 0.85,
    LockColorFind    = Color3.fromRGB(112, 219, 217),
    LockColorLock    = Color3.fromRGB(255, 175, 61),
    LockColorDone    = Color3.fromRGB(0, 229, 178),
    LockColorLost    = Color3.fromRGB(255, 98, 107),
    LockColorKill    = Color3.fromRGB(255, 226, 160),
    LockAcquireTime  = 0.10,
    LockShrinkTime   = 0.18,
    LockLoseTime     = 0.35,
    LockKillHold     = 0.25,
    LockKillFade     = 0.45,
    LockPulse        = true,
    LockWallCheck    = true,

    AntiShake          = true,
    AntiShakeMaxAmp    = 0.5,
    AntiShakeConfirm   = 2,
    AntiShakeRespectMove = true,
    AntiShakeLockRotation = false,
    AntiShakeKillSrc   = true,
    AntiShakeFOV       = true,
    AntiShakeFOVTol    = 4,
    AntiShakeOffset    = false,
    AntiShakeOffsetTol = 0.6,

    FireInterval  = 0,
    NoUI          = false,
    Debug         = false,
}
for k, v in pairs(DEFAULTS) do if CFG[k] == nil then CFG[k] = v end end

local function safe(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok and CFG.Debug then warn("[MYQF.AutoShoot] " .. tostring(err)) end
    return ok, err
end
local function dbg(m)
    if CFG.Debug then warn("[MYQF.AutoShoot] " .. tostring(m)) end
end

local mkvec
do
    local ok, vlib = pcall(function() return vector end)
    if ok and vlib and type(vlib.create) == "function" then
        mkvec = function(p) return vlib.create(p.X, p.Y, p.Z) end
    else
        mkvec = function(p) return Vector3.new(p.X, p.Y, p.Z) end
    end
end

local function getCam() return workspace.CurrentCamera end

local cachedRE, reTime, reFails = nil, 0, 0
local BACKOFF = { 1, 3, 8, 20 }
local function getFireRE()
    if cachedRE and cachedRE.Parent and tick() - reTime < BACKOFF[math.min(reFails + 1, #BACKOFF)] then
        return cachedRE
    end
    reTime = tick()

    if type(getNil) == "function" then
        local ok, r = pcall(getNil, "Fire", "RemoteEvent")
        if ok and typeof(r) == "Instance" and r:IsA("RemoteEvent") then
            cachedRE, reFails = r, 0
            return r
        end
    end

    local spots = {}
    if lp.Character then spots[#spots + 1] = lp.Character end
    local bp = lp:FindFirstChild("Backpack")
    if bp then spots[#spots + 1] = bp end
    for _, c in ipairs(spots) do
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "Fire" then
                cachedRE, reFails = d, 0
                return d
            end
        end
    end

    local found
    pcall(function()
        for _, d in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if d:IsA("RemoteEvent") and d.Name == "Fire" then found = d break end
        end
    end)
    if found then cachedRE, reFails = found, 0 return found end

    reFails = math.min(reFails + 1, #BACKOFF - 1)
    return cachedRE
end

local zRoot, zRootTime = nil, 0
local function zombieRoot()
    if zRoot and zRoot.Parent and tick() - zRootTime < 5 then return zRoot end
    zRootTime = tick()
    zRoot = nil
    local g = workspace:FindFirstChild("Game")
    if g then
        local n = g:FindFirstChild("NPCs")
        zRoot = n and n:FindFirstChild("Zombies")
        if not zRoot then
            for _, d in ipairs(g:GetDescendants()) do
                if d.Name == "Zombies" then zRoot = d break end
            end
        end
    end
    return zRoot
end

local function getAimPart(model)
    if not model then return nil end
    local p = model:FindFirstChild(CFG.AimPart)
    if p and p:IsA("BasePart") then return p end
    p = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    if p and p:IsA("BasePart") then return p end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function skipFriends()
    if CFG.SkipFriends ~= nil then return CFG.SkipFriends end
    return not CFG.AttackFriend
end

local function passTeamCheck(plr)
    if plr == lp then return false end
    if CFG.TeamCheck then
        local a, b = plr.Team, lp.Team
        if a and b and a == b then return false end
    end
    if skipFriends() then
        local ok, isF = pcall(function() return plr:IsFriendsWith(lp.UserId) end)
        if ok and isF then return false end
    end
    return true
end

local zCacheTime, zCacheList = 0, {}
local function refreshZombies()
    if tick() - zCacheTime < 0.15 then return end
    zCacheTime = tick()
    table.clear(zCacheList)
    local root = zombieRoot()
    if not root then return end

    local function push(m)
        if not m:IsA("Model") then return end
        local hum = m:FindFirstChildOfClass("Humanoid")
        if (not hum or hum.Health > 0) then
            local part = getAimPart(m)
            if part then zCacheList[#zCacheList + 1] = { Part = part, Model = m } end
        end
    end

    local direct = 0
    for _, m in ipairs(root:GetChildren()) do
        if m:IsA("Model") then direct = direct + 1 end
    end
    if direct > 0 then
        for _, m in ipairs(root:GetChildren()) do push(m) end
    else
        for _, m in ipairs(root:GetDescendants()) do push(m) end
    end
end

local targets, scored = {}, {}
local function collectTargets()
    table.clear(targets)
    if CFG.AttackZombies then
        refreshZombies()
        for i = 1, #zCacheList do targets[#targets + 1] = zCacheList[i] end
    end
    if CFG.AttackPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if passTeamCheck(plr) then
                local ch = plr.Character
                local hum = ch and ch:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = getAimPart(ch)
                    if part then targets[#targets + 1] = { Part = part, Model = ch } end
                end
            end
        end
    end
end

local rayParams = RaycastParams.new()
rayParams.IgnoreWater = true
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
local filterBuf = {}

local function visible(part, model, camPos)
    if not CFG.WallCheck then return true end
    if not part or not part.Parent then return false end
    table.clear(filterBuf)
    if lp.Character then filterBuf[#filterBuf + 1] = lp.Character end
    if model and model.Parent then filterBuf[#filterBuf + 1] = model end
    rayParams.FilterDescendantsInstances = filterBuf

    local res = workspace:Raycast(camPos, part.Position - camPos, rayParams)
    if not res then return true end
    local inst = res.Instance
    if inst == part then return true end
    if model and model.Parent then
        local ok, isDesc = pcall(function() return inst:IsDescendantOf(model) end)
        if ok and isDesc then return true end
    end
    return false
end

local SHAKE = { lastRaw = nil, base = nil, lastD = nil,
                lastRoot = nil, baseFov = nil, flip = 0 }
local function resetShake()
    SHAKE.lastRaw, SHAKE.base, SHAKE.lastD = nil, nil, nil
    SHAKE.lastRoot, SHAKE.baseFov, SHAKE.flip = nil, nil, 0
end

local function neutralizeShakeSources()
    if not CFG.AntiShakeKillSrc then return end
    local containers = {}
    pcall(function() containers[#containers + 1] = game:GetService("ReplicatedStorage") end)
    pcall(function() containers[#containers + 1] = game:GetService("ReplicatedFirst") end)
    pcall(function() containers[#containers + 1] = lp:WaitForChild("PlayerScripts", 3) end)
    pcall(function() containers[#containers + 1] = lp:WaitForChild("PlayerGui", 3) end)

    for _, root in ipairs(containers) do
        pcall(function()
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ModuleScript") then
                    local n = string.lower(d.Name)
                    if string.find(n, "shake") or string.find(n, "recoil") then
                        pcall(function()
                            local m = require(d)
                            if type(m) == "table" then
                                for k, v in pairs(m) do
                                    local kn = string.lower(tostring(k))
                                    if type(v) == "function"
                                        and (string.find(kn, "shake") or string.find(kn, "recoil")
                                          or string.find(kn, "trauma") or string.find(kn, "punch")) then
                                        m[k] = function() end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end
end

local function antiShakeStep()
    if not CFG.AntiShake then resetShake() return end
    local cam = getCam()
    if not cam then return end
    local raw = cam.CFrame

    local rootPos = nil
    pcall(function()
        local ch = lp.Character
        local rp = ch and ch:FindFirstChild("HumanoidRootPart")
        if rp then rootPos = rp.Position end
    end)

    if SHAKE.lastRaw == nil then
        SHAKE.lastRaw, SHAKE.base, SHAKE.lastD = raw, raw, nil
        SHAKE.lastRoot, SHAKE.baseFov, SHAKE.flip = rootPos, cam.FieldOfView, 0
        return
    end

    local d = raw.Position - SHAKE.lastRaw.Position
    local mag = d.Magnitude
    local isShake = false

    if mag > CFG.AntiShakeMaxAmp * 6 then
        SHAKE.base, SHAKE.flip = raw, 0
    elseif mag > 0.0015 and mag <= CFG.AntiShakeMaxAmp then
        if SHAKE.lastD and SHAKE.lastD.Magnitude > 0.0015 and d:Dot(SHAKE.lastD) < 0 then
            SHAKE.flip = SHAKE.flip + 1
        else
            SHAKE.flip = 0
        end
        if SHAKE.flip >= CFG.AntiShakeConfirm then
            local exempt = false
            if CFG.AntiShakeRespectMove and rootPos and SHAKE.lastRoot then
                local rm = rootPos - SHAKE.lastRoot
                local rmMag = rm.Magnitude
                if rmMag > 0.0015 and d:Dot(rm.Unit) > 0 and math.abs(mag - rmMag) <= rmMag * 0.6 then
                    exempt = true
                end
            end
            isShake = not exempt
        end
    else
        SHAKE.flip = 0
    end

    if isShake then
        local base = SHAKE.base
        if rootPos and SHAKE.lastRoot then
            base = base + (rootPos - SHAKE.lastRoot)
        end
        SHAKE.base = base
        pcall(function()
            if CFG.AntiShakeLockRotation then
                cam.CFrame = base
            else
                cam.CFrame = CFrame.new(base.Position) * (raw - raw.Position)
            end
        end)
    else
        SHAKE.base = raw
    end

    if CFG.AntiShakeFOV then
        pcall(function()
            local fov = cam.FieldOfView
            if math.abs(fov - (SHAKE.baseFov or fov)) <= CFG.AntiShakeFOVTol then
                cam.FieldOfView = SHAKE.baseFov or fov
            else
                SHAKE.baseFov = fov
            end
        end)
    end

    if CFG.AntiShakeOffset then
        pcall(function()
            local ch = lp.Character
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if h and h.CameraOffset.Magnitude <= CFG.AntiShakeOffsetTol then
                h.CameraOffset = Vector3.zero
            end
        end)
    end

    SHAKE.lastRaw, SHAKE.lastD, SHAKE.lastRoot = raw, d, rootPos
end

local LOCKS = { active = {}, byModel = {}, pool = {} }
local lockCount = 0

local function quadOut(x) return 1 - (1 - x) * (1 - x) end

local function makeCorner(parent, cornerIndex, thick)
    local ax, ay = 0, 0
    if cornerIndex == 2 or cornerIndex == 4 then ax = 1 end
    if cornerIndex == 3 or cornerIndex == 4 then ay = 1 end

    local f = Instance.new("Frame")
    f.Name = "C" .. tostring(cornerIndex)
    f.AnchorPoint = Vector2.new(ax, ay)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Parent = parent

    local h = Instance.new("Frame")
    h.Name = "H"
    h.BorderSizePixel = 0
    h.AnchorPoint = Vector2.new(0, ay)
    h.Position = UDim2.new(0, 0, ay, 0)
    h.Size = UDim2.new(1, 0, 0, thick)
    h.Parent = f

    local v = Instance.new("Frame")
    v.Name = "V"
    v.BorderSizePixel = 0
    v.AnchorPoint = Vector2.new(ax, 0)
    v.Position = UDim2.new(ax, 0, 0, 0)
    v.Size = UDim2.new(0, thick, 1, 0)
    v.Parent = f

    return f, h, v
end

local function lockCreate()
    local gui = Instance.new("BillboardGui")
    gui.Name = "MYQF_TacLock"
    gui.LightInfluence = 0
    gui.AlwaysOnTop = true
    gui.ResetOnSpawn = false
    gui.ClipsDescendants = false
    gui.MaxDistance = CFG.LockMaxDistance
    gui.StudsOffset = Vector3.new(0, 0, 0)

    local corners = {}
    local arms = {}
    for i = 1, 4 do
        local c, h, v = makeCorner(gui, i, CFG.LockThickness)
        corners[i] = c
        arms[i] = { h, v }
    end

    return { gui = gui, corners = corners, arms = arms,
             model = nil, part = nil, state = nil,
             t = 0, hold = 0, lost = 0, pulse = 0, alpha = 0 }
end

local function paintCorner(e, i, inset, armW, armH, color, alpha)
    local c = e.corners[i]
    local ax = (i == 2 or i == 4) and 1 or 0
    local ay = (i == 3 or i == 4) and 1 or 0
    c.Size = UDim2.new(0, armW, 0, armH)
    c.Position = UDim2.new(ax, ax == 0 and inset or -inset,
                           ay, ay == 0 and inset or -inset)
    local trans = 1 - alpha
    local h, v = e.arms[i][1], e.arms[i][2]
    h.BackgroundColor3 = color
    h.BackgroundTransparency = trans
    v.BackgroundColor3 = color
    v.BackgroundTransparency = trans
end

local function lockPaint(e)
    if not CFG.AdvancedUI then return end
    local p = e.progress or 0
    local eased = quadOut(p)
    local inset = CFG.LockInset * eased
    local armW = math.max(CFG.LockThickness * 2,
                          CFG.LockBoxW * (CFG.LockArmLong + (CFG.LockArmShort - CFG.LockArmLong) * eased))
    local armH = math.max(CFG.LockThickness * 2,
                          CFG.LockBoxH * (CFG.LockArmLong + (CFG.LockArmShort - CFG.LockArmLong) * eased))

    local color
    if e.state == "KILLED" then
        color = CFG.LockColorKill
    elseif e.state == "LOST" then
        color = CFG.LockColorLost
    elseif p < 0.5 then
        color = CFG.LockColorFind:lerp(CFG.LockColorLock, p / 0.5)
    else
        color = CFG.LockColorLock:lerp(CFG.LockColorDone, (p - 0.5) / 0.5)
    end

    local alpha = e.alpha or 0
    for i = 1, 4 do
        paintCorner(e, i, inset, armW, armH, color, alpha)
    end
end

local function lockSetState(e, s, progress)
    e.state = s
    e.t = 0
    if progress ~= nil then e.progress = progress end
    if s == "ACQUIRE" then
        e.progress = 0
        e.alpha = 0
    elseif s == "LOCKING" then
        if e.progress == nil then e.progress = 0 end
    elseif s == "LOCKED" then
        e.progress = 1
        e.lockedAt = e.lockedAt or tick()
    elseif s == "LOST" then
        e.alpha = CFG.LockAlpha
    elseif s == "KILLED" then
        e.alpha = CFG.LockAlpha
    end
end

local function lockAcquire()
    local e = table.remove(LOCKS.pool)
    if not e then e = lockCreate() end
    e.progress, e.hold, e.lost, e.pulse, e.alpha = 0, 0, 0, 0, 0
    e.state = nil
    e.lockedAt = nil
    return e
end

local function lockRelease(e)
    if not e then return end
    if e.model then LOCKS.byModel[e.model] = nil end
    for i, v in ipairs(LOCKS.active) do
        if v == e then table.remove(LOCKS.active, i) break end
    end
    lockCount = #LOCKS.active
    pcall(function()
        e.gui.Adornee = nil
        e.gui.Enabled = false
        e.gui.Parent = nil
    end)
    e.model, e.part = nil, nil
    LOCKS.pool[#LOCKS.pool + 1] = e
end

local function lockDestroyAll()
    for _, e in ipairs(LOCKS.active) do
        pcall(function() e.gui:Destroy() end)
    end
    for _, e in ipairs(LOCKS.pool) do
        pcall(function() e.gui:Destroy() end)
    end
    table.clear(LOCKS.active)
    table.clear(LOCKS.byModel)
    table.clear(LOCKS.pool)
    lockCount = 0
end

local function lockMark(model, part)
    if not model or not part or not model.Parent then return nil end

    local e = LOCKS.byModel[model]
    if e then
        e.hold = CFG.LockHoldTime
        e.part = part
        if e.state == "LOST" then lockSetState(e, "LOCKING", 0) end
        return e
    end

    while lockCount >= CFG.LockMaxCount and #LOCKS.active > 0 do
        local victim
        for i = 1, #LOCKS.active do
            if LOCKS.active[i].state == "LOST" then victim = LOCKS.active[i] break end
        end
        lockRelease(victim or LOCKS.active[1])
    end

    e = lockAcquire()
    e.model, e.part = model, part
    pcall(function()
        e.gui.Adornee = part
        e.gui.Size = UDim2.new(CFG.LockScaleX, CFG.LockBoxW, CFG.LockScaleY, CFG.LockBoxH)
        e.gui.MaxDistance = CFG.LockMaxDistance
        e.gui.Enabled = CFG.AdvancedUI
        e.gui.Parent = part
    end)
    lockSetState(e, "ACQUIRE")
    LOCKS.byModel[model] = e
    LOCKS.active[#LOCKS.active + 1] = e
    lockCount = #LOCKS.active
    return e
end

local function lockTick(e, dt, camPos)
    local m, p = e.model, e.part
    if not m or not m.Parent or not p or not p.Parent then return false end

    local hum = m:FindFirstChildOfClass("Humanoid")
    local dead = hum and hum.Health <= 0
    local far = (p.Position - camPos).Magnitude > CFG.LockMaxDistance

    if dead then
        if e.state ~= "KILLED" then lockSetState(e, "KILLED") end
        e.t = e.t + dt
        if e.t <= CFG.LockKillHold then
            e.alpha = CFG.LockAlpha
        else
            e.alpha = CFG.LockAlpha * (1 - math.clamp((e.t - CFG.LockKillHold) / CFG.LockKillFade, 0, 1))
            if e.alpha <= 0.01 then return false end
        end
        lockPaint(e)
        return true
    end

    local blocked = far or (CFG.LockWallCheck and not visible(p, m, camPos))
    if blocked then
        e.lost = e.lost + dt
        if e.lost >= CFG.LockLoseTime and e.state ~= "LOST" then
            lockSetState(e, "LOST")
        end
    else
        e.lost = 0
        if e.state == "LOST" then lockSetState(e, "LOCKING", 0) end
    end

    if e.state ~= "LOST" then
        e.hold = e.hold - dt
        if e.hold <= 0 then lockSetState(e, "LOST") end
    end

    e.t = e.t + dt

    if e.state == "ACQUIRE" then
        e.alpha = CFG.LockAlpha * math.clamp(e.t / math.max(CFG.LockAcquireTime, 0.01), 0, 1)
        if e.t >= CFG.LockAcquireTime then lockSetState(e, "LOCKING", 0) end

    elseif e.state == "LOCKING" then
        e.progress = math.clamp(e.t / math.max(CFG.LockShrinkTime, 0.01), 0, 1)
        e.alpha = CFG.LockAlpha
        if e.progress >= 1 then lockSetState(e, "LOCKED", 1) end

    elseif e.state == "LOCKED" then
        e.alpha = CFG.LockAlpha
        if CFG.LockPulse then
            e.pulse = e.pulse + dt * 2.2
            e.alpha = math.clamp(CFG.LockAlpha + math.sin(e.pulse) * 0.10, 0, 1)
        end

    elseif e.state == "LOST" then
        e.progress = math.max(0, (e.progress or 0) - dt * 2.5)
        e.alpha = math.max(0, (e.alpha or 0) - dt / 0.30 * CFG.LockAlpha)
        if e.alpha <= 0.01 then return false end
    end

    lockPaint(e)
    return true
end

local function lockUpdate(dt, camPos)
    if not (CFG.AdvancedUI or CFG.LockBeforeFire) then
        for i = #LOCKS.active, 1, -1 do lockRelease(LOCKS.active[i]) end
        lockCount = 0
        return
    end

    local show = CFG.AdvancedUI
    for i = #LOCKS.active, 1, -1 do
        local e = LOCKS.active[i]
        if not lockTick(e, dt, camPos) then
            lockRelease(e)
        elseif e.gui.Enabled ~= show then
            e.gui.Enabled = show
        end
    end
    lockCount = #LOCKS.active
end

local lastFire = 0
local statusTargets = 0
local lastCamPos = Vector3.new()
local preMarks = {}

local function step()
    if not CFG.Master then return end

    local cam = getCam()
    if not cam then return end
    local camPos  = cam.CFrame.Position
    local camLook = cam.CFrame.LookVector
    lastCamPos = camPos

    collectTargets()
    statusTargets = #targets

    table.clear(scored)
    for _, t in ipairs(targets) do
        local part = t.Part
        if part and part.Parent then
            local delta = part.Position - camPos
            local dist = delta.Magnitude
            if dist > 0.1 and dist <= CFG.MaxDistance then
                local s
                if CFG.AimMode == "Distance" then
                    s = dist
                else
                    s = math.deg(math.acos(math.clamp(camLook:Dot(delta.Unit), -1, 1)))
                end
                scored[#scored + 1] = { s = s, t = t, d = dist }
            end
        end
    end
    table.sort(scored, function(a, b) return a.s < b.s end)

    local re = getFireRE()
    if not re then return end
    if CFG.FireInterval > 0 and tick() - lastFire < CFG.FireInterval then return end

    table.clear(preMarks)
    local maxShots = math.max(1, CFG.MaxShotsPerFrame)
    local marked = 0
    for i = 1, math.min(#scored, CFG.MaxCandidates) do
        if marked >= maxShots then break end
        local t = scored[i].t
        if visible(t.Part, t.Model, camPos) then
            local e = lockMark(t.Model, t.Part)
            if e then
                preMarks[#preMarks + 1] = { e = e, t = t, d = scored[i].d }
            end
            marked = marked + 1
        end
    end

    local now = tick()
    for _, mk in ipairs(preMarks) do
        local e = mk.e
        if CFG.LockBeforeFire then
            if e.state ~= "LOCKED" then

            elseif (now - (e.lockedAt or 0)) < CFG.LockFireDelay then

            else
                local pos = mk.t.Part.Position
                local arg2 = CFG.SecondArg
                if CFG.SecondArgMode == "distance" then arg2 = mk.d end
                safe(function() re:FireServer(mkvec(pos), arg2) end)
                lastFire = now
            end
        else
            local pos = mk.t.Part.Position
            local arg2 = CFG.SecondArg
            if CFG.SecondArgMode == "distance" then arg2 = mk.d end
            safe(function() re:FireServer(mkvec(pos), arg2) end)
            lastFire = now
        end
    end
end

local RUNTIME = { running = true, shakeBound = false, gui = nil, conns = {} }
local function trackConnection(c) RUNTIME.conns[#RUNTIME.conns + 1] = c return c end

task.spawn(function()
    safe(neutralizeShakeSources)
    local bound = false
    safe(function()
        RS:BindToRenderStep("MYQF_AntiShake", Enum.RenderPriority.Camera.Value + 10, function()
            if RUNTIME.running then safe(antiShakeStep) end
        end)
        bound = true
    end)
    if bound then
        RUNTIME.shakeBound = true
    else
        trackConnection(RS.RenderStepped:Connect(function()
            if RUNTIME.running then safe(antiShakeStep) end
        end))
    end
end)

task.spawn(function()
    while RUNTIME.running do
        local dt = RS.RenderStepped:Wait()
        local cam = getCam()
        local camPos = cam and cam.CFrame.Position or lastCamPos
        safe(step)
        safe(lockUpdate, dt, camPos)
    end
    lockDestroyAll()
end)

local function stopAll()
    if not RUNTIME.running then return end
    RUNTIME.running = false

    if RUNTIME.shakeBound then
        pcall(function() RS:UnbindFromRenderStep("MYQF_AntiShake") end)
        RUNTIME.shakeBound = false
    end
    for _, c in ipairs(RUNTIME.conns) do
        pcall(function() if c and c.Connected then c:Disconnect() end end)
    end
    table.clear(RUNTIME.conns)

    resetShake()
    lockDestroyAll()
    dbg("已完全卸载")
end
G.MYQF_AutoShoot_Stop = stopAll

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local camera = workspace.CurrentCamera
local loadStartTime = tick()

local COPY_UID_TEXT = "UID:3493104875211423"
local GUI_NAME = "HLlinfeng"

local I18N = {
    en = {
        HideShow = "Hide/Show", LockGui = "Lock GUI", ResetUIPos = "Reset UI Position",
        HideUI = "Hide UI (Long Press to Open)", Copied = "Copied",
        Master = "Total Attack", AttackPlayers = "Attack Players", AttackZombies = "Attack Zombies",
        TeamCheck = "Skip Teammates", WallCheck = "Wall Check",
        AdvancedUI = "Tactical Lock HUD", LockBeforeFire = "Lock Then Fire",
    },
    cn = {
        HideShow = "隐藏/显示", LockGui = "锁定Gui", ResetUIPos = "重置界面位置",
        HideUI = "隐藏界面(长按打开)", Copied = "复制成功",
        Master = "总攻击", AttackPlayers = "攻击玩家", AttackZombies = "攻击僵尸",
        TeamCheck = "跳过队友", WallCheck = "墙壁检测",
        AdvancedUI = "战术锁定框", LockBeforeFire = "先锁后打",
    }
}
local currentLang = "cn"
local function T(key)
    local lang = I18N[currentLang]
    return (lang and lang[key]) or key
end
local function applyI18N(el, key)
    if not el or not key then return end
    el:SetAttribute("I18NKey", key)
    el.Text = T(key)
end

local S = {
    DeviceType = (function()
        local sc = camera.ViewportSize
        local a = sc.X / sc.Y
        return (a >= 1.3 and sc.X >= 900) and "Desktop" or ((a < 1.3 and sc.X >= 600) and "Tablet" or "Mobile")
    end)(),
    Features = { lockGui = false },
    UI = {ScreenGui = nil, Main = nil, MinFrame = nil, Panels = {}, PanelOrigins = {}, PanelsVisible = true},
    Modules = {},
}

local UICFG = ({
    Mobile = { MainW=60, MainH=156, SubW=60, BtnH=22, TitleH=34, MinSize=32, Font={Main=10,Sub=11,Title=12,Min=18}, Space=6, Scale=1.0 },
    Tablet = { MainW=85, MainH=200, SubW=85, BtnH=30, TitleH=40, MinSize=40, Font={Main=12,Sub=13,Title=14,Min=20}, Space=7, Scale=1.3 },
    Desktop = { MainW=110, MainH=260, SubW=110, BtnH=36, TitleH=48, MinSize=48, Font={Main=14,Sub=15,Title=16,Min=24}, Space=10, Scale=1.7 }
})[S.DeviceType]

local CFG0 = UICFG
local TITLE_CORNER = UDim.new(0, 8)
local MAIN_BOTTOM_CORNER = UDim.new(0, 8)
local INNER_TOP_PAD = math.max(1, math.floor(2 * CFG0.Scale))
local INNER_BOTTOM_PAD = math.max(2, math.floor(5 * CFG0.Scale))
local CLOSE_BTN_CORNER = math.max(8, math.floor(6 * CFG0.Scale))
local ITEM_GAP = math.floor(4 * CFG0.Scale)
local BOTTOM_CORNER_PX = 8
local BLACK_EXTRA_H = math.max(1, math.floor(2 * CFG0.Scale))
local COPY_FEEDBACK_TIME = 0.8
local LANG_TEXT = Color3.fromRGB(255, 60, 60)
local LANG_TEXT_HOVER = Color3.fromRGB(255, 110, 110)

local function cornerToPx(frame, corner)
    local minDim = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
    if minDim <= 0 then minDim = math.max(frame.Size.X.Offset, frame.Size.Y.Offset) end
    return math.max(1, math.floor(minDim * corner.Scale + corner.Offset + 0.5))
end

local function uisafe(ctx, fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, r = pcall(fn, ...)
    if not ok then warn(string.format("[MYQFUI-ERROR] %s | %s", ctx, tostring(r))) end
    return ok, r
end

local function RegModule(name, mod) S.Modules[name] = mod end

local SUB = {
    Title    = Color3.fromRGB(55, 55, 60),
    Body     = Color3.fromRGB(15, 15, 20),
    Content  = Color3.fromRGB(15, 15, 20),
    Btn      = Color3.fromRGB(35, 35, 40),
    BtnHover = Color3.fromRGB(45, 45, 50),
    Green    = Color3.fromRGB(0, 255, 0),
    Red      = Color3.fromRGB(255, 0, 0),
    White    = Color3.fromRGB(255, 255, 255),
    Stroke   = Color3.fromRGB(0, 0, 0),
    Black    = Color3.fromRGB(0, 0, 0),
}
local C = {
    Title = SUB.Title, Panel = SUB.Body, Content = SUB.Content,
    Btn = SUB.Btn, BtnHover = SUB.BtnHover, MainPanel = SUB.Body,
    MinFrame = Color3.fromRGB(72,72,78), White = SUB.White,
    Red = SUB.Red, Green = SUB.Green, Stroke = SUB.Stroke,
}
local MYQ = {
    Btn = SUB.Btn, Hover = SUB.BtnHover, Press = Color3.fromRGB(25, 25, 30),
    KnobImage = "rbxassetid://6755657357",
}

local function detectArceusXContainer()
    local ok, found = pcall(function()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.ClipToDeviceSafeArea == true and v.DisplayOrder == 0
               and v.Enabled == true and v.ResetOnSpawn == true and v.AutoLocalize == true then
                if #v:GetChildren() == 1 then return v end
            end
        end
        return nil
    end)
    if ok and found then return found end
    return nil
end

local function getExecutorContainer()
    local arceus = detectArceusXContainer()
    if arceus then return arceus end
    if type(gethui) == "function" then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    if type(get_hidden_gui) == "function" then
        local ok, res = pcall(get_hidden_gui)
        if ok and res then return res end
    end
    if type(getgenv) == "function" then
        local ok, genv = pcall(getgenv)
        if ok and genv then
            if type(genv.gethui) == "function" then
                local ok2, res = pcall(genv.gethui)
                if ok2 and res then return res end
            end
            if type(genv.get_hidden_gui) == "function" then
                local ok2, res = pcall(genv.get_hidden_gui)
                if ok2 and res then return res end
            end
        end
    end
    return CoreGui
end

local targetParent = getExecutorContainer()
if targetParent:FindFirstChild(GUI_NAME) then
    targetParent:FindFirstChild(GUI_NAME):Destroy()
end

local uiRefreshers = {}
local statusLabel = nil
local minF

local Nanoka = Instance.new("ScreenGui")
Nanoka.Name = GUI_NAME
Nanoka.Parent = targetParent
Nanoka.ResetOnSpawn = false
Nanoka.IgnoreGuiInset = true
Nanoka.DisplayOrder = 1000
Nanoka.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Nanoka.Enabled = false
S.UI.ScreenGui = Nanoka

local uiVisible = false
Nanoka:GetPropertyChangedSignal("Enabled"):Connect(function() uiVisible = Nanoka.Enabled end)

local container = Instance.new("Frame")
container.Name = "Frame"
container.Parent = Nanoka
container.Size = UDim2.new(1, 0, 1, 0)
container.Position = UDim2.new(0, 0, 0, 0)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.Active = false
container.ClipsDescendants = false
container.ZIndex = 0

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.P then Nanoka.Enabled = not Nanoka.Enabled end
end)

local function switchLanguage()
    currentLang = (currentLang == "en") and "cn" or "en"
    for _, d in ipairs(Nanoka:GetDescendants()) do
        local k = d:GetAttribute("I18NKey")
        if k and (d:IsA("TextLabel") or d:IsA("TextButton")) then
            local val = d:GetAttribute("I18NValue")
            if val ~= nil then
                d.Text = T(k) .. " [" .. tostring(val) .. "]"
            else
                d.Text = T(k)
            end
        end
    end
end

local function styleButton(btn, text, col)
    btn.Size = UDim2.new(1, 0, 0, CFG0.BtnH)
    btn.BackgroundColor3 = SUB.Btn
    btn.Text = text
    btn.TextColor3 = col or SUB.White
    btn.Font = Enum.Font.Gotham
    btn.TextSize = CFG0.Font.Sub
    btn.TextWrapped = true
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.TextStrokeColor3 = SUB.Stroke
    btn.TextStrokeTransparency = 0.2
    btn.Active = true
    btn.BorderSizePixel = 0
end

local function CreateCFGToggle(text, parent, cfgKey)
    local b = Instance.new("TextButton")
    b.Parent = parent
    styleButton(b, "")
    applyI18N(b, text)
    b.BackgroundColor3 = SUB.Btn
    local function refresh() b.TextColor3 = CFG[cfgKey] and SUB.Green or SUB.Red end
    refresh()
    b.MouseEnter:Connect(function() b.BackgroundColor3 = SUB.BtnHover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = SUB.Btn; refresh() end)
    b.MouseButton1Click:Connect(function()
        CFG[cfgKey] = not CFG[cfgKey]
        refresh()
    end)
    uiRefreshers[#uiRefreshers + 1] = refresh
    return b
end

local function CreateToggle(text, parent, featureKey, callback)
    local on = S.Features[featureKey] or false
    local b = Instance.new("TextButton")
    b.Parent = parent
    styleButton(b, "")
    applyI18N(b, text)
    b.BackgroundColor3 = SUB.Btn
    b.TextColor3 = on and SUB.Green or SUB.Red
    b.MouseEnter:Connect(function() b.BackgroundColor3 = SUB.BtnHover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = SUB.Btn end)
    b.MouseButton1Click:Connect(function()
        on = not on
        S.Features[featureKey] = on
        b.TextColor3 = on and SUB.Green or SUB.Red
        if callback then uisafe("Toggle."..featureKey, callback, on) end
    end)
    return b
end

local function createLangSwitchButton(parent, onAfterHide)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(1, 0, 0, CFG0.BtnH)
    b.BackgroundColor3 = SUB.Btn
    b.BorderSizePixel = 0
    b.Text = "语言切换\n到英文"
    b.TextColor3 = LANG_TEXT
    b.Font = Enum.Font.Gotham
    b.TextSize = CFG0.Font.Sub
    b.TextWrapped = true
    b.TextScaled = true
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Center
    b.TextYAlignment = Enum.TextYAlignment.Center
    b.TextStrokeColor3 = SUB.Stroke
    b.TextStrokeTransparency = 0.2
    b.Active = true
    b.MouseEnter:Connect(function() b.BackgroundColor3 = SUB.BtnHover; b.TextColor3 = LANG_TEXT_HOVER end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = SUB.Btn; b.TextColor3 = LANG_TEXT end)
    b.MouseButton1Click:Connect(function()
        b.Visible = false
        if onAfterHide then uisafe("LangRecalc", onAfterHide) end
        uisafe("SwitchLanguage", switchLanguage)
    end)
    return b
end

local function createMYQButton(text, parent, onClick, radiusPx, maskTop)
    radiusPx = radiusPx or 5
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(1, 0, 0, CFG0.BtnH)
    b.BackgroundColor3 = MYQ.Btn
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.Active = true
    b.ZIndex = 5
    if radiusPx > 0 then Instance.new("UICorner", b).CornerRadius = UDim.new(0, radiusPx) end

    local topMask = nil
    if maskTop and radiusPx > 0 then
        topMask = Instance.new("Frame", b)
        topMask.Size = UDim2.new(1, 0, 0, radiusPx)
        topMask.Position = UDim2.new(0, 0, 0, 0)
        topMask.BackgroundColor3 = MYQ.Btn
        topMask.BorderSizePixel = 0
        topMask.ZIndex = 6
        topMask.Active = false
    end

    local lbl = Instance.new("TextLabel")
    lbl.Parent = b
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    applyI18N(lbl, text)
    lbl.TextColor3 = SUB.White
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = CFG0.Font.Sub
    lbl.TextScaled = true
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextStrokeColor3 = SUB.Stroke
    lbl.TextStrokeTransparency = 0.2
    lbl.Active = false
    lbl.ZIndex = 7

    local function applyColor(c)
        b.BackgroundColor3 = c
        if topMask then topMask.BackgroundColor3 = c end
    end
    b.MouseEnter:Connect(function() applyColor(MYQ.Hover) end)
    b.MouseLeave:Connect(function() applyColor(MYQ.Btn) end)
    b.MouseButton1Down:Connect(function() applyColor(MYQ.Press) end)
    b.MouseButton1Up:Connect(function() applyColor(MYQ.Hover) end)
    if onClick then b.MouseButton1Click:Connect(function() uisafe("MYQBtn."..text, onClick) end) end
    return b
end

local function createCloseGUIButton(parent, onClose)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(1, 0, 0, CFG0.BtnH)
    btn.BackgroundColor3 = MYQ.Btn
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.ZIndex = 5
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, CLOSE_BTN_CORNER)

    local topMask = Instance.new("Frame", btn)
    topMask.Size = UDim2.new(1, 0, 0, CLOSE_BTN_CORNER)
    topMask.Position = UDim2.new(0, 0, 0, 0)
    topMask.BackgroundColor3 = MYQ.Btn
    topMask.BorderSizePixel = 0
    topMask.ZIndex = 6
    topMask.Active = false

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Close GUI"
    lbl.TextColor3 = SUB.White
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = CFG0.Font.Sub
    lbl.TextScaled = true
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.TextStrokeColor3 = SUB.Stroke
    lbl.TextStrokeTransparency = 0.2
    lbl.Active = false
    lbl.ZIndex = 7

    local function applyColor(c) btn.BackgroundColor3 = c; topMask.BackgroundColor3 = c end
    btn.MouseEnter:Connect(function() applyColor(MYQ.Hover) end)
    btn.MouseLeave:Connect(function() applyColor(MYQ.Btn) end)
    btn.MouseButton1Down:Connect(function() applyColor(MYQ.Press) end)
    btn.MouseButton1Up:Connect(function() applyColor(MYQ.Hover) end)
    btn.MouseButton1Click:Connect(function() if onClose then uisafe("CloseGUI", onClose) end end)
    return btn
end

local function CreateSlider(text, parent, featureKey, minVal, maxVal, callback)
    minVal = minVal or 0
    maxVal = maxVal or 100
    local defaultVal = S.Features[featureKey]
    if type(defaultVal) ~= "number" then defaultVal = minVal end
    defaultVal = math.clamp(defaultVal, minVal, maxVal)

    local cont = Instance.new("Frame")
    cont.Parent = parent
    cont.Size = UDim2.new(1, 0, 0, CFG0.BtnH + 5)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel = 0
    cont.Active = false

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = cont
    sliderFrame.BackgroundColor3 = SUB.Btn
    sliderFrame.Size = UDim2.new(1, 0, 1, 0)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 10
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 5)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Parent = sliderFrame
    sliderLabel.TextScaled = true
    sliderLabel.BackgroundColor3 = SUB.Btn
    sliderLabel:SetAttribute("I18NKey", text)
    sliderLabel:SetAttribute("I18NValue", defaultVal)
    sliderLabel.Text = T(text) .. " [" .. tostring(defaultVal) .. "]"
    sliderLabel.TextColor3 = SUB.White
    sliderLabel.Size = UDim2.new(1, 0, 0.7, 0)
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.BorderSizePixel = 0
    sliderLabel.ZIndex = 10

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Parent = sliderFrame
    sliderTrack.BackgroundColor3 = SUB.White
    sliderTrack.Size = UDim2.new(0.9, 0, 0.05, 0)
    sliderTrack.Position = UDim2.new(0.05, 0, 0.8, 0)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = 10

    local sliderKnob = Instance.new("ImageLabel")
    sliderKnob.Parent = sliderTrack
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundTransparency = 1
    sliderKnob.Size = UDim2.new(0.055, 0, 5, 0)
    sliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
    sliderKnob.Image = MYQ.KnobImage
    sliderKnob.BorderSizePixel = 0
    sliderKnob.ZIndex = 12

    local clickCatcher = Instance.new("TextButton")
    clickCatcher.Parent = sliderFrame
    clickCatcher.BackgroundTransparency = 1
    clickCatcher.Text = ""
    clickCatcher.TextTransparency = 1
    clickCatcher.Size = UDim2.new(1, 0, 1, 0)
    clickCatcher.AutoButtonColor = false
    clickCatcher.ZIndex = 35
    clickCatcher.Active = true

    local cur = defaultVal
    local dragging = false

    local function setValue(value)
        value = math.clamp(value, minVal, maxVal)
        local roundedVal = math.floor(value + 0.5)
        local percent = (value - minVal) / (maxVal - minVal)
        sliderKnob.Position = UDim2.new(percent, 0, 0.5, 0)
        sliderLabel:SetAttribute("I18NValue", roundedVal)
        sliderLabel.Text = T(text) .. " [" .. tostring(roundedVal) .. "]"
        if roundedVal ~= cur then
            cur = roundedVal
            S.Features[featureKey] = cur
            if callback then uisafe("Slider."..text, callback, cur) end
        end
    end

    local function updateFromScreenX(screenX)
        local ap = sliderTrack.AbsolutePosition
        local as = sliderTrack.AbsoluteSize
        if as.X <= 0 then return end
        setValue(minVal + ((screenX - ap.X) / as.X) * (maxVal - minVal))
    end

    clickCatcher.MouseButton1Down:Connect(function()
        dragging = true
        updateFromScreenX(UIS2:GetMouseLocation().X)
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            updateFromScreenX(UIS2:GetMouseLocation().X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderKnob.Position = UDim2.new((cur - minVal) / (maxVal - minVal), 0, 0.5, 0)
    return {Container = cont, GetValue = function() return cur end}
end

local function maskFrameBottom(frame, corner)
    local px = cornerToPx(frame, corner)
    local mask = Instance.new("Frame", frame)
    mask.Size = UDim2.new(1, 0, 0, px)
    mask.Position = UDim2.new(0, 0, 1, -px)
    mask.BackgroundColor3 = frame.BackgroundColor3
    mask.BorderSizePixel = 0
    mask.ZIndex = 0
end
local function maskFrameTop(frame, corner)
    local px = cornerToPx(frame, corner)
    local mask = Instance.new("Frame", frame)
    mask.Size = UDim2.new(1, 0, 0, px)
    mask.Position = UDim2.new(0, 0, 0, 0)
    mask.BackgroundColor3 = frame.BackgroundColor3
    mask.BorderSizePixel = 0
    mask.ZIndex = 0
end

local main = Instance.new("Frame")
main.Parent = container
main.Name = "Frame"
main.Size = UDim2.new(0, CFG0.MainW, 0, CFG0.TitleH)
main.BackgroundColor3 = SUB.Title
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = TITLE_CORNER
maskFrameBottom(main, TITLE_CORNER)

local mt = Instance.new("TextLabel", main)
mt.Size = UDim2.new(1, 0, 1, 0)
mt.BackgroundTransparency = 1
mt.Text = "Gui"
mt.TextColor3 = SUB.White
mt.Font = Enum.Font.GothamBold
mt.TextSize = CFG0.Font.Title
mt.TextScaled = true
mt.TextXAlignment = Enum.TextXAlignment.Center
mt.TextYAlignment = Enum.TextYAlignment.Center
mt.Active = false

local mainBody = Instance.new("Frame")
mainBody.Name = "Body"
mainBody.Parent = main
mainBody.Size = UDim2.new(1, 0, 0, 0)
mainBody.Position = UDim2.new(0, 0, 1, 0)
mainBody.BackgroundColor3 = SUB.Body
mainBody.BorderSizePixel = 0
mainBody.Active = true
Instance.new("UICorner", mainBody).CornerRadius = MAIN_BOTTOM_CORNER
maskFrameTop(mainBody, MAIN_BOTTOM_CORNER)

main:GetPropertyChangedSignal("Position"):Connect(function()
    local viewport = camera.ViewportSize
    local size = main.AbsoluteSize
    if size.X > 0 and size.Y > 0 then
        local curX = main.Position.X.Offset
        local curY = main.Position.Y.Offset
        local newX = math.clamp(curX, -math.floor(size.X * 0.75), math.floor(viewport.X - size.X * 0.25))
        local newY = math.clamp(curY, -math.floor(size.Y * 0.75), math.floor(viewport.Y - size.Y * 0.25))
        if newX ~= curX or newY ~= curY then main.Position = UDim2.new(0, newX, 0, newY) end
    end
end)

local function stroke(lbl) lbl.TextStrokeColor3 = SUB.Stroke; lbl.TextStrokeTransparency = 0.2 end

local function mkBtn(text, y, noI18N)
    local b = Instance.new("TextButton")
    b.Parent = mainBody
    b.Size = UDim2.new(1, -4 * CFG0.Scale, 0, CFG0.BtnH)
    b.Position = UDim2.new(0, 2 * CFG0.Scale, 0, y)
    b.BackgroundColor3 = SUB.Btn
    if noI18N then b.Text = text else applyI18N(b, text) end
    b.TextColor3 = SUB.White
    b.Font = Enum.Font.Gotham
    b.TextSize = CFG0.Font.Main
    b.TextScaled = true
    b.AutoButtonColor = false
    b.TextXAlignment = Enum.TextXAlignment.Center
    b.TextYAlignment = Enum.TextYAlignment.Center
    b.BorderSizePixel = 0
    stroke(b)
    b.Active = true
    b.MouseEnter:Connect(function() b.BackgroundColor3 = SUB.BtnHover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = SUB.Btn end)
    return b
end

local mainGap = math.max(3, math.floor(4 * CFG0.Scale))
local y0 = INNER_TOP_PAD
local sp = CFG0.BtnH + mainGap

local toggleBtn = mkBtn("Hide/Show", y0, true)
toggleBtn.MouseButton1Click:Connect(function()
    S.UI.PanelsVisible = not S.UI.PanelsVisible
    for _, p in ipairs(S.UI.Panels) do p.Visible = S.UI.PanelsVisible end
end)

local lockGuiToggle = CreateToggle("LockGui", mainBody, "lockGui", function(on)
    main.Draggable = not on
    for _, p in ipairs(S.UI.Panels) do p.Draggable = not on end
    if minF then minF.Draggable = not on end
end)
lockGuiToggle.Size = UDim2.new(1, -4*CFG0.Scale, 0, CFG0.BtnH)
lockGuiToggle.Position = UDim2.new(0, 2*CFG0.Scale, 0, y0 + sp)

local resetPosBtn = mkBtn("ResetUIPos", y0 + sp * 2)

local hideBtn = createMYQButton("HideUI", mainBody, nil, 0, false)
hideBtn.Size = UDim2.new(1, -4 * CFG0.Scale, 0, CFG0.BtnH)
hideBtn.Position = UDim2.new(0, 2 * CFG0.Scale, 0, y0 + sp * 3)
hideBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    for _, p in ipairs(S.UI.Panels) do p.Visible = false end
    if minF then minF.Visible = true end
end)

mainBody.Size = UDim2.new(1, 0, 0, y0 + sp * 3 + CFG0.BtnH + INNER_BOTTOM_PAD)

minF = Instance.new("Frame")
minF.Parent = container
minF.Name = "Frame"
minF.Size = UDim2.new(0, CFG0.MinSize, 0, CFG0.MinSize)
minF.BackgroundColor3 = C.MinFrame
minF.Visible = false
minF.BorderSizePixel = 0
minF.Active = true
minF.Draggable = true
local minC = Instance.new("UICorner"); minC.Parent = minF; minC.CornerRadius = TITLE_CORNER
local minL = Instance.new("TextLabel"); minL.Parent = minF
minL.Size = UDim2.new(1, 0, 1, 0)
minL.BackgroundTransparency = 1
minL.Text = "GUI"
minL.TextColor3 = SUB.White
minL.Font = Enum.Font.GothamBold
minL.TextSize = CFG0.Font.Min
minL.TextXAlignment = Enum.TextXAlignment.Center
minL.TextYAlignment = Enum.TextYAlignment.Center
stroke(minL)
minL.Active = false

local holdTask, pressPos
minF.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if holdTask then task.cancel(holdTask) end
    pressPos = Vector2.new(input.Position.X, input.Position.Y)
    holdTask = task.delay(0.7, function()
        if minF and minF.Visible and pressPos then
            minF.Visible = false
            main.Visible = true
            for _, p in ipairs(S.UI.Panels) do p.Visible = S.UI.PanelsVisible end
        end
        holdTask = nil
        pressPos = nil
    end)
end)
minF.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if pressPos then
            local cur = Vector2.new(input.Position.X, input.Position.Y)
            if (cur - pressPos).Magnitude > 5 then
                if holdTask then task.cancel(holdTask); holdTask = nil end
                pressPos = nil
            end
        end
    end
end)
minF.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if holdTask then task.cancel(holdTask); holdTask = nil end
        pressPos = nil
    end
end)

S.UI.Main = main
S.UI.MinFrame = minF

local function CreatePanel(titleText, list)
    list = list or {}
    local f = Instance.new("Frame")
    f.Parent = container
    f.Name = "Frame"
    f.Size = UDim2.new(0, CFG0.SubW, 0, CFG0.TitleH)
    f.BackgroundColor3 = SUB.Title
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true
    local crn = Instance.new("UICorner"); crn.Parent = f; crn.CornerRadius = TITLE_CORNER
    maskFrameBottom(f, TITLE_CORNER)

    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = SUB.White
    title.Font = Enum.Font.GothamBold
    title.TextSize = CFG0.Font.Title
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.Active = false

    local bodyBg = Instance.new("Frame", f)
    bodyBg.Name = "Body"
    bodyBg.Size = UDim2.new(1, 0, 0, 0)
    bodyBg.Position = UDim2.new(0, 0, 1, 0)
    bodyBg.BackgroundColor3 = SUB.Body
    bodyBg.BorderSizePixel = 0
    bodyBg.Active = true
    Instance.new("UICorner", bodyBg).CornerRadius = TITLE_CORNER
    maskFrameTop(bodyBg, TITLE_CORNER)

    local separator = Instance.new("Frame", bodyBg)
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.Position = UDim2.new(0, 0, 0, 0)
    separator.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    separator.BorderSizePixel = 0
    separator.ZIndex = 2

    local content = Instance.new("Frame", bodyBg)
    content.Name = "Content"
    content.Size = UDim2.new(1, -4 * CFG0.Scale, 0, 0)
    content.Position = UDim2.new(0, 2 * CFG0.Scale, 0, INNER_TOP_PAD)
    content.BackgroundColor3 = SUB.Content
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    local layout = Instance.new("UIListLayout", content)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, ITEM_GAP)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local itemCount = #list
    local lastItem = itemCount > 0 and list[itemCount] or nil
    local lastIsBlack = type(lastItem) == "table" and (lastItem.Type == "BlackButton" or lastItem.Type == "BlackLabel")
    local regularCount = lastIsBlack and (itemCount - 1) or itemCount

    local function computeBodyH(contentH)
        if lastIsBlack then
            return INNER_TOP_PAD + contentH + ITEM_GAP + CFG0.BtnH + BLACK_EXTRA_H
        else
            return INNER_TOP_PAD + contentH + INNER_BOTTOM_PAD
        end
    end
    local function recalcSize()
        task.defer(function()
            local newH = layout.AbsoluteContentSize.Y
            if newH < 10 then newH = 10 end
            content.Size = UDim2.new(1, -4 * CFG0.Scale, 0, newH)
            bodyBg.Size = UDim2.new(1, 0, 0, computeBodyH(newH))
        end)
    end

    for i = 1, regularCount do
        local item = list[i]
        if type(item) == "table" and item.Type == "Slider" then
            CreateSlider(item.Text, content, item.Key, item.Min, item.Max, item.Callback)
        elseif type(item) == "table" and item.Type == "LangSwitch" then
            createLangSwitchButton(content, recalcSize)
        elseif type(item) == "table" and item.Type == "Button" then
            if item.Text == "Close GUI" then
                createCloseGUIButton(content, function() Nanoka:Destroy() end)
            end
        elseif type(item) == "table" and item.Type == "Status" then
            local lbl = Instance.new("TextLabel", content)
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = "目标 0"
            lbl.TextColor3 = Color3.fromRGB(160, 160, 170)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = CFG0.Font.Main
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            statusLabel = lbl
        else
            CreateCFGToggle(item, content, item)
        end
    end

    task.wait(0.02)
    local h = layout.AbsoluteContentSize.Y
    if h < 10 then h = 10 end
    content.Size = UDim2.new(1, -4 * CFG0.Scale, 0, h)
    bodyBg.Size = UDim2.new(1, 0, 0, computeBodyH(h))

    if lastIsBlack then
        local blackY = INNER_TOP_PAD + h + ITEM_GAP
        local blackH = CFG0.BtnH + BLACK_EXTRA_H
        local fontScale = 1.0
        if lastItem.FontScale then fontScale = lastItem.FontScale
        elseif lastItem.BigFont then fontScale = 1.6 end
        local maxFS = math.floor(CFG0.Font.Sub * fontScale)

        if lastItem.Type == "BlackButton" then
            local blackBox = Instance.new("TextButton", bodyBg)
            blackBox.Size = UDim2.new(1, 0, 0, blackH)
            blackBox.Position = UDim2.new(0, 0, 0, blackY)
            blackBox.BackgroundColor3 = SUB.Black
            blackBox.BorderSizePixel = 0
            blackBox.Text = ""
            blackBox.AutoButtonColor = false
            blackBox.Active = true
            blackBox.ZIndex = 3
            Instance.new("UICorner", blackBox).CornerRadius = UDim.new(0, BOTTOM_CORNER_PX)

            local lbl = Instance.new("TextLabel", blackBox)
            lbl.Size = UDim2.new(1, -8, 0, CFG0.BtnH)
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.BackgroundTransparency = 1
            if lastItem.NoI18N then lbl.Text = lastItem.Text else applyI18N(lbl, lastItem.Text) end
            lbl.TextColor3 = SUB.White
            lbl.Font = Enum.Font.Gotham
            lbl.TextScaled = true
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.TextStrokeColor3 = SUB.Stroke
            lbl.TextStrokeTransparency = 0.2
            lbl.Active = false
            lbl.ZIndex = 6
            local c = Instance.new("UITextSizeConstraint", lbl)
            c.MaxTextSize = maxFS
            c.MinTextSize = 6

            local fbTask = nil
            blackBox.MouseButton1Click:Connect(function()
                if lastItem.Callback then uisafe("BlackBtn", lastItem.Callback) end
                if lastItem.Feedback then
                    if lastItem.NoI18N then
                        lbl.Text = lastItem.Feedback
                    else
                        lbl:SetAttribute("I18NKey", lastItem.Feedback)
                        lbl.Text = T(lastItem.Feedback)
                    end
                    if fbTask then task.cancel(fbTask) end
                    fbTask = task.delay(COPY_FEEDBACK_TIME, function()
                        if lbl and lbl.Parent then
                            if lastItem.NoI18N then
                                lbl.Text = lastItem.Text
                            else
                                lbl:SetAttribute("I18NKey", lastItem.Text)
                                lbl.Text = T(lastItem.Text)
                            end
                        end
                        fbTask = nil
                    end)
                end
            end)
        elseif lastItem.Type == "BlackLabel" then
            local blackBox = Instance.new("Frame", bodyBg)
            blackBox.Size = UDim2.new(1, 0, 0, blackH)
            blackBox.Position = UDim2.new(0, 0, 0, blackY)
            blackBox.BackgroundColor3 = SUB.Black
            blackBox.BorderSizePixel = 0
            blackBox.Active = false
            blackBox.ZIndex = 3
            Instance.new("UICorner", blackBox).CornerRadius = UDim.new(0, BOTTOM_CORNER_PX)

            local lbl = Instance.new("TextLabel", blackBox)
            lbl.Size = UDim2.new(1, -8, 0, CFG0.BtnH)
            lbl.Position = UDim2.new(0, 4, 0, 0)
            lbl.BackgroundTransparency = 1
            if lastItem.NoI18N then lbl.Text = lastItem.Text else applyI18N(lbl, lastItem.Text) end
            lbl.TextColor3 = SUB.White
            lbl.Font = Enum.Font.Gotham
            lbl.TextScaled = true
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.TextStrokeColor3 = SUB.Stroke
            lbl.TextStrokeTransparency = 0.2
            lbl.Active = false
            lbl.ZIndex = 6
            local c = Instance.new("UITextSizeConstraint", lbl)
            c.MaxTextSize = maxFS
            c.MinTextSize = 6
        end
    end

    table.insert(S.UI.Panels, f)
    return f
end

CreatePanel("AutoShoot", {
    "Master",
    "AttackPlayers",
    "AttackZombies",
    "TeamCheck",
    "WallCheck",
    "AdvancedUI",
    "LockBeforeFire",
    {Type="Status"},
    {Type="BlackButton", Text="作者:滚木", Feedback="复制成功", FontScale=1.8, NoI18N=true, Callback=function()
        if setclipboard then setclipboard(COPY_UID_TEXT)
        elseif toclipboard then toclipboard(COPY_UID_TEXT)
        elseif set_clipboard then set_clipboard(COPY_UID_TEXT) end
    end},
})

CreatePanel("Misc", {
    {Type="Button", Text="Close GUI"},
    {Type="LangSwitch"},
})

local sx = 6 * CFG0.Scale
local sy = ((S.DeviceType == "Tablet") and (45 * CFG0.Scale) or (65 * CFG0.Scale)) - 1
local gap = 0
local mainPos = UDim2.new(0, sx, 0, sy)
sx = sx + CFG0.MainW + gap
for _, p in ipairs(S.UI.Panels) do
    S.UI.PanelOrigins[p] = UDim2.new(0, sx, 0, sy)
    sx = sx + CFG0.SubW + gap
end
main.Position = mainPos
for p, o in pairs(S.UI.PanelOrigins) do p.Position = o end
local minPos = UDim2.new(0, 12 * CFG0.Scale, 0, 65 * CFG0.Scale)
minF.Position = minPos

resetPosBtn.MouseButton1Click:Connect(function()
    local ti = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(main, ti, {Position = mainPos}):Play()
    for p, o in pairs(S.UI.PanelOrigins) do TweenService:Create(p, ti, {Position = o}):Play() end
    TweenService:Create(minF, ti, {Position = minPos}):Play()
end)

task.spawn(function()
    while Nanoka.Parent do
        task.wait(0.3)
        for _, f in ipairs(uiRefreshers) do safe(f) end
        safe(function()
            if statusLabel and statusLabel.Parent then
                statusLabel.Text = "目标 " .. tostring(statusTargets)
                    .. " · 锁定 " .. tostring(lockCount)
                    .. (CFG.Master and " · 开火中" or "")
            end
        end)
    end
end)

Nanoka.Enabled = true
uiVisible = true

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Loaded",
        Text = string.format("%.2fs | %s", tick() - loadStartTime, S.DeviceType),
        Duration = 3
    })
end)

return CFG
