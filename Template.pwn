#include <a_samp>
#include <a_mysql> 
#include <a_colors>
#include <streamer>    
#include <zcmd>
#include <sscanf2>
#include <foreach>
#include <TimestampToDate>
#include <YSI\y_timers>
#include <YSI\y_utils>

main() { }

// 			Enums


//			Other Includes


// 			Useful Functions

#define    		ToSeconds(%0)     		%0 * 1000
#define     	ToMinutes(%0)     		%0 * ToSeconds(60)
#define     	ToHours(%0)       		%0 * ToMinutes(60)
#define    		ToDays(%0)        		%0 * ToHours(24)

//			GPCI
native gpci(playerid, serial[], len = sizeof serial);


//			MySQL


//			Other Defines


// 			Other Variables


// 		 	Functions

stock GetPlayerGPCI(playerid)
{
    new szGPCI[64];
    gpci(playerid, szGPCI, sizeof szGPCI);
    return szGPCI;
}

stock GetPlayerNameEx(playerid)
{
	new szName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, szName, MAX_PLAYER_NAME);

	for(new i = 0; i < MAX_PLAYER_NAME) if(szName[i] == '_') szName[i] = ' ';

	return szName;
}

stock GetPlayerName_(playerid)
{
	new szName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, szName, MAX_PLAYER_NAME);
	return szName;
}

//          Callbacks & Hooks


// 			Timers


// 			Commands