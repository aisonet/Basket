//
//  GameOver.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import "GameOver.h"
#import "MainMenu.h"
#import "IntroLayer.h"

#import "AppDelegate.h"
#import "Global.h"

#import <Social/Social.h>


@implementation GameOver

-(id) init
{
    if ((self = [super init])) {
        self.touchEnabled = YES;
        [self createBackground];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    int runCnt = [userDefaults integerForKey:@"ADS"];
    [userDefaults setInteger: runCnt + 1 forKey:@"ADS"];
    
    AppController *del = [AppController sharedDelegate];
    //[del showRevmobAds];
    [del showApplovinAds];
    
    if (runCnt % 5 == 0) {
        [[Chartboost sharedChartboost] showInterstitial];
    }
    
    g_mainMenu = nil;
    g_gameOverMenu = self;
    
    if (g_bGameSuccess) {
        [[SimpleAudioEngine sharedEngine] playEffect: @"sndWin.aif"];
    } else {
        [[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"sndLaugh%d.aif", arc4random()%2]];
    }
    
    return self;
}

-(void) createBackground
{
    if (g_bGameSuccess) {
        newSprite(@"mgBackgroundBlue", G_SWIDTH / 2, G_SHEIGHT / 2, self, -1, RATIO_XY);
    } else {
        newSprite(@"mgBackgroundPink", G_SWIDTH / 2, G_SHEIGHT / 2, self, -1, RATIO_XY);
    }
    
    m_mRetry = newButton(@"retry", G_SWIDTH / 2, getY(420), self, @selector(onClickRetry), false,RATIO_Y);
    m_mMore = newButton(@"more", G_SWIDTH / 2, getY(820), self, @selector(onClickMore), false,RATIO_Y);
    m_mRate = newButton(@"rate", G_SWIDTH / 2, getY(720), self, @selector(onClickRate), false,RATIO_Y);
    m_mScore = newButton(@"scores", G_SWIDTH / 2, getY(520), self, @selector(onClickScore), false,RATIO_Y);
    m_mMenu = newButton(@"menu", G_SWIDTH / 2, getY(620), self, @selector(onClickMenu), false,RATIO_Y);
    
    CCSprite *sprite;
    if (g_bGameSuccess) {
        sprite = newSprite(@"success", G_SWIDTH / 2, G_SHEIGHT / 2, self, 99, RATIO_XY);
    } else {
        sprite = newSprite(@"fail", G_SWIDTH / 2, G_SHEIGHT / 2, self, 99, RATIO_XY);
    }
    
    [sprite runAction: [CCSequence actions:[CCDelayTime actionWithDuration:4.0f], [CCFadeTo actionWithDuration:1.0 opacity:0], [CCCallFuncN actionWithTarget:self selector:@selector(enableMenu:)], nil]];
    
    m_mFB = newButton(@"fb", G_SWIDTH / 4, getY(950), self, @selector(onClickFB), false,RATIO_Y);
    m_mTW = newButton(@"tw", G_SWIDTH * 2 / 4, getY(950), self, @selector(onClickTW), false,RATIO_Y);
    m_mML = newButton(@"email", G_SWIDTH * 3 / 4, getY(950), self, @selector(onClickMail), false,RATIO_Y);
    menu = [CCMenu menuWithItems: m_mMenu, m_mScore, m_mRetry, m_mMore, m_mFB, m_mML, m_mTW, nil];
    menu.position = ccp(0, 0);
    [self addChild: menu z:10];
    
    [menu setEnabled:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"Rated"]) {
        [menu addChild: m_mRate];
    }
}

-(void) enableMenu:(id)sender
{
    [menu setEnabled:YES];
}

-(void) updateRateButton
{
    [menu removeChild: m_mRate];
}

