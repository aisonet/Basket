//
//  GameLayer.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright 2014 Vojta. All rights reserved.
//

#import "GameLayer.h"
#import "MainMenu.h"
#import "GameOver.h"

#import "AppDelegate.h"
#import "Global.h"

#import <Social/Social.h>


@implementation GameLayer

-(id) init
{
    if ((self = [super init])) {
        self.touchEnabled = YES;
        [self createBackground];
        [self initVariable];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"sndGameStart.aif"];
        
    }
    
    return self;
}

-(void) initVariable
{
    m_iScore = 0;
    m_iCurrentStep = 0;
    m_fInitialTime = DISTANCE_MODE_TIME;
    m_bStartedGame = NO;
    m_fPassedTime = 0;
    m_bTimeModeEnd = NO;
    g_bGameSuccess = NO;
    
    m_aWhiteTile = [[NSMutableArray alloc] init];
    m_aBlackTile = [[NSMutableArray alloc] init];
    m_aRedTile = [[NSMutableArray alloc] init];
    m_aPrint = [[NSMutableArray alloc] init];
    
    CCSprite *tmpSprite = [CCSprite spriteWithFile:@"tileBlack.png"];
    
    NSLog(@"%f, %f", tmpSprite.contentSize.width, tmpSprite.contentSize.height);
    
    float tileScaleX = G_SCALEX * 189.0 / tmpSprite.contentSize.width / g_fScaleR, tileScaleY = G_SCALEY * 230.0 / tmpSprite.contentSize.height / g_fScaleR;
    float gapH = 3, gapW = 2;
    for (int i = -3; i < 4; i++) {
        if (i < 3) {
            int k = arc4random() % 4;
            float cx = 1 + gapW * (k + 1) + 189 * k, cy = gapH * (i + 1) + 230 * i;
            CCSprite *blackSprite = newSprite(@"tileBlack", getX(cx), getY(cy), self, 1, RATIO_XY);
            blackSprite.scaleX = tileScaleX;
            blackSprite.scaleY = tileScaleY;
            blackSprite.tag = 3 - i;
            blackSprite.anchorPoint = ccp(0, 1);
            
            [m_aBlackTile addObject:blackSprite];
        }
        
        for (int j = 0; j < 4; j++) {
            float x = 1 + gapW * (j + 1) + 189 * j, y = gapH * (i + 1) + 230 * i;
            CCSprite *sprite;
            if (i == 3) {
                sprite = newSprite(@"tileGreen", getX(x), getY(y), self, 0, RATIO_XY);
                sprite.opacity = 254;
            } else {
                sprite = newSprite(@"tileWhite", getX(x), getY(y), self, 0, RATIO_XY);
            }
            
            sprite.scaleX = tileScaleX;
            sprite.scaleY = tileScaleY;
            sprite.tag = -1;
            sprite.anchorPoint = ccp(0, 1);
            
            if (i == 3) {
                [m_aPrint addObject: sprite];
                if (j == 1) {
                    m_sFootSprite[0] = newSprite(@"shoe0", getX(x) + sprite.boundingBox.size.width / 2, getY(y) - sprite.boundingBox.size.height / 2, self, 10, RATIO_XY);
                    m_sFootSprite[1] = newSprite(@"shoe1", getX(x) + sprite.boundingBox.size.width / 2, getY(y) - sprite.boundingBox.size.height / 2, self, 10, RATIO_XY);
                    m_sFootSprite[0].scaleX = tileScaleX;
                    m_sFootSprite[0].scaleY = tileScaleY;
                    m_sFootSprite[1].scaleX = tileScaleX;
                    m_sFootSprite[1].scaleY = tileScaleY;
                    sprite.tag = -1;
                    m_sFootSprite[1].visible = NO;
                }
            } else {
                [m_aWhiteTile addObject: sprite];
            }
        }
    }
    
    if (g_iGameMode != 0) {
        [self schedule:@selector(update:) interval:0.01];
    }
}

-(void) createBackground
{
    CCLayerColor *layer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    [self addChild: layer z: -1];
    
    if (g_iGameMode == 0) {
        m_lbtScore = [self newLabel: @"0" :FONT_NAME :56 :ccc3(144, 0, 0) :ccp(getX(750), getY(50))];
    }
    
    if (g_iGameMode == 1) {
        m_lbtTime = [self newLabel: @"0.000\"" :FONT_NAME :56 :ccc3(0, 255, 0) :ccp(getX(750), getY(50))];
    }
    
    if (g_iGameMode == 2) {
        m_lbtTime = [self newLabel: @"0.000\"" :FONT_NAME :56 :ccc3(0, 255, 0) :ccp(getX(750), getY(50))];
        m_lbtScore = [self newLabel: @"0" :FONT_NAME :56 :ccc3(255, 0, 0) :ccp(getX(750), getY(100))];
    }
}

