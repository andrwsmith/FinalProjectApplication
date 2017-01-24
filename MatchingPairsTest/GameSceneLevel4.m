//
//  GameSceneLevel4.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 21/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//


#import "GameScene.h"

@interface GameSceneLevel4 ()

@property (strong, nonatomic) SKNode *Card1_L4;
@property (strong, nonatomic) SKNode *Card2_L4;

@end

@implementation GameSceneLevel4
{
    SKSpriteNode *staveCard;
    SKSpriteNode *speakerCard;
    SKSpriteNode *background_L4;
    SKSpriteNode *healthMeter_L4;
    SKSpriteNode *nextLevelButton_L4;
    SKSpriteNode *gameOverButton_L4;
    SKLabelNode *scoreLabel_L4;
    SKLabelNode *clefLabel_L4;
    SKLabelNode *levelLabel_L4;
    SKLabelNode *gameOverLabel_L4;
    SKLabelNode *levelCompleteLabel_L4;
    SKTexture *FullHealthMeter3;
    SKTexture *HealthMeter3m1;
    SKTexture *HealthMeter3m2;
    SKTexture *EmptyHealthMeter3;
    SKSpriteNode *medal;
    SKTexture *gold;
    SKTexture *silver;
    SKTexture *bronze;
    SKTexture *platinum;
}

int grid_L4[9]; // used to store card in each grid position for musical stave cards
int grid2_L4[9]; // used to store card in each grid position for speaker note cards
int xGridSize_L4 = 160; // used to size grid x axis
int yGridSize_L4 = 200; // used to size grid y axis
int currentScore_L4 = 0;
int correctMatches_L4 = 0;
int scoreMultiplier_L4 = 1;
int healthCount_L4 = 3;
BOOL selectedCard_L4 = NO;

// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Reset variables incase returning from game over state
    currentScore_L4 = 0;
    correctMatches_L4 = 0;
    scoreMultiplier_L4 = 1;
    healthCount_L4 = 3;
    selectedCard_L4 = NO;
    
    // run method to set up various labels and life meter textures
    [self levelSetup];
    
    switch(arc4random_uniform(3))
    {
        case 0:
            [self randomCards1_L4];
            break;
        case 1:
            [self randomCards2_L4];
            break;
        case 2:
            [self randomCards3_L4];
            break;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        // set up actions for card animations
        SKAction *scaleTo = [SKAction scaleTo:0.55 duration:0.2];
        SKAction *scaleBy = [SKAction scaleTo:0.5 duration:0.2];
        SKAction *fade = [SKAction fadeAlphaTo:0.7 duration:0.2];
        SKAction *resetFade = [SKAction fadeAlphaTo:1.0 duration:0.2];
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.3];
        SKAction *remove = [SKAction removeFromParent];
        
        // set up action sequences for card animations
        SKAction *highlight = [SKAction sequence:@[scaleTo,fade]];
        SKAction *unhighlight = [SKAction sequence:@[scaleBy,resetFade]];
        SKAction *successfulMatch = [SKAction sequence:@[fadeOut, remove]];
        
        
        if ((![node.name isEqualToString:@"other"])) // if the node touched corresponds to a card sprite node...
        {
            
            if (selectedCard_L4 == NO) // if first card is touched...
            {
                selectedCard_L4 = YES; // set state to yes
                _Card1_L4 = node; // save the card's state
                
                [_Card1_L4 runAction:highlight]; // run action to highlight the card
                NSLog(@"Name of first card is %@", _Card1_L4.name);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card1_L4.name];
            }
            
            else if (selectedCard_L4 == YES) // if second card is touched...
            {
                _Card2_L4 = node; // save the card's state
                NSLog(@"Name of second card is %@", _Card2_L4.name);
                
                [_Card2_L4 runAction:highlight];
                
                if (_Card1_L4.name == _Card2_L4.name) // if names match, then the match is successful...
                {
                    
                    if (_Card2_L4 == _Card1_L4) // ...but if the second touch is the same as the first...
                    {
                        [_Card1_L4 runAction: unhighlight];
                    }
                    
                    else if (_Card1_L4.zPosition == _Card2_L4.zPosition) // ...or if both cards are the same type...
                    {
                        [_Card1_L4 runAction: unhighlight];
                        [_Card2_L4 runAction: unhighlight];
                        [self lifeMeter_L4]; // lose a heart, so call life meter method
                    }
                    
                    else
                    {
                        // Fade out both cards and remove
                        NSLog(@"Correct match!");
                        [_Card1_L4 runAction:successfulMatch];
                        [_Card2_L4 runAction:successfulMatch];
                        
                        correctMatches_L4 = correctMatches_L4 + 1;
                        
                        // Handle scoring
                        
                        currentScore_L4 = (currentScore_L4 + (1 * scoreMultiplier_L4)); // add points
                        
                        scoreMultiplier_L4 = scoreMultiplier_L4 + 1; // every correct answer adds 1 to multiplier
                        
                        scoreLabel_L4.text = [NSString stringWithFormat:@"Score: %d", currentScore_L4]; // update label
                    }
                }
                
                else // otherwise, if the names don't match, the match is unsuccessful.
                {
                    // Unhighlight both cards
                    NSLog(@"Incorrect match!");
                    [_Card1_L4 runAction:unhighlight];
                    [_Card2_L4 runAction:unhighlight];
                    
                    // Handle scoring
                    [self lifeMeter_L4];
                }
                
                selectedCard_L4 = NO; // Reset the state of selectedCard
                NSLog(@"selectedCard state is = %hhd", selectedCard_L4);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card2_L4.name];
                
            }
        }
        
        // Call levelComplete method
        [self levelComplete_L4];
        
        if ([node.name isEqualToString:@"nextLevel"]) // When level is complete, press button to move to next level
        {
            GameSceneLevel5 *moveToScene = [[GameSceneLevel5 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
        
        if ([node.name isEqualToString:@"gameOverButton"]) // If it's game over, press button to restart level
        {
            GameSceneLevel4 *moveToScene = [[GameSceneLevel4 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
    }
}



/******ADDITIONAL METHODS******/


/*THIS METHOD IS USED TO SET UP VARIOUS LABELS, SPRITES AND TEXTURES. CALLED IN THE didMoveToView METHOD */
-(void)levelSetup
{
    // Set up background
    background_L4 = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background_L4.name = @"other";
    background_L4.size = self.frame.size;
    background_L4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background_L4.zPosition = -2; // keep the background behind everything else
    
    [self addChild:background_L4];
    
    // Set up score label
    scoreLabel_L4 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    scoreLabel_L4.text = @"Score: 0";
    scoreLabel_L4.fontSize = 30;
    scoreLabel_L4.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+280);
    scoreLabel_L4.name = @"other";
    
    [self addChild:scoreLabel_L4];
    
    // Set up clef label
    clefLabel_L4 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    clefLabel_L4.text = @"Clef: Treble";
    clefLabel_L4.fontSize = 30;
    clefLabel_L4.position = CGPointMake(CGRectGetMidX(self.frame)-390, CGRectGetMidY(self.frame)+330);
    clefLabel_L4.name = @"other";
    
    [self addChild:clefLabel_L4];
    
    // Set up level label
    levelLabel_L4 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelLabel_L4.text = @"Level: 4";
    levelLabel_L4.fontSize = 30;
    levelLabel_L4.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+330);
    levelLabel_L4.name = @"other";
    
    [self addChild:levelLabel_L4];
    
    // Set up game over label
    gameOverLabel_L4 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    gameOverLabel_L4.text = @"Game Over!";
    gameOverLabel_L4.fontSize = 100;
    gameOverLabel_L4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverLabel_L4.name = @"other";
    gameOverLabel_L4.zPosition = 3;
    gameOverLabel_L4.alpha = 0;
    
    [self addChild:gameOverLabel_L4];
    
    // Set up "next level" Button
    nextLevelButton_L4 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    nextLevelButton_L4.yScale = 0.5;
    nextLevelButton_L4.xScale = 0.5;
    nextLevelButton_L4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    nextLevelButton_L4.name = @"nextLevel";
    nextLevelButton_L4.zPosition = 3;
    nextLevelButton_L4.alpha = 0;
    
    [self addChild:nextLevelButton_L4];
    
    // Set up "game over" Button
    gameOverButton_L4 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    gameOverButton_L4.yScale = 0.5;
    gameOverButton_L4.xScale = 0.5;
    gameOverButton_L4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    gameOverButton_L4.name = @"gameOverButton";
    gameOverButton_L4.zPosition = 3;
    gameOverButton_L4.alpha = 0;
    
    [self addChild:gameOverButton_L4];
    
    // Set up "level complete" label
    levelCompleteLabel_L4 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelCompleteLabel_L4.text = @"Level Complete!";
    levelCompleteLabel_L4.fontSize = 100;
    levelCompleteLabel_L4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+120);
    levelCompleteLabel_L4.name = @"other";
    levelCompleteLabel_L4.zPosition = 3;
    levelCompleteLabel_L4.alpha = 0;
    
    [self addChild:levelCompleteLabel_L4];
    
    // Set up medal textures and sprite
    platinum = [SKTexture textureWithImageNamed:@"PlatinumV2"];
    gold = [SKTexture textureWithImageNamed:@"GoldV2"];
    silver = [SKTexture textureWithImageNamed:@"SilverV2"];
    bronze = [SKTexture textureWithImageNamed:@"BronzeV2"];
    
    medal = [SKSpriteNode spriteNodeWithTexture:bronze];
    medal.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50);
    medal.xScale = 0.5;
    medal.yScale = 0.5;
    medal.zPosition = 6;
    medal.name = @"other";
    medal.alpha = 0;
    
    [self addChild:medal];
    
    // Set up health meter textures and sprite
    FullHealthMeter3 = [SKTexture textureWithImageNamed:@"FullHealthMeter3"];
    HealthMeter3m1 = [SKTexture textureWithImageNamed:@"HealthMeter3-1"];
    HealthMeter3m2 = [SKTexture textureWithImageNamed:@"HealthMeter3-2"];
    EmptyHealthMeter3 = [SKTexture textureWithImageNamed:@"EmptyHealthMeter3"];
    
    healthMeter_L4 = [SKSpriteNode spriteNodeWithTexture:FullHealthMeter3];
    healthMeter_L4.xScale = 0.5;
    healthMeter_L4.yScale = 0.5;
    healthMeter_L4.anchorPoint = CGPointMake(0, 0);
    healthMeter_L4.position = CGPointMake(CGRectGetMidX(self.frame)-470, CGRectGetMidY(self.frame)+255);
    healthMeter_L4.name = @"other";
    
    
    [self addChild:healthMeter_L4];
} // end method


