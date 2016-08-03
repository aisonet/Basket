//
//  MainMenu.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainMenu : CCLayer {
    CCMenu *menu;
    CCMenuItemImage *m_mPlay, *m_mScore, *m_mRate, *m_mMore;
}

-(void) updateRateButton;

@end