-(CCLabelTTF*) newLabel:(NSString*)str :(NSString*)fontName :(int)size :(ccColor3B)color :(CGPoint)pos
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:fontName fontSize:size];
    label.scale = G_SCALEX / g_fScaleR;
    [self addChild: label z:99];
    [label setColor:color];
    label.anchorPoint = ccp(1, 0.5);
    label.position = pos;
    
    return label;
}

#pragma mark -ClickActions

-(void) gameEnd
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //int runCnt = [userDefaults integerForKey:@"ADS"];
    
    //AppController *delegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    //if (runCnt % 2) [delegate hideADS];
    //else [delegate hideBanner];
    
    CCScene *scene = [CCScene node];
    GameOver *layer = [GameOver node];
    layer.position = ccp(0, 0);
    if (g_iGameMode == 0) [layer setSurvivalScore: m_iScore];
    if (g_iGameMode == 1) [layer setTimeScore: m_fPassedTime];
    if (g_iGameMode == 2) [layer setDistanceScore: m_iScore];
    [scene addChild: layer];
    
    [[CCDirector sharedDirector] replaceScene: scene];
}

-(void) onEndDeadAnimation:(ccTime) dt
{
    
}

-(void) onGameSuccess:(ccTime) dt
{
    g_bGameSuccess = YES;
    [self unschedule: @selector(onGameSuccess:)];
    [self gameEnd];
}

#pragma mark -GameEngine

-(void) update:(ccTime)dt
{
    if (g_iGameMode == 1) {
        m_fPassedTime += dt;
        [m_lbtTime setString: [NSString stringWithFormat: @"%.3f", m_fPassedTime]];
    }
    
    if (g_iGameMode == 2) {
        m_fInitialTime -= dt;
        [m_lbtTime setString: [NSString stringWithFormat: @"%.3f", m_fInitialTime]];
        
        if (m_fInitialTime < 0) {
            g_bGameSuccess = YES;
            [self gameEnd];
        }
    }
    
    int speedY = 6 + m_iCurrentStep / SURVIVAL_MODE_DIFFICULTY;
    if (speedY > SURVIVAL_MODE_HIGHSPEED) speedY = SURVIVAL_MODE_HIGHSPEED;
    if (g_iGameMode != 0) speedY = 0;
    speedY *= G_SCALEY / g_fScaleR;
    
    m_sFootSprite[0].position = ccp(m_sFootSprite[0].position.x, m_sFootSprite[0].position.y - speedY);
    m_sFootSprite[1].position = ccp(m_sFootSprite[1].position.x, m_sFootSprite[1].position.y - speedY);
    
    if (m_sFootSprite[0].position.y < - 100 * G_SCALEY / g_fScaleR)
        [self gameEnd];
    
    for (int i = m_aRedTile.count - 1; i >= 0; i--) {
        CCSprite *sprite = (CCSprite*) [m_aRedTile objectAtIndex:i];
        sprite.position = ccp(sprite.position.x, sprite.position.y - speedY);
    }
    
    for (int i = m_aPrint.count - 1; i >= 0; i--) {
        CCSprite *sprite = (CCSprite*) [m_aPrint objectAtIndex:i];
        sprite.position = ccp(sprite.position.x, sprite.position.y - speedY);
        
        if (sprite.position.y < -200 * G_SCALEY / g_fScaleR) {
            [m_aPrint removeObject: sprite];
            [self removeChild: sprite cleanup:YES];
        }
    }
    
    for (int i = 0; i < m_aWhiteTile.count; i++) {
        CCSprite *sprite = (CCSprite*) [m_aWhiteTile objectAtIndex:i];
        sprite.position = ccp(sprite.position.x, sprite.position.y - speedY);
        
        if (sprite.position.y < 0) {
            if(g_iGameMode == 1 && m_bTimeModeEnd) continue;
            sprite.position = ccp(sprite.position.x, sprite.position.y + (3.0 + 230.0) * 6.0 * G_SCALEY / g_fScaleR);
            sprite.opacity = 255;
        }
    }
    
    for (int i = 0; i < m_aBlackTile.count; i++) {
        CCSprite *sprite = (CCSprite*) [m_aBlackTile objectAtIndex:i];
        sprite.position = ccp(sprite.position.x, sprite.position.y - speedY);
        
        if (sprite.position.y < 0) {
            if(g_iGameMode == 1 && m_bTimeModeEnd) continue;
            
            int k = arc4random() % 4;
            float cx = 1 + 2.0 * (k + 1) + 189 * k;
            sprite.position = ccp(getX(cx), sprite.position.y + (3.0 + 230.0) * 6.0 * G_SCALEY / g_fScaleR);
            sprite.tag += 6;
            
            if (sprite.tag == TIME_MODE_LENGTH && g_iGameMode == 1) {
                m_bTimeModeEnd = YES;
                for (int j = 0; j < 4; j ++) {
                    float x = 1 + 2 * (j + 1) + 189 * j;
                    CCSprite *redSprite;
                    redSprite = newSprite(@"tileRed", getX(x), sprite.position.y, self, 5, RATIO_XY);
                    redSprite.scaleX = sprite.scaleX;
                    redSprite.scaleY = sprite.scaleY;
                    redSprite.tag = -1;
                    redSprite.anchorPoint = ccp(0.0, 1.0);
                    NSLog(@"%f, %f", sprite.position.y, redSprite.position.y);
                    [m_aRedTile addObject: redSprite];
                }
            }
            sprite.opacity = 255;
        }
    }
}