/*THIS METHOD HANDLES THE LIFE METER AND GAME OVER MECHANICS. CALLED IN THE touchesBegan METHOD*/
-(void)lifeMeter_L4
{
    // set up actions for health meter
    SKAction *removeHeart1 = [SKAction setTexture:HealthMeter3m1];
    SKAction *removeHeart2 = [SKAction setTexture:HealthMeter3m2];
    SKAction *emptyHearts = [SKAction setTexture:EmptyHealthMeter3];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.5];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *fadeOutSequence = [SKAction sequence:@[fadeOut, remove]];
    
    // Handle score multiplier
    scoreMultiplier_L4 = 1;
    
    // Handle health meter
    healthCount_L4 = healthCount_L4 - 1; // lose a heart from health meter for incorrect match
    
    if (healthCount_L4 == 2)
    {
        [healthMeter_L4 runAction:removeHeart1];
    }
    else if(healthCount_L4 == 1)
    {
        [healthMeter_L4 runAction:removeHeart2];
    }
    else if(healthCount_L4 == 0)
    {
        [healthMeter_L4 runAction:emptyHearts];
        [gameOverLabel_L4 runAction:fadeIn];
        [gameOverButton_L4 runAction:fadeIn];
        
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"C"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"D"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"E"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"F"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"G"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"A"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"B"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"C2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"D2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"E2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"F2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"G2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"A2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"DS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"AS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"CS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"FS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GF"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"BF"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"DF2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"EF2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GF2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"AF2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
    }
} // end method



