
--[[

Note: make sure you create a sound folder in replicatedstorage, ReplicatedStorage > Folder("Assets") > Folder("Sounds")
Note: to be able to use the music/or table function make sure you add a "Music" sound instance in sould folder


------------------------------|| Playing Sounds ||----------------------------

Client Side Example:

-- SoundManager:AddSound("SoundName",{
	-- any properties you would like to adjust will be dealt wit here;
	
	Volume = 1,
	Looped = false,
	Parent = Character:FindFirstChild("HumanoidRootPart") or workspace
	
}, "Client")


or
-- SoundManager:AddSound("SoundName",{Volume = 1, Looped = false, Parent = Character:FindFirstChild("HumanoidRootPart")}, "Client")

Server Side Example: (Only works on the server)

-- SoundManager:AddSound("SoundName",{
	-- any properties you would like to adjust will be dealt wit here;
	
	Volume = 1,
	TimePosition = .5,
	Parent = Character:FindFirstChild("HumanoidRootPart") or workspace

}, "Server", {{Player = Player, Distance = 5}})


Table Side Example: (Could be used for a music system)

-- SoundManager:AddSound({"5153611141", "303967360", "1214579613", "1214579613"} -- insert sound IDS, {Volume = .28, Parent = PlayerGui)}, "Table")


Create Instanced Side : Example 

-- SoundManager:AddSound("1214579613" --insert Sound Id, {

	Name = "Music",
	Volume = .75,
	Parent = Player:WaitForChild("PlayerGui"),

}, "CreateSound")



------------------------------|| Stopping Sounds ||----------------------------

-- this function really isnt needed cus u can jus loop through object decscenedants and destroy it from there but dnc


Client Side Example:

SoundManager:StopSound("SoundName",{
	Parent = Character
}, "Client")


Server Side Example:

SoundManager:StopSound("SoundName",{
	Parent = Character
}, "Client", {Player = Player, Distance = 5)



-- || Made by Fresh/SunGazerFresh/FreshOtaku tehe..... || --

]]