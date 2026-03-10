-- gets clientreplicator to spoof the packets
local player = game:GetService("Players").LocalPlayer
local replicator = game:GetService("NetworkClient"):WaitForChild("ClientReplicator")
if replicator then 
  print("Replicator Found: ClientReplicator is Supported Load the main script for FEbypass now")
