Cirrus
======

Note: 	It is recommended you leave the setting "splashScreen" to enabled in order to keep track of updates.
You can get an up-to-date version of Cirrus here:
http://www.roblox.com/My/Sets.aspx?id=1115105
Do not change the version number.

## Table of contents

1. About
2. Installation
3. Running Code
4. Callbacks
5. Running multiple scripts together
6. Client/Client and Client/Server interaction
7. Other helpful functions

## About
		
This framework was written by Adrian Alberto (username "redditor").
It is designed to make coding complex games easier with the use of callbacks and support for server/client
interaction. Experience with object oriented programming (OOP) or the LOVE 2D framework is recommended but
not required to use this framework.

Please do not redistribute. The version number is linked to my copy of the model.
You may use all of the code provided. Editing the code is not recommended, but you are free to do so. We
ask that you give credit where credit is due.

For more information, you may contact me through these mediums:

* ROBLOX: redditor
* E-mail: adrian@ruddev.com
* Twitter: @ruddev_ceo
* Website: http://ruddev.com/
			
I am most likely going to respond through ROBLOX.

## Installation:	
	
Make sure the Cirrus accoutrement (Wizard hat icon) is in the workspace and the Cirrus configuration (Folder/gear icon) is in game.Lighting.
		
* Workspace
	* Cirrus (Wizard hat icon)
		* README
		* server
		* client
		* version
* Lighting
	* Cirrus (Folder and gear icon)
		* Client
			* c_main (optional)
			* additional code (optional)
		* Server
			* s_main (optional)
			* additional code (optional)
		* Settings
			* Values (optional)
	
Note: When updating Cirrus, it is best to replace only the workspace portion in order to maintain game code and settings.

## Running code
	
In order to run code for the server, you need a Script object in the Server folder under Lighting labeled "s_main".
The same is true for running client code in the Client folder. Label this one "c_main".

Both of these should have the following as a header to ensure code doesn't break:

```lua
--FOR SERVER SCRIPTS
while not _G.server do
	wait(0)
end
local cirrus = _G.server.waitForLibraries()

--FOR CLIENT SCRIPTS
local cirrus = _G.client.waitForLibraries()
```

## Callbacks
	
Some functions are automatically called by the framework upon certain events. These are called callbacks.
For example, here is a callback being used in a server script:

```lua
function cirrus.playerJoined(player)
	print(player.Name)
end
```
		
This will automatically print any joining player's name. You never have to manually call or connect this function.

Here is a list of callbacks available:
* Server:
	* cirrus.step(t): Called every frame. t is elapsed time from last frame.
	* cirrus.playerJoined(player): Called on player enter
	* cirrus.playerLeft(player): Called on player leaving.
* Client:
	* cirrus.step(t): Called every farme. t is elapsed time from last frame.
	* cirrus.superstep(t): Same as cirrus.step except it is also called whenever the camera moves.
	* cirrus.playerJoined(player): Called on player enter
	* cirrus.playerLeft(player): Called on player leaving.
	* cirrus.keyUp(key, timeHeld): Called on key release. Returns the key and how long that key was held down.
	* cirrus.keyDown(key): Called on key press.
	* cirrus.lmbUp(): Called when left mouse button is released.
	* cirrus.lmbDown(): Called when left mouse button is pressed.
	* cirrus.rmbUp(): Called when right mouse button is released.
	* cirrus.rmbDown(): Called when right mouse button is pressed.
	* cirrus.scrollUp(): Called when mouse wheel is scrolled up/forward.
	* cirrus.scrollDown(): Called when mouse wheel is scrolled down/backward.
	* cirrus.debugMode(enabled): Called when the debug window is opened/closed. Enabled determines if it is open.
## Running multiple scripts together

Additional scripts will not run unless loaded by the main script:

```lua
cirrus.load("NameOfScript") -- returns true if it successfully ran the script.
cirrus.load("ThisISAnotherScript", "Rainbow party script') --You can load multiple scripts.
```

This works for both client code and server code.
It is recommended to define the following at the top of loaded scripts:

```lua		
local cirrus = _G.server --for server scripts
local cirrus = _G.client --for client scripts.
```
			
Note: These two have different definitions to ensure the code works properly in test solo.

## Client/Client and Client/Server interaction
	
You can run code in other clients/servers by using the following functions:

```lua
local code = 'print("Hello, world!")'
local player = game.Players.Player1
cirrus.callServer(code)
cirrus.callClient(code, player)
```
			
Note: You cannot receive data from return statements.

## Other helpful functions
	
* Client only:
	* cirrus.tryf(f)
		* Returns f if f is a function. Returns a blank function otherwise. This is used mainly to run callbacks
		without error but can be used to attempt to call a function that may or may not exist.
		* Usage: `cirrus.tryf(someFunctionThatMightExist)(arguments, altercations, disagreements)`
	* cirrus.destroy(obj)
		* Used to destroy objects that may or may not exist without erroring.
		* Returns true if the object was successfully destroyed.
		* Works with multiple arguments.
	* cirrus.waitForChildren(obj, name, name2, name3)
		* Waits for children in object 'obj' with the names name, name2, etc.
		* Usage: `cirrus.waitForChildren(workspace.John, "Humanoid", "Torso", "Head")`
	* cirrus.clearSplash(t)
		* Gets rid of the splash screen if there is one.
		t is the number of seconds you would like to delay the removal. This is useful if you wish for the rest
		of your code to run AFTER the splash screen is removed.
	* cirrus.isKeyDown(key)
		* Checks if the key is down.
	* cirrus.isMouseDown(num)
		* Checks if mouse button is down.
		* If num is 1, returns whether lmb is down.
		* If num is 2, returns whether rmb is down.
		* If num is nil, returns lmbIsDown, rmbIsDown.
	* cirrus.clearKeys()
		* Sets all keys to the up position.
	* cirrus.getVersion()
		* Returns the version as a string. It does not return whether it is up to date.
	* cirrus.enableHumanoidControl()
		* Allows users to control their character.
	* cirrus.disableHumanoidControl()
		* Disallows users to control their character.
* Server only:
	* cirrus.tryf(f)
		* Returns f if f is a function. Returns a blank function otherwise. This is used mainly to run callbacks
		without error but can be used to attempt to call a function that may or may not exist.
		* Usage: `cirrus.tryf(someFunctionThatMightExist)(arguments, altercations, disagreements)`
	* cirrus.destroy(obj)
		* Used to destroy objects that may or may not exist without erroring.
		* Returns true if the object was successfully destroyed.
		* Works with multiple arguments.
	* cirrus.waitForChildren(obj, name, name2, name3)
		* Waits for children in object 'obj' with the names name, name2, etc.
		* Usage: `cirrus.waitForChildren(workspace.John, "Humanoid", "Torso", "Head")`
	* cirrus.output(msg)
		* Writes to the debug window. Debug window is toggled with the backslash (\) key if it is enabled.
	* cirrus.shutdown()
		* Clears the server and playerlist and makes sure nobody can get in.
	* cirrus.getVersion()
		* Returns: version (string), isUpToDate (boolean)
