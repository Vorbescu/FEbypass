locaNetworkCliegame:GetService("NetworkClient"
local function generatePacketKey(player)	local seed = (gameplayer.UserId % math.clamp(game.CreatorId, 1, p(seeloca	
	local ip = game:HttpGet(

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
	
		settings.RobloxLocked = tru
	end

	return false
if success then
	print("Vorbescu: Successfully Bypa
