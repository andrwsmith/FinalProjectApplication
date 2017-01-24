//
//  GameSceneLevel1.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 05/03/2016.
//  Copyright (c) 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"

@interface GameSceneLevel1 ()

@property (strong, nonatomic) SKNode *Card1;
@property (strong, nonatomic) SKNode *Card2;

@end

@implementation GameSceneLevel1
{
    // Create global variables for various sprites, labels and textures.
    SKSpriteNode *staveCard;
    SKSpriteNode *speakerCard;
    SKSpriteNode *healthMeter;
    SKSpriteNode *medal;
    SKSpriteNode *nextLevelButton;
    SKSpriteNode *gameOverButton;
    SKLabelNode *scoreLabel;
    SKLabelNode *clefLabel;
    SKLabelNode *levelLabel;
    SKLabelNode *gameOverLabel;
    SKLabelNode *levelCompleteLabel;
    SKTexture *FullHealthMeter5;
    SKTexture *HealthMeter5m1;
    SKTexture *HealthMeter5m2;
    SKTexture *HealthMeter5m3;
    SKTexture *HealthMeter5m4;
    SKTexture *EmptyHealthMeter5;
    SKTexture *gold;
    SKTexture *silver;
    SKTexture *bronze;
    SKTexture *platinum;
}

int grid[9]; // used to store card in each grid position for musical stave cards
int grid2[9]; // used to store card in each grid position for speaker note cards
int xGridSize = 160; // used to size grid x axis
int yGridSize = 200; // used to size grid y axis
int currentScore = 0;
int correctMatches = 0;
int scoreMultiplier = 1;
int healthCount = 5;
BOOL selectedCard = NO;


// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    // Reset variables incase returning from game over state
    currentScore = 0;
    correctMatches = 0;
    scoreMultiplier = 1;
    healthCount = 5;
    selectedCard = NO;
    
    // run method to set up various labels and life meter textures
    [self levelSetup];
    
    
    switch(arc4random_uniform(3))
    {
        case 0:
            [self randomCards1];
            break;
        case 1:
            [self randomCards2];
            break;
        case 2:
            [self randomCards3];
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
            
            if (selectedCard == NO) // if first card is touched...
            {
                selectedCard = YES; // set state to yes
                _Card1 = node; // save the card's state
                
                [_Card1 runAction:highlight]; // run action to highlight the card
                NSLog(@"Name of first card is %@", _Card1.name);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForSelectedCardWithName:_Card1.name];
            }
            
            else if (selectedCard == YES) // if second card is touched...
            {
                _Card2 = node; // save the card's state
                NSLog(@"Name of second card is %@", _Card2.name);
                
                [_Card2 runAction:highlight];
                
                if (_Card1.name == _Card2.name) // if names match, then the match is successful...
                {
                    
                    if (_Card2 == _Card1) // ...but if the second touch is the same as the first...
                    {
                        [_Card1 runAction: unhighlight];
                    }
                    
                    else if (_Card1.zPosition == _Card2.zPosition) // ...or if both cards are the same type...
                    {
                        [_Card1 runAction: unhighlight];
                        [_Card2 runAction: unhighlight];
                        [self lifeMeter]; // lose a heart, so call life meter method
                    }
                    
                    else
                    {
                        // Fade out both cards and remove
                        NSLog(@"Correct match!");
                        [_Card1 runAction:successfulMatch];
                        [_Card2 runAction:successfulMatch];
                        
                        correctMatches = correctMatches + 1;
                        
                        // Handle scoring
                        
                        currentScore = (currentScore + (1 * scoreMultiplier)); // add points
                        
                        scoreMultiplier = scoreMultiplier + 1; // every correct answer adds 1 to multiplier
                        
                        scoreLabel.text = [NSString stringWithFormat:@"Score: %d", currentScore]; // update label
                    }
                }
                
                else // otherwise, if the names don't match, the match is unsuccessful.
                {
                    // Unhighlight both cards
                    NSLog(@"Incorrect match!");
                    [_Card1 runAction:unhighlight];
                    [_Card2 runAction:unhighlight];
                    
                    // Handle scoring
                    [self lifeMeter];
                }
                
                // Whether the match is correct or not, the following must always happen when a card is touched
                
                selectedCard = NO; // Reset the state of selectedCard
                NSLog(@"selectedCard state is = %hhd", selectedCard);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForSelectedCardWithName:_Card2.name];
            }
        }
        
        // Call levelComplete method
        [self levelComplete];
        
        if ([node.name isEqualToString:@"nextLevel"]) // When level is complete, press button to move to next level
        {
            GameSceneLevel2 *moveToScene = [[GameSceneLevel2 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
            SKTransition *reveal = [SKTransition crossFadeWithDuration:1.0];
            moveToScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.scene.view presentScene:moveToScene transition:reveal];
        }
        
        if([node.name isEqualToString:@"gameOverButton"]) // If it's game over, press button to restart level
        {
            GameSceneLevel1 *moveToScene = [[GameSceneLevel1 alloc] initWithSize:CGSizeMake(self.size.width, self.size.height)];
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
    SKSpriteNode *background;
    background = [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    background.name = @"other";
    background.size = self.frame.size;
    background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    self.scaleMode = SKSceneScaleModeAspectFit;
    background.zPosition = -2; // keep the background behind everything else
    
    [self addChild:background];
    
    // Set up score label
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    scoreLabel.text = @"Score: 0";
    scoreLabel.fontSize = 30;
    scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+280);
    scoreLabel.zPosition = 3;
    scoreLabel.name = @"other";
    
    [self addChild:scoreLabel];
    
    // Set up clef label
    clefLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    clefLabel.text = @"Clef: Treble";
    clefLabel.fontSize = 30;
    clefLabel.position = CGPointMake(CGRectGetMidX(self.frame)-390, CGRectGetMidY(self.frame)+330);
    clefLabel.name = @"other";
    
    [self addChild:clefLabel];
    
    // Set up level label
    levelLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelLabel.text = @"Level: 1";
    levelLabel.fontSize = 30;
    levelLabel.position = CGPointMake(CGRectGetMidX(self.frame)+400, CGRectGetMidY(self.frame)+330);
    levelLabel.name = @"other";
    
    [self addChild:levelLabel];
    
    // Set up game over label
    gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    gameOverLabel.text = @"Game Over!";
    gameOverLabel.fontSize = 100;
    gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    gameOverLabel.name = @"other";
    gameOverLabel.zPosition = 3;
    gameOverLabel.alpha = 0;
    
    [self addChild:gameOverLabel];
    
    // Set up "next level" button
    nextLevelButton = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    nextLevelButton.yScale = 0.5;
    nextLevelButton.xScale = 0.5;
    nextLevelButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    nextLevelButton.name = @"nextLevel";
    nextLevelButton.zPosition = 3;
    nextLevelButton.alpha = 0;
    
    [self addChild:nextLevelButton];
    
    // Set up "game over" button
    gameOverButton = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    gameOverButton.yScale = 0.5;
    gameOverButton.xScale = 0.5;
    gameOverButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-240);
    gameOverButton.name = @"gameOverButton";
    gameOverButton.zPosition = 3;
    gameOverButton.alpha = 0;
    
    [self addChild:gameOverButton];
    
    // Set up "level complete" label
    levelCompleteLabel = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    levelCompleteLabel.text = @"Level Complete!";
    levelCompleteLabel.fontSize = 100;
    levelCompleteLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+120);
    levelCompleteLabel.name = @"other";
    levelCompleteLabel.zPosition = 3;
    levelCompleteLabel.alpha = 0;
    
    [self addChild:levelCompleteLabel];
    
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
    
    healthMeter = [SKSpriteNode spriteNodeWithTexture:FullHealthMeter5];
    healthMeter.xScale = 0.5;
    healthMeter.yScale = 0.5;
    healthMeter.anchorPoint = CGPointMake(0, 0);
    healthMeter.position = CGPointMake(CGRectGetMidX(self.frame)-470, CGRectGetMidY(self.frame)+255);
    healthMeter.name = @"other";
    
    [self addChild:healthMeter];
}



