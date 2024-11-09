#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

float			 g_posBase[3];

int				 g_tickrate;
int				 g_count;
int				 g_sprite;
static const int color[][] = {
	{255,  0,	  0,	 100},
	{ 0,	 255, 0,	 100},
	{ 255, 255, 0,   100},
	{ 255, 255, 255, 100},
	{ 0,	 255, 255, 100}
};

public void OnPluginStart()
{
	RegAdminCmd("sm_draw_tick", CommandTickLine, ADMFLAG_ROOT);
}

public void OnMapStart()
{
	g_sprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

public void OnMapEnd()
{
	g_count = 0;
}

Action CommandTickLine(int client, int args)
{
	if (client < 1)
	{
		return Plugin_Handled;
	}

	GetClientAbsOrigin(client, g_posBase);
	g_tickrate = RoundToNearest(1.0 / GetTickInterval());
	g_count	   = 1;
	if (args == 1)
	{
		char sTemp[8];
		GetCmdArg(1, sTemp, sizeof(sTemp));
		g_count = StringToInt(sTemp);
	}

	if (g_count > 0)
	{
		PrintToChatAll("\x03 test on %itick with %i line/tick", g_tickrate, g_count);
		SetConVarInt(FindConVar("sv_multiplayer_maxtempentities"), 128);	// allow transmit more TE per tick
	}

	return Plugin_Handled;
}

public void OnGameFrame()
{
	if (g_count < 1)
	{
		return;
	}
	static float posStart[3], posEnd[3];
	posStart	  = g_posBase;

	int	  seq	  = GetGameTickCount() % g_tickrate;
	int	  col_idx = (seq / 10) % sizeof(color);
	float height  = 100.0 / g_count;

	posStart[0] += seq * 2.0;
	posEnd[0] = posStart[0];
	posEnd[1] = posStart[1];

	for (int i = 0; i < g_count; i++)
	{
		posEnd[2] = posStart[2] + height;
		TE_SetupBeamPoints(posStart, posEnd, g_sprite, 0, 0, 0, 1.0, 1.0, 1.0, 1, 0.0, color[col_idx], 0);	  // 141 bits = 17.625 bytes
		TE_SendToAll();
		posStart[2] = posEnd[2] + 1.0;
	}
}