-(void) setSurvivalScore:(int) score
{
    int maxScore = [[NSUserDefaults standardUserDefaults] integerForKey: [NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
    
    if (maxScore < score) {
        maxScore = score;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:maxScore forKey:[NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [delegate submitScore:0 :maxScore];
    [delegate submitScore:maxScore];
    
    m_iScore = score;
    
    [self newLabel: @"GAME OVER" :FONT_NAME :70 :ccc3(144, 57, 0) : ccp(G_SWIDTH / 2, getY(160))];
    [self newLabel: [NSString stringWithFormat: @"STEP: %d", score] :FONT_NAME :48 :ccc3(255, 0, 0) : ccp(G_SWIDTH / 2, getY(260))];
    [self newLabel: [NSString stringWithFormat: @"BEST: %d", maxScore]:FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(330))];
}

- (void) setTimeScore:(float) score{
    float minScore = [[NSUserDefaults standardUserDefaults] floatForKey: [NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
    
    if (minScore == 0) minScore = 10000;
    
    [self newLabel: @"GAME OVER" :FONT_NAME :56 :ccc3(0, 0, 0) : ccp(G_SWIDTH / 2, getY(160))];
    
    if (g_bGameSuccess) {
        if (minScore > score) {
            minScore = score;
        }
        [[NSUserDefaults standardUserDefaults] setFloat:minScore forKey:[NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [delegate submitScore:1 :minScore];
        
        m_iScore = score;
        
        [self newLabel: [NSString stringWithFormat: @"STEP: %.3f", score] :FONT_NAME :48 :ccc3(255, 0, 0) : ccp(G_SWIDTH / 2, getY(260))];
        [self newLabel: [NSString stringWithFormat: @"BEST: %.3f", minScore]:FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(330))];
    } else {
        if (minScore == 10000) {
            [self newLabel: [NSString stringWithFormat: @"BEST: %.3f", minScore]:FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(260))];
        } else {
            [self newLabel: @"BEST: -":FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(260))];
        }
    }
}

-(void) setDistanceScore:(int) score
{
    int maxScore = [[NSUserDefaults standardUserDefaults] integerForKey: [NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
    [self newLabel: @"GAME OVER" :FONT_NAME :56 :ccc3(0, 0, 0) : ccp(G_SWIDTH / 2, getY(160))];
    
    if (g_bGameSuccess) {
        if (maxScore < score) {
            maxScore = score;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:maxScore forKey:[NSString stringWithFormat:@"SCORE_%d", g_iGameMode]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        m_iScore = score;
        AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [delegate submitScore:2 :maxScore];
        
        [self newLabel: [NSString stringWithFormat: @"STEP %d", score] :FONT_NAME :48 :ccc3(255, 0, 0) : ccp(G_SWIDTH / 2, getY(260))];
        [self newLabel: [NSString stringWithFormat: @"BEST %d", maxScore]:FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(360))];
    } else {
        [self newLabel: [NSString stringWithFormat: @"BEST %d", maxScore]:FONT_NAME :48 :ccc3(0, 255, 0) : ccp(G_SWIDTH / 2, getY(260))];
    }
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

-(void) onClickScore
{
    [[SimpleAudioEngine sharedEngine] playEffect: @"sndScores.aif"];
    AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    if(g_iGameMode == 0) [delegate showLeaderboard_Survival];
    if(g_iGameMode == 1) [delegate showLeaderboard_Time];
    if(g_iGameMode == 2) [delegate showLeaderboard_Distance];
}

-(void) onClickRate
{
    [[SimpleAudioEngine sharedEngine] playEffect: @"sndWin.aif"];
    FX_BTN();
    AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [delegate showRate];
}

-(void) onClickMenu
{
    FX_BTN();
    [[CCDirector sharedDirector] replaceScene: [MainMenu node]];
}

-(void) onClickRetry
{
    [[SimpleAudioEngine sharedEngine] playEffect: @"sndRetry.aif"];
    [[CCDirector sharedDirector] replaceScene: [IntroLayer node]];
}

-(void) onClickMore
{
    AppController *del = [AppController sharedDelegate];
    [del showMoreGames];
}

-(void) onClickFB
{
    FX_BTN();
    [self shareFB:[NSString stringWithFormat: @"My Score: %d %@", m_iScore, GAME_FBTEXT]];
}

-(void) onClickTW
{
    FX_BTN();
    [self shareTwitter:[NSString stringWithFormat: @"My Score: %d %@", m_iScore, GAME_TWITTERTEXT]];
}


-(void) onClickMail
{
    FX_BTN();
    [self sendMail:EMAIL_SUBJECT :[NSString stringWithFormat: @"My Score: %d %@", m_iScore, EMAIL_BODY]];
}

#pragma mark Share Feature

-(void) shareFB:(NSString *)text
{
    //if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:text];
        //[controller addURL:[NSURL URLWithString:@"http://www.appcoda.com"]];
        
        [[CCDirector sharedDirector]presentViewController:controller animated:YES completion:nil];
    //}
}

-(void) shareTwitter:(NSString *)text
{
    //if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [controller setInitialText:text];
        //[controller addURL:[NSURL URLWithString:@"http://www.appcoda.com"]];
        
        [[CCDirector sharedDirector]presentViewController:controller animated:YES completion:nil];
    //}
}

-(void) sendMail:(NSString *)subject :(NSString *)body
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        //Display Email Composer
        
        MFMailComposeViewController *pickerMail = [[MFMailComposeViewController alloc] init];
        pickerMail.mailComposeDelegate = self;
        
        [pickerMail setSubject:subject];
        
        // Fill out the email body text
        NSString *emailBody = body;
        [pickerMail setMessageBody:emailBody isHTML:NO];
        [[CCDirector sharedDirector] presentModalViewController:pickerMail animated:YES];
        [pickerMail release];
    } else {
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [[CCDirector sharedDirector]dismissModalViewControllerAnimated:YES];
    
    switch (result) {
        case MFMailComposeResultSent:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Sending Result"
                                  message: @"Email Sent"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            break;
        }
        case MFMailComposeResultSaved:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Email Result"
                                  message: @"Email Saved"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            break;
        }
        case MFMailComposeResultCancelled:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Email Result"
                                  message: @"Email Cancelled"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            break;
        }
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Email Result"
                                  message: @"Email Failed"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            break;
        }
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Email Result"
                                  message: @"Email Other Error"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            break;
        }
    }
}

-(void) showPurchaseAlert:(NSString *) messsage :(int)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flappy Bird" message:messsage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.tag = tag;
    [alert show];
    alert = nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            //cancel
            NSLog(@"NO");
            break;
        case 1:
            NSLog(@"GetLives");
            NSLog(@"YES");
            break;
        default:
            break;
    }
}

-(void) dealloc
{
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
