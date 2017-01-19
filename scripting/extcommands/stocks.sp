EngineVersion gGame;
#undef REQUIRE_EXTENSIONS
#include <cstrike>
#include <tf2>
float EmptyVec[3];
//==Text/Chat Helpers================================================
public void ShowActivityExt(int client, char[] message, any ...) {
	char sourceName[MAX_TARGET_LENGTH+8];
	char formatMessage[255];
	int sourceTeam = (client) ? GetClientTeam(client) : 0;
	for(int target = 1; target <= MaxClients; target++) {
		if(!IsClientInGame(target) || IsFakeClient(target)) {
			continue;
		}
		SetGlobalTransTarget(target);
		FormatActivitySource(client, target, sourceName, sizeof(sourceName));
		CRemoveColors(sourceName, sizeof(sourceName));
		CTeamColorize(sourceTeam, sourceName, sizeof(sourceName));
		VFormat(formatMessage, sizeof(formatMessage), message, 3);
		CFormat(formatMessage, sizeof(formatMessage));
		if(target != client) {
			//LowerCaseString(formatMessage, sizeof(formatMessage), ' ');
			formatMessage[0] = CharToLower(formatMessage[0]);
			Format(formatMessage, sizeof(formatMessage), "%s %s", sourceName, formatMessage);
		}
		Format(formatMessage, sizeof(formatMessage), "[SM] %s", formatMessage);
		PrintToChat(target, formatMessage);
	}
}

public void LogActionExt(int client, int target, char[] action, char[] targetName) {
	CStripColors(targetName, 255);
	if(target != -1) {
		LogAction(client, target, "\"%L\" %s \"%L\"", client, action, target);
	} else {
		LogAction(client, target, "\"%L\" %s \"%s\"", client, action, targetName);
	}
}

public void ReplyToCommandExt(int client, char[] command, char[] replacement, char[] message, any ...) {
	char formatMessage[255];
	SetGlobalTransTarget(client);
	VFormat(formatMessage, sizeof(formatMessage), message, 5);
	ReplaceString(formatMessage, sizeof(formatMessage), command, replacement);
	Format(formatMessage, sizeof(formatMessage), "[SM] %s", formatMessage);
	if(client == 0) {
		PrintToServer(formatMessage);
	} else if(GetCmdReplySource() == SM_REPLY_TO_CHAT) {
		CFormat(formatMessage, sizeof(formatMessage));
		PrintToChat(client, formatMessage);
	} else {
		PrintToConsole(client, formatMessage);
	}
}

char CTag[][] = {
	"^01", //White
	"^02",
	"^03",
	"^04",
	"^05",
	"^06",
	"^07",
	"^08",
	"^09",
	"^0A",
	"^0B",
	"^0C",
	"^0D",
	"^0E",
	"^0F",
	"^10"
};

char CTagCode[][] = {
	"\x01",
	"\x02",
	"\x03",
	"\x04",
	"\x05",
	"\x06",
	"\x07",
	"\x08",
	"\x09",
	"\x0A",
	"\x0B",
	"\x0C",
	"\x0D",
	"\x0E",
	"\x0F",
	"\x10"
};

char transTeam[][6] = {
	"spec",
	"spec",
	"t",
	"ct"
};
char teamClr[][] = {
	"\x05",
	"\x08",
	"\x09",
	"\x0D"
};

stock void CRemoveColors(char[] source, int size) {
	for(int c = 0; c < sizeof(CTag); c++) {
		ReplaceString(source, size, CTag[c], "");
	}
}
stock void CStripColors(char[] source, int size) {
	for(int c = 0; c < sizeof(CTagCode); c++) {
		ReplaceString(source, size, CTagCode[c], "");
	}
}

stock void CTeamColorize(int team, char[] source, int size) {
	Format(source, size, "%s%s\x01", teamClr[team], source);
}

stock void CFormat(char[] source, int size) {
	for(int c = 0; c < sizeof(CTag); c++) {
		ReplaceString(source, size, CTag[c], CTagCode[c]);
	}
}

stock void LowerCaseString(char[] source, int size, char del) {
	for(int c = 0; c < size; c++) {
		if(source[c] == del) break;
		if(IsCharUpper(source[c])) {
			source[c] = CharToLower(source[c]);
		}
	}
}

//==Command Helpers==================================================

stock void exRespawnPlayer(int client) {
	switch(gGame) {
		case Engine_CSGO, Engine_CSS: {
			CS_RespawnPlayer(client);
		}
		case Engine_TF2: {
			TF2_RespawnPlayer(client);
		}
	}
}

stock void exSetClientArmor(int client, int amount, bool helmet) {
	SetEntProp(client, Prop_Send, "m_ArmorValue", amount);
	SetEntProp(client, Prop_Send, "m_bHasHelmet", helmet);
	//SetEntProp(client, Prop_Send, "m_bHasHeavyArmor", true);
}

stock int exGetClientArmor(int client) {
	return GetEntProp(client, Prop_Send, "m_ArmorValue");
}

stock void exSetClientAccount(int client, int amount) {
	if(amount > 16000) {
		amount = 16000;
	} else if(amount < 0) {
		amount = 0;
	}
	SetEntProp(client, Prop_Send, "m_iAccount", amount);
}

stock int exGetClientAccount(int client) {
	return GetEntProp(client, Prop_Send, "m_iAccount");
}

stock void extTeam(int client, int team, bool silent) {
	if(silent && (gGame == Engine_CSGO || gGame == Engine_CSS)) {
		
	} else {
		ChangeClientTeam(client, team);
	}
}

stock void extMelee(int client) {
	extDisarm(client, true);
}

stock void extDisarm(int client, bool melee) {
	if(gGame == Engine_CSGO || gGame == Engine_CSS) {
		new weapon = -1;
		for(new slot = 5; slot >= 0; slot--) {
			if(slot == 2 && melee) {
				weapon = GetPlayerWeaponSlot(client, slot);
				if(IsValidEntity(weapon)) {
					extSetActiveWeapon(client, weapon);
				}
				continue;
			}
			while((weapon = GetPlayerWeaponSlot(client, slot)) != -1) {
				if(IsValidEntity(weapon)) {
					RemovePlayerItem(client, weapon);
				}
			}
		}
	}
}

stock void extSpeed(int client, float speed) {
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
}

stock extSetActiveWeapon(client, weapon) {
	SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", weapon);
	ChangeEdictState(client, FindDataMapInfo(client, "m_hActiveWeapon"));
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", true);
}


stock bool extTraceEye(client, float pos[3]) {
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(INVALID_HANDLE)) {
		TR_GetEndPosition(pos, INVALID_HANDLE);
		return true;
	}
	return false;
}
public bool TraceEntityFilterPlayer(entity, contentsMask)
{
	return (entity > GetMaxClients() || !entity);
}

char propertyFDA[3][] = {
	"m_iFrags",
	"m_iDeaths",
	"m_iAssists"
};

stock void extSetKDA(int client,  int amount, int type) {
	SetEntProp(client, Prop_Data, propertyFDA[type], amount);
}