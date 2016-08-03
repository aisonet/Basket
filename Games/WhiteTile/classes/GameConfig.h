//
//  GameConfig.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright (c) 2014 Vojta. All rights reserved.
//

#ifndef WhiteTile_GameConfig_h
#define WhiteTile_GameConfig_h


#import "cocos2d.h"
#import "Constants.h"

#define TEXT_TAG    1
#define FX_BTN() [[SimpleAudioEngine sharedEngine] playEffect:@"sndButtonClass1.aif"];

typedef enum
{
    D_EASY = 0,
    D_MEDIUM,
    D_HARD,
} DIFFICULTY;

extern BOOL g_bMusicOff;
extern BOOL g_bSoundOff;
extern BOOL g_bGameSuccess;
extern int g_iGameMode;


#endif
