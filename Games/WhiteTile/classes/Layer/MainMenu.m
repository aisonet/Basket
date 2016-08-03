//
//  MainMenu.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import "MainMenu.h"
#import "SelectMode.h"
#import "Global.h"
#import "AppDelegate.h"


@implementation MainMenu

-(id) init
{
    if ((self = [super init])) {
        self.touchEnabled = YES;
        [self createBackground];
    }
    
    g_mainMenu = self;
    g_gameOverMenu = nil;
    
    return self;
}


-(void) createBackground
{
    newSprite(@"main_bg", G_SWIDTH / 2, G_SHEIGHT / 2, self, -1, RATIO_XY);
    newSprite(@"mgLogoBig", G_SWIDTH / 2, getY(350), self, 1, RATIO_Y);
    
    m_mPlay = newButton(@"play", G_SWIDTH / 2, getY(620), self, @selector(onClickStart), false,RATIO_Y);
    m_mScore = newButton(@"scores", G_SWIDTH / 2, getY(730), self, @selector(onClickScore), false,RATIO_Y);
    m_mRate = newButton(@"rate", G_SWIDTH / 2, getY(920), self, @selector(onClickRate), false,RATIO_Y);
    m_mMore = newButton(@"more", G_SWIDTH / 2, getY(820), self, @selector(onClickMore), false,RATIO_Y);
    menu = [CCMenu menuWithItems: m_mPlay, m_mScore, m_mMore, nil];
    menu.position = ccp(0, 0);
    [self addChild: menu z:10];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"Rated"])
        [menu addChild: m_mRate];
    
    m_mPlay.position = ccp(G_SWIDTH * 2, getY(620));
    m_mScore.position = ccp(G_SWIDTH * 2, getY(720));
    m_mMore.position = ccp(G_SWIDTH * 2, getY(920));
    m_mRate.position = ccp(G_SWIDTH * 2, getY(820));
    
    [m_mPlay runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.0], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(620))], nil]];
    [m_mScore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(720))], nil]];
    [m_mMore runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.4], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(820))], nil]];
    [m_mRate runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCMoveTo actionWithDuration:0.5 position:ccp(G_SWIDTH / 2, getY(920))], nil]];
}

-(void) updateRateButton
{
    [menu removeChild: m_mRate];
}

-(void) onClickStart
{
    FX_BTN();
    [[CCDirector sharedDirector] replaceScene: [SelectMode node]];
}

-(void) onClickScore
{
    [[SimpleAudioEngine sharedEngine] playEffect: @"sndScores.aif"];
    AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [delegate showLeaderboard];
}

-(void) onClickRate
{
    FX_BTN();
    AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [delegate showRate];
}

-(void) onClickMore
{
    FX_BTN();
    AppController *del = [AppController sharedDelegate];
    [del showMoreGames];
}

-(void) dealloc
{
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
