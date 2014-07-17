////////////////////////////////////
//							      //
//		 Server Mail Addon		  //
//		 Created by Cobalt		  //
//			  sv_init			  //
//								  //
////////////////////////////////////

MsgN( "Server Mail addon by Cobalt loaded!" )

if not file.Exists( "mail", "DATA" ) then
	file.CreateDir( "mail" )
end

if not file.Exists( "mail/blacklistgroups.txt", "DATA" ) then
	file.Write( "mail/blacklistgroups.txt" )
end

if not file.Exists( "mail/whitelistids.txt", "DATA" ) then
	file.Write( "mail/whitelistids.txt" )
end

if not file.Exists( "mail/blacklistids.txt", "DATA" ) then
	file.Write( "mail/blacklistids.txt" )
end

CreateConVar( "mail_admingroup", 1, FCVAR_ARCHIVE )
CreateConVar( "mail_logmail", 0, FCVAR_ARCHIVE )

local NWStrings = {
	"SendMail",
	"SendMailCallback",
	"RequestPlys",
	"RequestPlysCallback",
	"SendSteamID",
	"DownloadFile",
	"SendMailGroup",
	"GroupMessageTables",
	"SetReply",
	"SetReplyCallback",
	"SetComboBoxValue",
	"SetComboBoxValueCallback",
	"SetSteamIDText",
	"SetSteamIDTextCallback",
	"RequestBlocked",
	"RequestBlockedCallback",
	"SendUpdatedGroups",
	"SendUpdatedIDs",
	"SendUpdatedIDs2",
	"ApplyCvarChanges",
	"FetchConVarNumber",
	"FetchConVarNumberCallback",
	"WriteSentMail",
	"WriteSentSteamID",
	"WriteSentGroup",
	"WriteSentEveryone"
}

for k, v in next, NWStrings do
	util.AddNetworkString( v )
end

concommand.Add( "mailbox", function( ply )
	umsg.Start( "mailbox", ply )
	umsg.End()
end )