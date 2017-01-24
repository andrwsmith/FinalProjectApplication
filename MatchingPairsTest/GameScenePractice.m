//
//  GameScenePractice.m
//  MatchingPairsTest
//
//  Created by Andrew Smith on 25/04/2016.
//  Copyright © 2016 Andrew Smith. All rights reserved.
//

#import "GameScene.h"

@interface GameScenePractice ()

@property (strong, nonatomic) SKNode *Card1_P;
@property (strong, nonatomic) SKNode *Card2_P;

@end

@implementation GameScenePractice
{
    // Create global variables for various sprites, labels and textures.
    SKSpriteNode *staveCard;
    SKSpriteNode *speakerCard;
    SKSpriteNode *nextLevelButton_P;
    SKLabelNode *clefLabel_P;
}

int grid_P[9]; // used to store card in each grid position for musical stave cards
int grid2_P[9]; // used to store card in each grid position for speaker note cards
int xGridSize_P = 160; // used to size grid x axis
int yGridSize_P = 200; // used to size grid y axis
BOOL selectedCard_P = NO;

// didMoveToView method.
-(void)didMoveToView:(SKView *)view
{
    selectedCard_P = NO;
    
    // run method to set up various labels and life meter textures
    [self practiceSetup];
    [self practiceCards];
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
            
            if (selectedCard_P == NO) // if first card is touched...
            {
                selectedCard_P = YES; // set state to yes
                _Card1_P = node; // save the card's state
                
                [_Card1_P runAction:highlight]; // run action to highlight the card
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForSelectedCardWithName:_Card1_P.name];
            }
            
            else if (selectedCard_P == YES) // if second card is touched...
            {
                _Card2_P = node; // save the card's state
                
                [_Card2_P runAction:highlight];
                
                if (_Card1_P.name == _Card2_P.name) // if names match, then the match is successful...
                {

                    if (_Card2_P == _Card1_P) // ...but if the second touch is the same as the first...
                    {
                        [_Card1_P runAction: unhighlight];
                    }
                    
                    else if (_Card1_P.zPosition == _Card2_P.zPosition) // ...or if both cards are the same type...
                    {
                        [_Card1_P runAction: unhighlight];
                        [_Card2_P runAction: unhighlight];
                    }
                    
                    else
                    {
                        // Fade out both cards and remove
                        [_Card1_P runAction:successfulMatch];
                        [_Card2_P runAction:successfulMatch];
                    }
                }
                
                else // otherwise, if the names don't match, the match is unsuccessful.
                {
                    // Unhighlight both cards
                    [_Card1_P runAction:unhighlight];
                    [_Card2_P runAction:unhighlight];
                }
                
                // Whether the match is correct or not, the following must always happen when a card is touched
                
                selectedCard_P = NO; // Reset the state of selectedCard
                NSLog(@"selectedCard state is = %hhd", selectedCard_P);
                
                // Call method to play the corresponding note audio when the card is pressed
                [self playSoundsForSelectedCardWithName:_Card2_P.name];
            }
        }
        
        if ([node.name isEqualToString:@"nextLevel"]) // When level is complete, press button to move to next level
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
-(void)practiceSetup
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
    
    // Set up clef label
    clefLabel_P = [SKLabelNode labelNodeWithFontNamed:@"DevanagariSangamMN"];
    clefLabel_P.text = @"Clef: Treble";
    clefLabel_P.fontSize = 30;
    clefLabel_P.position = CGPointMake(CGRectGetMidX(self.frame)-390, CGRectGetMidY(self.frame)+330);
    clefLabel_P.name = @"other";
    
    [self addChild:clefLabel_P];
    
    // Set up "next level" button
    nextLevelButton_P = [SKSpriteNode spriteNodeWithImageNamed:@"ContinueButton"];
    nextLevelButton_P.yScale = 0.5;
    nextLevelButton_P.xScale = 0.5;
    nextLevelButton_P.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+305);
    nextLevelButton_P.name = @"nextLevel";
    nextLevelButton_P.zPosition = 3;
    nextLevelButton_P.alpha = 1;
    
    [self addChild:nextLevelButton_P];
}



/*THIS METHOD SETS UP THE CARD GRIDS. CALLED IN THE didMoveToView METHOD*/
-(void)practiceCards
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
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_A"];
                    staveCard.name = @"A";
                    break;
                case 1:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_G"];
                    staveCard.name = @"G";
                    break;
                case 2:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_E2"];
                    staveCard.name= @"E2";
                    break;
                case 3:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_D"];
                    staveCard.name = @"D";
                    break;
                case 4:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C"];
                    staveCard.name = @"C";
                    break;
                case 5:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_FS"];
                    staveCard.name = @"FS";
                    break;
                case 6:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_BF"];
                    staveCard.name = @"BF";
                    break;
                case 7:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_F"];
                    staveCard.name = @"F";
                    break;
                case 8:
                    staveCard = [SKSpriteNode spriteNodeWithImageNamed:@"Card_C2"];
                    staveCard.name = @"C2";
                    break;
            }
            
            grid_P[j*3+i] = randomCard; // store the cards in the grid
            
            staveCard.xScale = 0.5;
            staveCard.yScale = 0.5;
            staveCard.position = CGPointMake(((i*xGridSize_P)+112),((j*yGridSize_P)+120));
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
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_D"];
                    speakerCard.name = @"D";
                    break;
                case 2:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_FS"];
                    speakerCard.name = @"FS";
                    break;
                case 3:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_G"];
                    speakerCard.name = @"G";
                    break;
                case 4:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_BF"];
                    speakerCard.name = @"BF";
                    break;
                case 5:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_A"];
                    speakerCard.name = @"A";
                    break;
                case 6:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_E2"];
                    speakerCard.name = @"E2";
                    break;
                case 7:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_C"];
                    speakerCard.name = @"C";
                    break;
                case 8:
                    speakerCard = [SKSpriteNode spriteNodeWithImageNamed:@"SpeakerCard_F"];
                    speakerCard.name = @"F";
                    break;
            }
            
            grid2_P[j*3+i] = randomSpeakerCard; // store the cards in the grid
            
            speakerCard.xScale = 0.5;
            speakerCard.yScale = 0.5;
            speakerCard.position = CGPointMake(((i*xGridSize_P)+600),((j*yGridSize_P)+120));
            [self addChild:speakerCard];
            
            randomSpeakerCard = randomSpeakerCard + 1;
        }
    }
} // end method


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
    
    else if ([cardName isEqualToString:@"E2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A E2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"FS"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"G"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A G1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"A"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"BF"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A A#1" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"C2"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A C2" waitForCompletion:NO]];
    }
    
    else if ([cardName isEqualToString:@"F"])
    {
        [self runAction:[SKAction playSoundFileNamed:@"A F1" waitForCompletion:NO]];
    }
} // end method

@end
