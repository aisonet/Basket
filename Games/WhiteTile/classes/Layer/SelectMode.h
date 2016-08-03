//
//  SelectMode.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SelectMode : CCLayer {
    CCMenu *menu;
    CCMenuItemImage *m_mSurvival, *m_mTime, *m_mDistance, *m_mMenu;
}

@end
