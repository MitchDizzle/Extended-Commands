#pragma semicolon 1
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION "1.2.0"
#include "extcommands/stocks.sp"
#pragma newdecls required
public Plugin myinfo = {
	name = "Extended Commands",
	author = "Mitch.",
	description = "Additional admin commands.",
	version = PLUGIN_VERSION,
	url = "http://dizzle.wtf/"
};

public void OnPluginStart() {
	CreateConVar("sm_extcommands_version", PLUGIN_VERSION, "Extended Commands Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	LoadTranslations("common.phrases");
	LoadTranslations("extcommands.phrases");
	
	gGame = GetEngineVersion();
	
	SetupCommands();
}

/* Commands */
#define MAXCOMMANDS 20
public void SetupCommands() {
	RegAdminCmd("sm_respawn", Command_Spawn, ADMFLAG_KICK); //Added 2-17-2016
	RegAdminCmd("sm_spawn", Command_Spawn, ADMFLAG_KICK);

	RegAdminCmd("sm_health", Command_Health, ADMFLAG_KICK); //Added 2-17-2016
	RegAdminCmd("sm_healths", Command_Health, ADMFLAG_KICK);
	RegAdminCmd("sm_hp", Command_Health, ADMFLAG_KICK);

	if(gGame == Engine_CSGO || gGame == Engine_CSS) {
		RegAdminCmd("sm_armor", Command_Armor, ADMFLAG_KICK); //Added 2-17-2016
		RegAdminCmd("sm_armors", Command_Armor, ADMFLAG_KICK);

		RegAdminCmd("sm_account", Command_Account, ADMFLAG_KICK); //Added 2-22-2016
		RegAdminCmd("sm_cash", Command_Account, ADMFLAG_KICK);
		RegAdminCmd("sm_money", Command_Account, ADMFLAG_KICK);
	}

	RegAdminCmd("sm_team", Command_Team, ADMFLAG_KICK); //Added 2-22-16
	RegAdminCmd("sm_changeteam", Command_Team, ADMFLAG_KICK);
	RegAdminCmd("sm_spec", Command_Team, ADMFLAG_KICK);

	LoadWeaponFile();
	RegAdminCmd("sm_give", Command_Give, ADMFLAG_KICK); //Added 2-24-16
	RegAdminCmd("sm_fakegive", Command_Give, ADMFLAG_KICK);

	RegAdminCmd("sm_melee", Command_Melee, ADMFLAG_KICK); //Added 2-24-16
	RegAdminCmd("sm_knife", Command_Melee, ADMFLAG_KICK);

	RegAdminCmd("sm_disarm", Command_Disarm, ADMFLAG_KICK); //Added 2-24-16
	RegAdminCmd("sm_strip", Command_Disarm, ADMFLAG_KICK);

	RegAdminCmd("sm_speed", Command_Speed, ADMFLAG_KICK); //Added 2-24-16

	RegAdminCmd("sm_teleport", Command_Teleport, ADMFLAG_KICK); //Added 2-25-16
	RegAdminCmd("sm_tele", Command_Teleport, ADMFLAG_KICK);
	RegAdminCmd("sm_tp", Command_Teleport, ADMFLAG_KICK);

	RegAdminCmd("sm_frag", Command_FDA, ADMFLAG_KICK); //Added 2-26-16
	RegAdminCmd("sm_frags", Command_FDA, ADMFLAG_KICK);
	RegAdminCmd("sm_kills", Command_FDA, ADMFLAG_KICK);
	RegAdminCmd("sm_death", Command_FDA, ADMFLAG_KICK);
	RegAdminCmd("sm_deaths", Command_FDA, ADMFLAG_KICK);
	//RegAdminCmd("sm_assist", Command_FDA, ADMFLAG_KICK);
	//RegAdminCmd("sm_assists", Command_FDA, ADMFLAG_KICK);
	
	RegAdminCmd("sm_launch", Command_PL, ADMFLAG_KICK); //Added 2-26-16
	RegAdminCmd("sm_push", Command_PL, ADMFLAG_KICK);
	RegAdminCmd("sm_shove", Command_PL, ADMFLAG_KICK);
	
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_KICK); //Added 2-26-16
	RegAdminCmd("sm_restartround", Command_EndRound, ADMFLAG_KICK);
	RegAdminCmd("sm_rr", Command_EndRound, ADMFLAG_KICK);
	
	RegAdminCmd("sm_execute", Command_Execute, ADMFLAG_KICK); //Added 2-26-16
	RegAdminCmd("sm_exec", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_fakeexec", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_fexec", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_sexecute", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_sexec", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_sfakeexec", Command_Execute, ADMFLAG_KICK);
	RegAdminCmd("sm_sfexec", Command_Execute, ADMFLAG_KICK);
	
	RegAdminCmd("sm_clantag", Command_ClanTag, ADMFLAG_KICK); //Added 2-26-16
	RegAdminCmd("sm_tag", Command_ClanTag, ADMFLAG_KICK);
	RegAdminCmd("sm_sclantag", Command_ClanTag, ADMFLAG_KICK);
	RegAdminCmd("sm_stag", Command_ClanTag, ADMFLAG_KICK);
	
	RegAdminCmd("sm_projectilefix", Command_ProjectileFix, ADMFLAG_KICK); //Added 3-21-16
	RegAdminCmd("sm_projectilesfix", Command_ProjectileFix, ADMFLAG_KICK);
	RegAdminCmd("sm_fixprojectile", Command_ProjectileFix, ADMFLAG_KICK);
	RegAdminCmd("sm_fixprojectiles", Command_ProjectileFix, ADMFLAG_KICK);
	RegAdminCmd("sm_pf", Command_ProjectileFix, ADMFLAG_KICK);

	RegAdminCmd("sm_extend", Command_Extend, ADMFLAG_KICK); //Added 3-21-16

	RegAdminCmd("sm_botkick", Command_BotKick, ADMFLAG_KICK); //Added 3-21-16

	RegAdminCmd("sm_drop", Command_Drop, ADMFLAG_KICK); //Added 3-21-16
}

//== Respawn =============================================================
public Action Command_Spawn(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_respawn", arg1, "%t", "Respawn usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
//
	bool force = (args > 1) ? true : false;
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i]) || GetClientTeam(clientList[i]) <= 1) continue;
		extRespawnPlayer(clientList[i], force);
	}
