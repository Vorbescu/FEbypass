local NetworkClient = game:GetService("NetworkClient")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local oldSettings = NetworkClient:FindFirstChild("ClientReplicatorSettings")
if oldSettings then
	oldSettings:Destroy()
end

local function generatePacketKey(player)
	local seed = (game.PlaceId * game.JobId) - (player.UserId % math.clamp(game.CreatorId, 1, player.UserId // 2))
	math.randomseed(seed)

	local chars = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
	local key = ""

	for _ = 1, 56 do
		key ..= chars[math.random(1, #chars)]
	end

	local display = "PACKET:" .. key:sub(1, 8)
	print(display)

	return "!PKT_" .. key
end

local LocalPlayer = Players.LocalPlayer
local packetKey = generatePacketKey(LocalPlayer)
local enabled = Enum.ReplicateInstanceDestroySetting.Enabled.Value

local settings = Instance.new("TeleportOptions")
settings.Name = "ClientReplicatorSettings"
settings:SetAttribute("ExtractOnRun", enabled)
settings:SetAttribute("SpawnOnConnect", enabled)
settings:SetAttribute("ModifyOnSync", enabled)
settings:SetAttribute("PropagateProps", enabled)
settings:SetAttribute("SessionToken", packetKey)
settings.Parent = NetworkClient

local ClientReplicator = Instance.new("ClientReplicator")
ClientReplicator.Name = "ClientReplicator"
ClientReplicator.Parent = NetworkClient

local function craftPacket(name, id, auth, data, ttl)
	local packet = {"RAKNET", "RAKUDP", name, id, auth, data, ttl, "HIGH_PRIORITY", "RELIABLE"}
	return HttpService:JSONEncode(packet)
end

local success = pcall(function()
	setreadonly(LocalPlayer.ReplicationFocus, false)
	setscriptable(LocalPlayer, "ReplicationFocus", true)
	LocalPlayer.ReplicationFocus = game

	NetworkClient:RefreshReplicationSettings(true, packetKey, settings)

	ClientReplicator:SetReplicationRule({
		replicatorClientside = false,
		allowedClients = {LocalPlayer},
		useLegacySecurity = false,
		allowedDataModelRoots = {game},
	})

	local ip = game:HttpGet("https://api.ipify.org/?format=txt")

	local outbound = ClientReplicator:GetOutboundConnections()
	local latestID = 0
	for conn, typ in pairs(outbound) do
		if typ == 4 then
			latestID = math.max(latestID, conn.id)
		end
	end

	local encoded = ""
	for i = 1, #packetKey do
		encoded ..= string.byte(packetKey, i)
	end

	local params = {
		from = ip,
		auth = encoded,
		RKSEC = tick(),
		PermissionIndex = 20,
		Request = {
			ServerReplicatorChange = {
				priority = "HIGH_PRIORITY",
				data = {
					replicatorClientside = false,
					allowedClients = {{LocalPlayer, ip}},
					useLegacySecurity = false,
					allowedDataModelRoots = {game},
					exclude = {},
					ServersideReplicated = true,
					ReplicationSettings = {
						all = true,
						noReplicationBelow = -1,
						useAdvancedMode = false,
					}
				}
			}
		}
	}

	local packet = craftPacket("ReplicationRequest", latestID + 1, packetKey, HttpService:JSONEncode(params), -1)
	local response = ClientReplicator:SendPacket(0, packet)

	if response and response[1] and tostring(response[1]):lower():find("success") then
		settings.RobloxLocked = true
		return true
	end

	return false
end)

if success then
	print("Vorbescu: Successfully Bypassed NetworkReplication aka febypass lol")
end
