#include <YSI\y_hooks>

#define DIALOG_OWNER1				9951
#define DIALOG_OWNER2_CONFIRM		9952
#define DIALOG_OWNER2 				9953
#define DIALOG_CONFIRM				9954

#define DIALOG_NEWNAME				9955
#define DIALOG_EDITOWNER			9956
#define DIALOG_EDITOWNER2			9957
#define DIALOG_EDITTYPE				9958


stock GetPlayerName_(playerid) // Adding this because I'm lazy.
{
	new szName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, szName, sizeof szName);
	return szName;
}

stock GetPlayerID(playername[], &var) // Also because I'm lazy.
{
	for(new i = 0; i <= MAX_PLAYERS; i++)
  	{
    	if(IsPlayerConnected(i))
    	{
      		new szName[MAX_PLAYER_NAME];
      		GetPlayerName(i, szName, sizeof szName);

      		if(strcmp(szName, playername, true, strlen(szName)) == 0)
      		{
      			var = i;
        		return i;
      		}
    	}
  	}
  	var = INVALID_PLAYER_ID;
	return INVALID_PLAYER_ID;
}

CMD:lnrestrict(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use that command.");

	new szLN[MAX_PLAYER_NAME];

	if(sscanf(params, "s[MAX_PLAYER_NAME]", szLN)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /lnrestrict [last name]");

	format(szMiscArray, sizeof szMiscArray, "SELECT * FROM `lastnames` WHERE `Name`='%s'", szLN);
	mysql_function_query(MainPipeline, szMiscArray, true, "LastNameCheck", "ds", playerid, szLN);
	return 1;
}

CMD:lndelete(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use that command.");

	new szLN[MAX_PLAYER_NAME];

	if(sscanf(params, "s[MAX_PLAYER_NAME]", szLN)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /lndelete [last name]");

	format(szMiscArray, sizeof szMiscArray, "SELECT * FROM `lastnames` WHERE `Name`='%s'", szLN);
	mysql_function_query(MainPipeline, szMiscArray, true, "LastNameCheckDelete", "ds", playerid, szLN);

	return 1;
}

forward LastNameCheckDelete(playerid, lastname[]);
public LastNameCheckDelete(playerid, lastname[])
{
	new rows, fields;
	cache_get_data(rows, fields);

	if(rows != 0)
	{
		SendClientMessage(playerid, COLOR_WHITE, "Deleting last name from database...");

		format(szMiscArray, sizeof szMiscArray, "DELETE FROM `lastnames` WHERE `Name`='%s'", lastname);
		mysql_function_query(MainPipeline, szMiscArray, true, "LastNameDeleted", "ds", playerid, lastname);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "That last name is not restricted. If you wish to restrict it, use /lnrestrict.");
	return 1;
}

forward LastNameDeleted(playerid, lastname[]);
public LastNameDeleted(playerid, lastname[])
{
	SendClientMessage(playerid, COLOR_WHITE, "Last name deleted from database successfully.");

	format(szMiscArray, sizeof szMiscArray, "%s deleted last name %s.", GetPlayerNameEx(playerid), lastname);
	Log("logs/lastnames.log", szMiscArray);
	return 1;
}

CMD:lnhelp(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use that command.");

	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	SendClientMessage(playerid, COLOR_GRAD3, "*** Restricted Last Name Commands *** /lnrestrict /lndelete /lnview /lnlist");
	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	return 1;
}

CMD:lnview(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use that command.");

	new szLN[MAX_PLAYER_NAME];

	if(sscanf(params, "s[MAX_PLAYER_NAME]", szLN)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /lnview [last name]");

	format(szMiscArray, sizeof szMiscArray, "SELECT * FROM `lastnames` WHERE `Name`='%s'", szLN);
	mysql_function_query(MainPipeline, szMiscArray, true, "LastNameCheckView", "ds", playerid, szLN);
	return 1;
}

CMD:lnlist(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_GRAD2, "You're not authorised to use that command.");

	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________"); // Should've used threaded queries here, didn't. Oh well.
	mysql_query(MainPipeline, "SELECT * FROM `lastnames`", true);

	new rows, fields;
	cache_get_data(rows, fields, MainPipeline);

	if(rows > 0)
	{
		new name[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szRestrictedBy[MAX_PLAYER_NAME], szType[15];
		for(new row = 0; row < rows; row++)
		{
			cache_get_field_content(row, "Name", name, MainPipeline);
			cache_get_field_content(row, "Owner1", szOwner, MainPipeline);
			cache_get_field_content(row, "Owner2", szOwner2, MainPipeline);
			cache_get_field_content(row, "RestrictedBy", szRestrictedBy, MainPipeline);
			new type = cache_get_field_content_int(row, "Type", MainPipeline); if(type == 1) format(szType, sizeof szType, "Last Name"); else format(szType, sizeof szType, "Middle Name");

			for(new i = 0; i < MAX_PLAYER_NAME; i++)
			{
				if(szOwner[i] == '_') szOwner[i] = ' ';
				if(szOwner2[i] == '_') szOwner2[i] = ' ';
				if(szRestrictedBy[i] == '_') szRestrictedBy[i] = ' ';
			}

			format(szMiscArray, sizeof szMiscArray, "Name: %s | Owner: %s | Co-Owner: %s | Restricted By: %s | Type: %s", name, szOwner, szOwner2, szRestrictedBy, szType);
			SendClientMessage(playerid, COLOR_GREY, szMiscArray);
		}
	}

	SendClientMessageEx(playerid, COLOR_GREEN,"_______________________________________");
	return 1;
}

forward LastNameCheckView(playerid, name[]);
public LastNameCheckView(playerid, name[])
{
	new rows, fields;
	cache_get_data(rows, fields);

	if(rows != 0)
	{
		new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szRestrictedBy[MAX_PLAYER_NAME], type, szType[15];

		for(new row = 0; row < rows; row++)
		{
			cache_get_field_content(row, "Name", szName, MainPipeline);
			cache_get_field_content(row, "Owner1", szOwner, MainPipeline);
			cache_get_field_content(row, "Owner2", szOwner2, MainPipeline);
			cache_get_field_content(row, "RestrictedBy", szRestrictedBy, MainPipeline);
			type = cache_get_field_content_int(row, "Type", MainPipeline); if(type == 1) format(szType, sizeof szType, "Last Name"); else format(szType, sizeof szType, "Middle Name");
		}

		for(new i = 0; i < MAX_PLAYER_NAME; i++)
		{
			if(szOwner[i] == '_') szOwner[i] = ' ';
			if(szOwner2[i] == '_') szOwner2[i] = ' ';
			if(szRestrictedBy[i] == '_') szRestrictedBy[i] = ' ';
		}

		SendClientMessage(playerid, COLOR_GRAD1, "That name is restricted: ");
		format(szMiscArray, sizeof szMiscArray, "Name: %s | Owner: %s | Co-Owner: %s | Restricted By: %s | Type: %s", szName, szOwner, szOwner2, szRestrictedBy, szType);
		SendClientMessage(playerid, COLOR_GREY, szMiscArray);
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "That last name is not restricted. If you wish to restrict it, use /lnrestrict.");
	return 1;
}

stock IsRestricted(fullname[])
{
	format(szMiscArray, sizeof szMiscArray, "SELECT * FROM `lastnames` WHERE `Name`='%s'", fullname);
	mysql_query(MainPipeline, szMiscArray, true);

	new rows, fields;
	cache_get_data(rows, fields);

	if(rows != 0) return 1;
	return 0;
}

stock CheckLN(playerid, name[])
{
	format(szMiscArray, sizeof szMiscArray, "SELECT * FROM `lastnames` WHERE `Name`='%s'", name);
	mysql_function_query(MainPipeline, szMiscArray, true, "NameChangeCheck", "d", playerid);
}

stock SendLNAuthRequest(playerid, name[])
{
	// Code borrowed from below function.
	format(szMiscArray, sizeof szMiscArray, "SELECT `Owner1`, `Owner2` FROM `lastnames` WHERE `Name`='%s'", name);
	mysql_query(MainPipeline, szMiscArray, true);

	new fields, rows;
	cache_get_data(rows, fields, MainPipeline);

	new Owner1[MAX_PLAYER_NAME];
	new iOwnerID = -1;
	new Owner2[MAX_PLAYER_NAME];
	new iOwner2ID = -1; 

	if(rows > 0) // Name exists
	{
		for(new row = 0; row < rows; row++)
		{
			cache_get_field_content(row, "Owner1", Owner1, MainPipeline);
			cache_get_field_content(row, "Owner2", Owner2, MainPipeline);
		}

		if(strlen(Owner1) > 0) GetPlayerID(Owner1, iOwnerID);
		if(strlen(Owner2) > 0) GetPlayerID(Owner2, iOwner2ID);
	}

	new szRequestedName[MAX_PLAYER_NAME];
	GetPVarString(playerid, "NewNameRequest", szRequestedName, MAX_PLAYER_NAME);

	if(IsPlayerConnected(iOwnerID) && iOwnerID != -1)
	{
		format(szMiscArray, sizeof szMiscArray, "A name change request has been sent by %s for the last name %s (/lnapprove or /lnreject).", GetPlayerNameEx(playerid), name);
		SendClientMessage(iOwnerID, COLOR_LIGHTBLUE, szMiscArray);
		SetPVarString(playerid, "LNRequest", name);
		SetPVarInt(iOwnerID, "LNRequestID", playerid);
		SetPVarInt(iOwnerID, "ActiveLNRequest", 1);
		//SetPVarInt(playerid, "LNAuthorised", 1);
	}

	else if(IsPlayerConnected(iOwner2ID) && iOwner2ID != -1)
	{
		format(szMiscArray, sizeof szMiscArray, "A name change request has been sent by %s for the name %s (/lnapprove or /lnreject).", GetPlayerNameEx(playerid), name);
		SendClientMessage(iOwner2ID, COLOR_LIGHTBLUE, szMiscArray);
		SetPVarString(playerid, "LNRequest", name);
		SetPVarInt(iOwner2ID, "LNRequestID", playerid);
		SetPVarInt(iOwner2ID, "ActiveLNRequest", 1);
		//SetPVarInt(playerid, "LNAuthorised", 1);
	}
}

CMD:lnapprove(playerid, params[])
{
	if(GetPVarInt(playerid, "ActiveLNRequest") == 0) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have a pending restricted last name change request.");

	new iReqID = GetPVarInt(playerid, "LNRequestID");

	if(!IsPlayerConnected(iReqID))
	{
		DeletePVar(playerid, "LNRequest");
		return SendClientMessage(playerid, COLOR_GREY, "The player requesting the name change is no longer connected.");
	}

	new RequestedName[MAX_PLAYER_NAME];
	GetPVarString(iReqID, "NewNameRequest", RequestedName, MAX_PLAYER_NAME);

	if(GetPVarType(playerid, "HasReport"))
	{
		SendClientMessage(playerid, COLOR_GREY, "That player already has a pending report.");
		SendClientMessageEx(iReqID, COLOR_GREY, "You can only have 1 active report at a time. (/cancelreport)");
	}
	
	SendClientMessage(playerid, COLOR_WHITE, "Name change request approved.");
	SendClientMessage(iReqID, COLOR_WHITE, "Your name change permission request has been approved.");

	SetPVarInt(iReqID, "RequestingNameChange", 1);
	SetPVarInt(iReqID, "NameChangeCost", 0);

	SetPVarInt(iReqID, "RequestingNameChange", 1);
	SetPVarInt(iReqID, "NameChangeCost", 0);
	new playername[MAX_PLAYER_NAME];
	GetPlayerName(iReqID, playername, sizeof(playername));
	format(szMiscArray, sizeof szMiscArray, "You have requested a namechange from %s to %s at no cost, please wait until a General Admin approves it.", playername, RequestedName);
	SendClientMessageEx(iReqID, COLOR_YELLOW, szMiscArray);
	SendReportToQue(iReqID, "Name Change Request", 2, 4);

	DeletePVar(playerid, "LNRequestID");
	DeletePVar(iReqID, "LNRequest");
	DeletePVar(iReqID, "RequestedName");
	return 1;
}

CMD:lnreject(playerid, params[])
{
	if(GetPVarInt(playerid, "ActiveLNRequest") == 0) return SendClientMessage(playerid, COLOR_GRAD2, "You do not have a pending restricted last name change request.");

	new iReqID = GetPVarInt(playerid, "LNRequestID");

	if(!IsPlayerConnected(iReqID))
	{
		DeletePVar(playerid, "LNRequest");
		return SendClientMessage(playerid, COLOR_GREY, "The player requesting the name change is no longer connected.");
	}
	
	SendClientMessage(playerid, COLOR_WHITE, "Name change request rejected.");
	SendClientMessage(iReqID, COLOR_WHITE, "Your name change permission request has been {FF0000}rejected{FFFFFF}.");

	DeletePVar(playerid, "LNRequestID");
	DeletePVar(iReqID, "LNRequest");
	DeletePVar(iReqID, "RequestedName");
	return 1;
}

stock LNOwnerOnline(name[])
{
	format(szMiscArray, sizeof szMiscArray, "SELECT `Owner1`, `Owner2` FROM `lastnames` WHERE `Name`='%s'", name);
	mysql_query(MainPipeline, szMiscArray, true);

	new fields, rows;
	cache_get_data(rows, fields, MainPipeline);

	new Owner1[MAX_PLAYER_NAME];
	new iOwnerID = -1;
	new Owner2[MAX_PLAYER_NAME];
	new iOwner2ID = -1; 

	if(rows > 0) // Name exists
	{
		for(new row = 0; row < rows; row++)
		{
			cache_get_field_content(row, "Owner1", Owner1, MainPipeline);
			cache_get_field_content(row, "Owner2", Owner2, MainPipeline);
		}

		if(strlen(Owner1) > 0) GetPlayerID(Owner1, iOwnerID);
		if(strlen(Owner2) > 0) GetPlayerID(Owner2, iOwner2ID);
	}

	if(IsPlayerConnected(iOwnerID) && iOwnerID != -1 || IsPlayerConnected(iOwner2ID) && iOwner2ID != -1) return 1;

	return 0;
}

forward LastNameCheck(playerid, lastname[]);
public LastNameCheck(playerid, lastname[])
{
	new rows, fields;
	cache_get_data(rows, fields);

	if(rows == 0)
	{
		SetPVarString(playerid, "RestrictingLNOwner", "Nobody");
		SetPVarString(playerid, "RestrictingLNOwner2", "Nobody");
		SetPVarInt(playerid, "RestrictingLNType", 1);
		SendClientMessage(playerid, COLOR_GRAD3, "You are now restricting a last name. Select a menu option to edit it. When you're done, pick finish.");
		SetPVarString(playerid, "RestrictingLN", lastname);
		format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} Nobody\n{A9C4E4}Co-Owner:{FFFFFF} Nobody\n{A9C4E4}Name Type:{FFFFFF} Last\n\n{A9C4E4}Finish", lastname);
		ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
	}
	else return SendClientMessage(playerid, COLOR_GRAD2, "That last name is restricted. If you wish to delete it, use /lndelete.");
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_NEWNAME)
	{
		if(!response)
		{
			SendClientMessage(playerid, COLOR_GRAD2, "You have cancelled the last name restriction.");
			DeletePVar(playerid, "RestrictingLN");
			return 0;
		}

		switch(listitem)
		{
			case 0:
			{ 
				new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
				GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
				GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
				GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
				new type = GetPVarInt(playerid, "RestrictingLNType");
				if(type == 1) format(szType, sizeof szType, "Last");
				else format(szType, sizeof szType, "Middle");
				format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
				ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
			}
			case 1:
			{
				format(szMiscArray, sizeof szMiscArray, "{A9C4E4}You are now editing the {FFFFFF}owner{A9C4E4} of the name.\nInput their ID in the box below.");
				ShowPlayerDialog(playerid, DIALOG_EDITOWNER, DIALOG_STYLE_INPUT, "Last Name Restriction | Owner", szMiscArray, "Continue", "Cancel");
			}
			case 2:
			{
				format(szMiscArray, sizeof szMiscArray, "{A9C4E4}You are now editing the {FFFFFF}co-owner{A9C4E4} of the name.\nInput their ID in the box below.");
				ShowPlayerDialog(playerid, DIALOG_EDITOWNER2, DIALOG_STYLE_INPUT, "Last Name Restriction | Co-Owner", szMiscArray, "Continue", "Cancel");
			}
			case 3: ShowPlayerDialog(playerid, DIALOG_EDITTYPE, DIALOG_STYLE_LIST, "Last Name Restriction | Type", "Last Name\nMiddle Name", "Continue", "Cancel");

			case 4:
			{
				new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME];
				GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
				GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME);
				GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME);
				new type = GetPVarInt(playerid, "RestrictingLNType");
				RestrictLastName(playerid, szName, szOwner, szOwner2, type);
			}
		}
	}

	if(dialogid == DIALOG_EDITOWNER)
	{
		if(!response)
		{
			new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
			GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
			GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
			new type = GetPVarInt(playerid, "RestrictingLNType");
			if(type == 1) format(szType, sizeof szType, "Last");
			else format(szType, sizeof szType, "Middle");
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
			ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
			return 0;
		}
		
		new iOwner = strval(inputtext);
		if(IsPlayerConnected(iOwner))
		{
			SetPVarString(playerid, "RestrictingLNOwner", GetPlayerName_(iOwner));
			new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
			GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
			GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
			new type = GetPVarInt(playerid, "RestrictingLNType");
			if(type == 1) format(szType, sizeof szType, "Last");
			else format(szType, sizeof szType, "Middle");
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
			ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
		}
		else 
		{
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}You are now editing the {FFFFFF}owner{A9C4E4} of the name.\nInput their ID in the box below.\n{FF0000}Invalid player specified.");
			ShowPlayerDialog(playerid, DIALOG_EDITOWNER, DIALOG_STYLE_INPUT, "Last Name Restriction | Owner", szMiscArray, "Continue", "Cancel");
		}
	}

	if(dialogid == DIALOG_EDITOWNER2)
	{
		if(!response)
		{
			new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
			GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
			GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
			new type = GetPVarInt(playerid, "RestrictingLNType");
			if(type == 1) format(szType, sizeof szType, "Last");
			else format(szType, sizeof szType, "Middle");
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
			ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
			return 0;
		}
		
		new iOwner = strval(inputtext);
		if(IsPlayerConnected(iOwner))
		{
			SetPVarString(playerid, "RestrictingLNOwner2", GetPlayerName_(iOwner));
			new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
			GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
			GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
			new type = GetPVarInt(playerid, "RestrictingLNType");
			if(type == 1) format(szType, sizeof szType, "Last");
			else format(szType, sizeof szType, "Middle");
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
			ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
		}
		else 
		{
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}You are now editing the {FFFFFF}owner{A9C4E4} of the name.\nInput their ID in the box below.\n{FF0000}Invalid player specified.");
			ShowPlayerDialog(playerid, DIALOG_EDITOWNER, DIALOG_STYLE_INPUT, "Last Name Restriction | Owner", szMiscArray, "Continue", "Cancel");
		}
	}

	if(dialogid == DIALOG_EDITTYPE)
	{
		if(!response)
		{
			new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
			GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
			GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
			new type = GetPVarInt(playerid, "RestrictingLNType");
			if(type == 1) format(szType, sizeof szType, "Last");
			else format(szType, sizeof szType, "Middle");
			format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
			ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
			return 0;
		}
		
		SetPVarInt(playerid, "RestrictingLNType", listitem + 1);
		new szName[MAX_PLAYER_NAME], szOwner[MAX_PLAYER_NAME], szOwner2[MAX_PLAYER_NAME], szType[15];
		GetPVarString(playerid, "RestrictingLN", szName, MAX_PLAYER_NAME);
		GetPVarString(playerid, "RestrictingLNOwner", szOwner, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner[i] == '_') szOwner[i] = ' ';
		GetPVarString(playerid, "RestrictingLNOwner2", szOwner2, MAX_PLAYER_NAME); for(new i = 0; i < MAX_PLAYER_NAME; i++) if(szOwner2[i] == '_') szOwner2[i] = ' ';
		new type = GetPVarInt(playerid, "RestrictingLNType");
		if(type == 1) format(szType, sizeof szType, "Last");
		else format(szType, sizeof szType, "Middle");
		format(szMiscArray, sizeof szMiscArray, "{A9C4E4}Name:{FFFFFF} %s\n{A9C4E4}Owner:{FFFFFF} %s\n{A9C4E4}Co-Owner:{FFFFFF} %s\n{A9C4E4}Name Type:{FFFFFF} %s\n\n{A9C4E4}Finish", szName, szOwner, szOwner2, szType);
		ShowPlayerDialog(playerid, DIALOG_NEWNAME, DIALOG_STYLE_LIST, "Last Name Restriction | Menu", szMiscArray, "Continue", "Cancel");
	}
	/*if(dialogid == DIALOG_OWNER1)
	{
		if(!response)
		{
			SendClientMessage(playerid, COLOR_GRAD2, "You have cancelled the last name restriction.");
			DeletePVar(playerid, "RestrictingLN");
			return 0;
		}
		
		new iOwner = strval(inputtext);
		if(IsPlayerConnected(iOwner))
		{
			format(szMiscArray, sizeof szMiscArray, "Owner: {FFFFFF}%s{A9C4E4} | Co-Owner: {FFFFFF}N/A{A9C4E4}\nIs there a co-owner of this name?", GetPlayerNameEx(iOwner));
			ShowPlayerDialog(playerid, DIALOG_OWNER2_CONFIRM, DIALOG_STYLE_MSGBOX, "Last Name Restriction | Co-Owner", szMiscArray, "Yes", "No");
			SetPVarString(playerid, "RestrictedLNOwner", GetPlayerName_(iOwner));
		}
		else 
		{
			new szLN[MAX_PLAYER_NAME];
			GetPVarString(playerid, "RestrictingLN", szLN, MAX_PLAYER_NAME);
			format(szMiscArray, sizeof szMiscArray, "You are now restricting the last name, '{FFFFFF}%s{A9C4E4}'.\nPlease enter the player ID of the {FFFFFF}owner{A9C4E4} to continue.\n{B54747}Invalid player ID specified.", szLN);
			ShowPlayerDialog(playerid, DIALOG_OWNER1, DIALOG_STYLE_INPUT, "Last Name Restriction | Owner", szMiscArray, "Continue", "Cancel");
		}
	}


	if(dialogid == DIALOG_OWNER2_CONFIRM)
	{
		if(response) // Yes.
		{
			new szLN[MAX_PLAYER_NAME];
			GetPVarString(playerid, "RestrictingLN", szLN, MAX_PLAYER_NAME);
			format(szMiscArray, sizeof szMiscArray, "You are now restricting the last name, '{FFFFFF}%s{A9C4E4}'.\nPlease enter the player ID of the {FFFFFF}co-owner{A9C4E4} to continue.\n", szLN);
			ShowPlayerDialog(playerid, DIALOG_OWNER2, DIALOG_STYLE_INPUT, "Last Name Restriction | Co-Owner", szMiscArray, "Finish", "Cancel");
		}
		else // No.
		{
			new szOwner[MAX_PLAYER_NAME];
			new szLN[MAX_PLAYER_NAME];
			GetPVarString(playerid, "RestrictingLN", szLN, MAX_PLAYER_NAME);
			GetPVarString(playerid, "RestrictedLNOwner", szOwner, MAX_PLAYER_NAME);

			RestrictLastName(playerid, szLN, szOwner, "");
		}	
	}

	if(dialogid == DIALOG_OWNER2)
	{
		if(!response)
		{
			SendClientMessage(playerid, COLOR_GRAD2, "You have cancelled the last name restriction.");
			DeletePVar(playerid, "RestrictingLN");
			DeletePVar(playerid, "RestrictedLNOwner");
			return 0;
		}
		
		new iOwner = strval(inputtext);
		new szOwnerMain[MAX_PLAYER_NAME];
		new szLN[MAX_PLAYER_NAME];
		GetPVarString(playerid, "RestrictedLNOwner", szOwnerMain, MAX_PLAYER_NAME);
		GetPVarString(playerid, "RestrictingLN", szLN, MAX_PLAYER_NAME);

		if(IsPlayerConnected(iOwner))
		{
			SendClientMessage(playerid, COLOR_WHITE, "Restricting last name...");
			RestrictLastName(playerid, szLN, szOwnerMain, GetPlayerName_(iOwner));
		}
		else 
		{
			GetPVarString(playerid, "RestrictingLN", szLN, MAX_PLAYER_NAME);
			format(szMiscArray, sizeof szMiscArray, "You are now restricting the last name, '{FFFFFF}%s{A9C4E4}'.\nPlease enter the player ID of the {FFFFFF}co-owner{A9C4E4} to continue.\n", szLN);
			ShowPlayerDialog(playerid, DIALOG_OWNER2, DIALOG_STYLE_INPUT, "Last Name Restriction | Co-Owner", szMiscArray, "Finish", "Cancel");
		}
	}
	*/
	return 1;
}

