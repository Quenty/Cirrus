local cirrus = {}
local MarketplaceService = game:getService("MarketplaceService")
local engine = script.Parent
local resourceBin = game.Lighting:findFirstChild("Cirrus")
local info = game:getService("MarketplaceService"):GetProductInfo(124635387)["Description"]
local newVersion = string.match(info, "v[%d%.]+") or engine.version.Value
local logs = string.match(info, "Logs:(.+):EndLogs") or "No update logs for Cirrus found"
local settings = {}
	settings.customChars = true
	settings.splashScreen = true
	settings.blacklist = 128527648 --This doesn't actually have a blacklist in it.
if resourceBin and resourceBin:findFirstChild("Settings") then
	for i, v in pairs(resourceBin.Settings:GetChildren()) do
		if v:IsA("Instance") and string.find(v.ClassName, "Value") then
			settings[v.Name] = v.Value
		end
	end
end

local bins = {} --Index is a player object. Value is the bin that contains the client main script and other cirrus related stuff.
local outputText = {} --Index is default, value is a message.

--Allows you to call a function without error in the case that it does not exist
cirrus.tryf = function(func)
	if type(func) == "function" then
		return func
	else
		return function() end
	end
end

cirrus.destroy = function(...)
	local success = true
	for _, obj in pairs({...}) do
		if not pcall(function() obj:Destroy() end) then
			success = false
		end
	end
	return success
end

--Allows you to string code to your main script.
cirrus.load = function(...)
	local failed = false
	for i, scriptName in pairs({...}) do
		local s = resourceBin.Server:findFirstChild(scriptName)
		if s and s:IsA("Script") then
			s:clone().Parent = engine
			cirrus.output("Loaded "..scriptName)
		else
			cirrus.output("Failed to load "..scriptName)
			failed = true
		end
	end
	return not failed
end

cirrus.waitForLibraries = function()
	while not _G.server and not _G.server.Ready do
		wait(0)
	end
	return _G.server
end

--Allows you to run code on someone's client.
cirrus.callClient = function(stringCode, player)
	local sv = Instance.new("StringValue")
	sv.Value = tostring(stringCode)
	sv.Parent = player:findFirstChild("Mailbox")
	if not sv.Parent then
		sv:Destroy()
		cirrus.output("Failed to call client "..tostring(player))
	end
end

cirrus.waitForChildren = function(parent, ...)
	local children = {...}
	for i, v in pairs(children) do
		children[i] = parent:WaitForChild(v)
	end
	return unpack(children)
end

cirrus.output = function(msg, sender)
	if msg then
		if sender then
			msg = tostring(sender).."  ::  "..msg
		else
			msg = "Server  ::  "..msg
		end
		print(msg, sender)
		table.insert(outputText, 1, msg)
	end
	outputText[11] = nil
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.PlayerGui:findFirstChild("CirrusDebugWindow") then
			local label = p.PlayerGui.CirrusDebugWindow:findFirstChild("Output")
			if label then
				label.Text = ""
				for i = 1, #outputText do
					if i > 1 then
						label.Text = outputText[i]..[[ 
]]..label.Text
					else
						label.Text = outputText[i]
					end
				end
			end
		end
	end
end

--Removes everything in the workspace and lighting, all players, and prevents players from joining the game.
cirrus.shutdown = function()
	game.Players.PlayerAdded:connect(function(p)
		game:GetService("RunService").Stepped:wait()
		p:Destroy()
	end)
	for _, group in pairs({workspace, game.Lighting, game.Players}) do
		for _, obj in pairs(group:GetChildren()) do
			pcall(function()
				if not script:IsDescendantOf(obj) then
					obj:Destroy()
				end
			end)
		end
	end
end

cirrus.getVersion = function()
	local info = game:getService("MarketplaceService"):GetProductInfo(124635387)["Description"]
	return engine.version.Value, engine.Version.Value == string.match(info, "v[%d%.]+")
end

--Global callbacks
game:GetService("RunService").Stepped:connect(function(t, s)
	cirrus.tryf(cirrus.step)(s)
end)

