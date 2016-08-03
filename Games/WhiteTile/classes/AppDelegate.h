//
//  AppDelegate.h
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright Vojta 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#import <RevMobAds/RevMobAds.h>
#import "Chartboost.h"

#import "GameCenterManager.h"
#import <GameKit/GameKit.h>

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate, ChartboostDelegate, RevMobAdsDelegate, GameCenterManagerDelegate, GKLeaderboardViewControllerDelegate>
{
	UIWindow *window_;
	MyNavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
    
    GameCenterManager *_gameCenterManager;
	NSString *_currentLeaderBoard_Survival;
    NSString *_currentLeaderBoard_Time;
    NSString *_currentLeaderBoard_Distance;
    NSString *_currentLeaderBoard;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@property (nonatomic, retain) GameCenterManager *_gameCenterManager;
@property (nonatomic, retain) NSString *_currentLeaderBoard;
@property (nonatomic, retain) NSString *_currentLeaderBoard_Survial;
@property (nonatomic, retain) NSString *_currentLeaderBoard_Time;
@property (nonatomic, retain) NSString *_currentLeaderBoard_Distance;

+(AppController*) sharedDelegate;

#pragma mark - Advertisement

-(void) showRevmobAds;
-(void) showApplovinAds;
-(void) showChartboost;
-(void) showMoreGames;
-(void) showRate;

#pragma mark - Game Center

-(void) submitScore:(int)mode :(int)score;
-(void) submitScore: (int)score;
-(void) showLeaderboard;
-(void) showLeaderboard_Survival;
-(void) showLeaderboard_Time;
-(void) showLeaderboard_Distance;
-(BOOL) initGameCenter;


@end
