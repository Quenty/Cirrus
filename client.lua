_G.client = {}
local cirrus = _G.client
local engine = workspace:findFirstChild("Cirrus")
local resourceBin = game.Lighting:findFirstChild("Cirrus")
local cBin = script.Parent
wait(0)
script.Parent = nil
local myPlayer = game.Players.LocalPlayer
local myCamera = workspace.CurrentCamera
local myMouse = myPlayer:GetMouse()
local settings = {}
	settings.debugWindow = true
local keysdown = {}
if resourceBin and resourceBin:findFirstChild("Settings") then
	for i, v in pairs(resourceBin.Settings:GetChildren()) do
		if v:IsA("Instance") and string.find(v.ClassName, "Value") then
			settings[v.Name] = v.Value
		end
	end
end

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
	if not cBin or not cBin.Parent then
		cBin = Instance.new("Backpack")
		cBin.Name = "CirrusBin"
		cBin.Parent = myPlayer
	end
	local failed = false
	for i, scriptName in pairs({...}) do
		local s = resourceBin.Client:findFirstChild(scriptName)
		if s and s:IsA("LocalScript") then
			s:clone().Parent = cBin
			cirrus.output("Loaded "..scriptName)
		else
			cirrus.output("Failed to load "..scriptName)
			failed = true
		end
	end
	return not failed
end

cirrus.waitForLibraries = function()
	while not _G.client and not _G.client.Ready do
		wait(0)
	end
	return _G.client
end

cirrus.waitForChildren = function(parent, ...)
	local children = {...}
	for i, v in pairs(children) do
		children[i] = parent:WaitForChild(v)
	end
	return unpack(children)
end

cirrus.getVersion = function()
	return engine.version.Value
end

--Allows you to run a string of code server-side.
cirrus.callServer = function(stringCode)
	local sv = Instance.new("StringValue")
	sv.Value = tostring(stringCode)
	sv.Parent = engine.Mailbox
end

--Allows you to run a string of code on someone else's client.
cirrus.callClient = function(stringCode, player)
	local sv = Instance.new("StringValue")
	sv.Value = tostring(stringCode)
	sv.Parent = player:findFirstChild("Mailbox")
	if not sv.Parent then sv:Destroy() end
end

cirrus.output = function(msg)
	if msg then
		cirrus.callServer("cirrus.output('"..msg.."', game.Players['"..myPlayer.Name.."'])")
	else
		cirrus.callServer("cirrus.output()")
	end
end


--Removes the default splash screen.
cirrus.clearSplash = function(t)
	if myPlayer.PlayerGui:findFirstChild("CirrusSplash") then
		wait(t)
		myPlayer.PlayerGui.CirrusSplash:Destroy()
	end
end

cirrus.clearKeys = function()
	keysdown = {}
end

cirrus.isKeyDown = function(key)
	return (keysdown[key] or keysdown[string.byte(key)]) ~= nil
end

cirrus.isMouseDown = function(num)
	if num == 1 then
		return keysdown.LMB
	elseif num == 2 then
		return keysdown.RMB
	else
		return keysdown.LMB, keysdown.RMB
	end
end

cirrus.enableHumanoidControl = function()
	game:GetService("ControllerService"):ClearAllChildren()
	Instance.new("HumanoidController", game:GetService("ControllerService"))
end

cirrus.disableHumanoidControl = function()
	game:GetService("ControllerService"):ClearAllChildren()
end