//
	CRemoveColors(targetName, sizeof(targetName));
	if(multiLang) {
		ShowActivityExt(client, "%t", "Respawn target", targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Respawn target", "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

public void extRespawnPlayer(int client, bool force) {
	if(force || !IsPlayerAlive(client)) {
		exRespawnPlayer(client);
	}
}

//== Health ==============================================================
public Action Command_Health(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 2) {
		ReplyToCommandExt(client, "sm_health", arg1, "%t", "Health usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	GetCmdArg(2, arg1, sizeof(arg1));
	bool add = (arg1[0] != '-') ? (arg1[0] != '+') ? false : true : true;
	int hp = StringToInt(arg1);
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extHealth(clientList[i], hp, add);
	}
//
	if(multiLang) {
		if(add) {
			ShowActivityExt(client, "%t", "Health target add", hp, targetName);
		} else {
			ShowActivityExt(client, "%t", "Health target set", targetName, hp);
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		if(add) {
			ShowActivityExt(client, "%t", "Health target add", hp, "_s", targetName);
		} else {
			ShowActivityExt(client, "%t", "Health target set", "_s", targetName, hp);
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

public void extHealth(int client, int amount, bool add) {
	int hp = add ? GetClientHealth(client) : 0;
	hp = hp + amount;
	if(hp < 0) {
		ForcePlayerSuicide(client);
		return;
	}
	SetEntityHealth(client, hp);
}

//== Armor ===============================================================
public Action Command_Armor(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 2) {
		ReplyToCommandExt(client, "sm_armor", arg1, "%t", "Armor usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
//
	GetCmdArg(2, arg1, sizeof(arg1));
	bool add = (arg1[0] != '-') ? (arg1[0] != '+') ? false : true : true;
	int armor = StringToInt(arg1);
	bool helmet = args == 3;
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extArmor(clientList[i], armor, helmet, add);
	}
//
	CRemoveColors(targetName, sizeof(targetName));
	if(multiLang) {
		if(add) {
			ShowActivityExt(client, "%t", "Armor target add", armor, targetName);
		} else {
			ShowActivityExt(client, "%t", "Armor target set", targetName, armor);
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		if(add) {
			ShowActivityExt(client, "%t", "Armor target add", armor, "_s", targetName);
		} else {
			ShowActivityExt(client, "%t", "Armor target set", "_s", targetName, armor);
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

public void extArmor(int client, int amount, bool helmet, bool add) {
	int armor = add ? exGetClientArmor(client) : 0;
	exSetClientArmor(client, armor + amount, helmet);
}

//== Account =============================================================
public Action Command_Account(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 2) {
		ReplyToCommandExt(client, "sm_account", arg1, "%t", "Account usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
//
	GetCmdArg(2, arg1, sizeof(arg1));
	bool add = (arg1[0] != '-') ? (arg1[0] != '+') ? false : true : true;
	int account = StringToInt(arg1);
	if(account > 16000) {
		account = 16000;
	} else if(account < 0) {
		account = 0;
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extAccount(clientList[i], account, add);
	}
//
	CRemoveColors(targetName, sizeof(targetName));
	if(multiLang) {
		if(add) {
			ShowActivityExt(client, "%t", "Account target add", account, targetName);
		} else {
			ShowActivityExt(client, "%t", "Account target set", targetName, account);
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		if(add) {
			ShowActivityExt(client, "%t", "Account target add", account, "_s", targetName);
		} else {
			ShowActivityExt(client, "%t", "Account target set", "_s", targetName, account);
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

public void extAccount(int client, int amount, bool add) {
	int account = add ? exGetClientAccount(client) : 0;
	exSetClientAccount(client, account + amount);
}

//== Team ================================================================
public Action Command_Team(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_team", arg1, "%t", "Team usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
	if(!multiLang) CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
//
	if (args >= 2) {
		GetCmdArg(2, arg1, sizeof(arg1));
	}
	int team = GetTeamFromString(arg1);
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extTeam(clientList[i], team, false);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Team target", targetName, transTeam[team]);
		LogActionExt(client, -1, argString, targetName);
	} else {
		ShowActivityExt(client, "%t", "Team target", "_s", targetName, transTeam[team]);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}
public int GetTeamFromString(char[] strTeam) {
	if(StrEqual(strTeam, "3", false) || 
	   StrEqual(strTeam, "counter-terrorist", false) || 
	   StrEqual(strTeam, "ct", false) || 
	   StrEqual(strTeam, "c-t", false) ||
	   StrEqual(strTeam, "blue", false)) {
		return 3;
	} else if (StrEqual(strTeam, "2", false) || 
	   StrEqual(strTeam, "terrorist", false) || 
	   StrEqual(strTeam, "t", false) || 
	   StrEqual(strTeam, "red", false)) {
		return 2;
	}
	return 1;
}

//== Team ================================================================
StringMap WeaponTrie;
public Action Command_Give(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_give", arg1, "%t", "Give usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	bool fakeGive = StrContains(arg1, "fake", false)>=0 ? true : false;
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	GetCmdArg(2, arg1, sizeof(arg1));
	if(!fakeGive) {
		//bool multItems = StrContains(arg1, ",", false)>=0 ? true : false;
		char itemBuffer[6][24];
		int itemCnt = ExplodeString(arg1, ",", itemBuffer, 6, 24);
		for(int i = 0; i < clientCount; i++) {
			if(!IsClientInGame(clientList[i]) || !IsPlayerAlive(clientList[i])) continue;
			if(itemCnt > 0) {
				for(int item = 0; item <= itemCnt; item++) {
					extGive(clientList[i], itemBuffer[item]);
				}
			} else {
				extGive(clientList[i], arg1);
			}
		}
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Give target", arg1, targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Give target", arg1, "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}
public void LoadWeaponFile() {
	SMCParser SMC = SMC_CreateParser(); 
	SMC_SetReaders(SMC, NewSection, KeyValue, EndSection); 
	char sPaths[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPaths, sizeof(sPaths),"configs/extendedcommands/weapons.txt");
	WeaponTrie = CreateTrie();
	SMC_ParseFile(SMC, sPaths);
	delete SMC;
}
public SMCResult NewSection(SMCParser smc, const char[] name, bool opt_quotes) { }
public SMCResult EndSection(SMCParser smc) { }
public SMCResult KeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	SetTrieString(WeaponTrie, key, key, false);
	SetTrieString(WeaponTrie, value, key, false);
}
public void extGive(int client, char[] item) {
	char exactWeapon[100];
	if(GetTrieString(WeaponTrie, item, exactWeapon, sizeof(exactWeapon))) {
		GivePlayerItem(client, exactWeapon);
	}
}

//== Melee ===============================================================
public Action Command_Melee(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_melee", arg1, "%t", "Melee usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extMelee(clientList[i]);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Melee target", targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Melee target", "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== Disarm ==============================================================
public Action Command_Disarm(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_disarm", arg1, "%t", "Disarm usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extDisarm(clientList[i], false);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Disarm target", targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Disarm target", "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== Speed ===============================================================
public Action Command_Speed(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_speed", arg1, "%t", "Speed usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	GetCmdArg(2, arg1, sizeof(arg1));
	float speed = StringToFloat(arg1);
	if(speed > 10.0) {
		speed = 10.0;
	} else if(speed < 0.0) {
		speed = 0.0;
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extSpeed(clientList[i], speed);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Speed target", targetName, speed);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Speed target", "_s", targetName, speed);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== Teleport ============================================================
/*
Teleport <target> - Teleport <target> to client's aim
Teleport <target> <player> - Teleport <target> to <player>
Teleport <target> <player> <z>- Teleport <target> to <player> with [z] offset
Teleport <target> <x> <y> <z>- Teleport <target> to <x>, <y>, <z>
*/
public Action Command_Teleport(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_teleport", arg1, "%t", "Teleport usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	float fTeleLoc[3];
	int player = -1;
	if(args == 1) { //Teleport to aim
		extTraceEye(client, fTeleLoc);
	} else if(args <= 3) { //Teleport to player (or with z offset)
		GetCmdArg(2, arg1, sizeof(arg1));
		player = FindTarget(client, arg1, false, false);
		if(player == -1) {
			ReplyToTargetError(client, COMMAND_TARGET_NONE);
			return Plugin_Handled;
		}
		GetClientAbsOrigin(player, fTeleLoc);
		if(args == 3) { //Add Z Offset
			GetCmdArg(3, arg1, sizeof(arg1));
			fTeleLoc[2] += StringToFloat(arg1);
		}
	} else if(args == 4) { //Teleport to position.
		for(int i=0; i < 3; i++) {
			GetCmdArg(i+2, arg1, sizeof(arg1));
			fTeleLoc[i] = StringToFloat(arg1);
		}
	}

	if(GetVectorDistance(fTeleLoc, EmptyVec) <= 0.1) {
		ReplyToCommand(client, "%t", "Teleport invalid location");
		return Plugin_Handled;
	}

	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		TeleportEntity(clientList[i], fTeleLoc, NULL_VECTOR, NULL_VECTOR);
	}
//
	if(multiLang) {
		if(player != -1) {
			char playerName[MAX_TARGET_LENGTH+8];
			GetClientName(player, playerName, sizeof(playerName));
			CTeamColorize(GetClientTeam(player), playerName, sizeof(playerName));
			ShowActivityExt(client, "%t", "Teleport target player", targetName, playerName);
		} else {
			ShowActivityExt(client, "%t", "Teleport target pos", targetName, fTeleLoc[0], fTeleLoc[1], fTeleLoc[2]);
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		if(player != -1) {
			char playerName[MAX_TARGET_LENGTH+8];
			GetClientName(player, playerName, sizeof(playerName));
			CTeamColorize(GetClientTeam(player), playerName, sizeof(playerName));
			ShowActivityExt(client, "%t", "Teleport target player", "_s", targetName, playerName);
		} else {
			ShowActivityExt(client, "%t", "Teleport target pos", "_s", targetName, fTeleLoc[0], fTeleLoc[1], fTeleLoc[2]);
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== KDA =================================================================
char translationFDA[3][] = {
	"FDA Frags target",
	"FDA Deaths target",
	"FDA Assists target"
};
public Action Command_FDA(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_fda", arg1, "%t", "FDA usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	int type = 0;
	if(StrContains(arg1, "death", false) >= 0) {
		type = 1;
	} else if(StrContains(arg1, "assist", false) >= 0) {
		type = 2;
	}
//
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	GetCmdArg(2, arg1, sizeof(arg1));
	int amount = StringToInt(arg1);
	if(amount > 9999) {
		amount = 9999;
	} else if(amount < -9999) {
		amount = -9999;
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		extSetKDA(clientList[i], amount, type);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", translationFDA[type], targetName, amount);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", translationFDA[type], "_s", targetName, amount);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== Push/Launch =========================================================
public Action Command_PL(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_pushlaunch", arg1, "%t", "PushLaunch usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	bool push = (StrContains(arg1, "launch", false) >= 0) ? false : true;
//
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	float vector[3] = {0.0, 0.0, 10.0};
	float fDirection[3];
	float fOrigin[3];
	float mult = 1.0;
	if(args > 1) {
		GetCmdArg(2, arg1, sizeof(arg1));
		mult = StringToFloat(arg1);
		if(mult > 100.0) {
			mult = 100.0;
		} else if(mult < -100.0) {
			mult = -100.0;
		}
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		GetClientEyePosition(clientList[i], fOrigin);
		if(push) {
			float fTempVec[3];
			GetClientEyeAngles(clientList[i], fTempVec);
			GetAngleVectors(fTempVec, fTempVec, NULL_VECTOR, NULL_VECTOR);
			fDirection[0] = fOrigin[0] + (fTempVec[0] * 500.0 * mult);
			fDirection[1] = fOrigin[1] + (fTempVec[1] * 500.0 * mult);
			fDirection[2] = fOrigin[2] + (fTempVec[2] * 500.0 * mult);
			MakeVectorFromPoints(fOrigin, fDirection, vector);
		}
		if(vector[2] < 6.0) {
			vector[2] = 6.0;
		}
		GetEntPropVector(clientList[i], Prop_Send, "m_vecOrigin", fOrigin);
		fOrigin[2] += 5.0;
		TeleportEntity(clientList[i], fOrigin, NULL_VECTOR, vector);
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", push ? "Push target" : "Launch target", targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", push ? "Push target" : "Launch target", "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== EndRound ============================================================
public Action Command_EndRound(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args > 1) {
		ReplyToCommandExt(client, "sm_endround", arg1, "%t", "Endround usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	float delay = 5.0;
	if(args == 1) {
		GetCmdArg(1, arg1, sizeof(arg1));
		delay = StringToFloat(arg1);
		if(delay > 10.0 || delay < 0.0) {
			delay = 5.0;
		}
	}
	
	CS_TerminateRound(delay, CSRoundEnd_Draw, true);
//
	ShowActivityExt(client, "%t", "Endround message");
	LogAction(client, -1, argString);
	return Plugin_Handled;
}

//== Execute =============================================================
public Action Command_Execute(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 2) {
		ReplyToCommandExt(client, "sm_execute", arg1, "%t", "Exec usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	ReplaceString(arg1, sizeof(arg1), "sm_", "", false);
	bool fake = (StrContains(arg1, "f", false) >= 0) ? true : false;
	bool silent = (StrContains(arg1, "s", false) >= 0) ? true : false;
//
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	char command[255];
	GetCmdArg(2, command, sizeof(command));
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		if(fake) {
			FakeClientCommand(clientList[i], command);
		} else {
			ClientCommand(clientList[i], command);
		}
	}
//
	if(multiLang) {
		if(!silent) {
			ShowActivityExt(client, "%t", "Exec target", command, targetName);
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		if(!silent) {
			CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
			ShowActivityExt(client, "%t", "Exec target", command, "_s", targetName);
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== ClanTag =============================================================
public Action Command_ClanTag(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 1) {
		ReplyToCommandExt(client, "sm_clantag", arg1, "%t", "ClanTag usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	ReplaceString(arg1, sizeof(arg1), "sm_", "", false);
	bool silent = (StrContains(arg1, "s", false) >= 0) ? true : false;
	bool remove = (args < 2) ? true : false;
//
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	char tag[255];
	if(args==2) {
		GetCmdArg(2, tag, sizeof(tag));
		if(StrEqual(tag, "", false)) {
			remove = true;
		}
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i])) continue;
		CS_SetClientClanTag(clientList[i], tag);
	}
//
	if(multiLang) {
		if(!silent) {
			if(remove) {
				ShowActivityExt(client, "%t", "ClanTag target removed", targetName);
			} else {
				ShowActivityExt(client, "%t", "ClanTag target", targetName, tag);
			}
		}
		LogActionExt(client, -1, argString, targetName);
	} else {
		if(!silent) {
			CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
			if(remove) {
				ShowActivityExt(client, "%t", "ClanTag target removed", "_s", targetName);
			} else {
				ShowActivityExt(client, "%t", "ClanTag target", "_s", targetName, tag);
			}
		}
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

//== ProjectileFix =======================================================
public Action Command_ProjectileFix(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	int owner = -1;
	char className[128];
	for(int i = MaxClients+1; i < 2048; i++) {
		if(IsValidEntity(i)) {
			GetEntPropString(i, Prop_Data, "m_iClassname", className, sizeof(className));
			if(StrContains(className, "projectile", false) >= 0) {
				owner = GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity");
				if(owner >= 1 && owner <= MaxClients) {
					PrintToConsole(client, "Killed %N's %s", owner, className);
				}
				AcceptEntityInput(i, "Kill");
			}
		}
	}
//
	ShowActivityExt(client, "%t", "ProjectileFix message");
	LogAction(client, -1, argString);
	return Plugin_Handled;
}

//== Extend ==============================================================
public Action Command_Extend(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if(args < 1) {
		ReplyToCommandExt(client, "sm_extend", arg1, "%t", "Extend usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
//
	GetCmdArg(1, arg1, sizeof(arg1));
	int ext = StringToInt(arg1);
	int iCurrentRoundTime = GameRules_GetProp("m_iRoundTime");
	GameRules_SetProp("m_iRoundTime", iCurrentRoundTime+ext, 4, 0, true);
//
	ShowActivityExt(client, "%t", "Extend message");
	LogAction(client, -1, argString);
	return Plugin_Handled;
}

//== BotKick ==============================================================
public Action Command_BotKick(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if (args < 0) {
		ReplyToCommandExt(client, "sm_botkick", arg1, "%t", "BotKick usage");
		return Plugin_Handled;
	}
//
	ServerCommand("bot_kick");
//
	return Plugin_Handled;
}

//== Drop ================================================================
public Action Command_Drop(int client, int args) {
	char arg1[32];
	GetCmdArg(0, arg1, sizeof(arg1));
	if(args < 1) {
		ReplyToCommandExt(client, "sm_drop", arg1, "%t", "Drop usage");
		return Plugin_Handled;
	}
	char argString[255];
	GetCmdArgString(argString, sizeof(argString));
	Format(argString, sizeof(argString), "%s %s", arg1, argString);
	char targetName[MAX_TARGET_LENGTH+8];
	int clientList[MAXPLAYERS];
	int clientCount;
	bool multiLang;
	GetCmdArg(1, arg1, sizeof(arg1));
	if ((clientCount = ProcessTargetString(arg1,client,clientList,MAXPLAYERS,COMMAND_FILTER_CONNECTED|COMMAND_FILTER_ALIVE,targetName,sizeof(targetName),multiLang)) <= 0) {
		ReplyToTargetError(client, clientCount);
		return Plugin_Handled;
	}
	CRemoveColors(targetName, sizeof(targetName));
//
	bool allWeapons = false;
	int slot = 0;
	bool currentWeapon = false;
	if(args > 1) {
		GetCmdArg(2, arg1, sizeof(arg1));
		if(StrEqual(arg1, "all", false)) {
			allWeapons = true;
		} else if(strlen(arg1) == 1) {
			slot = StringToInt(arg1);
		}
	} else {
		currentWeapon = true;
	}
	for(int i = 0; i < clientCount; i++) {
		if(!IsClientInGame(clientList[i]) || !IsPlayerAlive(clientList[i])) continue;
		if(currentWeapon) {
			extDrop(clientList[i]);
		} else if(allWeapons) {
			extDropAll(clientList[i]);
		} else if(slot > 0) {
			extDropSlot(clientList[i], slot);
		} else {
			extDropWeapon(clientList[i], arg1);
		}
	}
//
	if(multiLang) {
		ShowActivityExt(client, "%t", "Drop multiple weapons", targetName);
		LogActionExt(client, -1, argString, targetName);
	} else {
		CTeamColorize(GetClientTeam(clientList[0]), targetName, sizeof(targetName));
		ShowActivityExt(client, "%t", "Drop multiple weapons", "_s", targetName);
		LogActionExt(client, clientList[0], argString, targetName);
	}
	return Plugin_Handled;
}

public void extDropWeapon(int client, char[] item) {
	char exactWeapon[100];
	char className[32];
	if(GetTrieString(WeaponTrie, item, exactWeapon, sizeof(exactWeapon))) {
		int weaponIndex = -1;
		int weapon = -1;
		for(int slot = 5; slot >= 0; slot--) {
			weapon = GetPlayerWeaponSlot(client, slot);
			if(IsValidEntity(weapon)) {
				GetEntPropString(weapon, Prop_Data, "m_iClassname", className, sizeof(className));
				if(StrEqual(exactWeapon, className)) {
					weaponIndex = weapon;
					continue;
				}
			}
		}
		if(weaponIndex != -1) {
			SDKHooks_DropWeapon(client, weaponIndex, NULL_VECTOR, NULL_VECTOR);
		}
		
	}
}
public void extDropSlot(int client, int slot) {
	int weaponIndex = GetPlayerWeaponSlot(client, slot-1);
	if(weaponIndex != -1) {
		CS_DropWeapon(client, weaponIndex, true, true);
	}
}
public void extDropAll(int client) {
	int weapon = -1;
	for(int slot = 5; slot >= 0; slot--) {
		while((weapon = GetPlayerWeaponSlot(client, slot)) != -1) {
			if(IsValidEntity(weapon)) {
				SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
}
public void extDrop(int client) {
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if(IsValidEntity(weapon)) {
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
	}
}