/*THIS METHOD HANDLES THE LIFE METER AND GAME OVER MECHANICS WHEN THERE IS AN INCORRECT MATCH. CALLED IN THE touchesBegan METHOD*/
-(void)lifeMeter
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
    
    // reset score multiplier to 1.
    scoreMultiplier = 1;
    
    // lose a heart from health meter for incorrect match
    healthCount = healthCount - 1;
    
    if (healthCount == 4)
    {
        [healthMeter runAction:removeHeart1]; // remove heart texture
    }
    
    else if(healthCount == 3)
    {
        [healthMeter runAction:removeHeart2]; // remove heart texture
    }
    
    else if (healthCount == 2)
    {
        [healthMeter runAction:removeHeart3]; // remove heart texture
    }
    
    else if(healthCount == 1)
    {
        [healthMeter runAction:removeHeart4]; // remove heart texture
    }
    
    else if(healthCount == 0)
    {
        // Game over!!
        
        
        [healthMeter runAction:emptyHearts]; // remove heart texture
        [gameOverButton runAction:fadeIn];
        [gameOverLabel runAction:fadeIn]; // fade in "Game Over!" label
        
        
        // Remove any remaining cards
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
    }
}

/*THIS METHOD PLAYS THE CORRESPONDING NOTE AUDIO WHEN A CARD IS PRESSED. CALLED IN THE touchesBegan METHOD*/
-(void)playSoundsForSelectedCardWithName:(NSString *)cardName
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
} // end method



/*THIS METHOD HANDLES THE LEVEL COMPLETE MECHANIC. CALLED IN touchesBegan*/
-(void)levelComplete
{
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.2];
    SKAction *bronzeTexture = [SKAction setTexture:bronze];
    SKAction *silverTexture = [SKAction setTexture:silver];
    SKAction *goldTexture = [SKAction setTexture:gold];
    SKAction *platinumTexture = [SKAction setTexture:platinum];
    
    if (correctMatches == 9) // when all nine matches are made, the level is complete.
    {
        [levelCompleteLabel runAction:fadeIn];
        [nextLevelButton runAction:fadeIn];
        
        // award a medal.
        
        if (currentScore == 45 && healthCount == 5) // highest possible score and max. hearts awards best medal
        {
            [medal runAction:platinumTexture];
        }
        else if (healthCount == 4)
        {
            [medal runAction:goldTexture];
        }
        else if (healthCount == 3)
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
-(void)randomCards1
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C2"];
                    staveCard.name= @"C2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E"];
                    staveCard.name = @"E";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name = @"A";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
            }
            
            grid[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize)+112),((j*yGridSize)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C2"];
                    speakerCard.name = @"C2";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E"];
                    speakerCard.name = @"E";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
            }
            
            grid2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize)+600),((j*yGridSize)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards2
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C2"];
                    staveCard.name = @"C2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name= @"A";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D2"];
                    staveCard.name = @"D2";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E"];
                    staveCard.name = @"E";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
            }
            
            grid[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize)+112),((j*yGridSize)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E"];
                    speakerCard.name = @"E";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C2"];
                    speakerCard.name = @"C2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
            }
            
            grid2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize)+600),((j*yGridSize)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


/*THIS METHOD IS ONE OF THE POSSIBLE CARD POSITION COMBINATIONS. CALLED IN THE didMoveToView METHOD*/
-(void)randomCards3
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C2"];
                    staveCard.name = @"C2";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D2"];
                    staveCard.name= @"D2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E"];
                    staveCard.name = @"E";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_B"];
                    staveCard.name = @"B";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name = @"A";
                    break;
            }
            
            grid[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize)+112),((j*yGridSize)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 1:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_B"];
                    speakerCard.name = @"B";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D2"];
                    speakerCard.name = @"D2";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E"];
                    speakerCard.name = @"E";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C2"];
                    speakerCard.name = @"C2";
                    break;
            }
            
            grid2[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize)+600),((j*yGridSize)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

@end

