while not _G.server or not _G.server.waitForLibraries do
	wait(0)
end
local cirrus = _G.server.waitForLibraries()

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --	

function cirrus.step(s)
	--Anything in here will run every frame.
	--This is optional, as are the other callbacks.
	--View the README for more information.
end