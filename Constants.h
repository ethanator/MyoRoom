//
//  Constants.h
//  MyoRoom
//
//  Created by Yuxuan Chen on 9/13/14.
//  Copyright (c) 2014 Yuxuan Chen. All rights reserved.
//

#ifndef MyoRoom_Constants_h
#define MyoRoom_Constants_h

// Strings
#define APPLICATION_ID          "com.ethanychen.MyoRoom"
#define STATUS_CONNECTED        "Connected"
#define STATUS_UNCONNECTED      "Unconnected"
#define BUTTON_MYO_CONNECTED    "Reconnect"
#define BUTTON_MYO_UNCONNECTED  "Click to pair"

// Functions
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// Colors
#define ORANGE_YELLOW (0xFFCC00)

#endif
