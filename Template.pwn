#include <a_samp>
#include <a_mysql>  
#include <streamer>    
#include <zcmd>
#include <sscanf2>
#include <foreach>
#include <TimestampToDate>
#include <YSI\y_timers>
#include <YSI\y_utils>

#include <YSI\y_hooks>

/*
	            Next Generation Gaming, LLC
    (created by Next Generation Gaming Development Team)
                    
    Copyright (c) 2016, Next Generation Gaming, LLC
    
    All rights reserved.
   
    Redistribution and use in source and binary forms, with or without modification, are not permitted in any case.

    ---------------------------

    Project Name:
    			(project name here)	

    Documentation:
    			(gdoc link here)

    Script Developers:
    			Westen

*/

// 			Useful Functions

#define    		ToSeconds(%0)     		%0 * 1000
#define     	ToMinutes(%0)     		%0 * ToSeconds(60)
#define     	ToHours(%0)       		%0 * ToMinutes(60)
#define    		ToDays(%0)        		%0 * ToHours(24)

//			GPCI
native gpci(playerid, serial[], len = sizeof serial);


//			Other Defines


// 			Enums


// 			Other Variables


// 		 	Functions

stock GetPlayerGPCI(playerid)
{
    new szGPCI[64];
    gpci(playerid, szGPCI, sizeof szGPCI);
    return szGPCI;
}

//          Callbacks & Hooks


// 			Timers


//			MySQL


// 			Commands