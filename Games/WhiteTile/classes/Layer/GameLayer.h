//
//  GameLayer.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface GameLayer : CCLayer<MFMailComposeViewControllerDelegate> {
    CCSprite *m_sFootSprite[2];
    
    int m_iScore;
    int m_iSpeedY;
    int m_iCurrentStep;
    
    float m_fPassedTime;
    float m_fInitialTime;
    
    BOOL m_bStartedGame;
    BOOL m_bTimeModeEnd;
    
    NSMutableArray *m_aWhiteTile;
    NSMutableArray *m_aBlackTile;
    NSMutableArray *m_aRedTile;
    NSMutableArray *m_aPrint;
    
    CCLabelTTF *m_lbtScore;
    CCLabelTTF *m_lbtTime;
}

-(void) dealloc;

@end
