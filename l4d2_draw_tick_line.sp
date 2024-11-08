#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

float			 g_posBase[3];
bool			 g_show;
int				 g_tickrate;
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
	g_show = false;
}

Action CommandTickLine(int client, int args)
{
	if (client < 1)
	{
		return Plugin_Handled;
	}

	GetClientAbsOrigin(client, g_posBase);
	g_tickrate = RoundToNearest(1.0 / GetTickInterval());
	PrintToChatAll("\x03 test on %itick", g_tickrate);

	g_show = true;
	return Plugin_Handled;
}

public void OnGameFrame()
{
	if (!g_show)
	{
		return;
	}
	static float posStart[3], posEnd[3];
	posStart	= g_posBase;

	int seq		= GetGameTickCount() % g_tickrate;
	int col_idx = (seq / 10) % sizeof(color);

	posStart[0] += seq * 2.0;
	posEnd = posStart;
	posEnd[2] += 100.0;
	TE_SetupBeamPoints(posStart, posEnd, g_sprite, 0, 0, 0, 1.0, 1.0, 1.0, 1, 0.0, color[col_idx], 0);
	TE_SendToAll();
}
