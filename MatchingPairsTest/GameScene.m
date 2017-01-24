//
//  GameScene.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 24/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property (strong, nonatomic) SKNode *introCard1;
@property (strong, nonatomic) SKNode *introCard2;

@end

@implementation GameScene
{
    SKSpriteNode *background_S;
    SKSpriteNode *exampleNoteCard;
    SKSpriteNode *exampleLetterCard;
    SKSpriteNode *continueButton;
    SKLabelNode *titleLabel;
    SKLabelNode *mainText;
    SKLabelNode *mainText2;
    SKLabelNode *mainText3;
}

// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Call introSetup method
    [self introSetup];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if ([node.name isEqualToString:@"continue"]) // if the continue button is touched, move to next scene.
        {
            GameScenePractice *moveToScene = [[GameScenePractice alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
    }
}


/*SETUP METHOD, CALLED IN didMoveToView METHOD TO ADD LABELS AND SPRITES.*/
-(void)introSetup
{
    // Set up background
    background_S = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background_S.size = self.frame.size;
    background_S.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background_S.zPosition = -2;
    [self addChild:background_S];
    
    // Set up title label
    titleLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    titleLabel.text = @"Matching Notes";
    titleLabel.fontSize = 100;
    titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+ 250);
    titleLabel.zPosition = 3;
    titleLabel.alpha = 0;
    [self addChild:titleLabel];
    
    // Set up main text label
    mainText = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    mainText.fontSize = 30;
    mainText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+150);
    mainText.zPosition = 3;
    mainText.alpha = 0;
    mainText.text = @"Match the musical note cards to their corresponding note letters";
    [self addChild:mainText];
    
    // Set up another main text label
    mainText2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    mainText2.fontSize = 30;
    mainText2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-170);
    mainText2.zPosition = 3;
    mainText2.alpha = 0;
    mainText2.text = @"Tap a card to select or deselect it and you'll hear the corresponding note";
    [self addChild:mainText2];
    
    continueButton = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    continueButton.yScale = 0.5;
    continueButton.xScale = 0.5;
    continueButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-270);
    continueButton.alpha = 0;
    continueButton.name = @"continue";
    [self addChild:continueButton];
    
    // Set up example card sprites
    exampleNoteCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
    exampleNoteCard.yScale = 0.5;
    exampleNoteCard.xScale = 0.5;
    exampleNoteCard.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame));
    exampleNoteCard.alpha = 0;
    [self addChild:exampleNoteCard];
    
    exampleLetterCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
    exampleLetterCard.yScale = 0.5;
    exampleLetterCard.xScale = 0.5;
    exampleLetterCard.position = CGPointMake(CGRectGetMidX(self.frame)+100, CGRectGetMidY(self.frame));
    exampleLetterCard.alpha = 0;
    [self addChild:exampleLetterCard];
    
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    
    // Fade in all labels and sprites
    [titleLabel runAction:fadeIn];
    [mainText runAction:fadeIn];
    [mainText2 runAction:fadeIn];
    [mainText3 runAction:fadeIn];
    [continueButton runAction:fadeIn];
    [exampleLetterCard runAction:fadeIn];
    [exampleNoteCard runAction:fadeIn];
    
}

@end
