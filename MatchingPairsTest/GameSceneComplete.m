//
//  GameSceneComplete.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 24/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"

@interface GameSceneComplete ()

@end


@implementation GameSceneComplete
{
    SKSpriteNode *background_LC;
    SKSpriteNode *continueButton_LC;
    SKLabelNode *gameCompleteLabel;
    SKLabelNode *restartLabel;
}

// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Set up actions to fade in
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.3];
    
    // Set up background
    background_LC = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background_LC.size = self.frame.size;
    background_LC.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background_LC.zPosition = -2;
    
    [self addChild:background_LC];
    
    // Set up game complete label
    gameCompleteLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    gameCompleteLabel.text = @"Thanks for playing!";
    gameCompleteLabel.fontSize = 100;
    gameCompleteLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameCompleteLabel.zPosition = 3;
    gameCompleteLabel.alpha = 0;
    
    [self addChild:gameCompleteLabel];
    
    // Set up continue button
    continueButton_LC = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    continueButton_LC.yScale = 0.5;
    continueButton_LC.xScale = 0.5;
    continueButton_LC.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-200);
    continueButton_LC.alpha = 0;
    continueButton_LC.name = @"continue";
    [self addChild:continueButton_LC];
    
    
    // Fade in labels
    [gameCompleteLabel runAction:fadeIn];
    [continueButton_LC runAction:fadeIn];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        
        if ([node.name isEqualToString:@"continue"])
        {
            GameScene *moveToScene = [[GameScene alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
       
    }
}



@end