//
//  GameSceneLevel5.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 21/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"

@interface GameSceneLevel5 ()

@property (strong, nonatomic) SKNode *Card1_L5;
@property (strong, nonatomic) SKNode *Card2_L5;

@end

@implementation GameSceneLevel5
{
    SKSpriteNode *staveCard;
    SKSpriteNode *speakerCard;
    SKSpriteNode *background_L5;
    SKSpriteNode *healthMeter_L5;
    SKSpriteNode *nextLevelButton_L5;
    SKSpriteNode *gameOverButton_L5;
    SKLabelNode *scoreLabel_L5;
    SKLabelNode *clefLabel_L5;
    SKLabelNode *levelLabel_L5;
    SKLabelNode *gameOverLabel_L5;
    SKLabelNode *levelCompleteLabel_L5;
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

int grid_L5[9]; // used to store card in each grid position for musical stave cards
int grid2_L5[9]; // used to store card in each grid position for speaker note cards
int xGridSize_L5 = 160; // used to size grid x axis
int yGridSize_L5 = 200; // used to size grid y axis
int currentScore_L5 = 0;
int correctMatches_L5 = 0;
int scoreMultiplier_L5 = 1;
int healthCount_L5 = 3;
BOOL selectedCard_L5 = NO;

// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Reset variables incase returning from game over state
    currentScore_L5 = 0;
    correctMatches_L5 = 0;
    scoreMultiplier_L5 = 1;
    healthCount_L5 = 3;
    selectedCard_L5 = NO;
    
    // run method to set up various labels and life meter textures
    [self levelSetup];
    
    switch(arc4random_uniform(3))
    {
        case 0:
            [self randomCards1_L5];
            break;
        case 1:
            [self randomCards2_L5];
            break;
        case 2:
            [self randomCards3_L5];
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
            
            if (selectedCard_L5 == NO) // if first card is touched...
            {
                selectedCard_L5 = YES; // set state to yes
                _Card1_L5 = node; // save the card's state
                
                [_Card1_L5 runAction:highlight]; // run action to highlight the card
                NSLog(@"Name of first card is %@", _Card1_L5.name);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card1_L5.name];
            }
            
            else if (selectedCard_L5 == YES) // if second card is touched...
            {
                _Card2_L5 = node; // save the card's state
                NSLog(@"Name of second card is %@", _Card2_L5.name);
                
                [_Card2_L5 runAction:highlight];
                
                if (_Card1_L5.name == _Card2_L5.name) // if names match, then the match is successful...
                {
                    
                    if (_Card2_L5 == _Card1_L5) // ...but if the second touch is the same as the first...
                    {
                        [_Card1_L5 runAction: unhighlight];
                    }
                    
                    else if (_Card1_L5.zPosition == _Card2_L5.zPosition) // ...or if both cards are the same type...
                    {
                        [_Card1_L5 runAction: unhighlight];
                        [_Card2_L5 runAction: unhighlight];
                        [self lifeMeter_L5]; // lose a heart, so call life meter method
                    }
                    
                    else
                    {
                        // Fade out both cards and remove
                        NSLog(@"Correct match!");
                        [_Card1_L5 runAction:successfulMatch];
                        [_Card2_L5 runAction:successfulMatch];
                        
                        correctMatches_L5 = correctMatches_L5 + 1;
                        
                        // Handle scoring
                        
                        currentScore_L5 = (currentScore_L5 + (1 * scoreMultiplier_L5)); // add points
                        
                        scoreMultiplier_L5 = scoreMultiplier_L5 + 1; // every correct answer adds 1 to multiplier
                        
                        scoreLabel_L5.text = [NSString stringWithFormat:@"Score: %d", currentScore_L5]; // update label
                    }
                }
                
                else // otherwise, if the names don't match, the match is unsuccessful.
                {
                    // Unhighlight both cards
                    NSLog(@"Incorrect match!");
                    [_Card1_L5 runAction:unhighlight];
                    [_Card2_L5 runAction:unhighlight];
                    
                    // Handle scoring
                    [self lifeMeter_L5];
                }
                
                selectedCard_L5 = NO; // Reset the state of selectedCard
                NSLog(@"selectedCard state is = %hhd", selectedCard_L5);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card2_L5.name];
                
            }
        }
        
        // Call levelComplete method
        [self levelComplete_L5];
        
        if ([node.name isEqualToString:@"nextLevel"]) // When level is complete, press button to move to next level
        {
            GameSceneComplete *moveToScene = [[GameSceneComplete alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
        
        if ([node.name isEqualToString:@"gameOverButton"]) // If it's game over, press button to restart level
        {
            GameSceneLevel5 *moveToScene = [[GameSceneLevel5 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
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
    background_L5 = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background_L5.name = @"other";
    background_L5.size = self.frame.size;
    background_L5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background_L5.zPosition = -2; // keep the background behind everything else
    
    [self addChild:background_L5];
    
    // Set up score label
    scoreLabel_L5 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    scoreLabel_L5.text = @"Score: 0";
    scoreLabel_L5.fontSize = 30;
    scoreLabel_L5.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+280);
    scoreLabel_L5.name = @"other";
    
    [self addChild:scoreLabel_L5];
    
    // Set up clef label
    clefLabel_L5 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    clefLabel_L5.text = @"Clef: Treble";
    clefLabel_L5.fontSize = 30;
    clefLabel_L5.position = CGPointMake(CGRectGetMidX(self.frame)-390, CGRectGetMidY(self.frame)+330);
    clefLabel_L5.name = @"other";
    
    [self addChild:clefLabel_L5];
    
    // Set up level label
    levelLabel_L5 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelLabel_L5.text = @"Level: 5";
    levelLabel_L5.fontSize = 30;
    levelLabel_L5.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+330);
    levelLabel_L5.name = @"other";
    
    [self addChild:levelLabel_L5];
    
    // Set up game over label
    gameOverLabel_L5 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    gameOverLabel_L5.text = @"Game Over!";
    gameOverLabel_L5.fontSize = 100;
    gameOverLabel_L5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverLabel_L5.name = @"other";
    gameOverLabel_L5.zPosition = 3;
    gameOverLabel_L5.alpha = 0;
    
    [self addChild:gameOverLabel_L5];
    
    // Set up "next level" Button
    nextLevelButton_L5 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    nextLevelButton_L5.yScale = 0.5;
    nextLevelButton_L5.xScale = 0.5;
    nextLevelButton_L5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    nextLevelButton_L5.name = @"nextLevel";
    nextLevelButton_L5.zPosition = 3;
    nextLevelButton_L5.alpha = 0;
    
    [self addChild:nextLevelButton_L5];
    
    // Set up "game over" Button
    gameOverButton_L5 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    gameOverButton_L5.yScale = 0.5;
    gameOverButton_L5.xScale = 0.5;
    gameOverButton_L5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    gameOverButton_L5.name = @"gameOverButton";
    gameOverButton_L5.zPosition = 3;
    gameOverButton_L5.alpha = 0;
    
    [self addChild:gameOverButton_L5];
    
    // Set up "level complete" label
    levelCompleteLabel_L5 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelCompleteLabel_L5.text = @"Level Complete!";
    levelCompleteLabel_L5.fontSize = 100;
    levelCompleteLabel_L5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+120);
    levelCompleteLabel_L5.name = @"other";
    levelCompleteLabel_L5.zPosition = 3;
    levelCompleteLabel_L5.alpha = 0;
    
    [self addChild:levelCompleteLabel_L5];
    
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
    
    healthMeter_L5 = [SKSpriteNode spriteNodeWithTexture:FullHealthMeter3];
    healthMeter_L5.xScale = 0.5;
    healthMeter_L5.yScale = 0.5;
    healthMeter_L5.anchorPoint = CGPointMake(0, 0);
    healthMeter_L5.position = CGPointMake(CGRectGetMidX(self.frame)-470, CGRectGetMidY(self.frame)+255);
    healthMeter_L5.name = @"other";
    
    
    [self addChild:healthMeter_L5];
} // end method


/*THIS METHOD HANDLES THE LIFE METER AND GAME OVER MECHANICS. CALLED IN THE touchesBegan METHOD*/
-(void)lifeMeter_L5
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
    scoreMultiplier_L5 = 1;
    
    // Handle health meter
    healthCount_L5 = healthCount_L5 - 1; // lose a heart from health meter for incorrect match
    
    if (healthCount_L5 == 2)
    {
        [healthMeter_L5 runAction:removeHeart1];
    }
    else if(healthCount_L5 == 1)
    {
        [healthMeter_L5 runAction:removeHeart2];
    }
    else if(healthCount_L5 == 0)
    {
        [healthMeter_L5 runAction:emptyHearts];
        [gameOverLabel_L5 runAction:fadeIn];
        [gameOverButton_L5 runAction:fadeIn];
        
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
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"G"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"B"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"F2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"EF"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GF"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"AF"] usingBlock:^(SKNode *node, BOOL *stop) {
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
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"CS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"FS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GS"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"CS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"DS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"FS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"GS2"] usingBlock:^(SKNode *node, BOOL *stop) {
            [node runAction:fadeOutSequence];
            [node removeFromParent];
        }];
        [self enumerateChildNodesWithName:[NSString stringWithFormat:@"AS2"] usingBlock:^(SKNode *node, BOOL *stop) {
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
    
    else if ([cardName isEqualToString:@"G"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"B"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A B1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"F2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"EF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"AF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"BF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"DF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"EF2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"CS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"FS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"CS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"DS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A D#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"FS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"GS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G#2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"AS2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A#2" waitForCompletion:NO]];
    }

    
} // end method


-(void)levelComplete_L5
{
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.2];
    SKAction *bronzeTexture = [SKAction setTexture:bronze];
    SKAction *silverTexture = [SKAction setTexture:silver];
    SKAction *goldTexture = [SKAction setTexture:gold];
    SKAction *platinumTexture = [SKAction setTexture:platinum];
    
    if (correctMatches_L5 == 9) // when all nine matches are made, the level is complete.
    {
        [levelCompleteLabel_L5 runAction:fadeIn];
        [nextLevelButton_L5 runAction:fadeIn];
        
        // award a medal.
        
        if (currentScore_L5 == 45 && healthCount_L5 == 3) // highest possible score and max. hearts awards best medal
        {
            [medal runAction:platinumTexture];
        }
        else if (healthCount_L5 == 2)
        {
            [medal runAction:goldTexture];
        }
        else if (healthCount_L5 == 1)
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
-(void)randomCards1_L5
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GS"];
                    staveCard.name = @"GS";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_CS"];
                    staveCard.name = @"CS";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_EF2"];
                    staveCard.name= @"EF2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_BF"];
                    staveCard.name = @"BF";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AF"];
                    staveCard.name = @"AF";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS"];
                    staveCard.name = @"FS";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AS2"];
                    staveCard.name = @"AS2";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
            }
            
            grid_L5[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L5)+112),((j*yGridSize_L5)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AS2"];
                    speakerCard.name = @"AS2";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS"];
                    speakerCard.name = @"FS";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_BF"];
                    speakerCard.name = @"BF";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_EF2"];
                    speakerCard.name = @"EF2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_CS"];
                    speakerCard.name = @"CS";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AF"];
                    speakerCard.name = @"AF";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GS"];
                    speakerCard.name = @"GS";
                    break;
            }
            
            grid2_L5[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L5)+600),((j*yGridSize_L5)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards2_L5
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS2"];
                    staveCard.name = @"FS2";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E"];
                    staveCard.name= @"E";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_BF"];
                    staveCard.name = @"BF";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GS2"];
                    staveCard.name = @"GS2";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_DS2"];
                    staveCard.name = @"DS2";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AF"];
                    staveCard.name = @"AF";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_EF"];
                    staveCard.name = @"EF";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_DF2"];
                    staveCard.name = @"DF2";
                    break;
            }
            
            grid_L5[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L5)+112),((j*yGridSize_L5)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_DS2"];
                    speakerCard.name = @"DS2";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GS2"];
                    speakerCard.name = @"GS2";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS2"];
                    speakerCard.name = @"FS2";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_DF2"];
                    speakerCard.name = @"DF2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_BF"];
                    speakerCard.name = @"BF";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E"];
                    speakerCard.name = @"E";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AF"];
                    speakerCard.name = @"AF";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_EF"];
                    speakerCard.name = @"EF";
                    break;
            }
            
            grid2_L5[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L5)+600),((j*yGridSize_L5)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards3_L5
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_AS2"];
                    staveCard.name = @"AS2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GF"];
                    staveCard.name = @"GF";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F2"];
                    staveCard.name= @"F2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_EF"];
                    staveCard.name = @"EF";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_BF"];
                    staveCard.name = @"BF";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_CS2"];
                    staveCard.name = @"CS2";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS2"];
                    staveCard.name = @"FS2";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_GS"];
                    staveCard.name = @"GS";
                    break;
            }
            
            grid_L5[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L5)+112),((j*yGridSize_L5)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_BF"];
                    speakerCard.name = @"BF";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_CS2"];
                    speakerCard.name = @"CS2";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_EF"];
                    speakerCard.name = @"EF";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GS"];
                    speakerCard.name = @"GS";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F2"];
                    speakerCard.name = @"F2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_GF"];
                    speakerCard.name = @"GF";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_AS2"];
                    speakerCard.name = @"AS2";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS2"];
                    speakerCard.name = @"FS2";
                    break;
            }
            
            grid2_L5[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L5)+600),((j*yGridSize_L5)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


@end





