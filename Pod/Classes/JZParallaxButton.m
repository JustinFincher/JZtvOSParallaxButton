//
//  JZParallaxButton.m
//  JZtvOSParallaxButton
//
//  Created by Fincher Justin on 15/11/10.
//  Copyright © 2015年 Fincher Justin. All rights reserved.
//
//
//         ______  ___                ____           ___       __  __
//     __ / /_  / / _ \___ ________ _/ / /__ ___ __ / _ )__ __/ /_/ /____  ___
//    / // / / /_/ ___/ _ `/ __/ _ `/ / / _ `/\ \ // _  / // / __/ __/ _ \/ _ \
//    \___/ /___/_/   \_,_/_/  \_,_/_/_/\_,_//_\_\/____/\_,_/\__/\__/\___/_//_/
//



//TranslationParameter: Level ++ , TranslationParameter ++
#define TranslationParameter  (float)([LayerArray count] * 2 - i)/(float)([LayerArray count] * 2)

//ScaleParameter: Level ++ , ScaleParameter ++
#define ScaleParameter  ScaleBase+ScaleAddition/5*((float)i/(float)([LayerArray count]))

//RotateParameter:
#define RotateParameter 0.4
#define SpotlightOutRange 5.0f
#define zPositionMax 9999


#import "JZParallaxButton.h"
#import <QuartzCore/QuartzCore.h>

@interface UIButton ()

@property int RotationNowStep;
@property NSTimer *RotationTimer;
@property UIImageView *SpotLightView;

@end

@implementation JZParallaxButton

@synthesize LayerArray;
@synthesize ParallaxEffectParameter;
@synthesize SpotLightView;
@synthesize RoundCornerEnabled,RoundCornerRadius;
@synthesize isParallax;
@synthesize RotationInterval,RotationNowStep,RotationAllSteps,RotationTimer;
@synthesize ScaleAddition,ScaleBase;

- (instancetype)initButtonWithCGRect:(CGRect)RectInfo
                      WithLayerArray:(NSMutableArray *)ArrayOfLayer
              WithRoundCornerEnabled:(BOOL)isRoundCorner
           WithCornerRadiusifEnabled:(CGFloat)Radius
                  WithRotationFrames:(int)Frames
                WithRotationInterval:(CGFloat)Interval
{
    self.RotationAllSteps = Frames;
    self.RotationInterval = Interval;
    self.RoundCornerEnabled = isRoundCorner;
    self.RoundCornerRadius = Radius;
    self.ScaleBase = 1.0f;
    self.ScaleAddition = 1.0f;

    
    LayerArray = [[NSMutableArray alloc] initWithCapacity:[ArrayOfLayer count]];
    
    self = [super initWithFrame:RectInfo];
    
    for (int i = 0; i < [ArrayOfLayer count]; i++)
    {
        UIImageView *LayerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIImage *LayerImage = [ArrayOfLayer objectAtIndex:i];
        [LayerImageView setImage:LayerImage];
        
        //从下往上添加
        [self addSubview:LayerImageView];
        [LayerArray addObject:LayerImageView];
        
        if (self.RoundCornerEnabled)
        {
            LayerImageView.layer.masksToBounds = YES;
            LayerImageView.layer.cornerRadius = self.RoundCornerRadius;
        }
        
        if (i == [ArrayOfLayer count] - 1)
        {
            //SPOTLIGHT
            SpotLightView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)];
            
            NSString *bundlePath = [[NSBundle bundleForClass:[JZParallaxButton class]]
                                    pathForResource:@"JZParallaxButton" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            
            SpotLightView.image = [UIImage imageNamed:@"Spotlight" inBundle:bundle compatibleWithTraitCollection:nil];
            SpotLightView.contentMode = UIViewContentModeScaleAspectFit;
            SpotLightView.layer.masksToBounds = YES;
            [LayerImageView addSubview:SpotLightView];
            SpotLightView.layer.zPosition = zPositionMax;
            [self bringSubviewToFront:SpotLightView];
            SpotLightView.alpha = 0.0;
            [LayerArray addObject:SpotLightView];
        }
    }
    
    

    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selfLongPressed:)];
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
    
    return self;
}

