//
//  SelectMode.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import "SelectMode.h"
#import "IntroLayer.h"
#import "MainMenu.h"
#import "Global.h"
#import "Chartboost.h"


@implementation SelectMode

-(id) init
{
    if ((self = [super init])) {
        self.touchEnabled = YES;
        [self createBackground];
    }
    
    return self;
}

-(void) createBackground
{
    newSprite(@"main_bg", G_SWIDTH / 2, G_SHEIGHT / 2, self, -1, RATIO_XY);
    
    [self newLabel: @"SELECT GAME MODE!" :FONT_NAME :68 :ccc3(0,255,0) :ccp(G_SWIDTH / 2, getY(230))];
    
    m_mSurvival = newButton(@"survival", G_SWIDTH / 2, getY(550), self, @selector(onClickSurvival), false,RATIO_Y);
    m_mTime = newButton(@"time", G_SWIDTH / 2, getY(650), self, @selector(onClickTime), false,RATIO_Y);
    m_mDistance = newButton(@"distance", G_SWIDTH / 2, getY(750), self, @selector(onClickDistance), false,RATIO_Y);
    m_mMenu = newButton(@"menu", G_SWIDTH / 2, getY(850), self, @selector(onClickMenu), false,RATIO_Y);
    menu = [CCMenu menuWithItems: m_mSurvival, m_mTime, m_mDistance, m_mMenu, nil];
    menu.position = ccp(0, 0);
    [self addChild: menu z:10];
    
    m_mSurvival.position = ccp(G_SWIDTH * 2, getY(550));
    m_mTime.position = ccp(G_SWIDTH * 2, getY(650));
    m_mDistance.position = ccp(G_SWIDTH * 2, getY(750));
    m_mMenu.position = ccp(G_SWIDTH * 2, getY(850));
    
    [m_mSurvival runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.0], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(550))], nil]];
    [m_mTime runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(650))], nil]];
    [m_mDistance runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(750))], nil]];
    [m_mMenu runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(850))], nil]];
}

-(CCLabelTTF*) newLabel:(NSString*) str : (NSString *) fontName :(int)size :(ccColor3B)color :(CGPoint) pos
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:fontName fontSize:size];
    label.scale = G_SCALEX / g_fScaleR;
    [self addChild: label];
    [label setColor:color];
    label.anchorPoint = ccp(0.5, 0.5);
    label.position = pos;
    
    return label;
}

-(void) onClickSurvival
{
    FX_BTN();
    g_iGameMode = 0;
    [[CCDirector sharedDirector] replaceScene: [IntroLayer node]];
}

-(void) onClickTime
{
    FX_BTN();
    g_iGameMode = 1;
    [[CCDirector sharedDirector] replaceScene: [IntroLayer node]];
}

- (void) onClickDistance
{
    FX_BTN();
    g_iGameMode = 2;
    [[CCDirector sharedDirector] replaceScene: [IntroLayer node]];
}

- (void) onClickMenu
{
    [[Chartboost sharedChartboost] showInterstitial];
    
    FX_BTN();
    [[CCDirector sharedDirector] replaceScene: [MainMenu node]];
}

-(void) dealloc
{
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}


@end
