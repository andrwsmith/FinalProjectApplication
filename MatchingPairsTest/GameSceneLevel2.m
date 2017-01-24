//
//  GameSceneLevel2.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 16/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"


@interface GameSceneLevel2 ()

@property (strong, nonatomic) SKNode *Card1_L2;
@property (strong, nonatomic) SKNode *Card2_L2;

@end

@implementation GameSceneLevel2
{
    SKSpriteNode *staveCard;
    SKSpriteNode *speakerCard;
    SKSpriteNode *background_L2;
    SKSpriteNode *healthMeter_L2;
    SKSpriteNode *nextLevelButton_L2;
    SKSpriteNode *gameOverButton_L2;
    SKLabelNode *scoreLabel_L2;
    SKLabelNode *clefLabel_L2;
    SKLabelNode *levelLabel_L2;
    SKLabelNode *gameOverLabel_L2;
    SKLabelNode *levelCompleteLabel_L2;
    SKTexture *FullHealthMeter5;
    SKTexture *HealthMeter5m1;
    SKTexture *HealthMeter5m2;
    SKTexture *HealthMeter5m3;
    SKTexture *HealthMeter5m4;
    SKTexture *EmptyHealthMeter5;
    SKSpriteNode *medal;
    SKTexture *gold;
    SKTexture *silver;
    SKTexture *bronze;
    SKTexture *platinum;
}

int grid_L2[9]; // used to store card in each grid position for musical stave cards
int grid2_L2[9]; // used to store card in each grid position for speaker note cards
int xGridSize_L2 = 160; // used to size grid x axis
int yGridSize_L2 = 200; // used to size grid y axis
int currentScore_L2 = 0;
int correctMatches_L2 = 0;
int scoreMultiplier_L2 = 1;
int healthCount_L2 = 5;
BOOL selectedCard_L2 = NO;


// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Reset variables incase returning from game over state
    currentScore_L2 = 0;
    correctMatches_L2 = 0;
    scoreMultiplier_L2 = 1;
    healthCount_L2 = 5;
    selectedCard_L2 = NO;
    
    
    // run method to set up various labels and life meter textures
    [self levelSetup];
    
    switch(arc4random_uniform(3))
    {
        case 0:
            [self randomCards1_L2];
            break;
        case 1:
            [self randomCards2_L2];
            break;
        case 2:
            [self randomCards3_L2];
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
            
            if (selectedCard_L2 == NO) // if first card is touched...
            {
                selectedCard_L2 = YES; // set state to yes
                _Card1_L2 = node; // save the card's state
                
                [_Card1_L2 runAction:highlight]; // run action to highlight the card
                NSLog(@"Name of first card is %@", _Card1_L2.name);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card1_L2.name];
            }
            
            else if (selectedCard_L2 == YES) // if second card is touched...
            {
                _Card2_L2 = node; // save the card's state
                NSLog(@"Name of second card is %@", _Card2_L2.name);
                
                [_Card2_L2 runAction:highlight];
                
                if (_Card1_L2.name == _Card2_L2.name) // if names match, then the match is successful...
                {
                    
                    if (_Card2_L2 == _Card1_L2) // ...but if the second touch is the same as the first...
                    {
                        [_Card1_L2 runAction: unhighlight];
                    }
                    
                    else if (_Card1_L2.zPosition == _Card2_L2.zPosition) // ...or if both cards are the same type...
                    {
                        [_Card1_L2 runAction: unhighlight];
                        [_Card2_L2 runAction: unhighlight];
                        [self lifeMeter_L2]; // lose a heart, so call life meter method
                    }
                    
                    else 
                    {
                        // Fade out both cards and remove
                        NSLog(@"Correct match!");
                        [_Card1_L2 runAction:successfulMatch];
                        [_Card2_L2 runAction:successfulMatch];
                        
                        correctMatches_L2 = correctMatches_L2 + 1;
                        
                        // Handle scoring
                        
                        currentScore_L2 = (currentScore_L2 + (1 * scoreMultiplier_L2)); // add points
                        
                        scoreMultiplier_L2 = scoreMultiplier_L2 + 1; // every correct answer adds 1 to multiplier
                        
                        scoreLabel_L2.text = [NSString stringWithFormat:@"Score: %d", currentScore_L2]; // update label
                    }
                }
                
                else // otherwise, if the names don't match, the match is unsuccessful.
                {
                    // Unhighlight both cards
                    NSLog(@"Incorrect match!");
                    [_Card1_L2 runAction:unhighlight];
                    [_Card2_L2 runAction:unhighlight];
                    
                    // Handle scoring
                    [self lifeMeter_L2];
                }
                
                
                selectedCard_L2 = NO; // Reset the state of selectedCard
                NSLog(@"selectedCard state is = %hhd", selectedCard_L2);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForCardWithName:_Card2_L2.name];
                
            }
        }
        
        // Call levelComplete method
        [self levelComplete_L2];
        
        if ([node.name isEqualToString:@"nextLevel"]) // When level is complete, press button to move to next level
        {
            GameSceneLevel3 *moveToScene = [[GameSceneLevel3 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
        
        if ([node.name isEqualToString:@"gameOverButton"]) // If it's game over, press button to restart level
        {
            GameSceneLevel2 *moveToScene = [[GameSceneLevel2 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
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
    background_L2 = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background_L2.name = @"other";
    background_L2.size = self.frame.size;
    background_L2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background_L2.zPosition = -2; // keep the background behind everything else
    
    [self addChild:background_L2];
    
    // Set up score label
    scoreLabel_L2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    scoreLabel_L2.text = @"Score: 0";
    scoreLabel_L2.fontSize = 30;
    scoreLabel_L2.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+280);
    scoreLabel_L2.name = @"other";
    
    [self addChild:scoreLabel_L2];
    
    // Set up clef label
    clefLabel_L2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    clefLabel_L2.text = @"Clef: Treble";
    clefLabel_L2.fontSize = 30;
    clefLabel_L2.position = CGPointMake(CGRectGetMidX(self.frame)-390, CGRectGetMidY(self.frame)+330);
    clefLabel_L2.name = @"other";
    
    [self addChild:clefLabel_L2];
    
    // Set up level label
    levelLabel_L2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelLabel_L2.text = @"Level: 2";
    levelLabel_L2.fontSize = 30;
    levelLabel_L2.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+330);
    levelLabel_L2.name = @"other";
    
    [self addChild:levelLabel_L2];
    
    // Set up game over label
    gameOverLabel_L2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    gameOverLabel_L2.text = @"Game Over!";
    gameOverLabel_L2.fontSize = 100;
    gameOverLabel_L2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverLabel_L2.name = @"other";
    gameOverLabel_L2.zPosition = 3;
    gameOverLabel_L2.alpha = 0;
    
    [self addChild:gameOverLabel_L2];
    
    // Set up "next level" button
    nextLevelButton_L2 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    nextLevelButton_L2.yScale = 0.5;
    nextLevelButton_L2.xScale = 0.5;
    nextLevelButton_L2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    nextLevelButton_L2.name = @"nextLevel";
    nextLevelButton_L2.zPosition = 3;
    nextLevelButton_L2.alpha = 0;
    
    [self addChild:nextLevelButton_L2];
    
    // Set up "game over" button
    gameOverButton_L2 = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    gameOverButton_L2.yScale = 0.5;
    gameOverButton_L2.xScale = 0.5;
    gameOverButton_L2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    gameOverButton_L2.name = @"gameOverButton";
    gameOverButton_L2.zPosition = 3;
    gameOverButton_L2.alpha = 0;
    
    [self addChild:gameOverButton_L2];
    
    
    // Set up "level complete" label
    levelCompleteLabel_L2 = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelCompleteLabel_L2.text = @"Level Complete!";
    levelCompleteLabel_L2.fontSize = 100;
    levelCompleteLabel_L2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+120);
    levelCompleteLabel_L2.name = @"other";
    levelCompleteLabel_L2.zPosition = 3;
    levelCompleteLabel_L2.alpha = 0;
    
    [self addChild:levelCompleteLabel_L2];
    
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
    FullHealthMeter5 = [SKTexture textureWithImageNamed:@"FullHealthMeter5"];
    HealthMeter5m1 = [SKTexture textureWithImageNamed:@"HealthMeter5-1"];
    HealthMeter5m2 = [SKTexture textureWithImageNamed:@"HealthMeter5-2"];
    HealthMeter5m3 = [SKTexture textureWithImageNamed:@"HealthMeter5-3"];
    HealthMeter5m4 = [SKTexture textureWithImageNamed:@"HealthMeter5-4"];
    EmptyHealthMeter5 = [SKTexture textureWithImageNamed:@"EmptyHealthMeter5"];
    
    healthMeter_L2 = [SKSpriteNode spriteNodeWithTexture:FullHealthMeter5];
    healthMeter_L2.xScale = 0.5;
    healthMeter_L2.yScale = 0.5;
    healthMeter_L2.anchorPoint = CGPointMake(0, 0);
    healthMeter_L2.position = CGPointMake(CGRectGetMidX(self.frame)-470, CGRectGetMidY(self.frame)+255);
    healthMeter_L2.name = @"other";
    
    
    [self addChild:healthMeter_L2];
} // end method


/*THIS METHOD HANDLES THE LIFE METER AND GAME OVER MECHANICS. CALLED IN THE touchesBegan METHOD*/
-(void)lifeMeter_L2
{
    // set up actions for health meter
    SKAction *removeHeart1 = [SKAction setTexture:HealthMeter5m1];
    SKAction *removeHeart2 = [SKAction setTexture:HealthMeter5m2];
    SKAction *removeHeart3 = [SKAction setTexture:HealthMeter5m3];
    SKAction *removeHeart4 = [SKAction setTexture:HealthMeter5m4];
    SKAction *emptyHearts = [SKAction setTexture:EmptyHealthMeter5];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.5];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *fadeOutSequence = [SKAction sequence:@[fadeOut, remove]];
    
    // Handle score multiplier
    scoreMultiplier_L2 = 1;
    
    // Handle health meter
    healthCount_L2 = healthCount_L2 - 1; // lose a heart from health meter for incorrect match
    
    if (healthCount_L2 == 4)
    {
        [healthMeter_L2 runAction:removeHeart1]; // remove heart texture
    }
    
    else if(healthCount_L2 == 3)
    {
        [healthMeter_L2 runAction:removeHeart2]; // remove heart texture
    }
    
    else if (healthCount_L2 == 2)
    {
        [healthMeter_L2 runAction:removeHeart3]; // remove heart texture
    }
    
    else if(healthCount_L2 == 1)
    {
        [healthMeter_L2 runAction:removeHeart4]; // remove heart texture
    }
    
    else if(healthCount_L2 == 0)
    {
        [healthMeter_L2 runAction:emptyHearts];
        [gameOverLabel_L2 runAction:fadeIn];
        [gameOverButton_L2 runAction:fadeIn];
        
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
    
} // end method



/*THIS METHOD HANDLES THE LEVEL COMPLETE MECHANIC. CALLED IN touchesBegan*/
-(void)levelComplete_L2
{
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.2];
    SKAction *bronzeTexture = [SKAction setTexture:bronze];
    SKAction *silverTexture = [SKAction setTexture:silver];
    SKAction *goldTexture = [SKAction setTexture:gold];
    SKAction *platinumTexture = [SKAction setTexture:platinum];
    
    if (correctMatches_L2 == 9) // when all nine matches are made, the level is complete.
    {
        [levelCompleteLabel_L2 runAction:fadeIn];
        [nextLevelButton_L2 runAction:fadeIn];
        
        // award a medal.
        
        if (currentScore_L2 == 45 && healthCount_L2 == 5) // highest possible score and max. hearts awards best medal
        {
            [medal runAction:platinumTexture];
        }
        else if (healthCount_L2 == 4)
        {
            [medal runAction:goldTexture];
        }
        else if (healthCount_L2 == 3)
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
-(void)randomCards1_L2
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name = @"E2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A2"];
                    staveCard.name= @"A2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name = @"A";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G2"];
                    staveCard.name = @"G2";
                    break;
            }
            
            grid_L2[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L2)+112),((j*yGridSize_L2)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G2"];
                    speakerCard.name = @"G2";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A2"];
                    speakerCard.name = @"A2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
            }
            
            grid2_L2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L2)+600),((j*yGridSize_L2)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards2_L2
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D2"];
                    staveCard.name = @"D2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A2"];
                    staveCard.name = @"A2";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name= @"A";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C2"];
                    staveCard.name = @"C2";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name = @"E2";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F2"];
                    staveCard.name = @"F2";
                    break;
            }
            
            grid_L2[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L2)+112),((j*yGridSize_L2)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C2"];
                    speakerCard.name = @"C2";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A2"];
                    speakerCard.name = @"A2";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F2"];
                    speakerCard.name = @"F2";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
            }
            
            grid2_L2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L2)+600),((j*yGridSize_L2)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards3_L2
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name = @"E2";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D2"];
                    staveCard.name= @"D2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name = @"A";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F2"];
                    staveCard.name = @"F2";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E"];
                    staveCard.name = @"E";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G2"];
                    staveCard.name = @"G2";
                    break;
            }
            
            grid_L2[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_L2)+112),((j*yGridSize_L2)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E"];
                    speakerCard.name = @"E";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F2"];
                    speakerCard.name = @"F2";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G2"];
                    speakerCard.name = @"G2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
            }
            
            grid2_L2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_L2)+600),((j*yGridSize_L2)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


@end
