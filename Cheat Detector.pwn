// Anti-Cheat - One RP

#include <a_samp>
#include <a_mysql> // MySQL R39-4

#define MSQL_HOST       ""
#define MYSQL_DB        ""
#define MYSQL_USER      ""
#define MYSQL_PASS      ""
new MySQL;

enum{
	ANTICHEAT_SETTINGS,
	ANTICHEAT_EDIT_CODE
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
	// Anti Cheat
    if(dialogid == ANTICHEAT_SETTINGS)
	{
		if(!response)
	    {
	        pAntiCheatSettingsPage{playerid} = 0;
	        return 1; // ????????? ??????
	    }

	    if (!strcmp(inputtext, AC_DIALOG_NEXT_PAGE_TEXT))
	    {
	        pAntiCheatSettingsPage{playerid}++;
	    }
	    else if (!strcmp(inputtext, AC_DIALOG_PREVIOUS_PAGE_TEXT))
	    {
	        pAntiCheatSettingsPage{playerid}--;
	    }
	    else // ???? ????? ?????? ?????-???? ?? ????? ????-????
	    {
	        pAntiCheatSettingsEditCodeId[playerid] = pAntiCheatSettingsMenuListData[playerid][listitem];
	        return ShowPlayer_AntiCheatEditCode(playerid, pAntiCheatSettingsEditCodeId[playerid]);
	    }
	    return ShowPlayer_AntiCheatSettings(playerid);
	}
	if(dialogid == ANTICHEAT_EDIT_CODE)
	{
		if (!response) // ???? ????? ?????? ??????
	    {
	        pAntiCheatSettingsEditCodeId[playerid] = -1;
	        return ShowPlayer_AntiCheatSettings(playerid);
	    }

	    new
	        item = pAntiCheatSettingsEditCodeId[playerid];

	    if (AC_CODE_TRIGGER_TYPE[item] == listitem)
	        return ShowPlayer_AntiCheatSettings(playerid);

	    if (AC_CODE_TRIGGER_TYPE[item] == AC_CODE_TRIGGER_TYPE_DISABLED && listitem != AC_CODE_TRIGGER_TYPE_DISABLED)
	        EnableAntiCheat(item, 1);

	    AC_CODE_TRIGGER_TYPE[item] = listitem;

	    new
	        sql_query[101 - 4 + 1 + 2];

	    format(sql_query, sizeof(sql_query), "UPDATE "AC_TABLE_SETTINGS" SET `"AC_TABLE_FIELD_TRIGGER"` = '%d' WHERE `"AC_TABLE_FIELD_CODE"` = '%d'",
	        listitem,
	        item);

	    mysql_function_query(MySQL, sql_query, false, "", ""); // ?????????? ?????? ? ???? ??????
	    return ShowPlayer_AntiCheatSettings(playerid); // ?????????? ??????? ???? ???????? ????-????
	}
    return 1;
}

//============================================================================//
// ANTICHEAT
//============================================================================//
#define AC_TABLE_SETTINGS "anticheat_settings"
#define AC_TABLE_FIELD_CODE "ac_code" 
#define AC_TABLE_FIELD_TRIGGER "ac_code_trigger_type" 
#define AC_MAX_CODES 53 
#define AC_MAX_CODE_LENGTH (3 + 1) 
#define AC_MAX_CODE_NAME_LENGTH (33 + 1) 
#define AC_MAX_TRIGGER_TYPES 3 
#define AC_MAX_TRIGGER_TYPE_NAME_LENGTH (8 + 1) 
#define AC_GLOBAL_TRIGGER_TYPE_PLAYER 0
#define AC_GLOBAL_TRIGGER_TYPE_IP 1
#define AC_CODE_TRIGGER_TYPE_DISABLED 0 
#define AC_CODE_TRIGGER_TYPE_WARNING 1 
#define AC_CODE_TRIGGER_TYPE_KICK 2 
#define AC_TRIGGER_ANTIFLOOD_TIME 20 
#define AC_MAX_CODES_ON_PAGE 15
#define AC_DIALOG_NEXT_PAGE_TEXT ">>> Next page" 
#define AC_DIALOG_PREVIOUS_PAGE_TEXT "<<< Previous page"


