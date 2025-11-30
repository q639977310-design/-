local v_u_1 = http_request or request or (HttpPost or syn.request)
local v_u_2 = nil
local v_u_3 = 0
local function v_u_9(p4, p5, p6)
	-- upvalues: (ref) v_u_3, (ref) v_u_9
	v_u_3 = v_u_3 + 1
	if p6 then
		local v7 = v_u_9(p4, p5) and v_u_9(p4, p6)
		if v7 then
			v7 = v_u_9(p5, p6)
		end
		return v7
	else
		local v8 = type(p4) == typeof(p5) and (typeof(p4) == type(p5) and (type(p4) == typeof(p5) or typeof(p4) == type(p5))) and (#tostring(p4) == #tostring(p5) and rawequal(p4, p5))
		if v8 then
			if tostring(p4) < tostring(p5) or tostring(p4) > tostring(p5) then
				v8 = false
			else
				v8 = rawequal(tostring(p4), tostring(p5))
			end
		end
		return v8
	end
end
local function v_u_11(p10)
	return ({ ... })[p10]
end
local function v_u_18(p_u_12)
	-- upvalues: (ref) v_u_1, (ref) v_u_2, (ref) v_u_11
	local v_u_13 = false
	local v15 = {
		["__call"] = v_u_1,
		["__index"] = function(_, p14)
			-- upvalues: (ref) v_u_13, (ref) v_u_1, (ref) v_u_2, (ref) p_u_12
			v_u_13 = true
			if debug.info(2, "f") ~= v_u_1 then
				v_u_2 = "反钩子 [H - 1]"
				return "https://www.roblox.com/users/7207800972/profile"
			end
			if not coroutine.isyieldable() then
				return p_u_12[p14]
			end
			v_u_2 = "反钩子 [H - 2]"
			return "https://www.roblox.com/users/7207800972/profile"
		end
	}
	local v16 = setmetatable({}, v15)
	local v17 = v_u_11(2, pcall(v16))
	if v_u_13 then
		return v17
	end
end
local function v21(p19)
	-- upvalues: (ref) v_u_18
	local v20 = v_u_18({
		["Url"] = p19,
		["Method"] = "GET"
	})
	repeat
		task.wait()
	until v20
	return v20.Body
end
local function v23(p22)
	return string.split(p22 or "", ": ")[2]
end
local function v_u_26(p24, p25)
	-- upvalues: (ref) v_u_26
	if p24 == 0 then
		task.wait()
	end
	p25(...)
	v_u_26(p24 + 1, p25)
end
local function v28(p27)
	game:GetService("Players").LocalPlayer:Kick("")
	game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "危险行为"
	game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = p27
	task.wait(1)
	game:Shutdown()
	task.wait(1)
	task.spawn(function()
		while true do

		end
	end)
end
local v29 = {
	v_u_26,
	v_u_11,
	pcall,
	debug.info,
	islclosure,
	debug.getinfo,
	debug.getfenv,
	0,
	{
		"Url",
		"Method",
		"Headers",
		"Cookies",
		"Body"
	},
	table.insert,
	v_u_2,
	v_u_1
}
local v30 = { math.random, v_u_11, v_u_18 }
local v31 = {
	["__index"] = function()
		-- upvalues: (ref) v_u_2
		v_u_2 = "反钩子 [S1 - 1]"
	end,
	["__tostring"] = function()
		-- upvalues: (ref) v_u_2
		v_u_2 = "反钩子 [S1 - 1]"
	end
}
setmetatable(v29, v31)
local v32 = {
	["__index"] = function()
		-- upvalues: (ref) v_u_2
		v_u_2 = "反钩子 [S2 - F1]"
	end,
	["__tostring"] = function()
		-- upvalues: (ref) v_u_2
		v_u_2 = "反钩子 [S2 - F1]"
	end
}
setmetatable(v30, v32)
local v33 = type(getrawmetatable(v29).__index) ~= "function" and "反篡改 [M - S1]" or v_u_2
v_u_3 = v_u_3 + 1
local v34 = type(getrawmetatable(v29).__tostring) ~= "function" and "反篡改 [M - S1]" or v33
v_u_3 = v_u_3 + 1
local v35 = (type(getrawmetatable(v30).__index) ~= "function" or type(getrawmetatable(v30).__index) ~= type(getmetatable(v30).__index)) and "反篡改 [M - S1]" or v34
v_u_3 = v_u_3 + 1
local v36 = type(getrawmetatable(v30).__tostring) ~= "function" and "反篡改 [M - S1]" or v35
v_u_3 = v_u_3 + 1
local v37, v38 = pcall(pcall)
local _, _ = pcall(math.random)
local _, _ = pcall(setmetatable)
local _, _ = pcall(string.split)
local _, _ = pcall(debug.traceback)
local _, _ = pcall(getmetatable)
local _, _ = pcall(coroutine.wrap)
local _, _ = pcall(table.insert)
local v39 = (v37 or v38 ~= "missing argument #1") and "反函数钩子 [P]" or v36
v_u_3 = v_u_3 + 1
local v40 = {
	math.abs,
	os.clock,
	coroutine.isyieldable,
	debug.info,
	v_u_1,
	game:GetService("Players").LocalPlayer.Kick,
	table.insert,
	bit32.bxor,
	debug.getfenv,
	setrawmetatable,
	pcall,
	math.random,
	setmetatable,
	string.split,
	debug.traceback,
	debug.info,
	getrawmetatable,
	type,
	table.insert,
	math.random,
	v_u_11,
	table.concat,
	string.byte,
	string.char,
	debug.getinfo,
	islclosure,
	string.reverse,
	v_u_18,
	getmetatable
}
local v41 = next
local v42 = v_u_18
local v43 = v_u_26
local v44 = v_u_9
local v45 = v_u_3
local v46 = v_u_11
local v47 = nil
while true do
	local v48
	v47, v48 = v41(v40, v47)
	if v47 == nil then
		break
	end
	for _ = 1, 197 do
		v48 = coroutine.wrap(v48)
	end
	if v46(2, pcall(v48)) == "C stack overflow" then
		v_u_2 = "反函数钩子 [F - G2]"
		v39 = v_u_2
	end
end
v_u_3 = v45 + 1
local v49 = not debug.info(2, "f") and "反篡改 [1]" or v39
v_u_3 = v_u_3 + 1
local v50 = math.random() == math.random() and "反篡改 [2]" or v49
local v51 = not v44(v_u_3, 7) and "反钩子 [C]" or v50
local _, v52 = pcall(v43, 0, coroutine.wrap)
local v53 = v23(v52) ~= "missing argument #1 to \'wrap\' (function expected)" and "反函数钩子 [F - C]" or v51
local v54 = not string.sub(game:GetService("RbxAnalyticsService"):GetClientId(), 1, 8) == string.split(game:GetService("RbxAnalyticsService"):GetClientId(), "-")[1] and "反函数钩子 [F - S]" or v53
local v55 = loadstring(v21("https://raw.githubusercontent.com/Arg2A/v1/refs/heads/main/P"))()
local v56 = loadstring(v21("https://raw.githubusercontent.com/longshu886/linniscript/refs/heads/main/ng", true))()
local v57 = clonefunction(game:GetService("RbxAnalyticsService").GetClientId)(game:GetService("RbxAnalyticsService")):split("-")
local v58 = v57[1] .. v57[2] .. v57[3] .. v57[4] .. v57[5]
local v59 = not gethwid and "未知" or gethwid()
local v60 = table.find({ Enum.Platform.IOS }, game:GetService("UserInputService"):GetPlatform()) and "IOS" or (table.find({ Enum.Platform.Android }, game:GetService("UserInputService"):GetPlatform()) and "Android" or "PC/Mac")
local v61, v62
if v55[v58] ~= true or v56[v58] ~= true then
	v61 = "0xFF0000"
	v62 = "否"
else
	v61 = "0x32CD32"
	v62 = "是"
end
local v63 = {
	["username"] = "Advanced Bot",
	["embeds"] = {
		{
			["color"] = tonumber(tostring(v61)),
			["title"] = "有人注入了Advanced Logic",
			["fields"] = {
				{
					["name"] = "名称",
					["value"] = game:GetService("Players").LocalPlayer.Name,
					["inline"] = true
				},
				{
					["name"] = "昵称",
					["value"] = game:GetService("Players").LocalPlayer.DisplayName,
					["inline"] = true
				},
				{
					["name"] = "UID",
					["value"] = "[" .. game:GetService("Players").LocalPlayer.UserId .. "](" .. tostring("https://www.roblox.com/users/" .. game:GetService("Players").LocalPlayer.UserId .. "/profile") .. ")",
					["inline"] = true
				},
				{
					["name"] = "游戏ID",
					["value"] = "[" .. game.PlaceId .. "](" .. tostring("https://www.roblox.com/games/" .. game.PlaceId) .. ")",
					["inline"] = true
				},
				{
					["name"] = "游戏名称",
					["value"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
					["inline"] = true
				},
				{
					["name"] = "注入器",
					["value"] = identifyexecutor(),
					["inline"] = true
				},
				{
					["name"] = "HWID",
					["value"] = v59,
					["inline"] = true
				},
				{
					["name"] = "客户端ID",
					["value"] = game:GetService("RbxAnalyticsService"):GetClientId(),
					["inline"] = false
				},
				{
					["name"] = "设备",
					["value"] = v60,
					["inline"] = true
				},
				{
					["name"] = "用户状态",
					["value"] = v62,
					["inline"] = true
				}
			},
			["timestamp"] = os.date("%Y-%m-%dT%X.000Z")
		}
	}
}
v42({
	["Url"] = "https://discord.com/api/webhooks/1268122774069579806/Pi7q9f25rIwlkr-iLiIFEPJIvxx5dzcA9tSUXoTY8R1uUXF-CnFMJ91V2aX75dBOJCuY",
	["Method"] = "POST",
	["Headers"] = {
		["Content-Type"] = "application/json"
	},
	["Body"] = game.HttpService:JSONEncode(v63)
})
if v54 ~= nil then
	v28(v54)
end
if v55[v58] == true or v56[v58] == true then
	setfpscap(math.huge)
	_G.ScriptIsRunning = false
	_G.ScriptIsRunning = true
	local v_u_64 = game:GetService("Players")
	local v_u_65 = v_u_64.LocalPlayer
	game:GetService("CoreGui")
	game:GetService("RbxAnalyticsService")
	game:GetService("RunService")
	local _ = v_u_65.PlayerGui
	local v_u_66 = game:GetService("Workspace")
	local v_u_67 = game:GetService("Lighting")
	local v_u_68 = v_u_66.Zombies
	local v_u_69 = {
		["Red"] = Color3.fromRGB(255, 0, 0),
		["Green"] = Color3.fromRGB(0, 255, 0),
		["Blue"] = Color3.fromRGB(0, 0, 255),
		["Pink"] = Color3.fromRGB(255, 170, 255),
		["Cyan"] = Color3.fromRGB(85, 255, 255)
	}
	local v_u_70 = {
		["EspToggle"] = false,
		["HighlightToggle"] = false,
		["HighlightTransparency"] = 0.5,
		["SelectFillColor"] = Color3.fromRGB(255, 0, 0),
		["Fullbright"] = false,
		["Noclip"] = false,
		["Fly"] = false,
		["Flyspeed"] = 30,
		["InfJump"] = false,
		["SelectPlr"] = nil,
		["ZombieEsp"] = false,
		["KillAura"] = false,
		["AutoTeleportToSelectPlr"] = false,
		["AutoTeleportToSelectPlrDistance"] = 4.5,
		["EspScale"] = 0.5
	}
	local v_u_71 = loadstring(v21("https://raw.githubusercontent.com/ScriptMonkeyIsA1/Scripts/refs/heads/main/ns.cc"))()
	local v72 = loadstring(v21("https://raw.githubusercontent.com/ScriptMonkeyIsA1/Scripts/refs/heads/main/bob.afk"))()
	local v73 = loadstring(v21("https://raw.githubusercontent.com/Arg2A/v1/refs/heads/main/v"))():new("<font color=\"rgb(0,180,216)\">Advanced</font> <font color=\"rgb(252,255,0)\">Logic</font>", true, "gamesense", 0, false)
	local v74 = v73:Tab("战斗", "17901200092"):Section("杀戮光环", false)
	local v75 = v73:Tab("透视", "7733696665")
	local v76 = v75:Section("功能", false)
	local v77 = v75:Section("透视设置", false)
	local v78 = v73:Tab("玩家", "7743876054"):Section("玩家选项", true)
	local v79 = v73:Tab("本地", "7733752575")
	local v80 = v79:Section("本地玩家", false)
	local v_u_81 = v79:Section("本地视觉", false)
	local v82 = v79:Section("天空盒", false)
	local v83 = v73:Tab("关于", "7743871575")
	local v84 = v83:Section("关于作者", true)
	local v85 = v83:Section("关于脚本", true)
	function UpdateEsp(p_u_86, p_u_87)
		-- upvalues: (ref) v_u_64, (ref) v_u_70
		pcall(function()
			-- upvalues: (ref) v_u_64, (ref) p_u_86, (ref) v_u_70, (ref) p_u_87
			if v_u_64:FindFirstChild(p_u_86) and v_u_64:FindFirstChild(p_u_86).Character then
				if not (v_u_64:FindFirstChild(p_u_86).Character.Head:FindFirstChild("ALESP") and v_u_64:FindFirstChild(p_u_86).Character:FindFirstChild("ALHL")) then
					if not v_u_64:FindFirstChild(p_u_86).Character.Head:FindFirstChild("ALESP") then
						local v88 = Instance.new("BillboardGui")
						local v89 = Instance.new("TextLabel")
						v88.Name = "ALESP"
						v88.Parent = v_u_64:FindFirstChild(p_u_86).Character.Head
						v88.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
						v88.Active = true
						v88.ExtentsOffset = Vector3.new(0, 2, 0)
						v88.LightInfluence = 1
						v88.Size = UDim2.new(0, 200, 0, 50)
						v88.Enabled = v_u_70.EspToggle
						v88.AlwaysOnTop = true
						v89.Name = "Text"
						v89.Parent = v88
						v89.AnchorPoint = Vector2.new(0.5, 0.5)
						v89.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						v89.BackgroundTransparency = 1
						v89.BorderColor3 = Color3.fromRGB(0, 0, 0)
						v89.BorderSizePixel = 5
						v89.Position = UDim2.new(0.5, 0, 0.5, 0)
						v89.Size = UDim2.new(v_u_70.EspScale, 0, v_u_70.EspScale, 0)
						v89.Font = Enum.Font.SourceSansBold
						v89.Text = v_u_64:FindFirstChild(p_u_86).Name
						v89.TextColor3 = Color3.fromRGB(255, 255, 255)
						v89.TextScaled = true
						v89.TextSize = 1
						v89.TextStrokeTransparency = 0.19
						v89.TextWrapped = true
					end
					if not v_u_64:FindFirstChild(p_u_86).Character:FindFirstChild("ALHL") then
						local v90 = Instance.new("Highlight")
						v90.Name = "ALHL"
						v90.Parent = v_u_64:FindFirstChild(p_u_86).Character
						v90.FillColor = p_u_87
						v90.Enabled = v_u_70.HighlightToggle
						v90.FillTransparency = v_u_70.HighlightTransparency
					end
				end
				if v_u_64:FindFirstChild(p_u_86).Character.Head:FindFirstChild("ALESP") then
					local v91 = v_u_64:FindFirstChild(p_u_86).Character.Head:FindFirstChild("ALESP")
					local v92 = v91.Text
					v91.Enabled = v_u_70.EspToggle
					v92.Text = v_u_64:FindFirstChild(p_u_86).Name
					v92.Size = UDim2.new(v_u_70.EspScale, 0, v_u_70.EspScale, 0)
					v92.TextColor3 = p_u_87
				end
				if v_u_64:FindFirstChild(p_u_86).Character:FindFirstChild("ALHL") then
					local v93 = v_u_64:FindFirstChild(p_u_86).Character:FindFirstChild("ALHL")
					v93.FillColor = p_u_87
					v93.Enabled = v_u_70.HighlightToggle
					v93.FillTransparency = v_u_70.HighlightTransparency
				end
			end
		end)
	end
	function ZombieUpdateEsp(p_u_94, p_u_95)
		-- upvalues: (ref) v_u_64, (ref) v_u_70
		pcall(function()
			-- upvalues: (ref) p_u_94, (ref) v_u_64, (ref) v_u_70, (ref) p_u_95
			if p_u_94 and (p_u_94:GetAttribute("Type") ~= nil and p_u_94.Head) then
				if not (p_u_94.Head:FindFirstChild("ALESP") or p_u_94.Head:FindFirstChild("ALESP")) then
					local v96 = Instance.new("BillboardGui")
					local v97 = Instance.new("TextLabel")
					v96.Name = "ALESP"
					v96.Parent = v_u_64:FindFirstChild(plr).Character.Head
					v96.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
					v96.Active = true
					v96.ExtentsOffset = Vector3.new(0, 2, 0)
					v96.LightInfluence = 1
					v96.Size = UDim2.new(0, 200, 0, 50)
					v96.Enabled = v_u_70.EspToggle
					v96.AlwaysOnTop = true
					v97.Name = "Text"
					v97.Parent = v96
					v97.AnchorPoint = Vector2.new(0.5, 0.5)
					v97.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					v97.BackgroundTransparency = 1
					v97.BorderColor3 = Color3.fromRGB(0, 0, 0)
					v97.BorderSizePixel = 5
					v97.Position = UDim2.new(0.5, 0, 0.5, 0)
					v97.Size = UDim2.new(v_u_70.EspScale, 0, v_u_70.EspScale, 0)
					v97.Font = Enum.Font.SourceSansBold
					v97.Text = v_u_64:FindFirstChild(plr).Name
					v97.TextColor3 = Color3.fromRGB(255, 255, 255)
					v97.TextScaled = true
					v97.TextSize = 1
					v97.TextStrokeTransparency = 0.19
					v97.TextWrapped = true
				end
				if p_u_94.Head:FindFirstChild("ALESP") then
					local v98 = p_u_94.Head:FindFirstChild("ALESP")
					local v99 = v98.Text
					v98.Enabled = v_u_70.ZombieEsp
					v99.Text = p_u_94:GetAttribute("Type")
					v99.TextColor3 = p_u_95
				end
			end
		end)
	end
	function SpawnSkybox(p100)
		-- upvalues: (ref) v_u_67, (ref) v_u_71
		local v101 = v_u_67
		local v102, v103, v104 = pairs(v101:GetChildren())
		while true do
			local v105
			v104, v105 = v102(v103, v104)
			if v104 == nil then
				break
			end
			if v105:IsA("Sky") then
				v105:Destroy()
			end
		end
		if p100.Bk and (p100.Dn and (p100.Ft and (p100.Lf and (p100.Rt and (p100.Up and p100.Name))))) then
			local v106 = Instance.new("Sky")
			v106.Name = p100.Name
			v106.SkyboxBk = p100.Bk
			v106.SkyboxDn = p100.Dn
			v106.SkyboxFt = p100.Ft
			v106.SkyboxLf = p100.Lf
			v106.SkyboxRt = p100.Rt
			v106.SkyboxUp = p100.Up
			v106.Parent = v_u_67
			if p100.SunAsset and p100.SunAngularSize then
				v106.SunTextureId = p100.SunAsset
				v106.SunAngularSize = p100.SunAngularSize
			end
		else
			v_u_71:Notify("无效的天空盒参数", 2)
		end
	end
	function GetMelee()
		-- upvalues: (ref) v_u_65
		local v107, v108, v109 = pairs(v_u_65.Character:GetChildren())
		while true do
			local v110
			v109, v110 = v107(v108, v109)
			if v109 == nil then
				break
			end
			if v110:GetAttribute("Melee") then
				return v110
			end
		end
		local v111, v112, v113 = pairs(v_u_65.Backpack:GetChildren())
		while true do
			local v114
			v113, v114 = v111(v112, v113)
			if v113 == nil then
				break
			end
			if v114:GetAttribute("Melee") then
				return v114
			end
		end
	end
	function DistanceToCharacter(p115)
		-- upvalues: (ref) v_u_65
		if v_u_65.Character ~= nil then
			return (p115.HumanoidRootPart.CFrame.Position - v_u_65.Character.HumanoidRootPart.CFrame.Position).Magnitude
		end
	end
	local v_u_116 = {
		["AttackBarrel"] = false,
		["FaceToZombie"] = false
	}
	function KillAuraFunc()
		-- upvalues: (ref) v_u_70, (ref) v_u_68, (ref) v_u_65, (ref) v_u_116
		while v_u_70.KillAura == true do
			pcall(function()
				-- upvalues: (ref) v_u_68, (ref) v_u_70, (ref) v_u_65, (ref) v_u_116
				local v117 = v_u_68
				local v118, v119, v120 = pairs(v117:GetChildren())
				while true do
					local v121
					v120, v121 = v118(v119, v120)
					if v120 == nil then
						break
					end
					if v_u_70.KillAura == false then
						return
					end
					if v121.PrimaryPart ~= nil and (v_u_65.Character ~= nil and (v121:IsA("Model") and (DistanceToCharacter(v121) <= 12 and v121.State.Value ~= "Spawn"))) and v_u_65.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						if v121:GetAttribute("Type") == "Barrel" and v_u_116.AttackBarrel == false then
							return
						end
						local v122 = 10
						local v123 = GetMelee()
						if v123 then
							local v124 = v123.Name == "Pike" and 11 or v122
							local v125 = v123.Name == "Axe" and 9 or v124
							if v_u_116.FaceToZombie == true then
								local v126 = v121.PrimaryPart.CFrame.Position
								v_u_65.Character.HumanoidRootPart.CFrame = CFrame.lookAt(v_u_65.Character.HumanoidRootPart.CFrame.Position, Vector3.new(v126.X, v_u_65.Character.HumanoidRootPart.CFrame.Position.Y, v126.Z))
							end
							v_u_65.Character:FindFirstChildOfClass("Humanoid"):EquipTool(v123)
							if v_u_65.Character:FindFirstChildOfClass("Humanoid").AutoRotate == false then
								v_u_65.Character:FindFirstChildOfClass("Humanoid").AutoRotate = true
							end
							if v123.Name == "Axe" and v121.State.Value ~= "Stunned" then
								v123.RemoteEvent:FireServer("BraceBlock")
								v123.RemoteEvent:FireServer("StopBraceBlock")
								v123.RemoteEvent:FireServer("FeedbackStun", v121, v121.HumanoidRootPart.Position)
							end
							if DistanceToCharacter(v121) <= v125 then
								v123.RemoteEvent:FireServer("Swing", "Side")
								v123.RemoteEvent:FireServer("HitZombie", v121, v121.Head.Position, true)
							end
						end
					end
				end
			end)
			task.wait()
		end
	end
	v74:Toggle("开关", "KillAura", false, function(p127)
		-- upvalues: (ref) v_u_70
		v_u_70.KillAura = p127
		KillAuraFunc()
	end)
	v74:Toggle("攻击炸药桶僵尸", "AttackBarrel", false, function(p128)
		-- upvalues: (ref) v_u_116
		v_u_116.AttackBarrel = p128
	end)
	v74:Toggle("攻击时面向僵尸", "FacetoZombie", false, function(p129)
		-- upvalues: (ref) v_u_116
		v_u_116.FaceToZombie = p129
	end)
	v76:Toggle("玩家透视开关", "EspToggle", false, function(p130)
		-- upvalues: (ref) v_u_70
		v_u_70.EspToggle = p130
	end)
	v76:Toggle("僵尸透视开关", "HighlightToggle", false, function(p131)
		-- upvalues: (ref) v_u_70
		v_u_70.ZombieEsp = p131
	end)
	v76:Toggle("上色开关", "HighlightToggle", false, function(p132)
		-- upvalues: (ref) v_u_70
		v_u_70.HighlightToggle = p132
	end)
	task.spawn(function()
		-- upvalues: (ref) v_u_68, (ref) v_u_69
		while _G.ScriptIsRunning == true do
			local v133 = v_u_68
			local v134, v135, v136 = pairs(v133:GetChildren())
			while true do
				local v137
				v136, v137 = v134(v135, v136)
				if v136 == nil then
					break
				end
				ZombieUpdateEsp(v137, v_u_69.Red)
			end
			task.wait(2)
		end
	end)
	v77:Dropdown("透视颜色", "SelectFillColor", {
		"红",
		"绿",
		"蓝",
		"粉",
		"青"
	}, function(p138)
		-- upvalues: (ref) v_u_70, (ref) v_u_69
		if p138 == "红" then
			v_u_70.SelectFillColor = v_u_69.Red
		elseif p138 == "绿" then
			v_u_70.SelectFillColor = v_u_69.Green
		elseif p138 == "蓝" then
			v_u_70.SelectFillColor = v_u_69.Blue
		elseif p138 == "粉" then
			v_u_70.SelectFillColor = v_u_69.Pink
		elseif p138 == "青" then
			v_u_70.SelectFillColor = v_u_69.Cyan
		end
	end)
	v77:Slider("透视大小", "FillTransparency", 0.5, 0.1, 1, true, function(p139)
		-- upvalues: (ref) v_u_70
		v_u_70.EspScale = p139
	end)
	v77:Slider("上色透明度", "FillTransparency", 0.5, 0, 1, true, function(p140)
		-- upvalues: (ref) v_u_70
		v_u_70.HighlightTransparency = p140
	end)
	task.spawn(function()
		-- upvalues: (ref) v_u_64, (ref) v_u_65, (ref) v_u_70
		while _G.ScriptIsRunning == true do
			local v141 = v_u_64
			local v142, v143, v144 = pairs(v141:GetChildren())
			while true do
				local v145
				v144, v145 = v142(v143, v144)
				if v144 == nil then
					break
				end
				if v145.Name ~= v_u_65.Name then
					UpdateEsp(v145.Name, v_u_70.SelectFillColor)
				end
			end
			task.wait()
		end
	end)
	local v146 = v_u_64
	local v147, v148, v149 = pairs(v_u_64.GetChildren(v146))
	local v_u_150 = v_u_67
	local v_u_151 = v_u_64
	local v_u_152 = v_u_70
	local v_u_153 = v_u_65
	local v_u_154 = {}
	while true do
		local v155, v156 = v147(v148, v149)
		if v155 == nil then
			break
		end
		v149 = v155
		if v156.Name ~= v_u_153.Name then
			table.insert(v_u_154, v156.Name)
		end
	end
	local v_u_158 = v78:Dropdown("玩家列表", "Players", v_u_154, function(p157)
		-- upvalues: (ref) v_u_152
		v_u_152.SelectPlr = p157
	end)
	v_u_151.PlayerAdded:Connect(function(p159)
		-- upvalues: (ref) v_u_154, (ref) v_u_158
		table.insert(v_u_154, p159.Name)
		v_u_158.AddOption(p159.Name)
	end)
	v_u_151.PlayerRemoving:Connect(function(p160)
		-- upvalues: (ref) v_u_154, (ref) v_u_158
		table.remove(v_u_154, table.find(v_u_154, p160.Name))
		v_u_158.RemoveOption(p160.Name)
	end)
	v78:Button("传送到选中的玩家", function()
		-- upvalues: (ref) v_u_153, (ref) v_u_151, (ref) v_u_152
		pcall(function()
			-- upvalues: (ref) v_u_153, (ref) v_u_151, (ref) v_u_152
			local v161 = v_u_151
			v_u_153.Character.HumanoidRootPart.CFrame = v161:FindFirstChild(v_u_152.SelectPlr).Character.HumanoidRootPart.CFrame
		end)
	end)
	v78:Toggle("自动传送到选择的玩家身后", "Noclip", false, function(p162)
		-- upvalues: (ref) v_u_152
		v_u_152.AutoTeleportToSelectPlr = p162
	end)
	v78:Slider("自动传送距离", "Slider", 4.5, 1, 20, true, function(p163)
		-- upvalues: (ref) v_u_152
		v_u_152.AutoTeleportToSelectPlrDistance = p163
	end)
	task.spawn(function()
		-- upvalues: (ref) v_u_152, (ref) v_u_153, (ref) v_u_151
		while _G.ScriptIsRunning == true do
			if v_u_152.AutoTeleportToSelectPlr == true then
				pcall(function()
					-- upvalues: (ref) v_u_153, (ref) v_u_151, (ref) v_u_152
					local v164 = v_u_151
					local v165 = v_u_151
					v_u_153.Character.HumanoidRootPart.CFrame = v164:FindFirstChild(v_u_152.SelectPlr).Character.HumanoidRootPart.CFrame - v165:FindFirstChild(v_u_152.SelectPlr).Character.HumanoidRootPart.CFrame.LookVector * v_u_152.AutoTeleportToSelectPlrDistance
				end)
			end
			task.wait()
		end
	end)
	local v_u_166 = {
		["WalkSpeed"] = 16,
		["WalkSpeedToggle"] = false,
		["JumpPower"] = 50,
		["JumpPowerToggle"] = false,
		["Gravity"] = 196.2,
		["GravityToggle"] = false,
		["Fly"] = false,
		["FlySpeed"] = 30
	}
	v80:Label("移动速度")
	function WalkSpeed()
		-- upvalues: (ref) v_u_166, (ref) v_u_153
		while v_u_166.WalkSpeedToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_153, (ref) v_u_166
				v_u_153.Character.Humanoid.WalkSpeed = v_u_166.WalkSpeed
			end)
			task.wait()
		end
	end
	v80:Slider("数值", "WalkSpeed", 16, 1, 150, true, function(p167)
		-- upvalues: (ref) v_u_166
		v_u_166.WalkSpeed = p167
	end)
	v80:Toggle("开关", "WalkSpeedToggle", false, function(p168)
		-- upvalues: (ref) v_u_166
		v_u_166.WalkSpeedToggle = p168
		WalkSpeed()
	end)
	v80:Label("跳跃高度")
	function JumpPower()
		-- upvalues: (ref) v_u_166, (ref) v_u_153
		while v_u_166.JumpPowerToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_153, (ref) v_u_166
				v_u_153.Character.Humanoid.JumpPower = v_u_166.JumpPower
			end)
			task.wait()
		end
	end
	v80:Slider("数值", "JumpPower", 50, 1, 150, true, function(p169)
		-- upvalues: (ref) v_u_166
		v_u_166.JumpPower = p169
	end)
	v80:Toggle("开关", "JumpPowerToggle", false, function(p170)
		-- upvalues: (ref) v_u_166
		v_u_166.JumpPowerToggle = p170
		JumpPower()
	end)
	v80:Label("重力")
	function Gravity()
		-- upvalues: (ref) v_u_166, (ref) v_u_66
		while v_u_166.GravityToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_66, (ref) v_u_166
				v_u_66.Gravity = v_u_166.Gravity
			end)
			task.wait()
		end
	end
	v80:Slider("数值", "Gravity", 196.2, 1, 1000, true, function(p171)
		-- upvalues: (ref) v_u_166
		v_u_166.Gravity = p171
	end)
	v80:Toggle("开关", "GravityToggle", false, function(p172)
		-- upvalues: (ref) v_u_166
		v_u_166.GravityToggle = p172
		Gravity()
	end)
	function NoclipFunc()
		-- upvalues: (ref) v_u_152, (ref) v_u_153
		while v_u_152.Noclip == true do
			pcall(function()
				-- upvalues: (ref) v_u_153
				local v173, v174, v175 = pairs(v_u_153.Character:GetChildren())
				while true do
					local v176
					v175, v176 = v173(v174, v175)
					if v175 == nil then
						break
					end
					if v176:IsA("BasePart") then
						v176.CanCollide = false
					end
				end
			end)
			task.wait()
		end
	end
	v80:Toggle("穿墙", "Noclip", false, function(p177)
		-- upvalues: (ref) v_u_152, (ref) v_u_153
		v_u_152.Noclip = p177
		if p177 == false then
			pcall(function()
				-- upvalues: (ref) v_u_153
				local v178, v179, v180 = pairs(v_u_153.Character:GetChildren())
				while true do
					local v181
					v180, v181 = v178(v179, v180)
					if v180 == nil then
						break
					end
					if v181:IsA("BasePart") and (v181.Name == "Head" or (v181.Name == "Torso" or (v181.Name == "UpperTorso" or v181.Name == "LowerTorso"))) then
						v181.CanCollide = true
					end
				end
			end)
		end
		NoclipFunc()
	end)
	v80:Toggle("无限跳", "InfJump", false, function(p182)
		-- upvalues: (ref) v_u_152
		v_u_152.InfJump = p182
	end)
	game:GetService("UserInputService").JumpRequest:Connect(function()
		-- upvalues: (ref) v_u_152, (ref) v_u_153
		if v_u_152.InfJump == true then
			v_u_153.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
		end
	end)
	local function v_u_187()
		-- upvalues: (ref) v_u_166, (ref) v_u_153, (ref) v_u_66
		while v_u_166.Fly == true do
			pcall(function()
				-- upvalues: (ref) v_u_153, (ref) v_u_66, (ref) v_u_166
				if not v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
					local v183 = Instance.new("BodyVelocity")
					v183.Name = "FlyVelocity"
					v183.Parent = v_u_153.Character.HumanoidRootPart
					v183.MaxForce = Vector3.new(0, 0, 0)
					v183.Velocity = Vector3.new(0, 0, 0)
				end
				if not v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyGyro") then
					local v184 = Instance.new("BodyGyro")
					v184.Name = "FlyGyro"
					v184.Parent = v_u_153.Character.HumanoidRootPart
					v184.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
					v184.P = 1000
					v184.D = 50
				end
				if v_u_153.Character and (v_u_153.Character:FindFirstChildOfClass("Humanoid") and v_u_153.Character.Humanoid.RootPart and (v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") and v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyGyro"))) then
					local v185 = v_u_66.CurrentCamera
					v_u_153.Character.HumanoidRootPart.FlyGyro.CFrame = v_u_66.CurrentCamera.CFrame
					local v186 = require(v_u_153.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule")):GetMoveVector()
					v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity = Vector3.new()
					if v186.X > 0 then
						v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity = v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity + v185.CFrame.RightVector * (v186.X * v_u_166.FlySpeed)
					end
					if v186.X < 0 then
						v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity = v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity + v185.CFrame.RightVector * (v186.X * v_u_166.FlySpeed)
					end
					if v186.Z > 0 then
						v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity = v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity - v185.CFrame.LookVector * (v186.Z * v_u_166.FlySpeed)
					end
					if v186.Z < 0 then
						v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity = v_u_153.Character.HumanoidRootPart.FlyVelocity.Velocity - v185.CFrame.LookVector * (v186.Z * v_u_166.FlySpeed)
					end
					v_u_153.Character.Humanoid.PlatformStand = true
					v_u_153.Character.HumanoidRootPart.FlyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
					v_u_153.Character.HumanoidRootPart.FlyGyro.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
				end
			end)
			task.wait()
		end
	end
	v80:Toggle("飞行", "Fly", false, function(p188)
		-- upvalues: (ref) v_u_166, (ref) v_u_153, (ref) v_u_187
		v_u_166.Fly = p188
		if p188 == false then
			v_u_153.Character.Humanoid.PlatformStand = false
			if v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
				v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyVelocity"):Destroy()
			end
			if v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyGyro") then
				v_u_153.Character.HumanoidRootPart:FindFirstChild("FlyGyro"):Destroy()
			end
		end
		v_u_187()
	end)
	v80:Slider("飞行速度", "Slider", 30, 1, 150, true, function(p189)
		-- upvalues: (ref) v_u_166
		v_u_166.FlySpeed = p189
	end)
	local v_u_190 = {
		["DefFOV"] = v_u_66.CurrentCamera.FieldOfView,
		["DefCameraMaxZoomDistance"] = v_u_153.CameraMaxZoomDistance,
		["DefCameraMinZoomDistance"] = v_u_153.CameraMinZoomDistance,
		["FieldOfView"] = 70,
		["FieldOfViewToggle"] = false,
		["CameraMaxZoomDistance"] = 128,
		["CameraMaxZoomDistanceToggle"] = false,
		["CameraMinZoomDistance"] = 0.5,
		["CameraMinZoomDistanceToggle"] = false,
		["FullBright"] = false,
		["DefAmbient"] = v_u_150.Ambient
	}
	function FieldOfView()
		-- upvalues: (ref) v_u_190, (ref) v_u_66, (ref) v_u_81
		while v_u_190.FieldOfViewToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_66, (ref) v_u_81
				v_u_66.CurrentCamera.FieldOfView = v_u_81.FieldOfView
			end)
			task.wait()
		end
	end
	function CameraMaxZoomDistance()
		-- upvalues: (ref) v_u_190, (ref) v_u_153, (ref) v_u_81
		while v_u_190.CameraMaxZoomDistanceToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_153, (ref) v_u_81
				v_u_153.CameraMaxZoomDistance = v_u_81.CameraMaxZoomDistance
			end)
			task.wait()
		end
	end
	function CameraMinZoomDistance()
		-- upvalues: (ref) v_u_190, (ref) v_u_153
		while v_u_190.CameraMinZoomDistanceToggle == true do
			pcall(function()
				-- upvalues: (ref) v_u_153, (ref) v_u_190
				v_u_153.CameraMinZoomDistance = v_u_190.CameraMinZoomDistance
			end)
			task.wait()
		end
	end
	v_u_81:Slider("Fov", "Slider", 70, 1, 120, true, function(p191)
		-- upvalues: (ref) v_u_81, (ref) v_u_66, (ref) v_u_190
		v_u_81.FieldOfView = p191
		if p191 == false then
			v_u_66.CurrentCamera.FieldOfView = v_u_190.DefFOV
		end
		FieldOfView()
	end)
	v_u_81:Slider("最大相机聚焦距离", "Slider", 128, 1, 1200, true, function(p192)
		-- upvalues: (ref) v_u_81, (ref) v_u_153
		v_u_81.CameraMaxZoomDistance = p192
		if p192 == false then
			v_u_153.CameraMaxZoomDistance = v_u_81.DefCameraMaxZoomDistance
		end
		CameraMaxZoomDistance()
	end)
	v_u_81:Slider("最小相机聚焦距离", "Slider", 0.5, 1, 50, true, function(p193)
		-- upvalues: (ref) v_u_81, (ref) v_u_153, (ref) v_u_190
		v_u_81.CameraMinZoomDistance = p193
		if p193 == false then
			v_u_153.CameraMinZoomDistance = v_u_190.DefCameraMinZoomDistance
		end
		CameraMinZoomDistance()
	end)
	function FullBright()
		-- upvalues: (ref) v_u_166, (ref) v_u_150
		while v_u_166.FullBright == true do
			pcall(function()
				-- upvalues: (ref) v_u_150
				v_u_150.Ambient = Color3.new(1, 1, 1)
			end)
			task.wait()
		end
	end
	v_u_81:Toggle("全局高亮", "FullBright", false, function(p194)
		-- upvalues: (ref) v_u_190, (ref) v_u_150
		v_u_190.FullBright = p194
		if p194 == false then
			v_u_150.Ambient = v_u_190.DefAmbient
		end
		FullBright()
	end)
	local v_u_195 = {
		["Bk"] = nil,
		["Dn"] = nil,
		["Ft"] = nil,
		["Lf"] = nil,
		["Rt"] = nil,
		["Up"] = nil
	}
	v82:Dropdown("天空盒", "Skybox", { "cs_办公室", "Always.win", "Advanced Logic" }, function(p196)
		if p196 == "cs_办公室" then
			SpawnSkybox({
				["Name"] = "cs_office",
				["Bk"] = "rbxassetid://658623433",
				["Dn"] = "rbxassetid://316342560",
				["Ft"] = "rbxassetid://658625205",
				["Lf"] = "rbxassetid://658627155",
				["Rt"] = "rbxassetid://658628504",
				["Up"] = "rbxassetid://658632701"
			})
		elseif p196 == "Always.win" then
			SpawnSkybox({
				["Name"] = "Always.win",
				["Bk"] = "rbxassetid://17411013742",
				["Dn"] = "rbxassetid://17411013742",
				["Ft"] = "rbxassetid://17411013742",
				["Lf"] = "rbxassetid://17411013742",
				["Rt"] = "rbxassetid://17411013742",
				["Up"] = "rbxassetid://17411013742"
			})
		elseif p196 == "Advanced Logic" then
			SpawnSkybox({
				["Name"] = "Advanced Logic",
				["Bk"] = "rbxassetid://17803761395",
				["Dn"] = "rbxassetid://17803761395",
				["Ft"] = "rbxassetid://17803761395",
				["Lf"] = "rbxassetid://17803761395",
				["Rt"] = "rbxassetid://17803761395",
				["Up"] = "rbxassetid://17803761395",
				["SunAsset"] = "rbxassetid://17768924741",
				["SunAngularSize"] = 50
			})
		end
	end)
	v82:Textbox("自定义天空盒Bk", "Textbox", "请输入SkyboxBk贴图ID", function(p_u_197)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_197, (ref) v_u_195
			if p_u_197:find("rbx") then
				v_u_195.Bk = p_u_197
			else
				v_u_195.Bk = "rbxassetid://" .. p_u_197
			end
		end)
	end)
	v82:Textbox("自定义天空盒Dn", "Textbox", "请输入SkyboxDn贴图ID", function(p_u_198)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_198, (ref) v_u_195
			if p_u_198:find("rbx") then
				v_u_195.Dn = p_u_198
			else
				v_u_195.Dn = "rbxassetid://" .. p_u_198
			end
		end)
	end)
	v82:Textbox("自定义天空盒Ft", "Textbox", "请输入SkyboxFt贴图ID", function(p_u_199)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_199, (ref) v_u_195
			if p_u_199:find("rbx") then
				v_u_195.Ft = p_u_199
			else
				v_u_195.Ft = "rbxassetid://" .. p_u_199
			end
		end)
	end)
	v82:Textbox("自定义天空盒Lf", "Textbox", "请输入SkyboxLf贴图ID", function(p_u_200)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_200, (ref) v_u_195
			if p_u_200:find("rbx") then
				v_u_195.Lf = p_u_200
			else
				v_u_195.Lf = "rbxassetid://" .. p_u_200
			end
		end)
	end)
	v82:Textbox("自定义天空盒Rt", "Textbox", "请输入SkyboxRt贴图ID", function(p_u_201)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_201, (ref) v_u_195
			if p_u_201:find("rbx") then
				v_u_195.Rt = p_u_201
			else
				v_u_195.Rt = "rbxassetid://" .. p_u_201
			end
		end)
	end)
	v82:Textbox("自定义天空盒Up", "Textbox", "请输入SkyboxUp贴图ID", function(p_u_202)
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) p_u_202, (ref) v_u_195
			if p_u_202:find("rbx") then
				v_u_195.Up = p_u_202
			else
				v_u_195.Up = "rbxassetid://" .. p_u_202
			end
		end)
	end)
	v82:Button("修改自定义天空盒", function()
		-- upvalues: (ref) v_u_195
		pcall(function()
			-- upvalues: (ref) v_u_195
			SpawnSkybox({
				["Name"] = "我爱手冲",
				["Bk"] = v_u_195.Bk,
				["Dn"] = v_u_195.Dn,
				["Ft"] = v_u_195.Ft,
				["Lf"] = v_u_195.Lf,
				["Rt"] = v_u_195.Rt,
				["Up"] = v_u_195.Up
			})
		end)
	end)
	v84:Label("团队")
	v84:Label("Advanced Logic")
	v84:Label("群号: 684407929")
	v85:Label("当前版本 " .. v72)
else
	game:GetService("Players").LocalPlayer:Kick("您不是白名单用户,请加入684407929(Adavanced Logic官方群)购买")
	setclipboard(game:GetService("RbxAnalyticsService"):GetClientId())
end