- (void)selfLongPressed:(UILongPressGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Long Press");
        
        if (isParallax)
        {
            [self EndParallax];
        }
        else
        {
            [self BeginParallax];
        }
    }
}

- (void)BeginParallax
{
    self.isParallax = YES;
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
        //从下往上的z位置++
        LayerImageView.layer.transform = CATransform3DMakeTranslation(0, 0, i*30);
        LayerImageView.layer.zPosition = i*30;
    }
 
    [self AddShadow];
    [self BeginAnimation];
    
}

- (void)EndParallax
{
    self.isParallax = NO;
    [self EndAnimation];
    [self RemoveShadow];
}

- (void)BeginAnimation
{
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1 , 1.1);
                         SpotLightView.alpha = 1.0;
                     }
                     completion:^(BOOL finished)
    {
        if (finished)
        {
            [self BeginRotation];
        }
    }
     ];
}
- (void)EndAnimation
{
    [self EndRotation];
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
        CATransform3D NowTransform = LayerImageView.layer.transform;
        
        CATransform3D NewRotate = CATransform3DConcat(CATransform3DMakeRotation(0, 0, 1, 0), CATransform3DMakeRotation(0, 1, 0, 0));
        CATransform3D NewTranslation = CATransform3DMakeTranslation(0, 0, 0);
        CATransform3D NewScale = CATransform3DMakeScale(1, 1, 1);
        
        CATransform3D NewTwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
        CATransform3D NewAllTransform = CATransform3DConcat(NewTwoTransform,NewScale);
        
        CABasicAnimation *LayerImageViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        LayerImageViewCABasicAnimation.duration = 0.4f;
        LayerImageViewCABasicAnimation.autoreverses = YES;
        LayerImageViewCABasicAnimation.toValue = [NSValue valueWithCATransform3D:NewAllTransform];
        LayerImageViewCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:NowTransform];
        LayerImageViewCABasicAnimation.fillMode = kCAFillModeBoth;
        LayerImageViewCABasicAnimation.removedOnCompletion = YES;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:LayerImageViewCABasicAnimation, nil];
        animGroup.duration = 0.4f;
        animGroup.removedOnCompletion = YES;
        animGroup.autoreverses = NO;
        animGroup.fillMode = kCAFillModeRemoved;
        
        [CATransaction begin];
        LayerImageView.layer.transform = CATransform3DPerspect(NewAllTransform, CGPointMake(0, 0), 1000);
        [CATransaction setCompletionBlock:^
         {
             if (i == [LayerArray count] - 1)
             {
                 
                 [UIView animateWithDuration: 0.1
                                       delay: 0
                                     options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                                  animations:^{
                                      SpotLightView.alpha = 0.0;
                                  }
                                  completion:^(BOOL finished){}
                  ];

                 
             }
         }];
        [LayerImageView.layer addAnimation:animGroup forKey:@"LayerImageViewParallaxInitAnimation"];
        [CATransaction commit];
    }
    
}

