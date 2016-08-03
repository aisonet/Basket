//
//  Global.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright (c) 2014 Vojta. All rights reserved.
//

#ifndef WhiteTile_Global_h
#define WhiteTile_Global_h

#import "cocos2d.h"
#import <UIKit/UIDevice.h>
#import "GameConfig.h"
#import "SimpleAudioEngine.h"


#define G_ORG_WIDTH     768
#define G_ORG_HEIGHT    1024

#ifdef UI_USER_INTERFACE_IDIOM
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

#define G_SWIDTH    (IS_IPAD() ? 768: [[CCDirector sharedDirector] winSize].width)  //Screen width
#define G_SHEIGHT   (IS_IPAD() ? 1024: [[CCDirector sharedDirector] winSize].height)   //Screen height

#define G_SCALEX    (G_SWIDTH * g_fScaleR / G_ORG_WIDTH)
#define G_SCALEY    (G_SHEIGHT * g_fScaleR / G_ORG_HEIGHT)

#define FONT_NAME   @"Bauhaus 93"


typedef enum
{
    RATIO_XY = 0,
    RATIO_X,
    RATIO_Y,
} Ratio;

typedef enum{
    NORMALTOOLS = 588,
} TOOLSTATE;

extern float g_fScaleR; //For some retina things such text

@class GameOver;
@class MainMenu;
extern GameOver *g_gameOverMenu;
extern MainMenu *g_mainMenu;

extern int g_iLives;
float getX(int x);
float getY(int y);

void loadGameInfo();
void updateGameInfo();

CCSprite* newSprite(NSString *sName, float x, float y, id target, int zOrder, int nRatio);
CCSprite* newSprite_u(NSString *sName, float x, float y, int zOrder, int nRatio);

CCMenuItemImage* newButton(NSString* btnName, float x, float y, id target, SEL selector, BOOL isOneImage, int nRatio);
CCMenuItemImage* newButton_d(NSString* btnName, float x, float y, id target, SEL selector, int nRatio);
CCMenuItemImage* newButton_l(NSString* btnName, NSString *btnDisName, float x, float y, id target, SEL selector, int nRatio);

CCMenuItemToggle* newToggleButton(NSString *btnName, float x, float y, id target, SEL selector, BOOL isOneImage, int nRatio);

CCAnimation* newAnimation(NSString *name, int nStartNum, int nFrameNum, BOOL isAscending, float fDelayPerUnit);

CCSpriteFrame* getSpriteFromAnimation(CCAnimation *ani, int index);
CCLabelTTF *addTextToButton(CGPoint pos, CCNode *scene, NSString *str, int fontSize, int z);

void setScale(CCNode *node, int nRatio);


#endif


