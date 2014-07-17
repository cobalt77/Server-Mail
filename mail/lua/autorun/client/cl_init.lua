////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			  cl_init			  //
//								  //
////////////////////////////////////

MsgN( "Server Mail addon by Cobalt loaded!" )

if not file.Exists( "mail", "DATA" ) then
	file.CreateDir( "mail" )
	file.Write( "mail/welcome to mail.txt", 
	[[Hi, ]] .. GetConVar( "name" ):GetString() .. [[! Thanks for supporting this addon.
	Instructions:
	In the menu, you will see two panels, the one on the left will store messages and the one on the right will let you view them.
	Double click on a message on the left to view its contents on the right. 
	Right click on any message for a variety of options such as viewing a message, marking as read/unread, deleting, or replying to a message. 
	Refresh the message list with the 'refresh' button at the bottom.
	Compose a message with the 'compose mail' button at the bottom. 
	Swap between inbox and sent messages with the 'show sent' button at the bottom.
	]]
	)
	timer.Simple( 15, function()
		if LocalPlayer():IsValid() and LocalPlayer():IsAdmin() then
			file.Write( "mail/how to use admin functions.txt", 
			[[As an admin, you have a few settings you can change by using the admin settings button at the bottom. 
			Block usergroups from being able to send messages by entering the group name into the box and clicking apply. One group per line. 
			Whitelist steamids in blocked groups so they can send messages by inputting the user's steamid into the box and clicking apply. One steamid per line.
			Use the checkbox at the bottom to only allow admins to send messages to steamids or usergroups. Leaving this off will allow any non-blacklisted groups to send steamid and usergroup messages.
			]]
			)
		end
	end )
end

if not file.Exists( "sentmail", "DATA" ) then
	file.CreateDir( "sentmail" )
end

surface.CreateFont( "Outline", {
	font = "Trebuchet24",
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )

surface.CreateFont( "MailFont", {
	font = "Arial",
	size = 17,
	weight = 350,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )
	
surface.CreateFont( "Labels", {
	font = "CloseCaption_Normal",
	size = 13.5,
	weight = 300,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )

timer.Create( "CheckMessages", 60, 0, function()

	local files = file.Find( "mail/*", "DATA" )
	local num = 0
	
	for k, v in ipairs( files ) do
		local temp = file.Read( "mail/" .. v )
		if not string.find( temp, "###read###" ) then
			num = ( num + 1 )
		end
	end
	
	if num > 0 then
	
		surface.PlaySound( "garrysmod/content_downloaded.wav" )
		
		MsgN( "You have " .. num .. " unread message(s)!" )
		
		hook.Add( "HUDPaint", "Notification", function()
			draw.SimpleTextOutlined( "You have " .. num .. " unread message(s)!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
		end )
		
		timer.Simple( 4, function()
			hook.Remove( "HUDPaint", "Notification" )
		end )
		
	end
	
end )