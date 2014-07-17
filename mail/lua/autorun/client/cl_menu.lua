////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			   cl_menu			  //
//								  //
////////////////////////////////////

-- [[ Configuration options below: ]] --

local MenuKey 			= KEY_F6						-- Key that opens the menu. 				Can be KEY_F1 - KEY_F12
local MenuColor			= Color( 0, 0, 0, 200 ) 		-- Background color of the menu. 			Default: Color( 0, 0, 0, 200 )
local OutlineColor 		= Color( 255, 255, 255, 220 ) 	-- Outline color of menu objects. 			Default: Color( 255, 255, 255, 220 )
local TextColor			= Color( 255, 255, 255, 255 )	-- Text color of buttons. 					Default: Color( 255, 255, 255, 255 )
local TextColorDown		= Color( 100, 100, 100, 255 )	-- Text color of buttons while pressed.		Default: Color( 100, 100, 200, 255 )
	
-- [[ ---------------------------- ]] --


local main
local cmain
local amain

function OpenMailbox()
	
	if main then
		return
	end
	
	local blockedgroups = {}
	local whitelistids = {}
	local blacklistids = {}
	
	net.Start( "RequestBlocked" )
	net.SendToServer()
	
	net.Receive( "RequestBlockedCallback", function()
	
		local bg = net.ReadTable()
		local wi = net.ReadTable()
		local bi = net.ReadTable()
		
		for k, v in ipairs( bg ) do
			if v and v:len() > 0 then
				table.insert( blockedgroups, v:Trim() )
			end
		end
		
		for k, v in ipairs( wi ) do
			if v and v:len() > 0 then
				table.insert( whitelistids, v:Trim() )
			end
		end
		
		for k, v in ipairs( bi ) do
			if v and v:len() > 0 then
				table.insert( blacklistids, v:Trim() )
			end
		end
		
	end )
	
	main = vgui.Create( "DFrame" )	
	main:SetPos( 50,50 )
	main:SetSize( 800, 500 )
	main:SetTitle( "Mailbox" )
	main:SetVisible( true )
	main:SetDraggable( true )
	main:ShowCloseButton( true )
	main:MakePopup()
	main:Center()	
	main.btnMaxim:Hide()
	main.btnMinim:Hide() 
	
	main.Paint = function()
		surface.SetDrawColor( OutlineColor )
		surface.DrawOutlinedRect( 0, 0, main:GetWide(), main:GetTall() )		
		surface.SetDrawColor( MenuColor )
		surface.DrawRect( 1, 1, main:GetWide() - 2, main:GetTall() - 2 )		
	end
	
	main.OnClose = function()
		main = nil
	end
	
	local list = vgui.Create( "DListView" )
	list:SetParent( main )
	list:SetPos( 4, 27 )
	list:SetSize( 392, 419 )
	list:SetMultiSelect( false )
	list:AddColumn( "Time :: Unique ID" )
	list:AddColumn( "To/From" )
	
	local winbox = true
	
	local function populateList()
		
		winbox = true
		
		local files = file.Find( "mail/*", "DATA" )
		table.sort( files, function( a, b ) return a > b end )
		
		for k, v in next, files do
			local text = tostring( v ):sub( 1, -5 )
				local str
				if string.find( text, "%s" ) then
					string.sub( text, string.find( text, "%s" ), string.len( text ) )
					str = text:gsub( "^%l", string.upper )	
				end		
			local temp = file.Read( "mail/" .. v )
			local stre = string.Explode( "\n", temp )[ 1 ]:sub( 7 )
			if not string.find( temp, "###read###" ) then
				if string.find( stre, "STEAM" ) then
					list:AddLine( str:gsub( "_", ":" ) .. " (Unread)", string.sub( stre, 1, string.find( stre, "STEAM" ) - 3 ) )
				else
					list:AddLine( str:gsub( "_", ":" ) .. " (Unread)", "" )
				end
			else
				if string.find( stre, "STEAM" ) then
					list:AddLine( str:gsub( "_", ":" ), string.sub( stre, 1, string.find( stre, "STEAM" ) - 3 ) )
				else
					list:AddLine( str:gsub( "_", ":" ), "" )
				end
			end
		end	
		
	end
	
	local function populateSent()
		
		winbox = false
		
		local files = file.Find( "sentmail/*", "DATA" )
		table.sort( files, function( a, b ) return a > b end )
			
		for k, v in next, files do
			local text = tostring( v ):sub( 1, -5 )
				local str
				if string.find( text, "%s" ) then
					string.sub( text, string.find( text, "%s" ), string.len( text ) )
					str = text:gsub( "^%l", string.upper )	
				end		
			local temp = file.Read( "sentmail/" .. v )
			local stre = string.Explode( "\n", temp )[ 1 ]:sub( 9 )
			list:AddLine( str:gsub( "_", ":" ), stre )
		end
		
	end
	
	populateList()
	
	local txt = vgui.Create( "DTextEntry", main )
	txt:SetPos( 397, 27 )
	txt:SetSize( 399, 419 )
	txt:SetMultiline( true )
	txt:SetEditable( true )
	txt:SetText( "Double click or right click on a message to view its contents" )	
	
	list.DoDoubleClick = function( main, line )
	
		if winbox then
			local str = string.lower( list:GetLine( line ):GetValue( 1 ) )
			if string.find( list:GetLine( line ):GetValue( 1 ), "(Unread)" ) then
				txt:SetText( file.Read( "mail/" .. string.sub( str:gsub( ":", "_" ), 1, -10 ) .. ".txt" ) )
				file.Append( string.lower( "mail/" .. string.sub( list:GetLine( line ):GetValue( 1 ), 1, -10 ) ):gsub( ":", "_" ) .. ".txt", "\n\n###read###" )
			else
				txt:SetText( file.Read( "mail/" .. str:gsub( ":", "_" ) .. ".txt" ):gsub( "###read###", "" ) )
			end
		else
			local str = string.lower( list:GetLine( line ):GetValue( 1 ) )
			txt:SetText( file.Read( "sentmail/" .. str:gsub( ":", "_" ) .. ".txt" ) )
		end
		
		list:Clear()
		
		if winbox then
			populateList()
		else
			populateSent()
		end

	end
	
	list.OnRowRightClick = function( main, line )
	
		local str = string.lower( list:GetLine( line ):GetValue( 1 ) )
		local menu = DermaMenu()
		
			menu:AddOption( "View Contents", function()
			
				if winbox then
					local str = string.lower( list:GetLine( line ):GetValue( 1 ) )
					if string.find( list:GetLine( line ):GetValue( 1 ), "(Unread)" ) then
						txt:SetText( file.Read( "mail/" .. string.sub( str:gsub( ":", "_" ), 1, -10 ) .. ".txt" ) )
						file.Append( string.lower( "mail/" .. string.sub( list:GetLine( line ):GetValue( 1 ), 1, -10 ) ):gsub( ":", "_" ) .. ".txt", "\n\n###read###" )
					else
						txt:SetText( file.Read( "mail/" .. str:gsub( ":", "_" ) .. ".txt" ):gsub( "###read###", "" ) )
					end
				else
					local str = string.lower( list:GetLine( line ):GetValue( 1 ) )
					txt:SetText( file.Read( "sentmail/" .. str:gsub( ":", "_" ) .. ".txt" ) )
				end
				
				list:Clear()
				
				if winbox then
					populateList()
				else
					populateSent()
				end

			end ):SetIcon( "icon16/email_open.png" )
			
				if winbox then
				
					if not string.find( list:GetLine( line ):GetValue( 1 ), "(Unread)" ) then
					
						menu:AddOption( "Mark Unread", function()
						
							local f = file.Read( "mail/" .. str:gsub( ":", "_" ) .. ".txt" ) 
							f = string.gsub( f, "###read###", "" )
							
							file.Write( "mail/" .. str:gsub( ":", "_" ) .. ".txt", f )
							
							list:Clear()
							
							populateList()

						end ):SetIcon( "icon16/email.png" )
						
					else
					
						menu:AddOption( "Mark Read", function()
						
							file.Append( string.lower( "mail/" .. string.sub( list:GetLine( line ):GetValue( 1 ), 1, -10 ) ):gsub( ":", "_" ) .. ".txt", "\n\n###read###" )
							
							list:Clear()
							
							populateList()

						end ):SetIcon( "icon16/email_open_image.png" )
						
					end
					
				end
			
			menu:AddOption( "Delete", function()
			
				Derma_Query( "Are you sure you want to delete this message?", "Notice",
				
					"Yes", function() 
					
						if winbox then
						
							if not string.find( str, "(unread)" ) then
							
								file.Delete( "mail/" .. str:gsub( ":", "_" ) .. ".txt" )
								
								hook.Add( "HUDPaint", "DNotification", function()
									draw.SimpleTextOutlined( "Message Deleted!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
								end )
								
								timer.Simple( 2.5, function()
									hook.Remove( "HUDPaint", "DNotification" )
								end )
								
								surface.PlaySound( "garrysmod/content_downloaded.wav" )
								
							else
							
								file.Delete( "mail/" .. string.sub( str:gsub( ":", "_" ), 1, -10 ) .. ".txt" )
								
								hook.Add( "HUDPaint", "DNotification2", function()
									draw.SimpleTextOutlined( "Message Deleted!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
								end )
								
								timer.Simple( 2.5, function()
									hook.Remove( "HUDPaint", "DNotification2" )
								end )
								
								surface.PlaySound( "garrysmod/content_downloaded.wav" )
								
							end
							
						else
						
							file.Delete( "sentmail/" .. list:GetLine( line ):GetValue( 1 ):gsub( ":", "_" ) .. ".txt" )
							
							hook.Add( "HUDPaint", "DNotification2", function()
								draw.SimpleTextOutlined( "Message Deleted!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
							end )
							
							timer.Simple( 2.5, function()
								hook.Remove( "HUDPaint", "DNotification2" )
							end )
							
							surface.PlaySound( "garrysmod/content_downloaded.wav" )
							
						end
						
						list:Clear()
						
						if winbox then
							populateList()
						else
							populateSent()
						end

					end,
					
					"No", function() 
					end
					
				)	
				
			end ):SetIcon( "icon16/email_delete.png" )
			
			if not winbox then
				menu:Open()
				return
			end
			
			if table.HasValue( blockedgroups, LocalPlayer():GetNWString( "usergroup" ) ) or table.HasValue( blacklistids, LocalPlayer():SteamID() ) then
				if not table.HasValue( whitelistids, LocalPlayer():SteamID() ) then
					menu:Open()
					return
				end
			end
			
			if not ( string.find( list:GetLine( line ):GetValue( 1 ), "(Unread)" ) or string.find( list:GetLine( line ):GetValue( 1 ), "Welcome" ) or string.find( list:GetLine( line ):GetValue( 1 ), "How" ) ) then
			
				menu:AddOption( "Reply", function()
				
					net.Start( "SetReply" )
					net.SendToServer()
					
					local file = file.Read( "mail/" .. list:GetLine( line ):GetValue( 1 ):gsub( ":", "_" ) .. ".txt" )
					local exp = string.Explode( "\n", file )
					local str = exp[ 1 ]
					local str2 = string.sub( str, string.find( str, "STEAM" ) - 1 )
					local str3 = string.sub( str2, 2, -2 )
					
					net.Start( "SetSteamIDText" )
						net.WriteString( str3 )
					net.SendToServer()
					
				end ):SetIcon( "icon16/email_go.png" )
				
			end
			
		menu:Open()
		
		menu.Paint = function()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect( 0, 0, menu:GetWide(), menu:GetTall() )
			surface.SetDrawColor( 0, 0, 0, 230 )
			surface.DrawOutlinedRect( 0, 0, menu:GetWide(), menu:GetTall() )
		end
		
	end	
	
	local f = file.Find( "mail/*", "DATA" )
	local n = 0
	
	for k, v in pairs( f ) do
		local t = file.Read( "mail/" .. v )
		if not string.find( t, "###read###" ) then
			n = ( n + 1 )
		end
	end
	
	main:SetTitle( "Mailbox (" .. #list:GetLines() .. " messages, " .. n .." unread)" )		
	
	local compose = vgui.Create( "DButton", main )
	compose:SetText( "" )
	compose:SetPos( 4, 449 )
	compose:SetSize( 150, 47 )
	
	compose.Paint = function()
		surface.SetDrawColor( OutlineColor )
		surface.DrawOutlinedRect( 0, 0, compose:GetWide(), compose:GetTall() )
		
		surface.SetFont( "MailFont" )
		if compose:IsDown() then
			surface.SetTextColor( TextColorDown )
		else
			surface.SetTextColor( TextColor )
		end
		surface.SetTextPos( 29, 15 ) 
		surface.DrawText( "Compose Mail" )
		return true
	end

	function OpenCompose()
		
		if cmain then 
			return 
		end
		
		surface.PlaySound( "garrysmod/ui_click.wav" )
	
		if table.HasValue( blockedgroups, LocalPlayer():GetNWString( "usergroup" ) ) or table.HasValue( blacklistids, LocalPlayer():SteamID() ) then
			if not table.HasValue( whitelistids, LocalPlayer():SteamID() ) then
				chat.AddText( "You are not allowed to use this!" )
				return
			end
		end
	
		cmain = vgui.Create( "DFrame" )	
		local v = Vector( main:GetPos() )
		
		cmain:SetPos( v.x + 803, v.y )
		cmain:SetSize( 400, 250 )
		cmain:SetTitle( "Compose Message" )
		cmain:SetVisible( true )
		cmain:SetDraggable( true )
		cmain:ShowCloseButton( true )
		cmain:MakePopup()
		cmain.btnMaxim:Hide()
		cmain.btnMinim:Hide() 
		
		cmain.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, cmain:GetWide(), cmain:GetTall() )		
			surface.SetDrawColor( MenuColor )
			surface.DrawRect( 1, 1, cmain:GetWide() - 2, cmain:GetTall() - 2 )		
		end
		
		cmain:RequestFocus()
		
		cmain.OnClose = function()
			cmain = nil
		end
		
		local txt = vgui.Create( "DTextEntry", cmain )
		
		txt:SetPos( 4, 26 )
		txt:SetSize( 392, 198 )
		txt:SetMultiline( true )
		txt:SetEditable( true )
		txt:SetText( "" )		

		local stid = vgui.Create( "DTextEntry", cmain )
		stid:SetPos( 137, 226 )
		stid:SetSize( 130, 20 )
		stid:SetMultiline( false )
		stid:SetEditable( true )
		stid:SetText( "SteamID" )
		stid:SetDisabled( true )
		stid:SetEditable( false )

		local plys = vgui.Create( "DComboBox", cmain )
		plys:SetPos( 4, 226 )
		plys:SetSize( 130, 20 )
		plys:SetValue( "Player" )
		
		net.Receive( "SetComboBoxValueCallback", function()
			plys:SetValue( "Reply to SteamID" )
			stid:SetDisabled( false )
			stid:SetEditable( true )
		end )
		
		net.Receive( "SetSteamIDTextCallback", function()
			local id = net.ReadString()
			stid:SetText( id )
		end )
		
		net.Start( "RequestPlys" )
		net.SendToServer()
		
		net.Receive( "RequestPlysCallback", function()
		
			if cmain and IsValid( cmain ) then
			
				local tbl = net.ReadTable()

				for k, v in ipairs( tbl ) do
					plys:AddChoice( v:Nick() )
				end
				
				net.Start( "FetchConVarNumber" )
				net.SendToServer()
				
				net.Receive( "FetchConVarNumberCallback", function()
				
					local num = net.ReadString()
					
					if tonumber( num ) == 1 then
					
						if LocalPlayer():IsAdmin() then
				
							plys:AddChoice( "" )
							
							for k, v in pairs( ULib.ucl.groups ) do
								plys:AddChoice( tostring( k ) )
							end
							
							plys:AddChoice( "" )
							
							plys:AddChoice( "All Connected Players" )
							
							plys:AddChoice( "Offline SteamID" )
							
						end
						
					elseif tonumber( num ) == 0 then
						
						plys:AddChoice( "" )
							
						for k, v in pairs( ULib.ucl.groups ) do
							plys:AddChoice( tostring( k ) )
						end
						
						plys:AddChoice( "" )
						
						plys:AddChoice( "All Connected Players" )
						
						plys:AddChoice( "Offline SteamID" )
						
					end
					
				end )
				
			else
				return
			end

		end )
		
		local box = "Player"
		
		plys.OnSelect = function( panel, index, value, data )
		
			if tostring( value ) == "Offline SteamID" then
				stid:SetDisabled( false )
				stid:SetEditable( true )
			else
				stid:SetDisabled( true )
				stid:SetEditable( false )
			end
			
			box = tostring( value )
			
		end
		
		local send = vgui.Create( "DButton", cmain )
		send:SetText( "Send" )
		send:SetPos( 270, 226 )
		send:SetSize( 126, 20 )
		
		send.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, send:GetWide(), send:GetTall() )	
			surface.SetFont( "Labels" )
			if send:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 50, 3 ) 
			surface.DrawText( "Send" )
			return true
		end
		
		local groups = {}
		for k, v in pairs( ULib.ucl.groups ) do
			table.insert( groups, tostring( k ) )
		end
		
		send.DoClick = function()
		
			local aaa = txt:GetText()
			
			if not ( box == "Offline SteamID" or box == "All Connected Players" or box == "Player" or box == "" ) then
			
				if not table.HasValue( groups, box ) then
				
					net.Start( "SendMail" )
						net.WriteString( txt:GetText() )
						net.WriteString( box )
					net.SendToServer()
					
					if box == LocalPlayer():GetName() then
					
						hook.Add( "HUDPaint", "SNotification", function()
							draw.SimpleTextOutlined( "Message sent to " .. box .. "!", "Outline", ScrW() / 2 + 2, 55, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
						end )
						
						timer.Simple( 4, function()
							hook.Remove( "HUDPaint", "SNotification" )
						end )
						
					else
					
						surface.PlaySound( "garrysmod/content_downloaded.wav" )
						
						hook.Add( "HUDPaint", "SNotification", function()
							draw.SimpleTextOutlined( "Message sent to " .. box .. "!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
						end )
						
						timer.Simple( 4, function()
							hook.Remove( "HUDPaint", "SNotification" )
						end )
						
					end
					
					cmain:Close()
					
				else
				
					net.Start( "SendMailGroup" )
						net.WriteString( txt:GetText() )
						net.WriteString( box )
					net.SendToServer()
					
					surface.PlaySound( "garrysmod/content_downloaded.wav" )
					
					hook.Add( "HUDPaint", "SNotification", function()
						draw.SimpleTextOutlined( "Message sent to group " .. box .. "!", "Outline", ScrW() / 2 + 2, 55, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
					end )
					
					timer.Simple( 4, function()
						hook.Remove( "HUDPaint", "SNotification" )
					end )
					
					cmain:Close()
					
				end
				
			elseif box == "Offline SteamID" then
			
				if stid:GetText() == "SteamID" then
				
					chat.AddText( "Input a steamid!" )
					
				else
				
					local sid = stid:GetText()
					net.Start( "SendSteamID" )
						net.WriteString( txt:GetText() )
						net.WriteString( stid:GetText() )
					net.SendToServer()
					
					surface.PlaySound( "garrysmod/content_downloaded.wav" )
					
					hook.Add( "HUDPaint", "StNotification", function()
						draw.SimpleTextOutlined( "Message sent to " .. tostring( sid ) .. "!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
					end )
					
					timer.Simple( 4, function()
						hook.Remove( "HUDPaint", "StNotification" )
					end )
					
					cmain:Close()
					
				end
			
			elseif box == "All Connected Players" then
			
				net.Start( "RequestPlys" )
				net.SendToServer()
				
				net.Receive( "RequestPlysCallback", function()
				
					local pls = net.ReadTable()
					
					for k, v in ipairs( pls ) do
						local x = v:Nick()
						net.Start( "SendMail" )
							net.WriteString( "**Sent to Everyone**\n---------------\n" .. aaa )
							net.WriteString( x )
						net.SendToServer()
					end
					
				end )
				
				hook.Add( "HUDPaint", "AllNotification", function()
					draw.SimpleTextOutlined( "Message sent to everyone!", "Outline", ScrW() / 2 + 2, 55, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
				end )
				
				timer.Simple( 4, function()
					hook.Remove( "HUDPaint", "AllNotification" )
				end )
				
				cmain:Close()
				
			elseif box == "Player" or box == "" then
			
				if stid:GetText() ~= "SteamID" then
				
					local sid = stid:GetText()
					
					net.Start( "SendSteamID" )
						net.WriteString( txt:GetText() )
						net.WriteString( stid:GetText() )
					net.SendToServer()
					
					surface.PlaySound( "garrysmod/content_downloaded.wav" )
					
					hook.Add( "HUDPaint", "StNotification", function()
						draw.SimpleTextOutlined( "Message sent to " .. tostring( sid ) .. "!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
					end )
					
					timer.Simple( 4, function()
						hook.Remove( "HUDPaint", "StNotification" )
					end )
					
					cmain:Close()
					
				else
					chat.AddText( "Select a player or group!" )
				end
				
			end
			
		end
		
	end
	
	compose.DoClick = OpenCompose
	
	net.Receive( "SetReplyCallback", function()
		OpenCompose()
		net.Start( "SetComboBoxValue" )
		net.SendToServer()
	end )
	
	local refresh = vgui.Create( "DButton", main )
	refresh:SetText( "" )
	refresh:SetPos( 158, 449 )
	refresh:SetSize( 150, 47 )
	
	refresh.Paint = function()
		surface.SetDrawColor( OutlineColor )
		surface.DrawOutlinedRect( 0, 0, refresh:GetWide(), refresh:GetTall() )
		
		surface.SetFont( "MailFont" )
		if refresh:IsDown() then
			surface.SetTextColor( TextColorDown )
		else
			surface.SetTextColor( TextColor )
		end
		surface.SetTextPos( 29, 15 ) 
		surface.DrawText( "     Refresh" )
		return true
	end
	
	refresh.DoClick = function()
		
		if winbox then
		
			list:Clear()
			
			populateList()
			
			surface.PlaySound( "garrysmod/ui_click.wav" )
			
			local f = file.Find( "mail/*", "DATA" )
			local n = 0
			
			for k, v in ipairs( f ) do
				local t = file.Read( "mail/" .. v )
				if not string.find( t, "###read###" ) then
					n = ( n + 1 )
				end
			end
			
			main:SetTitle( "Mailbox (" .. #list:GetLines() .. " messages, " .. n .." unread)" )	
			
		else
			
			list:Clear()
			
			populateSent()
			
			surface.PlaySound( "garrysmod/ui_click.wav" )
			
			main:SetTitle( "Sent Mail (" .. #list:GetLines() .. " messages)" )
			
		end
		
	end
	
	local admin = vgui.Create( "DButton", main )
	admin:SetText( "" )
	admin:SetPos( 466, 449 )
	admin:SetSize( 150, 47 )
	
	if LocalPlayer():IsAdmin() then
		admin:SetDisabled( false )
		admin:SetVisible( true )
	else
		admin:SetDisabled( true )
		admin:SetVisible( false )
	end
	
	admin.Paint = function()
		surface.SetDrawColor( OutlineColor )
		surface.DrawOutlinedRect( 0, 0, admin:GetWide(), admin:GetTall() )
		
		surface.SetFont( "MailFont" )
		if admin:IsDown() then
			surface.SetTextColor( TextColorDown )
		else
			surface.SetTextColor( TextColor )
		end
		surface.SetTextPos( 29, 15 ) 
		surface.DrawText( "      Admin" )
		return true
	end
	
	admin.DoClick = function()
		
		if amain then return end
		
		surface.PlaySound( "garrysmod/ui_click.wav" )

		amain = vgui.Create( "DFrame" )	
		local v = Vector( main:GetPos() )
		
		amain:SetPos( v.x - 303, v.y )
		amain:SetSize( 300, 500 )
		amain:SetTitle( "Admin Options" )
		amain:SetVisible( true )
		amain:SetDraggable( true )
		amain:ShowCloseButton( true )
		amain:MakePopup()
		amain.btnMaxim:Hide()
		amain.btnMinim:Hide() 
		
		amain.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, amain:GetWide(), amain:GetTall() )		
			surface.SetDrawColor( MenuColor )
			surface.DrawRect( 1, 1, amain:GetWide() - 2, amain:GetTall() - 2 )		
		end
		
		amain:RequestFocus()
		
		amain.OnClose = function()
			amain = nil
		end
		
		local glabel = vgui.Create( "DLabel", amain )
		glabel:SetPos( 7, 27 )
		glabel:SetColor( TextColor )
		glabel:SetFont( "Labels" )
		glabel:SetText( "Set Blacklisted Groups (Cannot send messages)" )
		glabel:SizeToContents()
		
		local gblocked = vgui.Create( "DTextEntry", amain )
		gblocked:SetPos( 4, 42 )
		gblocked:SetSize( 292, 120 )
		gblocked:SetText( "" )
		gblocked:SetMultiline( true )
		
		local gexec = vgui.Create( "DButton", amain )
		gexec:SetPos( 5, 163 )
		gexec:SetSize( 290, 20 )
		gexec:SetText( "Apply Changes" )
		gexec.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, gexec:GetWide(), gexec:GetTall() )		
			surface.SetFont( "Labels" )
			if gexec:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 109, 3 ) 
			surface.DrawText( "Apply Changes" )
			return true
		end
		
		gexec.DoClick = function()
		
			local toSend = gblocked:GetText()
			
			net.Start( "SendUpdatedGroups" )
				net.WriteString( toSend )
			net.SendToServer()
			
			surface.PlaySound( "garrysmod/content_downloaded.wav" )
			
			hook.Add( "HUDPaint", "NotificationG", function()
				draw.SimpleTextOutlined( "Group permissions updated successfully!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
			end )
			
			timer.Simple( 4, function()
				hook.Remove( "HUDPaint", "NotificationG" )
			end )
			
		end
		
		local slabel = vgui.Create( "DLabel", amain )
		slabel:SetPos( 7, 197 )
		slabel:SetColor( TextColor )
		slabel:SetFont( "Labels" )
		slabel:SetText( "Set Whitelisted SteamIDs" )
		slabel:SizeToContents()
		
		local sblocked = vgui.Create( "DTextEntry", amain )
		sblocked:SetPos( 4, 212 )
		sblocked:SetSize( 145, 120 )
		sblocked:SetText( "" )
		sblocked:SetMultiline( true )
			
		local sexec = vgui.Create( "DButton", amain )
		sexec:SetPos( 5, 333 )
		sexec:SetSize( 143, 20 )
		sexec:SetText( "Apply Changes" )
		sexec.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, sexec:GetWide(), sexec:GetTall() )		
			surface.SetFont( "Labels" )
			if sexec:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 37, 3 ) 
			surface.DrawText( "Apply Changes" )
			return true
		end
		
		sexec.DoClick = function()
		
			local toSend = sblocked:GetText()
			
			net.Start( "SendUpdatedIDs" )
				net.WriteString( toSend )
			net.SendToServer()
			
			surface.PlaySound( "garrysmod/content_downloaded.wav" )
			
			hook.Add( "HUDPaint", "NotificationIDs", function()
				draw.SimpleTextOutlined( "SteamID whitelist updated successfully!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
			end )
			
			timer.Simple( 4, function()
				hook.Remove( "HUDPaint", "NotificationIDs" )
			end )
			
		end
		
		local slabel2 = vgui.Create( "DLabel", amain )
		slabel2:SetPos( 154, 197 )
		slabel2:SetColor( TextColor )
		slabel2:SetFont( "Labels" )
		slabel2:SetText( "Set Blacklisted SteamIDs" )
		slabel2:SizeToContents()
		
		local sblocked2 = vgui.Create( "DTextEntry", amain )
		sblocked2:SetPos( 151, 212 )
		sblocked2:SetSize( 145, 120 )
		sblocked2:SetText( "" )
		sblocked2:SetMultiline( true )
			
		local sexec2 = vgui.Create( "DButton", amain )
		sexec2:SetPos( 152, 333 )
		sexec2:SetSize( 143, 20 )
		sexec2:SetText( "Apply Changes" )
		sexec2.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, sexec2:GetWide(), sexec2:GetTall() )		
			surface.SetFont( "Labels" )
			if sexec2:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 37, 3 ) 
			surface.DrawText( "Apply Changes" )
			return true
		end
		
		sexec2.DoClick = function()
		
			local toSend = sblocked2:GetText()
			
			net.Start( "SendUpdatedIDs2" )
				net.WriteString( toSend )
			net.SendToServer()
			
			surface.PlaySound( "garrysmod/content_downloaded.wav" )
			
			hook.Add( "HUDPaint", "NotificationIDs", function()
				draw.SimpleTextOutlined( "SteamID blacklist updated successfully!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
			end )
			
			timer.Simple( 4, function()
				hook.Remove( "HUDPaint", "NotificationIDs" )
			end )
			
		end
		
		local abox = vgui.Create( "DCheckBoxLabel", amain )
		abox:SetPos( 5, 370 )
		abox:SetText( "Only admins can send to groups/ids" )
		abox:SetChecked( false )
		abox:SizeToContents()
		
		net.Start( "FetchConVarNumber" )
		net.SendToServer()
		
		net.Receive( "FetchConVarNumberCallback", function()
		
			if amain and IsValid( amain ) then
				local num = net.ReadString()
				
				if tonumber( num ) == 1 then
					abox:SetChecked( true )
				elseif tonumber( num ) == 0 then
					abox:SetChecked( false )
				end
			else
				return
			end
			
		end )
		
		local aboxapply = vgui.Create( "DButton", amain )
		aboxapply:SetPos( 220, 369 )
		aboxapply:SetSize( 70, 18 )
		aboxapply:SetText( "Apply" )
		aboxapply.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, aboxapply:GetWide(), aboxapply:GetTall() )		
			surface.SetFont( "Labels" )
			if aboxapply:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 22, 1.5 ) 
			surface.DrawText( "Apply" )
			return true
		end
		
		aboxapply.DoClick = function()
		
			local cvar = "mail_admingroup"
			
			local value = abox:GetChecked()
			
			net.Start( "ApplyCvarChanges" )
				if value then
					net.WriteString( "true" )
				else
					net.WriteString( "false" )
				end
			net.SendToServer() 
			
			surface.PlaySound( "garrysmod/content_downloaded.wav" )
		
			hook.Add( "HUDPaint", "NotificationCvar", function()
				draw.SimpleTextOutlined( "Changes applied successfully!", "Outline", ScrW() / 2 + 2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )
			end )
			
			timer.Simple( 4, function()
				hook.Remove( "HUDPaint", "NotificationCvar" )
			end )
			
		end

		net.Start( "RequestBlocked" )
		net.SendToServer()
		
		net.Receive( "RequestBlockedCallback", function()
		
			if amain and IsValid( amain ) then
				local bg = net.ReadTable()
				local wi = net.ReadTable()
				local bi = net.ReadTable()
				
				local str = table.concat( bg, "\n" )
				
				if str and str:len() > 0 then
					gblocked:SetText( str )
				else
					gblocked:SetText( "No blocked groups" )
				end
				
				local str2 = table.concat( wi, "\n" )
				
				if str2 and str2:len() > 0 then
					sblocked:SetText( str2 )
				else
					sblocked:SetText( "No whitelisted IDs" )
				end
				
				local str3 = table.concat( bi, "\n" )
				
				if str3 and str3:len() > 0 then
					sblocked2:SetText( str3 )
				else
					sblocked2:SetText( "No blacklisted IDs" )
				end
			else 
				return
			end
			
		end )
		
	end
	
	local toggle = vgui.Create( "DButton", main )
	toggle:SetText( "" )
	toggle:SetPos( 312, 449 )
	toggle:SetSize( 150, 47 )
	
	local inbox = true

	local function SwapForSent()
		list:Clear()
		populateSent()
		toggle.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, toggle:GetWide(), toggle:GetTall() )
			
			surface.SetFont( "MailFont" )
			if toggle:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 29, 15 ) 
			surface.DrawText( "  Show Inbox" )
			return true
		end
		inbox = false
	end
	
	local function SwapForInbox()
		list:Clear()
		populateList()
		toggle.Paint = function()
			surface.SetDrawColor( OutlineColor )
			surface.DrawOutlinedRect( 0, 0, toggle:GetWide(), toggle:GetTall() )
			
			surface.SetFont( "MailFont" )
			if toggle:IsDown() then
				surface.SetTextColor( TextColorDown )
			else
				surface.SetTextColor( TextColor )
			end
			surface.SetTextPos( 29, 15 ) 
			surface.DrawText( "  Show Sent" )
			return true
		end
		inbox = true
	end
	
	SwapForInbox()
	
	toggle.DoClick = function()
		
		surface.PlaySound( "garrysmod/ui_click.wav" )
		
		if inbox then
			SwapForSent()
			main:SetTitle( "Sent Mail (" .. #list:GetLines() .. " messages)" )
		else
			SwapForInbox()
			
			local f = file.Find( "mail/*", "DATA" )
			local n = 0
			
			for k, v in pairs( f ) do
				local t = file.Read( "mail/" .. v )
				if not string.find( t, "###read###" ) then
					n = ( n + 1 )
				end
			end
			
			main:SetTitle( "Mailbox (" .. #list:GetLines() .. " messages, " .. n .." unread)" )
		end
		
	end
	
end

function MailKeyPress()
	
	if input.IsKeyDown( MenuKey ) then
		if MailKeyDown then
			return
		end
		MailKeyDown = true
		if main and IsValid( main ) and main:IsVisible() then
			main:Close()
			if amain and IsValid( amain ) and amain:IsVisible() then
				amain:Close()
			end
			if cmain and IsValid( cmain ) and cmain:IsVisible() then
				cmain:Close()
			end
		else
			OpenMailbox()
		end
	else
		MailKeyDown = false
	end

end

hook.Add( "Think", "MailKey", MailKeyPress )
usermessage.Hook( "mailbox", OpenMailbox )