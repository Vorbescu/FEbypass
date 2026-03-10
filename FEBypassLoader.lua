local ClientReplicator = {}

ClientReplicator.Replicators = {
	ReplicationPackets = false,
	ReplicateFilteringEnabled = false,
	ReplicationInstance = true,
	AttachPackets = {
		Client = true
	}
}

ClientReplicator.PacketQueue = {}
ClientReplicator.Listeners = {}
ClientReplicator.Instances = {}

ClientReplicator.Stats = {
	PacketsSent = 0,
	PacketsReceived = 0,
	InstancesReplicated = 0,
	Latency = 0
}

local RunService = game:GetService("RunService")

function ClientReplicator:SetLatency(v)
	self.Stats.Latency = v
end

function ClientReplicator:SendPacket(packetName,data)

	if not self.Replicators.AttachPackets.Client then
		return
	end

	local packet = {
		Name = packetName,
		Data = data,
		Time = os.clock()
	}

	table.insert(self.PacketQueue,packet)

	self.Stats.PacketsSent += 1

	task.delay(self.Stats.Latency,function()

		if self.Listeners[packetName] then
			for _,callback in pairs(self.Listeners[packetName]) do
				task.spawn(callback,data)
			end
		end

		self.Stats.PacketsReceived += 1

	end)

end

function ClientReplicator:Listen(packetName,callback)

	if not self.Listeners[packetName] then
		self.Listeners[packetName] = {}
	end

	table.insert(self.Listeners[packetName],callback)

end

function ClientReplicator:ReplicateInstance(instance)

	if not self.Replicators.ReplicationInstance then
		return
	end

	local clone = instance:Clone()

	table.insert(self.Instances,clone)

	self.Stats.InstancesReplicated += 1

	return clone

end

function ClientReplicator:GetPackets()

	return self.PacketQueue

end

function ClientReplicator:GetStats()

	return self.Stats

end

RunService.RenderStepped:Connect(function()

	for i,packet in ipairs(ClientReplicator.PacketQueue) do
		if os.clock() - packet.Time > 10 then
			table.remove(ClientReplicator.PacketQueue,i)
		end
	end

end)

return ClientReplicator

print("Nah boiii u really expected this to work L boyy get yo ahh out of here Real one is private and its hidden")