- (void)BeginRotation
{
    //到达起始位置
    
    CGFloat PIE = 0;
    CGFloat Degress = M_PI*2*PIE;
    NSLog(@"Degress : %f PIE",PIE);
    CGFloat Sin = sin(Degress)/4;
    CGFloat Cos = cos(Degress)/4;
    
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];

        
        CATransform3D NewRotate ;
        CATransform3D NewTranslation ;
        CATransform3D NewScale = CATransform3DMakeScale(ScaleParameter, ScaleParameter, 1);
        
        if (i == [LayerArray count] - 1) //is spotlight
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-Cos*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(-Sin*100*TranslationParameter*SpotlightOutRange, -Cos*100*TranslationParameter*SpotlightOutRange, 0);
        }
        else
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(-Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(Cos*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(Sin*100*TranslationParameter, Cos*100*TranslationParameter, 0);

        }
        
        CATransform3D NewTwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
        CATransform3D NewAllTransform = CATransform3DConcat(NewTwoTransform,NewScale);
        
        
        CABasicAnimation *LayerImageViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        LayerImageViewCABasicAnimation.duration = 0.4f;
        LayerImageViewCABasicAnimation.autoreverses = YES;
        LayerImageViewCABasicAnimation.toValue = [NSValue valueWithCATransform3D:NewAllTransform];
        LayerImageViewCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:LayerImageView.layer.transform];
        LayerImageViewCABasicAnimation.fillMode = kCAFillModeBoth;
        LayerImageViewCABasicAnimation.removedOnCompletion = YES;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:LayerImageViewCABasicAnimation, nil];
        animGroup.duration = 0.4f;
        animGroup.removedOnCompletion = YES;
        animGroup.autoreverses = NO;
        animGroup.fillMode = kCAFillModeRemoved;
        
        [CATransaction begin];
        LayerImageView.layer.transform = CATransform3DPerspect(NewAllTransform, CGPointMake(0, 0), 1000);
        [CATransaction setCompletionBlock:^
         {
             if (i == [LayerArray count] - 1)
             {
                 //开始周期循环
                 RotationNowStep = 0;
                 RotationTimer =  [NSTimer scheduledTimerWithTimeInterval:RotationInterval/RotationAllSteps target:self selector:@selector(RotationCreator) userInfo:nil repeats:YES];
             }
         }];
        [LayerImageView.layer addAnimation:animGroup forKey:@"LayerImageViewParallaxInitAnimation"];
        [CATransaction commit];
    }

    
}

- (void)RotationCreator
{
 
    NSLog(@"RotationNowStep : %d of %d",RotationNowStep,RotationAllSteps);
    if (RotationNowStep == RotationAllSteps)
    {
        RotationNowStep = 1;
    }
    else
    {
        RotationNowStep ++ ;
    }
    
    CGFloat PIE = (float)RotationNowStep/(float)RotationAllSteps;
    CGFloat Degress = M_PI*2*PIE;
    NSLog(@"Degress : %f PIE",PIE);
    CGFloat Sin = sin(Degress)/4;
    CGFloat Cos = cos(Degress)/4;
    
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        if (i == [LayerArray count] - 1) //is spotlight
        {
            UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
            
            CATransform3D Rotate = CATransform3DConcat(CATransform3DMakeRotation(Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-Cos*RotateParameter, 1, 0, 0));
            CATransform3D Translation = CATransform3DMakeTranslation(-Sin*100*TranslationParameter*SpotlightOutRange, -Cos*100*TranslationParameter*SpotlightOutRange,0);
            CATransform3D Scale = CATransform3DMakeScale(ScaleParameter, ScaleParameter, 1);
            
            CATransform3D TwoTransform = CATransform3DConcat(Rotate,Translation);
            CATransform3D AllTransform = CATransform3DConcat(TwoTransform,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), 1000);
        }
        else //is Parallax layer
        {
            UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
            
            CATransform3D Rotate = CATransform3DConcat(CATransform3DMakeRotation(-Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(Cos*RotateParameter, 1, 0, 0));
            CATransform3D Translation = CATransform3DMakeTranslation(Sin*100*TranslationParameter, Cos*100*TranslationParameter, 0);
            CATransform3D Scale = CATransform3DMakeScale(ScaleParameter, ScaleParameter, 1);
            
            CATransform3D TwoTransform = CATransform3DConcat(Rotate,Translation);
            CATransform3D AllTransform = CATransform3DConcat(TwoTransform,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), 1000);
        }
        
    }

    
    
}
- (void)EndRotation
{
    [RotationTimer invalidate];
}

- (void)AddShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
    self.layer.shadowOpacity = 0.3;
    
    //Prevent Spotlight layer have shadow
    SpotLightView.layer.shadowOpacity = 0.0f;
}
- (void)RemoveShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
    self.layer.shadowOpacity = 0.0;
}


CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

@end