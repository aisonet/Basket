//
//  AppDelegate.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright Vojta 2014. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "MainMenu.h"
#import "Global.h"

#import "ALSdk.h"
#import "ALInterstitialAd.h"


@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskPortrait;
	
	// iPad only
	return UIInterfaceOrientationMaskPortrait;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	
	// iPad only
	// iPhone only
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [MainMenu node]];
	}
}
@end


@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;
@synthesize _gameCenterManager;
@synthesize _currentLeaderBoard;
@synthesize _currentLeaderBoard_Distance, _currentLeaderBoard_Survial, _currentLeaderBoard_Time;

+(AppController*) sharedDelegate
{
    return (AppController *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RevMobAds startSessionWithAppID:@"53668a4de9afebb55920ad7a"];
    [ALSdk initializeSdk];
    [self initGameCenter];
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if ([UIScreen mainScreen].scale==2.0f && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        CCLOG(@"iPad Retina Display Not supported");
    }
    else
    {
        if( ! [director_ enableRetinaDisplay:YES] )
        	CCLOG(@"Retina Display Not supported");
    }
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;

	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
    
    if (CC_CONTENT_SCALE_FACTOR() == 2)
        g_fScaleR = 2.0f;
	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];	
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
    
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = @"536689251873da7109d03f02";
    cb.appSignature = @"f74d99b9a9fa3b39fd5cd1dc37a5599a2a65309b";
    [cb startSession];
    [cb cacheInterstitial];
    [cb cacheMoreApps];
    
    [self showChartboost];
    [self showApplovinAds];
    //[self showRevmobAds];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

-(NSString *)getRateURL
{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
        return [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", RATE_ID];
    else
        return [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", RATE_ID];
}

-(void) showRate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"Rated"])
        return;
    
    if (RATE_DIRECTLY) {
        NSURL *url = [NSURL URLWithString:[self getRateURL]];
        
        if (![[UIApplication sharedApplication] openURL:url]) {
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        } else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"Rated"];
            if (g_mainMenu) [g_mainMenu updateRateButton];
            if (g_gameOverMenu) [g_gameOverMenu updateRateButton];
        }
    } else {
        UIAlertView *rateAlert = [[UIAlertView alloc]initWithTitle:RATE_TITLE message:RATE_MESSAGE delegate:self cancelButtonTitle:@"Remind me later" otherButtonTitles:@"Rate",nil];
        rateAlert.tag = 1001;
    	[rateAlert show];
        [rateAlert release];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        if (buttonIndex == 1)
        {
            NSURL *url = [NSURL URLWithString:[self getRateURL]];
            if (![[UIApplication sharedApplication] openURL:url])
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
            else {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:@"Rated"];
                if(g_mainMenu) [g_mainMenu updateRateButton];
                if(g_gameOverMenu) [g_gameOverMenu updateRateButton];
            }
        }
        else
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:@"Rated"];
        }
    }
}

#pragma mark - Advertisement

-(void) showRevmobAds
{
    [[RevMobAds session] showFullscreen];
}

-(void) showChartboost
{
    [[Chartboost sharedChartboost] showInterstitial];
}

-(void) showApplovinAds
{
    [ALInterstitialAd showOver:[[UIApplication sharedApplication] keyWindow]];
}

-(void) showMoreGames
{
    
    [[Chartboost sharedChartboost] showInterstitial];
    [self showApplovinAds];
    [self showRevmobAds];
    
    //[[Chartboost sharedChartboost] showMoreApps];
}

-(void) revmobAdDidFailWithError:(NSError *)error
{
    NSLog(@"RevMob Ad failed: %@", error);
    [[Chartboost sharedChartboost] showInterstitial];
}


#pragma mark - Game Center