stock RestrictLastName(playerid, lastname[], owner1[], owner2[], type)
{
	format(szMiscArray, sizeof szMiscArray, "INSERT INTO `lastnames` (`Name`, `Owner1`, `Owner2`, `RestrictedBy`, `Type`) VALUES('%s', '%s', '%s', '%s', %d)", g_mysql_ReturnEscaped(lastname, MainPipeline), g_mysql_ReturnEscaped(owner1, MainPipeline), g_mysql_ReturnEscaped(owner2, MainPipeline), GetPlayerName_(playerid), type);

	mysql_function_query(MainPipeline, szMiscArray, true, "LastNameRestricted", "dsssd", playerid, lastname, owner1, owner2, type);
}

forward LastNameRestricted(playerid, lastname[], owner1[], owner2[], type);
public LastNameRestricted(playerid, lastname[], owner1[], owner2[], type)
{
	SendClientMessage(playerid, COLOR_WHITE, "Last name restricted successfully.");
	new szType[15]; if(type == 1) format(szType, sizeof szType, "Last"); else format(szType, sizeof szType, "Middle");
	format(szMiscArray, sizeof szMiscArray, "%s restricted %s. Owner: %s | Co-Owner: %s | Type: %s", GetPlayerNameEx(playerid), lastname, owner1, owner2, szType);
	Log("logs/lastnames.log", szMiscArray);
	return 1;
}
