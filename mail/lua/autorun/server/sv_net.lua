////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			   sv_net			  //
//								  //
////////////////////////////////////

net.Receive( "SendMail", function( len, ply )

	local txt = net.ReadString()
	local ent = net.ReadString()
	local sender = ply:Nick()
	local pl
	local steamid = ply:SteamID()
	
	for k, v in ipairs( player.GetAll() ) do
		if v:Nick() == ent then
			pl = v
			break
		end
	end
	
	if pl then
	
		local ret = hook.Run( "mail.BlockMail", ply, pl, txt )
		
		if ( ret or ret == false ) and ret ~= true then
			ply:ChatPrint( "You are not allowed to send a message right now!" )
			return
		end
		
		net.Start( "SendMailCallback" )
			net.WriteString( txt )
			net.WriteString( sender )
			net.WriteString( steamid )
		net.Send( pl )
		
		local strex = string.Explode( "\n", txt )

		if strex[ 1 ] and strex[ 2 ] and string.find( tostring( strex[ 1 ] ), "**Sent to Everyone**" ) and string.find( tostring( strex[ 2 ] ), "---------------" ) then
			hook.Run( "mail.PlayerSentEveryoneMail", ply, txt )
		else
			hook.Run( "mail.PlayerSentMail", ply, pl, txt )
		end
		
	end 

end )

net.Receive( "RequestPlys", function( len, ply )

	local plys = player.GetAll()
	
	net.Start( "RequestPlysCallback" )
		net.WriteTable( plys )
	net.Send( ply )
	
end )

net.Receive( "SendSteamID", function( len, ply )

	local txt = net.ReadString()
	local stid = net.ReadString()
	local sender = ply:Nick()
	local ssteamid = ply:SteamID()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	local ret = hook.Run( "mail.BlockMailID", ply, stid, txt )
		
	if ( ret or ret == false ) and ret ~= true then
		ply:ChatPrint( "You are not allowed to send a message right now!" )
		return
	end
	
	file.Write( "mail/" .. str .. ".txt", "From: " .. sender .. " (" .. ssteamid .. ")\n" .. "Saved for SteamID: " .. stid .. "\n---------------\n" .. txt )

	local expl = string.Explode( "\n", txt )

	if ( expl[ 1 ] and expl[ 2 ] and string.find( expl[ 1 ], "**Group Message" ) and string.find( expl[ 2 ], "---------------" ) ) then else
		hook.Run( "mail.PlayerSentOfflineMail", ply, stid, txt )
	end
	
	
	for k, v in ipairs( player.GetAll() ) do
	
		local id = v:SteamID()
		local files = file.Find( "mail/*", "DATA" )
		
		for q, w in ipairs( files ) do
			local temp = file.Read( "mail/" .. w, "DATA" )
			if string.find( temp, "Saved for SteamID: " .. id ) then
				net.Start( "DownloadFile" )
					net.WriteString( w )
					net.WriteString( temp )
				net.Send( v )
				file.Delete( "mail/" .. w )
			end
		end
		
		timer.Simple( 1, function()
			umsg.Start( "CheckMessages", ply )
			umsg.End()
		end )
		
	end
	
end )

net.Receive( "SendMailGroup", function( len, ply )

	local txt = net.ReadString()
	local mGroup = net.ReadString()
	local tab = {}
	local file = file.Read( "ulib/users.txt", "DATA" )
	local gTable = ULib.parseKeyValues( file )
	
	for k, v in pairs( gTable ) do
		if v.group == mGroup then
			table.insert( tab, tostring( k ) )
		end
	end
	
	if tab then
		for i = 1, #tab do
			local aa = tostring( tab[ i ] )
			net.Start( "GroupMessageTables" )	
				net.WriteString( aa )
				net.WriteString( txt )
				net.WriteString( mGroup )
			net.Send( ply )
		end
		
		hook.Run( "mail.PlayerSentGroupMail", ply, mGroup, txt )
		
	end
	
end )

net.Receive( "SetReply", function( len, ply )
	net.Start( "SetReplyCallback" )
	net.Send( ply )
end )

net.Receive( "SetComboBoxValue", function( len, ply )
	net.Start( "SetComboBoxValueCallback" )
	net.Send( ply )
end )

net.Receive( "SetSteamIDText", function( len, ply )
	local id = net.ReadString()
	net.Start( "SetSteamIDTextCallback" )
		net.WriteString( id )
	net.Send( ply )
end )

net.Receive( "RequestBlocked", function( len, ply )

	local gblock = file.Read( "mail/blacklistgroups.txt", "DATA" )
	local tbl = string.Explode( "\n", gblock ) or ""
	
	local whiteid = file.Read( "mail/whitelistids.txt", "DATA" )
	local tbl2 = string.Explode( "\n", whiteid ) or ""
	
	local blackid = file.Read( "mail/blacklistids.txt", "DATA" )
	local tbl3 = string.Explode( "\n", blackid ) or ""
	
	net.Start( "RequestBlockedCallback" )
		net.WriteTable( tbl )
		net.WriteTable( tbl2 )
		net.WriteTable( tbl3 )
	net.Send( ply )
	
end )

net.Receive( "SendUpdatedGroups", function( len, ply )
	
	local str = net.ReadString()
	
	local ret = hook.Run( "mail.PlayerUpdatedGroupBlacklist", ply )
	
	if ( ret or ret == false ) and ret ~= true then
		ply:ChatPrint( "You are not allowed to change this!" )
		return ""
	end
	
	file.Write( "mail/blacklistgroups.txt", str )

end )

net.Receive( "SendUpdatedIDs", function( len, ply )
	
	local str = net.ReadString()
	
	local ret = hook.Run( "mail.PlayerUpdatedIDWhitelist", ply )	
	
	if ( ret or ret == false ) and ret ~= true then
		ply:ChatPrint( "You are not allowed to change this!" )
		return ""
	end
	
	file.Write( "mail/whitelistids.txt", str )

end )

net.Receive( "SendUpdatedIDs2", function( len, ply )
	
	local str = net.ReadString()

	local ret = hook.Run( "mail.PlayerUpdatedIDBlacklist", ply )
	
	if ( ret or ret == false ) and ret ~= true then
		ply:ChatPrint( "You are not allowed to change this!" )
		return ""
	end
	
	file.Write( "mail/blacklistids.txt", str )
	
end )	

net.Receive( "ApplyCvarChanges", function( len, ply )
	
	local bit = net.ReadString()
	
	bit2 = tobool( bit )
	
	local ret = hook.Run( "mail.PlayerAppliedCvar", ply, bit2 )
	
	if ( ret or ret == false ) and ret ~= true then
		ply:ChatPrint( "You are not allowed to change this ConVar!" )
		return ""
	end
	
	if bit2 then
		game.ConsoleCommand( "mail_admingroup 1" .. "\n" )
	else
		game.ConsoleCommand( "mail_admingroup 0" .. "\n" )
	end
	
end )

net.Receive( "FetchConVarNumber", function( len, ply )
	
	local num = GetConVar( "mail_admingroup" ):GetInt()
	
	net.Start( "FetchConVarNumberCallback" )
		net.WriteString( tostring( num ) )
	net.Send( ply )

end )