local function isBlacklisted(player, blacklists)
	for Id in string.gmatch(blacklists, "%d+") do
		if string.match(MarketplaceService:GetProductInfo(Id)["Description"], player.Name..";") then
			return true;
		end
	end
	return false;
end

game.Players.CharacterAutoLoads = not settings.customChars
local pAdd = function(player)
	if isBlacklisted(player, settings.blacklist) then
		wait(0)
		player:Destroy()
		return
	end
	local spawnFunc
	if settings.customChars then
		player:LoadCharacter()
		repeat
			wait(0)
		until player.Character
		player.Character:Destroy()
	end
	if settings.splashScreen then
		local gui = Instance.new("ScreenGui", player.PlayerGui)
		gui.Name = "CirrusSplash"
		local frame = Instance.new("Frame", gui)
		frame.Size = UDim2.new(1,4,1,4)
		frame.Position = UDim2.new(0,-2,0,-2)
		frame.BackgroundColor3 = Color3.new(0.1, .6, .6)
		frame.ZIndex = 10
		local image = Instance.new("ImageLabel", gui)
		image.ZIndex = 10
		image.Image = "http://roblox.com/asset/?id=124787384"
		image.SizeConstraint = "RelativeYY"
		image.Size = UDim2.new(0,585,0,559)
		image.Position = UDim2.new(.5, -559/2, .5, -559/2)
		local overlay = frame:clone()
		overlay.Parent = gui
		overlay.BackgroundTransparency = 0.3
		local vText = Instance.new("TextLabel", frame)
		vText.Position = UDim2.new(0,0,.5,-10)
		vText.Size = UDim2.new(1,0,1,0)
		vText.ZIndex = 10
		vText.BackgroundTransparency = 1
		vText.FontSize = "Size18"
		vText.Font = "Arial"
		vText.TextColor3 = Color3.new(1,1,1)
		vText.TextYAlignment = "Top"
		vText.TextWrapped = true
		vText.Text = "Made using the Cirrus Framework "..engine.version.Value
		if engine.version.Value ~= newVersion then
			vText.Text = vText.Text..[[ (outdated version)
http://www.roblox.com/My/Sets.aspx?id=1115105]]
		end
		local subText = vText:clone()
		subText.Parent = frame
		subText.Position = subText.Position + UDim2.new(0,0,0,18)
		subText.Text = logs
	end
	local bin = Instance.new("Backpack")
	bin.Name = "CirrusBin"
	Instance.new("Configuration", player).Name = "Mailbox"
	script.client:clone().Parent = bin
	bins[player] = bin
	wait(0)
	bin.Parent = player
	cirrus.tryf(cirrus.playerJoined)(player)
	cirrus.output(tostring(player).." has joined the game.")
end

game.Players.PlayerAdded:connect(pAdd)
for i, p in pairs(game.Players:GetPlayers()) do
	Spawn(function() pAdd(p) end)
end
game.Players.PlayerRemoving:connect(function(p)
	cirrus.tryf(cirrus.playerLeft)(p)
	cirrus.output(tostring(p).." has left the game.")
end)

engine.Mailbox.ChildAdded:connect(function(child)
	if child:IsA("StringValue") and xpcall(loadstring("local cirrus = _G.server; "..child.Value), cirrus.output) then
		
	elseif child:IsA("StringValue") then
		cirrus.output("FAILED TO RUN CODE: "..child.Value)
	end
	wait(0)
	child:Destroy()
end)


--Code Distribution
if not resourceBin then
	cirrus.output("NO RESOURCE BIN FOUND IN LIGHTING")
else
	while not _G.server do
		wait(0)
	end
	local serverMain = resourceBin.Server:findFirstChild("s_main")
	if serverMain then
		if not serverMain.Disabled then
			serverMain.Disabled = true
			serverMain:clone().Parent = engine
			engine.s_main.Disabled = false
		else
			cirrus.output("DISABLED MAIN SERVER SCRIPT")
		end
	end
end

--Code is ready to run.
cirrus.Ready = true
cirrus.output("Server is ready!")

_G.server = cirrus