new AC_CODE[AC_MAX_CODES][AC_MAX_CODE_LENGTH] =
{
    "000",
    "001",
    "002",
    "003",
    "004",
    "005",
    "006",
    "007",
    "008",
    "009",
    "010",
    "011",
    "012",
    "013",
    "014",
    "015",
    "016",
    "017",
    "018",
    "019",
    "020",
    "021",
    "022",
    "023",
    "024",
    "025",
    "026",
    "027",
    "028",
    "029",
    "030",
    "031",
    "032",
    "033",
    "034",
    "035",
    "036",
    "037",
    "038",
    "039",
    "040",
    "041",
    "042",
    "043",
    "044",
    "045",
    "046",
    "047",
    "048",
    "049",
    "050",
    "051",
    "052"
};
new AC_CODE_NAME[AC_MAX_CODES][AC_MAX_CODE_NAME_LENGTH] =
{
    {"Air Break (on foot)"},
    {"Air Break (in vehicle)"},
    {"Teleport (on foot)"},
    {"Teleport (in vehicle)"},
    {"Teleport (into/between vehicles)"},
    {"Teleport (vehicle to player)"},
    {"Teleport (pickups)"},
    {"Fly Hack (on foot)"},
    {"Fly Hack (in vehicle)"},
    {"Speed Hack (on foot)"},
    {"Speed Hack (in vehicle)"},
    {"Health Hack (in vehicle)"},
    {"Health Hack (onfoot)"},
    {"Armour Hack"},
    {"Money Hack"},
    {"Weapon Hack"},
    {"Ammo Hack (add)"},
    {"Ammo Hack (infinite)"},
    {"Special Actions Hack"},
    {"GodMode from Bullets (on foot)"},
    {"GodMode from Bullets (in vehicle)"},
    {"Invisible Hack"},
    {"Lagcomp-spoof"},
    {"Tuning Hack"},
    {"Parkour Mod"},
    {"Quick Turn"},
    {"Rapid Fire"},
    {"FakeSpawn"},
    {"FakeKill"},
    {"Pro Aim"},
    {"CJ Run"},
    {"CarShot"},
    {"CarJack"},
    {"Unfreeze"},
    {"AFK Ghost"},
    {"Full Aiming"},
    {"Fake NPC"},
    {"Reconnect"},
    {"High Ping"},
    {"Dialog Hack"},
    {"Sandbox"},
    {"Invalid Version"},
    {"RCON Hack"},
    {"Tuning Crasher"},
    {"Invalid Seat Crasher"},
    {"Dialog Crasher"},
    {"Attached Object Crasher"},
    {"Weapon Crasher"},
    {"Connects to One Slot"},
    {"Flood Callback Functions"},
    {"Flood Change Seat"},
    {"DDOS"},
    {"NOP's"}
};
new AC_TRIGGER_TYPE_NAME[AC_MAX_TRIGGER_TYPES][AC_MAX_TRIGGER_TYPE_NAME_LENGTH] =
{
    {"Disabled"},
    {"Warning"},
    {"Kick"}
};
new
    AC_CODE_TRIGGER_TYPE[AC_MAX_CODES],
    AC_CODE_TRIGGERED_COUNT[AC_MAX_CODES] = {0, ...};
new
    pAntiCheatLastCodeTriggerTime[MAX_PLAYERS][AC_MAX_CODES],
    pAntiCheatSettingsPage[MAX_PLAYERS char],
    pAntiCheatSettingsMenuListData[MAX_PLAYERS][AC_MAX_CODES_ON_PAGE],
    pAntiCheatSettingsEditCodeId[MAX_PLAYERS];


public OnGameModeInit()
{
    MySQL = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DB);
    if(mysql_errno(MySQL)){
        print("We cannot connect you to the database. Please double check your mysql config and try again");
        SendRconCommand("exit");
        return 0;
    }
    else{
        print("Connection to MySQL successful");
    }

	printf("[AntiCheat] Loading data from database...");
    mysql_function_query(MySQL, "SELECT * FROM `anticheat_settings`", true, "UploadAntiCheat", "");
    return 1;
}

forward OnCheatDetected(playerid, ip_address[], type, code);
public OnCheatDetected(playerid, ip_address[], type, code)
{
    if (type == AC_GLOBAL_TRIGGER_TYPE_PLAYER)
    {
        switch(code)
        {
            case 5, 6, 11, 22:
            {
                return 1;
            }
            case 32: // CarJack
            {
                new
                    Float:x,
                    Float:y,
                    Float:z;

                AntiCheatGetPos(playerid, x, y, z);
                return SetPlayerPos(playerid, x, y, z);
            }
            default:
            {
                if (gettime() - pAntiCheatLastCodeTriggerTime[playerid][code] < AC_TRIGGER_ANTIFLOOD_TIME)
                    return 1;

                pAntiCheatLastCodeTriggerTime[playerid][code] = gettime();
                AC_CODE_TRIGGERED_COUNT[code]++;

                new trigger_type = AC_CODE_TRIGGER_TYPE[code];

                switch(trigger_type)
                {
                    case AC_CODE_TRIGGER_TYPE_DISABLED: return 1;
                    case AC_CODE_TRIGGER_TYPE_WARNING:
                    {
                    	new str[128];
                    	format(str, sizeof(str),"["ANTICHEAT_NAME"]: %s[%d] suspected of using cheat programs: %s [code: %03d].", GetUserName(playerid), playerid, AC_CODE_NAME[code], code);
                    	SendAdminMessage(COLOR_RED, str);
                    	//SendMessage(playerid, -1, "You were suspected of using cheat programs: %s [code: %03d].", AC_CODE_NAME[code], code);
                    	new szString[128];
                    	format(szString, sizeof(szString), "%s[%d] suspected of using cheat programs: %s [code: %03d].", GetUserName(playerid), playerid, AC_CODE_NAME[code], code);
                    }
                    case AC_CODE_TRIGGER_TYPE_KICK:
                    {
                    	new str[128];
                    	format(str, sizeof(str),"["ANTICHEAT_NAME"]: %s[%d] was kicked on suspicion of using cheat programs: %s [code: %03d].", GetUserName(playerid), playerid, AC_CODE_NAME[code], code);
                    	SendAdminMessage(COLOR_RED, str);
                        SendMessage(playerid, -1, "You were kicked on suspicion of using cheats(%s).", AC_CODE_NAME[code], code);
                        AntiCheatKickWithDesync(playerid, code);
                    }
                }
            }
        }
    }
    else // AC_GLOBAL_TRIGGER_TYPE_IP
    {
        AC_CODE_TRIGGERED_COUNT[code]++;
        new str[128];
        format(str, sizeof(str),"<AC-BAN-IP> IP address %s was blocked: %s [code: %03d].", ip_address, AC_CODE_NAME[code], code);
        SendAdminMessage(COLOR_RED, str);
        BlockIpAddress(ip_address, 0);
    }
    return 1;
}

