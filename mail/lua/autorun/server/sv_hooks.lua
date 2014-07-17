////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			  sv_hooks			  //
//								  //
////////////////////////////////////

--[[

Serverside Hooks:

	mail.PlayerSentMail - Called when a player sends a message to another online player
		Args: 
			Player who sent mail 		[Entity]
			Player who received mail 	[Entity]
			Text sent 					[String]
	
	mail.PlayerSentOfflineMail - Called when a player sends a message to an offline steamid
		Args:
			Player who sent mail 		[Entity]
			SteamID receiving mail 		[String]
			Text sent 					[String]
			
	mail.PlayerSentGroupMail - Called when a player sends mail to a group
		Args:
			Player who sent mail		[Entity]
			Group receiving mail		[String]
			Text sent					[String]
			
	mail.PlayerSentEveryoneMail - Calls when a player sends everyone mail
		Args: 
			Player who sent mail		[Entity]
			Text sent					[String]
				
	mail.PlayerDownloadedMail - Called when an offline player downloads mail when he joins in
		Args:
			Player who downloaded mail	[Entity]
			Text Downloaded				[String]
			
	mail.PlayerOpenedMenu - Calls when a player opens the menu
		Args:
			Player who opened the menu	[Entity]
			
		*Return false to deny*
			
	mail.PlayerUpdatedGroupBlacklist - Calls when a player updates the group blacklist
		Args: 
			Player who changed it		[Entity]
			
		*Return false to deny*
	
	mail.PlayerUpdatedIDWhitelist - Calls when a player updates the SteamID whitelist
		Args:
			Player who changed it		[Entity]
			
		*Return false to deny*	
			
	mail.PlayerUpdatedIDBlacklist - Calls when a player updates the SteamID Blacklist
		Args:
			Player who changed it		[Entity]
			
		*Return false to deny*	
			
	mail.PlayerAppliedCvar - Calls when a player changes the cvar "mail_admingroup" through the menu
		Args: 
			Player who changed it		[Entity]
			Result						[Boolean]
			
		*Return false to deny*	
		
--]]

function DownloadFiles( ply )

	local id = ply:SteamID()
	local files = file.Find( "mail/*", "DATA" )
	
	for k, v in pairs( files ) do
	
		local temp = file.Read( "mail/" .. v, "DATA" )
		
		if string.find( temp, "Saved for SteamID: " .. id ) then
		
			net.Start( "DownloadFile" )
				net.WriteString( v )
				net.WriteString( temp )
			net.Send( ply )
			
			file.Delete( "mail/" .. v )
			
			hook.Run( "mail.PlayerDownloadedMail", ply, temp )
			
		end
		
	end
	
end

function SendMessageCheck( ply )

	timer.Simple( 4, function()
		if ply:IsValid() then
			umsg.Start( "CheckMessages", ply )
			umsg.End()
		end		
	end )
	
end

function MailChatCommand( ply, text, public )

	if string.sub( text, 1, 5 ) == "!mail" or string.sub( text, 1, 8 ) == "!mailbox" then
	
		local ret = hook.Run( "mail.PlayerOpenedMenu", ply )
		
		if ( ret or ret == false ) and ret ~= true then
			ply:ChatPrint( "You are not allowed to open this menu!" )
			return ""
		end
		
		umsg.Start( "mailbox", ply )
		umsg.End()
		
		return ""
	else
		return
	end
	
end


function UpdateGroupBlacklist( ply )

	for k, v in ipairs( player.GetAll() ) do
		if v:IsAdmin() then
			v:ChatPrint( "[Mail] " .. ply:Nick() .. " has updated group permissions." )
		end
	end
	
end

function UpdateIDWhitelist( ply )

	for k, v in ipairs( player.GetAll() ) do
		if v:IsAdmin() then
			v:ChatPrint( "[Mail] " .. ply:Nick() .. " has updated the SteamID whitelist." )
		end
	end
	
end

function UpdateIDBlacklist( ply )

	for k, v in ipairs( player.GetAll() ) do
		if v:IsAdmin() then
			v:ChatPrint( "[Mail] " .. ply:Nick() .. " has updated the SteamID blacklist." )
		end
	end
	
end

function AppliedCvars( ply, bit )

	if bit then
		
		for k, v in ipairs( player.GetAll() ) do
			if v:IsAdmin() then
				v:ChatPrint( "[Mail] " .. ply:Nick() .. " has allowed only admins to send group/steamid messages." )
			end
		end
		
	else
		
		for k, v in ipairs( player.GetAll() ) do
			if v:IsAdmin() then
				v:ChatPrint( "[Mail] " .. ply:Nick() .. " has allowed all non-blacklisted groups to send group/steamid messages." )
			end
		end
		
	end
	
end

function WriteSentMessages( sender, receiver, txt )

	net.Start( "WriteSentMail" )
		net.WriteEntity( receiver )
		net.WriteString( txt )
	net.Send( sender )
	
end

function WriteSentID( sender, steamid, txt )

	net.Start( "WriteSentSteamID" )
		net.WriteString( steamid )
		net.WriteString( txt )
	net.Send( sender )
	
end

function WriteGroupMessages( sender, group, txt )

	net.Start( "WriteSentGroup" )
		net.WriteString( group )
		net.WriteString( txt )
	net.Send( sender )
	
end

function WriteSentAllMessages( sender, txt )

	net.Start( "WriteSentEveryone" )
		net.WriteString( txt )
	net.Send( sender )
	
end

hook.Add( "PlayerAuthed", "DownloadFiles", DownloadFiles )
hook.Add( "PlayerInitialSpawn", "SendMessageCheck", SendMessageCheck )
hook.Add( "PlayerSay", "MailChatCommand", MailChatCommand )
hook.Add( "mail.PlayerSentEveryoneMail", "WriteSentEveryoneMail", WriteSentAllMessages )
hook.Add( "mail.PlayerSentGroupMail", "WriteSentGroupMail", WriteGroupMessages )
hook.Add( "mail.PlayerSentOfflineMail", "WriteSentOffline", WriteSentID )
hook.Add( "mail.PlayerSentMail", "WriteSent", WriteSentMessages )
hook.Add( "mail.PlayerUpdatedGroupBlacklist", "UpdateGroupBlacklist", UpdateGroupBlacklist )
hook.Add( "mail.PlayerUpdatedIDWhitelist", "UpdateIDWhitelist", UpdateIDWhitelist )
hook.Add( "mail.PlayerUpdatedIDBlacklist", "UpdateIDBlacklist", UpdateIDBlacklist )
hook.Add( "mail.PlayerAppliedCvar", "AppliedCvars", AppliedCvars )