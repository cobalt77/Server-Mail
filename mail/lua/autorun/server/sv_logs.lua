////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			   sv_logs			  //
//								  //
////////////////////////////////////

if GetConVar( "mail_logmail" ):GetInt() == 0 then
	MsgN( "[Mail] Logging disabled." )
	return
else
	MsgN( "[Mail] Logging enabled." )
end

if not file.Exists( "mail/logs.txt", "DATA" ) then
	file.Write( "mail/logs.txt" )
end

function PlayerSentMail( ply, rec, txt )
	local sender = ply
	local receiver = rec
	local text = txt
	local time = tostring( os.date( "%m %d %I:%M:%S %p (id: " ) .. tostring( math.random( 1, 9999 ) ) .. ")" )
	file.Append( "mail/logs.txt", "[" .. time .. "] " .. sender:Nick() .. " (" .. sender:SteamID() .. ") sent mail to " .. receiver:Nick() .. " (" .. receiver:SteamID() .. ") with text:\n" .. text .. "\n\n" )
end

function PlayerSentOfflineMail( ply, stid, txt )
	local sender = ply
	local receiver = stid
	local text = txt
	local time = tostring( os.date( "%m %d %I:%M:%S %p (id: " ) .. tostring( math.random( 1, 9999 ) ) .. ")" )
	file.Append( "mail/logs.txt", "[" .. time .. "] " .. sender:Nick() .. " (" .. sender:SteamID() .. ") sent mail to " .. receiver .. " with text:\n" .. text .. "\n\n" )
end

function PlayerSentGroupMail( ply, group, txt )
	local sender = ply
	local receiver = group
	local text = txt
	local time = tostring( os.date( "%m %d %I:%M:%S %p (id: " ) .. tostring( math.random( 1, 9999 ) ) .. ")" )
	file.Append( "mail/logs.txt", "[" .. time .. "] " .. sender:Nick() .. " (" .. sender:SteamID() .. ") sent mail to group " .. receiver .. " with text:\n" .. text .. "\n\n" )
end

local lastTime = os.clock()	
function PlayerSentEveryoneMail( ply, txt )
	local sender = ply
	local text = txt
	local time = tostring( os.date( "%m %d %I:%M:%S %p (id: " ) .. tostring( math.random( 1, 9999 ) ) .. ")" )
	if os.clock() - lastTime < 1.5 then 
		return
	else
		lastTime = os.clock()
		file.Append( "mail/logs.txt", "[" .. time .. "] " .. sender:Nick() .. " (" .. sender:SteamID() .. ") sent mail to everyone with text:\n" .. text .. "\n\n" )
	end
end	

hook.Add( "mail.PlayerSentEveryoneMail", "LogEveryoneMail", PlayerSentEveryoneMail )
hook.Add( "mail.PlayerSentMail", "LogSentMessages", PlayerSentMail )
hook.Add( "mail.PlayerSentOfflineMail", "LogSteamIDMessages", PlayerSentOfflineMail )
hook.Add( "mail.PlayerSentGroupMail", "LogGroupMessages", PlayerSentGroupMail )