-(BOOL) initGameCenter
{
    if (self._gameCenterManager != nil)
		return NO;
    self._currentLeaderBoard = LEADERBOARD_ID;
    self._currentLeaderBoard_Survial = LEADERBOARD_ID_SURVIVAL;
    self._currentLeaderBoard_Time = LEADERBOARD_ID_TIME;
    self._currentLeaderBoard_Distance = LEADERBOARD_ID_DISTANCE;
    
	if ([GameCenterManager isGameCenterAvailable])
	{
		self._gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self._gameCenterManager setDelegate:self];
		[self._gameCenterManager authenticateLocalUser];
        
        return YES;
	}
    else
    {
        NSString *message = @"This IOS version is not available Game Center.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message!" message:message delegate:self cancelButtonTitle:@"YES" otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
        [alert release];
    }
    
    return NO;
}

-(void) submitScore:(int)mode :(int)score
{
    if (mode == 0) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self._gameCenterManager reportScore:score forCategory:self._currentLeaderBoard_Survial];
            [self._gameCenterManager reloadHighScoresForCategory:self._currentLeaderBoard_Survial];
        }
    }
    
    if (mode == 1) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self._gameCenterManager reportScore:score forCategory: self._currentLeaderBoard_Time];
            [self._gameCenterManager reloadHighScoresForCategory:self._currentLeaderBoard_Time];
        }
    }
    
    if (mode == 2) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self._gameCenterManager reportScore:score forCategory:self._currentLeaderBoard_Distance];
            [self._gameCenterManager reloadHighScoresForCategory:self._currentLeaderBoard_Distance];
        }
    }
    
    if (mode == 3) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self._gameCenterManager reportScore:score forCategory:self._currentLeaderBoard];
            [self._gameCenterManager reloadHighScoresForCategory:self._currentLeaderBoard];
        }
    }
}

-(void)submitScore: (int)score
{
	if (score > 0) {
        if ([GameCenterManager isGameCenterAvailable]) {
            [self._gameCenterManager reportScore:score forCategory:self._currentLeaderBoard];
            [self._gameCenterManager reloadHighScoresForCategory:self._currentLeaderBoard];
        }
	}
}

-(void) showLeaderboard
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardViewController != NULL) {
		leaderboardViewController.category = self._currentLeaderBoard;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardViewController.leaderboardDelegate = self;
        
        [self.navController presentModalViewController:leaderboardViewController animated:YES];
        
	}
}

-(void) showLeaderboard_Survival
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardViewController != NULL) {
		leaderboardViewController.category = self._currentLeaderBoard_Survial;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardViewController.leaderboardDelegate = self;
        
        [self.navController presentModalViewController:leaderboardViewController animated:YES];
        
	}
}

-(void) showLeaderboard_Time
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardViewController != NULL) {
		leaderboardViewController.category = self._currentLeaderBoard_Time;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardViewController.leaderboardDelegate = self;
        
        [self.navController presentModalViewController:leaderboardViewController animated:YES];
        
	}
}

-(void) showLeaderboard_Distance
{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardViewController != NULL) {
		leaderboardViewController.category = self._currentLeaderBoard_Distance;
		leaderboardViewController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardViewController.leaderboardDelegate = self;
        
        [self.navController presentModalViewController:leaderboardViewController animated:YES];
        
	}
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self.navController dismissModalViewControllerAnimated:YES];
    [viewController release];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self.navController dismissModalViewControllerAnimated:YES];
    [viewController release];
}

#pragma makr GameCenterManager protocol

-(void) scoreReported:(NSError*)error
{
    NSString *message = @"Score submited succesfully to Game Center.";
    NSLog(@"%@", message);
}

-(void) processGameCenterAuth:(NSError*) error
{
    if (error == NULL) {
        NSLog(@"Game Center Auth success!");
    } else {
        NSLog(@"Game Center Auth faild!");
    }
}

-(void) reloadScoresComplete:(GKLeaderboard*)leaderBoard error:(NSError*) error
{
    if (error == NULL) {
        NSLog(@"Game Center reload socores success!");
    } else {
        NSLog(@"Game Center reload socores faild!");
    }
}

-(void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}


@end