--Global callbacks
local lastStep = time()
game:GetService("RunService").Stepped:connect(function(t, s)
	local now = time()
	cirrus.tryf(cirrus.step)(s)
	cirrus.tryf(cirrus.superstep)(now - lastStep)
	lastStep = now
end)
myCamera.Changed:connect(function(c)
	if c == "CoordinateFrame" then
		local now = time()
		cirrus.tryf(cirrus.superstep)(now - lastStep)
		lastStep = now
	end
end)
game.Players.PlayerAdded:connect(function(p)
	cirrus.tryf(cirrus.playerJoined)(p)
end)
game.Players.PlayerRemoving:connect(function(p)
	cirrus.tryf(cirrus.playerLeft)(p)
end)
myMouse.KeyDown:connect(function(key)
	cirrus.tryf(cirrus.keyDown)(key)
	local now = time()
	keysdown[key] = now
	keysdown[string.byte(key)] = now
end)
myMouse.KeyUp:connect(function(key)
	local now = time()
	local pressTime = keysdown[key]or keysdown[string.byte(key)] or now
	cirrus.tryf(cirrus.keyUp)(key, now - pressTime)
	keysdown[key] = nil
	keysdown[string.byte(key)] = nil
end)
myMouse.Button1Down:connect(function()
	cirrus.tryf(cirrus.lmbDown)()
	keysdown["LMB"] = true
end)
myMouse.Button1Up:connect(function()
	cirrus.tryf(cirrus.lmbUp)()
	keysdown["LMB"] = false
end)
myMouse.Button2Down:connect(function()
	cirrus.tryf(cirrus.rmbDown)()
	keysdown["RMB"] = true
end)
myMouse.Button2Up:connect(function()
	cirrus.tryf(cirrus.rmbUp)()
	keysdown["RMB"] = false
end)
myMouse.WheelForward:connect(function()
	cirrus.tryf(cirrus.scrollUp)()
end)
myMouse.WheelBackward:connect(function()
	cirrus.tryf(cirrus.scrollDown)()
end)


myPlayer.Mailbox.ChildAdded:connect(function(child)
	if child:IsA("StringValue") and xpcall(loadstring("local cirrus = _G.client; "..child.Value), cirrus.output) then
		
	elseif child:IsA("StringValue") then
		print("FAILED TO RUN CODE: "..child.Value)
	end
	wait(0)
	child:Destroy()
end)

function addDebugWindow()
	wait(0)
	if myPlayer.PlayerGui:findFirstChild("CirrusDebugWindow") then
		return
	end
	local gui = Instance.new("ScreenGui", myPlayer.PlayerGui)
	gui.Name = "CirrusDebugWindow"
	local label = Instance.new("TextLabel", gui)
	label.Name = "Output"
	label.Size = UDim2.new(0,500,0,150)
	label.Position = UDim2.new(0,10,0,155)
	label.BackgroundTransparency = .9
	label.BackgroundColor3 = Color3.new(.1,.1,.1)
	label.BorderColor3 = Color3.new(.1,.1,.1)
	label.ClipsDescendants = true
	label.TextYAlignment = "Bottom"
	label.TextXAlignment = "Left"
	label.TextWrapped = true
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = "ArialBold"
	label.FontSize = "Size12"
	label.Text = ""
	label.Visible = false
	myPlayer:GetMouse().KeyDown:connect(function(key)
		if string.byte(key) == 92 and gui and gui.Parent then
			label.Visible = not label.Visible
			cirrus.tryf(cirrus.debugMode)(label.Visible)
		end
	end)
	cirrus.output()
	cirrus.tryf(cirrus.debugMode)()
end
if settings.debugWindow then
	addDebugWindow()
	myPlayer.PlayerGui.ChildRemoved:connect(addDebugWindow)
	myPlayer.CharacterAdded:connect(addDebugWindow)
end


--Code Distribution
if not resourceBin then
	cirrus.output("NO RESOURCE BIN FOUND IN LIGHTING")
else
	while not _G.client do
		wait(0)
	end
	local clientMain = resourceBin.Client:findFirstChild("c_main")
	if clientMain then
		if not clientMain.Disabled then
			clientMain:clone().Parent = cBin
		else
			cirrus.output("DISABLED MAIN CLIENT SCRIPT")
		end
	end
end


--Code is ready to run.
cirrus.Ready = true
cirrus.output("Client is ready!")