- (void) startStepBlackTile
{
    self.touchEnabled = NO;
    [m_sFootSprite[0] runAction: [CCMoveBy actionWithDuration:0.05 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    [m_sFootSprite[1] runAction: [CCMoveBy actionWithDuration:0.05 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    
    for (int i = m_aPrint.count - 1; i >= 0; i--) {
        CCSprite *sprite = (CCSprite*) [m_aPrint objectAtIndex:i];
        [sprite runAction: [CCMoveBy actionWithDuration:0.01 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    }
    for (int i = 0; i < m_aWhiteTile.count; i++) {
        CCSprite *sprite = (CCSprite*) [m_aWhiteTile objectAtIndex:i];
        [sprite runAction: [CCMoveBy actionWithDuration:0.01 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    }
    for (int i = 0; i < m_aBlackTile.count; i++) {
        CCSprite *sprite = (CCSprite*) [m_aBlackTile objectAtIndex:i];
        [sprite runAction: [CCMoveBy actionWithDuration:0.01 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    }
    for (int i = 0; i < m_aRedTile.count; i++) {
        CCSprite *sprite = (CCSprite*) [m_aRedTile objectAtIndex:i];
        [sprite runAction: [CCMoveBy actionWithDuration:0.01 position:ccp(0, -233.0 * G_SCALEY / g_fScaleR)]];
    }
    
    [self schedule: @selector(endStepBlackTile:) interval:0.06];
}

- (void) endStepBlackTile:(ccTime)dt
{
    [self unschedule: @selector(endStepBlackTile:)];
    self.touchEnabled = YES;
}

#pragma mark -TouchDelegate

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    
    if (!m_bStartedGame) {
        m_bStartedGame = YES;
        if (g_iGameMode == 0) [self schedule:@selector(update:) interval:0.01];
    }
    
    if (g_iGameMode == 0) {
        for (int i = 0; i < m_aBlackTile.count; i++) {
            CCSprite *sprite = (CCSprite*) [m_aBlackTile objectAtIndex:i];
            
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                if (sprite.tag != m_iCurrentStep + 1) return;
                if (sprite.opacity == 254) continue;
                
                m_iCurrentStep++;
                CCSprite *printSrptie = newSprite([NSString stringWithFormat: @"print%d", m_iCurrentStep % 2], sprite.position.x + sprite.boundingBox.size.width / 2, sprite.position.y - sprite.boundingBox.size.height / 2, self, 2, RATIO_XY);
                printSrptie.scaleX = sprite.scaleX * 0.9;
                printSrptie.scaleY = sprite.scaleY * 0.9;
                [m_aPrint addObject: printSrptie];
                sprite.opacity = 254;
                
                m_sFootSprite[0].position = printSrptie.position;
                m_sFootSprite[1].position = printSrptie.position;
                m_sFootSprite[0].visible = NO;
                m_sFootSprite[1].visible = NO;
                m_sFootSprite[m_iCurrentStep % 2].visible = YES;
                
                m_iScore++;
                [m_lbtScore setString: [NSString stringWithFormat: @"%d", m_iScore]];
                
                [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"sndStep%d.aif", arc4random() % 8]];
                
                return;
            }
        }
        
        for (int i = 0; i < m_aWhiteTile.count; i++) {
            CCSprite *sprite = (CCSprite*) [m_aWhiteTile objectAtIndex:i];
            
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"sndIncorrect.aif"];
                
                [self unschedule:@selector(update:)];
                
                sprite.anchorPoint = ccp(0.5, 0.5);
                sprite.position = ccpAdd(sprite.position, ccp(sprite.boundingBox.size.width / 2, -sprite.boundingBox.size.height / 2));
                [sprite setZOrder:999];
                [sprite runAction: [CCSequence actions: [CCScaleTo actionWithDuration:0.5 scaleX:sprite.scaleX * 2 scaleY:sprite.scaleY * 2], [CCDelayTime actionWithDuration:0.5], [CCCallFunc actionWithTarget:self selector:@selector(gameEnd)], nil]];
                
                return;
            }
        }
    } else {
        for (int i = 0; i < m_aRedTile.count; i++) {
            CCSprite *sprite = (CCSprite*) [m_aRedTile objectAtIndex:i];
            
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                m_iCurrentStep++;
                CCSprite *printSrptie = newSprite([NSString stringWithFormat: @"print%d", m_iCurrentStep % 2], sprite.position.x + sprite.boundingBox.size.width / 2, sprite.position.y - sprite.boundingBox.size.height / 2, self, 2, RATIO_XY);
                printSrptie.scaleX = sprite.scaleX * 0.9;
                printSrptie.scaleY = sprite.scaleY * 0.9;
                [m_aPrint addObject: printSrptie];
                sprite.opacity = 254;
                
                m_sFootSprite[0].position = printSrptie.position;
                m_sFootSprite[1].position = printSrptie.position;
                m_sFootSprite[0].visible = NO;
                m_sFootSprite[1].visible = NO;
                m_sFootSprite[m_iCurrentStep % 2].visible = YES;
                self.touchEnabled = NO;
                [self unschedule: @selector(update:)];
                [self schedule:@selector(onGameSuccess:) interval:0.5];
                
                return;
            }
        }
        
        for (int i = 0; i < m_aBlackTile.count; i++) {
            CCSprite *sprite = (CCSprite*) [m_aBlackTile objectAtIndex:i];
            
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                if (sprite.tag != m_iCurrentStep + 1) return;
                if (sprite.opacity == 254) return;
                
                m_iCurrentStep++;
                CCSprite *printSrptie = newSprite([NSString stringWithFormat: @"print%d", m_iCurrentStep % 2], sprite.position.x + sprite.boundingBox.size.width / 2, sprite.position.y - sprite.boundingBox.size.height / 2, self, 2, RATIO_XY);
                printSrptie.scaleX = sprite.scaleX * 0.9;
                printSrptie.scaleY = sprite.scaleY * 0.9;
                [m_aPrint addObject: printSrptie];
                sprite.opacity = 254;
                
                m_sFootSprite[0].position = printSrptie.position;
                m_sFootSprite[1].position = printSrptie.position;
                m_sFootSprite[0].visible = NO;
                m_sFootSprite[1].visible = NO;
                m_sFootSprite[m_iCurrentStep % 2].visible = YES;
                
                [self startStepBlackTile];
                
                m_iScore++;
                [m_lbtScore setString: [NSString stringWithFormat: @"%d", m_iScore]];
                
                [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"sndStep%d.aif", arc4random() % 8]];
                return;
            }
        }
        
        for (int i = 0; i < m_aWhiteTile.count; i++) {
            CCSprite *sprite = (CCSprite*) [m_aWhiteTile objectAtIndex:i];
            
            if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"sndIncorrect.aif"];
                [self unschedule:@selector(update:)];
                
                sprite.anchorPoint = ccp(0.5, 0.5);
                sprite.position = ccpAdd(sprite.position, ccp(sprite.boundingBox.size.width / 2, -sprite.boundingBox.size.height / 2));
                [sprite setZOrder:999];
                [sprite runAction: [CCSequence actions: [CCScaleTo actionWithDuration:0.5 scaleX:sprite.scaleX * 2 scaleY:sprite.scaleY * 2], [CCDelayTime actionWithDuration:0.5], [CCCallFunc actionWithTarget:self selector:@selector(gameEnd)], nil]];
                
                return;
            }
        }
    }
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
}

-(void) dealloc
{
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
