print('✅B S M 2 AutoMine v. 1✅')

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild('HumanoidRootPart')
local gameContentFolder = workspace:FindFirstChild('__GAME_CONTENT')


local folderName = "BSM2_by_GHOSTIZ"
local fileName = "settings.json"
local filePath = folderName .. "/" .. fileName


local AutoMine = false
local AutoShard = false
local DistFromOre = 4
local PlayerTeleport = false
local OreSearch = {}

if not isfolder(folderName) then
	makefolder(folderName)
end


local function LoadSettings()
	if isfile(filePath) then
		local content = readfile(filePath)
		local data = HttpService:JSONDecode(content)
		if data then
			PlayerTeleport = data.PlayerTeleport
			DistFromOre = data.DistFromOre
			OreSearch = data.OreSearch
		end

	end
end


local function SaveSettings()
	local data = {
		DistFromOre = DistFromOre,
		OreSearch = OreSearch,
		PlayerTeleport = PlayerTeleport
	}
	local json = HttpService:JSONEncode(data)
	writefile(filePath, json)
end

LoadSettings()


local OreFolder = nil
for _,v in pairs(gameContentFolder:GetDescendants()) do
	if v:IsA('Folder') and v.Name:lower() == 'stone' then
		OreFolder = v.Parent
		break
	end
end


for _, ores in pairs(OreFolder:GetChildren()) do
	local name = ores.Name:lower()
	if OreSearch[name] == nil then
		OreSearch[name] = false
	end
end

local function SearchOre()
	local OreTarget = nil
	local MinimalDistance = math.huge

	local char = LocalPlayer.Character
	local HRP = char.HumanoidRootPart

	if #OreFolder:GetChildren() == 0 then return nil end

	for _, ores in pairs(OreFolder:GetChildren()) do
		if OreSearch[ores.Name:lower()] then
			for _, ore in pairs(ores:GetChildren()) do
				if #ore.Block:GetChildren() >= 3 then
					local TouchPart = ore.Touch
					local distance = (TouchPart.Position - HRP.Position).Magnitude
					if distance < MinimalDistance then
						OreTarget = TouchPart
						MinimalDistance = distance
					end
				end
			end
		end
	end

	return OreTarget, MinimalDistance
end

local function Mine()
	while AutoMine do
		local OreTarget, MinimalDistance = SearchOre()

		local Humanoid = character.Humanoid

		if OreTarget then
			for _,v in pairs(OreTarget:GetDescendants()) do
				if v:IsA('MeshPart') or v:IsA('BasePart') then
					v.CanCollide = false
				end
			end

			if MinimalDistance >= DistFromOre + 1 then
				local direction = (HumanoidRootPart.Position - OreTarget.Position).Unit
				local offset = direction * DistFromOre 
				local targetPosition = OreTarget.Position + offset
				if PlayerTeleport then
					HumanoidRootPart.CFrame = CFrame.new(OreTarget.Position)
				else
					Humanoid:MoveTo(targetPosition)
					Humanoid.MoveToFinished:Wait()
				end
			end
		end

		task.wait(.1)
	end
end

local function Shards()
	while AutoShard do
		local ShardsFolder = gameContentFolder:FindFirstChild('FireBurstShardsSpawns') 

		local Humanoid = character.Humanoid

		for i,v in pairs(ShardsFolder:GetChildren()) do
			if PlayerTeleport then
				HumanoidRootPart.CFrame = CFrame.new(v.Position)
			else
				Humanoid:MoveTo(Vector3.new(-142,5.8,-1586))
				Humanoid.MoveToFinished:Wait()
			end
			task.wait(0.4)
		end

		if PlayerTeleport then
			HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-142,5.8,-1586))
		else
			Humanoid:MoveTo(Vector3.new(-142,5.8,-1586))
			Humanoid.MoveToFinished:Wait()
		end

		task.wait(10)
	end
end

SaveSettings()

local library = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/0x"))()

local w1 = library:Window("Main")
local OreWindow = library:Window("Select Ores")

w1:Toggle(
	"Auto Mine",
	"am",
	false,
	function(toggled)
		AutoMine = toggled
		SaveSettings()
		Mine()
	end
) -- Text, Flag, Enabled, Callback, Flag Location (Optional)

w1:Toggle(
	"Auto Shards",
	"as",
	false,
	function(toggled)
		AutoShard = toggled
		SaveSettings()
		Shards()
	end
) -- Text, Flag, Enabled, Callback, Flag Location (Optional)

w1:Toggle(
	"Walk/Teleport",
	"atp",
	PlayerTeleport,
	function(toggled)
		PlayerTeleport = toggled
		SaveSettings()
	end
) -- Text, Flag, Enabled, Callback, Flag Location (Optional)

w1:Slider(
	"DistFromOre",
	"dfo",
	1,
	7,
	function(value)
		DistFromOre = value
		SaveSettings()
	end,
	DistFromOre
) -- Text, Flag, Minimum, Maximum, Callback, Default (Optional), Flag Location (Optional)

w1:Slider(
	"WalkSpeed",
	"WS",
	16,
	60,
	function(value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
	end,
	40
) -- Text, Flag, Minimum, Maximum, Callback, Default (Optional), Flag Location (Optional)

w1:Button(
	"Destroy GUI",
	function()
		AutoMine = false
		AutoShard = false
		for i, v in pairs(game.CoreGui:GetChildren()) do
			if v:FindFirstChild("Top") then
				v:Destroy()
			end
		end
	end
) -- Text, Callback

for name, status in pairs(OreSearch) do
	OreWindow:Toggle(
		name,
		nil,
		OreSearch[name:lower()],
		function(toggled)
			OreSearch[name:lower()] = toggled
			SaveSettings()
		end
	) -- Text, Flag, Enabled, Callback, Flag Location (Optional)
end

w1:Label("G H O S T I Z")