stock ShowPlayer_AntiCheatSettings(playerid)
{
    static
        dialog_string[42 + 19 - 8 + (AC_MAX_CODE_LENGTH + AC_MAX_CODE_NAME_LENGTH + AC_MAX_TRIGGER_TYPE_NAME_LENGTH + 10)*AC_MAX_CODES_ON_PAGE] = EOS;

    new
        triggeredCount = 0,
        page = pAntiCheatSettingsPage{playerid},
        next = 0,
        index = 0;

    dialog_string = "Name\tPunishment\tNumber of Positives\n";

    for(new i = 0; i < AC_MAX_CODES; i++)
    {
        if(i >= (page * AC_MAX_CODES_ON_PAGE) && i < (page * AC_MAX_CODES_ON_PAGE) + AC_MAX_CODES_ON_PAGE)
            next++;

        if(i >= (page - 1) * AC_MAX_CODES_ON_PAGE && i < ((page - 1) * AC_MAX_CODES_ON_PAGE) + AC_MAX_CODES_ON_PAGE)
        {
            triggeredCount = AC_CODE_TRIGGERED_COUNT[i];

            format(dialog_string, sizeof(dialog_string), "%s[%s] %s\t%s\t%d\n",
                dialog_string,
                AC_CODE[i],
                AC_CODE_NAME[i],
                AC_TRIGGER_TYPE_NAME[AC_CODE_TRIGGER_TYPE[i]],
                triggeredCount);

            pAntiCheatSettingsMenuListData[playerid][index++] = i;
        }
    }

    if(next)
        strcat(dialog_string, ""AC_DIALOG_NEXT_PAGE_TEXT"\n");

    if(page > 1)
        strcat(dialog_string, AC_DIALOG_PREVIOUS_PAGE_TEXT);

    return ShowPlayerDialog(playerid, ANTICHEAT_SETTINGS, DIALOG_STYLE_TABLIST_HEADERS, "Anticheat Settings", dialog_string, "Select", "Cancel");
}

stock ShowPlayer_AntiCheatEditCode(playerid, code)
{
    new
        dialog_header[22 - 4 + AC_MAX_CODE_LENGTH + AC_MAX_CODE_NAME_LENGTH],
        dialog_string[AC_MAX_TRIGGER_TYPE_NAME_LENGTH*AC_MAX_TRIGGER_TYPES];

    format(dialog_header, sizeof(dialog_header), "Code: %s | Name: %s", AC_CODE[code], AC_CODE_NAME[code]);

    for(new i = 0; i < AC_MAX_TRIGGER_TYPES; i++)
    {
        strcat(dialog_string, AC_TRIGGER_TYPE_NAME[i]);

        if(i + 1 != AC_MAX_TRIGGER_TYPES)
            strcat(dialog_string, "\n");
    }

    return ShowPlayerDialog(playerid, ANTICHEAT_EDIT_CODE, DIALOG_STYLE_LIST, dialog_header, dialog_string, "Select", "Return");
}


forward UploadAntiCheat();
public UploadAntiCheat()
{
    new rows = cache_num_rows(), tick = GetTickCount();

	if(!rows)
	{
        print("[MySQL]: Anti-cheat settings were not found in the database. Loading of the mod stopped - configure anti-cheat. ");
        //return GameModeExit();
    }

    for(new i = 0; i < AC_MAX_CODES; i++)
    {
        AC_CODE_TRIGGER_TYPE[i] = cache_get_field_content_int(i, "ac_code_trigger_type");

        if(AC_CODE_TRIGGER_TYPE[i] == AC_CODE_TRIGGER_TYPE_DISABLED) {
            EnableAntiCheat(i, 0);
        }
    }

    new mes[128];
    format(mes, sizeof(mes), "[AntiCheat]: Anti-cheat settings loaded successfully (loaded: %i). Time: %i Ð¼Ñÿ.", rows, GetTickCount() - tick);
    print(mes);

    return 1;
}


CMD:anticheats(playerid, params[])
{
    //You may put your administration code here.


    pAntiCheatSettingsPage{playerid} = 1;
    return ShowPlayer_AntiCheatSettings(playerid);
}