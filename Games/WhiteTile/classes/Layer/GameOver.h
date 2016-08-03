//
//  GameOver.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <messageUI/MFMailComposeViewController.h>

@interface GameOver : CCLayer<MFMailComposeViewControllerDelegate> {
    CCMenu *menu;
    CCMenuItemImage *m_mMenu, *m_mScore, *m_mRate, *m_mRetry, *m_mMore, *m_mTW, *m_mFB, *m_mML;
    int m_iScore;
}

- (void) setSurvivalScore:(int) score;
- (void) setTimeScore:(float) score;
- (void) setDistanceScore:(int) score;
- (void) updateRateButton;

@end
