//
//  IntroLayer.m
//  WhiteTile
//
//  Created by Vojta on 4/2/14.
//  Copyright Vojta 2014. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "SelectMode.h"
#import "GameLayer.h"
#import "Global.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {

		// ask director for the window size
		self.touchEnabled = YES;
        [self createBackground];
	}
	
	return self;
}

- (void) createBackground
{
    newSprite(@"main_bg", G_SWIDTH / 2, G_SHEIGHT / 2, self, -1, RATIO_XY);
    
    if (g_iGameMode == 0) {
        [self newLabel: @"SCORE YOU WANT TO MAKE?" :FONT_NAME :48 :ccc3(0,255,0) :ccp(G_SWIDTH / 2, getY(400))];
    } else if (g_iGameMode == 1) {
        [self newLabel: @"HOW FAST YOU WANT TO SCORE?" :FONT_NAME :48 :ccc3(0,255,0) :ccp(G_SWIDTH / 2, getY(400))];
    } else {
        [self newLabel: @"SCORE YOU WANT TO MAKE IN 60\nSECONDS?!" :FONT_NAME :48 :ccc3(0,255,0) :ccp(G_SWIDTH / 2, getY(400))];
    }
    
    [self newLabel: @"TAP ANYWHERE TO PLAY!" :FONT_NAME :48 :ccc3(0,255,0) :ccp(G_SWIDTH / 2, getY(820))];
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

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[CCDirector sharedDirector] replaceScene: [GameLayer node]];
}

-(void) dealloc
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
