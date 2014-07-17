////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			   cl_net			  //
//								  //
////////////////////////////////////

net.Receive( "SendMailCallback", function()

	local txt = net.ReadString() or "(No Message)"
	local ply = net.ReadString()
	local stid = net.ReadString()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	file.Write( "mail/" .. str .. ".txt", "From: " .. ply .. " (" .. stid .. ")\n" .. "---------------\n" .. txt )
	surface.PlaySound( "garrysmod/content_downloaded.wav" )
	
	hook.Add( "HUDPaint", "NewNotification", function()
		draw.SimpleTextOutlined( "New message from " .. ply .. "!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
	end )
	
	timer.Simple( 4, function()
		hook.Remove( "HUDPaint", "NewNotification" )
	end )
	
	MsgN( "New message from " .. ply .. "!" )
	
end )
	
net.Receive( "DownloadFile", function()

	local name = net.ReadString()
	local dl = net.ReadString()
	
	file.Write( "mail/" .. name, dl )
	
end )

net.Receive( "GroupMessageTables", function()

	local id = net.ReadString()
	local txt = net.ReadString()
	local mGroup = net.ReadString()
	
	net.Start( "SendSteamID" )
		net.WriteString( "**Group Message (" .. mGroup .. ")**" .. "\n---------------\n" .. txt )
		net.WriteString( id )
	net.SendToServer()
	
end )

net.Receive( "WriteSentMail", function()

	local receiver = net.ReadEntity()
	local txt = net.ReadString()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	file.Write( "sentmail/" .. str .. ".txt", "Sent to " .. receiver:Nick() .. " (" .. receiver:SteamID() .. ")\n" .. "---------------\n" .. txt )
	
end )

net.Receive( "WriteSentSteamID", function()

	local steamid = net.ReadString()
	local txt = net.ReadString()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	file.Write( "sentmail/" .. str .. ".txt", "Sent to steamid " .. steamid .. "\n" .. "---------------\n" .. txt )
	
end )

net.Receive( "WriteSentGroup", function()

	local group = net.ReadString()
	local txt = net.ReadString()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	file.Write( "sentmail/" .. str .. ".txt", "Sent to group " .. group .. "\n" .. "---------------\n" .. txt )
	
end )	

local lastTime = os.clock()
net.Receive( "WriteSentEveryone", function()

	local txt = net.ReadString()
	local str = tostring( os.date( "%m %d %I_%M_%S %p __ " ) .. math.random( 1, 9999 ) )
	
	if os.clock() - lastTime < 1.5 then 
		return
	else
		lastTime = os.clock()
		file.Write( "sentmail/" .. str .. ".txt", "Sent to Everyone" .. "\n---------------\n" .. txt )
	end
	
end )

usermessage.Hook( "CheckMessages", function()

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
		
		hook.Add( "HUDPaint", "Notificationumsg", function()
			draw.SimpleTextOutlined( "You have " .. num .. " unread message(s)!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
		end )
		
		timer.Simple( 4, function()
			hook.Remove( "HUDPaint", "Notificationumsg" )
		end )
		
	end
	
end )