/*THIS METHOD PLAYS THE CORRESPONDING NOTE AUDIO WHEN A CARD IS PRESSED. CALLED IN THE touchesBegan METHOD*/
-(void)playSoundsForCardWithName:(NSString *)cardName
{
    if ([cardName isEqualToString: @"C"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"D"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"E"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A E1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"F"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"G"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"A"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"B"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A B1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"C2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"D2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"E2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A E2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"F2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"G2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"A2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"DS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"AS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"CS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"FS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"BF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"DF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"EF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"AF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G#2" waitForCompletion:NO]];
    }
    
} // end method



/*THIS METHOD HANDLES THE LEVEL COMPLETE MECHANIC. CALLED IN touchesBegan*/
-(void)levelComplete_L4
{
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.2];
    SKAction *bronzeTexture = [SKAction setTexture:bronze];
    SKAction *silverTexture = [SKAction setTexture:silver];
    SKAction *goldTexture = [SKAction setTexture:gold];
    SKAction *platinumTexture = [SKAction setTexture:platinum];
    
    if (correctMatches_L4 == 9) // when all nine matches are made, the level is complete.
    {
        [levelCompleteLabel_L4 runAction:fadeIn];
        [nextLevelButton_L4 runAction:fadeIn];
        
        // award a medal.
        
        if (currentScore_L4 == 45 && healthCount_L4 == 3) // highest possible score and max. hearts awards best medal
        {
            [medal runAction:platinumTexture];
        }
        else if (healthCount_L4 == 2)
        {
            [medal runAction:goldTexture];
        }
        else if (healthCount_L4 == 1)
        {
            [medal runAction:silverTexture];
        }
        else
        {
            [medal runAction:bronzeTexture];
        }
        
        [medal runAction:fadeIn];
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards1_L4
{
    int i, j;
    int randomCard = 0;
    int randomSpeakerCard = 0;
    
    // Create the first grid of stave card sprites. Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomCard)
            {
                case 0:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_DF2"];
                    staveCard.name = @"DF2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS2"];
                    staveCard.name = @"FS2";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name= @"B";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F2"];
                    staveCard.name = @"F2";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AS"];
                    staveCard.name = @"AS";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_BF"];
                    staveCard.name = @"BF";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name = @"E2";
                    break;
            }
            
            grid_L4[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L4)+112),((j*yGridSize_L4)+120));
            staveCard.zPosition = 5;
            [self addChild:staveCard];
            
            randomCard = randomCard + 1; // add 1 to the switch statement variable
        }
    }
    
    
    // Create second grid for speaker card sprites. Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomSpeakerCard)
            {
                case 0:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AS"];
                    speakerCard.name = @"AS";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_BF"];
                    speakerCard.name = @"BF";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS2"];
                    speakerCard.name = @"FS2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F2"];
                    speakerCard.name = @"F2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_DF2"];
                    speakerCard.name = @"DF2";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
            }
            
            grid2_L4[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L4)+600),((j*yGridSize_L4)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards2_L4
{
    int i, j;
    int randomCard = 0;
    int randomSpeakerCard = 0;
    
    // Create the first grid of stave card sprites. Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomCard)
            {
                case 0:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_DS"];
                    staveCard.name = @"DS";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A2"];
                    staveCard.name= @"A2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GF2"];
                    staveCard.name = @"GF2";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name = @"E2";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_EF2"];
                    staveCard.name = @"EF2";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GS"];
                    staveCard.name = @"GS";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
            }
            
            grid_L4[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L4)+112),((j*yGridSize_L4)+120));
            staveCard.zPosition = 5;
            [self addChild:staveCard];
            
            randomCard = randomCard + 1;
        }
    }
    
    
    // Create second grid for speaker card sprites.  Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomSpeakerCard)
            {
                case 0:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GF2"];
                    speakerCard.name = @"GF2";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_EF2"];
                    speakerCard.name = @"EF2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A2"];
                    speakerCard.name = @"A2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GS"];
                    speakerCard.name = @"GS";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_DS"];
                    speakerCard.name = @"DS";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
            }
            
            grid2_L4[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L4)+600),((j*yGridSize_L4)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method



/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards3_L4
{
    int i, j;
    int randomCard = 0;
    int randomSpeakerCard = 0;
    
    // Create the first grid of stave card sprites. Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomCard)
            {
                case 0:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AF2"];
                    staveCard.name = @"AF2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GF"];
                    staveCard.name = @"GF";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A2"];
                    staveCard.name= @"A2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_CS2"];
                    staveCard.name = @"CS2";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS2"];
                    staveCard.name = @"FS2";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D2"];
                    staveCard.name = @"D2";
                    break;
            }
            
            grid_L4[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L4)+112),((j*yGridSize_L4)+120));
            staveCard.zPosition = 5;
            [self addChild:staveCard];
            
            randomCard = randomCard + 1;
        }
    }
    
    
    // Create second grid for speaker card sprites. Each switch statement case is added to a grid position on each
    // run through of the for loops.
    
    for (j = 0; j < 3; j++)
    {
        for (i = 0; i < 3; i ++)
        {
            switch (randomSpeakerCard)
            {
                case 0:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A2"];
                    speakerCard.name = @"A2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS2"];
                    speakerCard.name = @"FS2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_CS2"];
                    speakerCard.name = @"CS2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GF"];
                    speakerCard.name = @"GF";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AF2"];
                    speakerCard.name = @"AF2";
                    break;
            }
            
            grid2_L4[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L4)+600),((j*yGridSize_L4)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


@end

