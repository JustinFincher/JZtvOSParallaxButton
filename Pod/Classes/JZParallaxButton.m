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
#define OutTranslationParameter  (float)([LayerArray count] + i)/(float)([LayerArray count] * 2)
//#define InTranslationParameter  (float)(i)/(float)([LayerArray count])

//ScaleParameter: Level ++ , ScaleParameter ++
#define OutScaleParameter  ScaleBase+ScaleAddition/5*((float)i/(float)([LayerArray count]))
//#define InScaleParameter  1+ScaleAddition/10*((float)i/(float)([LayerArray count]))

//RotateParameter:
#define RotateParameter 0.5
#define SpotlightOutRange 20.0f
#define zPositionMax 800

#define BoundsVieTranslation 50
#define LayerVieTranslation 20

#define LongPressInterval 0.5

#import "JZParallaxButton.h"
#import <QuartzCore/QuartzCore.h>

@interface UIButton ()<UIGestureRecognizerDelegate>

@property (nonatomic,assign) int RotationNowStep;
@property (nonatomic,weak)NSTimer *RotationTimer;
@property (nonatomic,strong) UIImageView *SpotLightView;
@property (nonatomic,strong) UIView *BoundsView;
@property (nonatomic,assign) CGPoint TouchPointInSelf;
@property (nonatomic,assign) BOOL hasPreformedBeginAnimation;
@end

@implementation JZParallaxButton

@synthesize LayerArray;
@synthesize SpotLightView;
@synthesize RoundCornerEnabled,RoundCornerRadius;
@synthesize isParallax;
@synthesize RotationInterval,RotationNowStep,RotationAllSteps,RotationTimer;
@synthesize BoundsView;
@synthesize ScaleAddition,ScaleBase;
@synthesize ParallaxMethod;
@synthesize TouchPointInSelf,hasPreformedBeginAnimation;


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
    self.ScaleBase = 1.1f;
    self.ScaleAddition = 0.4f;

    
    LayerArray = [[NSMutableArray alloc] initWithCapacity:[ArrayOfLayer count]];
    
    self = [super initWithFrame:RectInfo];
    
    BoundsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    BoundsView.layer.masksToBounds = YES;
    BoundsView.layer.shouldRasterize = TRUE;
    BoundsView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    if (self.RoundCornerEnabled)
    {
        BoundsView.layer.cornerRadius = self.RoundCornerRadius;
    }
    [self addSubview:BoundsView];
    
    
    for (int i = 0; i < [ArrayOfLayer count]; i++)
    {
        UIImageView *LayerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIImage *LayerImage = [ArrayOfLayer objectAtIndex:i];
        [LayerImageView setImage:LayerImage];
        LayerImageView.layer.shouldRasterize = TRUE;
        LayerImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        //从下往上添加
        [BoundsView addSubview:LayerImageView];
        [LayerArray addObject:LayerImageView];
        
        
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
            [BoundsView addSubview:SpotLightView];
            SpotLightView.layer.zPosition = zPositionMax;
            [self bringSubviewToFront:SpotLightView];
            SpotLightView.alpha = 0.0;
            [LayerArray addObject:SpotLightView];
        }
    }
    
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selfLongPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = LongPressInterval;
    [self addGestureRecognizer:longPress];
    
    return self;
}


- (instancetype)initButtonWithCGRect:(CGRect)RectInfo
                      WithLayerArray:(NSMutableArray *)ArrayOfLayer
              WithRoundCornerEnabled:(BOOL)isRoundCorner
           WithCornerRadiusifEnabled:(CGFloat)Radius
                  WithRotationFrames:(int)Frames
                WithRotationInterval:(CGFloat)Interval
                  WithParallaxMethod:(ParallaxMethodType)Parallax
                    WithRotateMethod:(RotateMethodType)Rotate
{
    self = [self initButtonWithCGRect:RectInfo
                       WithLayerArray:ArrayOfLayer
               WithRoundCornerEnabled:isRoundCorner
            WithCornerRadiusifEnabled:Radius
                   WithRotationFrames:Frames
                 WithRotationInterval:Interval];
    self.ParallaxMethod = Parallax;
    self.RotateMethod = Rotate;
    return self;
}


- (void)selfLongPressed:(UILongPressGestureRecognizer *)sender
{
    CGPoint PressedPoint = [sender locationInView:self];
    //NSLog(@"%F , %F",PressedPoint.x,PressedPoint.y);
    self.TouchPointInSelf = PressedPoint;
    
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Long Press");
        self.hasPreformedBeginAnimation = NO;
        
        switch (self.RotateMethod)
        {
            case AutoRotate:
            {
                if (isParallax)
                {
                    [self EndParallax];
                }
                else
                {
                    [self BeginParallax];
                }
            }
                break;
                
            case WithFinger:
            {
                if (!isParallax)
                {
                    [self BeginParallax];
                }
            }
                break;
                
            case WithFingerReverse:
            {
                if (!isParallax)
                {
                    [self BeginParallax];
                }
            }
                break;
                
            default:
            {
                if (isParallax)
                {
                    [self EndParallax];
                }
                else
                {
                    [self BeginParallax];
                }
            }
                break;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (self.hasPreformedBeginAnimation == NO)
        {
            [self performSelector:@selector(TouchUp) withObject:self afterDelay:LongPressInterval ];
        }
        else
        {
            [self TouchUp];
        }
        
    }
}

- (void)TouchUp
{
    switch (self.RotateMethod)
    {
        case WithFinger:
        {
            [self EndParallax];
        }
            break;
            
        case WithFingerReverse:
        {
            [self EndParallax];
        }
            break;
            
        default:
            break;
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
        LayerImageView.layer.zPosition = i*10;
    }
 
    [self AddShadow];
    [self BeginAnimation];
    
}

- (void)EndParallax
{
    [self EndAnimation];
    [self RemoveShadow];
}

- (void)BeginAnimation
{
    __weak JZParallaxButton *weakSelf = self;
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0,1.0);
                         SpotLightView.alpha = 1.0;
                     }
                     completion:^(BOOL finished)
    {
        if (finished)
        {
            switch (self.RotateMethod)
            {
                case AutoRotate:
                    [weakSelf BeginAutoRotation];
                    break;
                    
                case WithFinger:
                    [weakSelf BeginManualAnimatiom];
                    break;
                    
                case WithFingerReverse:
                    [weakSelf BeginManualAnimatiom];
                    break;
                    
                default:
                    [weakSelf BeginAutoRotation];
                    break;
            }
        }
    }
     ];
}

- (void)BeginManualAnimatiom
{
    __weak JZParallaxButton *weakSelf = self;
    CGFloat XOffest;
    if (TouchPointInSelf.x < 0)
    {
        XOffest = - self.frame.size.width / 2;
    }else if (TouchPointInSelf.x > self.frame.size.width)
    {
        XOffest = self.frame.size.width / 2;
    }else
    {
        XOffest = TouchPointInSelf.x - self.frame.size.width / 2;
    }
    
    CGFloat YOffest;
    if (TouchPointInSelf.y < 0)
    {
        YOffest = - self.frame.size.height / 2;
    }else if (TouchPointInSelf.y > self.frame.size.height)
    {
        YOffest = self.frame.size.height / 2;
    }else
    {
        YOffest = TouchPointInSelf.y - self.frame.size.height / 2;
    }
    
    //NSLog(@"XOffest : %f , YOffest : %f",XOffest,YOffest);
    
    CGFloat XDegress = XOffest / self.frame.size.width / 2;
    CGFloat YDegress = YOffest / self.frame.size.height / 2;
    
    //NSLog(@"XDegress : %f , YDegress : %f",XDegress,YDegress);

    int i =0;
    CATransform3D NewRotate,NewTranslation,NewScale;
    
    switch (self.RotateMethod)
    {
        case WithFinger:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(-XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(XDegress*BoundsVieTranslation*OutTranslationParameter, YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
            
        case WithFingerReverse:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(-XDegress*BoundsVieTranslation*OutTranslationParameter, +YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
            
        default:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(-XDegress*BoundsVieTranslation*OutTranslationParameter, +YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
    }
    NewScale = CATransform3DMakeScale(OutScaleParameter, OutScaleParameter, 1);
    
    CATransform3D TwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
    CATransform3D AllTransform = CATransform3DConcat(TwoTransform,NewScale);
    
    CABasicAnimation *BoundsLayerCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    BoundsLayerCABasicAnimation.duration = 0.4f;
    BoundsLayerCABasicAnimation.autoreverses = NO;
    BoundsLayerCABasicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax)];
    BoundsLayerCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:BoundsView.layer.transform];
    BoundsLayerCABasicAnimation.fillMode = kCAFillModeBoth;
    BoundsLayerCABasicAnimation.removedOnCompletion = YES;
    [BoundsView.layer addAnimation:BoundsLayerCABasicAnimation forKey:@"BoundsLayerCABasicAnimation"];
    BoundsView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        
        float InTranslationParameter = [self InTranslationParameterWithLayerArray:LayerArray WithIndex:i];
        float InScaleParameter = [self InScaleParameterWithLayerArray:LayerArray WithIndex:i];
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
        
        CATransform3D NewTranslation ;
        CATransform3D NewScale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
        
        if (i == [LayerArray count] - 1) //is spotlight
        {
            switch (self.RotateMethod)
            {
                case WithFinger:
                {
                    NewTranslation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, 0);
                }
                    break;
                    
                case WithFingerReverse:
                {
                    NewTranslation = CATransform3DMakeTranslation(-XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, -YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, 0);
                }
                    break;
                    
                default:
                {
                    NewTranslation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, 0);
                }
                    break;
            }
        }
        else
        {
            switch (self.RotateMethod)
            {
                case WithFinger:
                {
                    NewTranslation = CATransform3DMakeTranslation(-XDegress*LayerVieTranslation*InTranslationParameter, -YDegress*LayerVieTranslation*InTranslationParameter, 0);
                }
                    break;
                    
                case WithFingerReverse:
                {
                    NewTranslation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter, YDegress*LayerVieTranslation*InTranslationParameter, 0);
                }
                    break;
                    
                default:
                {
                    NewTranslation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter, YDegress*LayerVieTranslation*InTranslationParameter, 0);
                }
                    break;
            }
            
        }
        
        CATransform3D NewAllTransform = CATransform3DConcat(NewTranslation,NewScale);
        
        CABasicAnimation *LayerImageViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        LayerImageViewCABasicAnimation.duration = 0.4f;
        LayerImageViewCABasicAnimation.autoreverses = NO;
        LayerImageViewCABasicAnimation.toValue = [NSValue valueWithCATransform3D:NewAllTransform];
        LayerImageViewCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:LayerImageView.layer.transform];
        LayerImageViewCABasicAnimation.fillMode = kCAFillModeBoth;
        LayerImageViewCABasicAnimation.removedOnCompletion = YES;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:LayerImageViewCABasicAnimation,nil];
        animGroup.duration = 0.4f;
        animGroup.removedOnCompletion = YES;
        animGroup.autoreverses = NO;
        animGroup.fillMode = kCAFillModeRemoved;
        
        [CATransaction begin];
        LayerImageView.layer.transform = CATransform3DPerspect(NewAllTransform, CGPointMake(0, 0), zPositionMax);
        [CATransaction setCompletionBlock:^
         {
             if (i == [LayerArray count] - 1)
             {
                 RotationTimer =  [NSTimer scheduledTimerWithTimeInterval:RotationInterval/RotationAllSteps target:weakSelf selector:@selector(ManualAnimatiom) userInfo:nil repeats:YES];
                 weakSelf.hasPreformedBeginAnimation = YES;
             }
         }];
        [LayerImageView.layer addAnimation:animGroup forKey:@"LayerImageViewParallaxInitAnimation"];
        [CATransaction commit];
    }

}

- (void)EndManualAnimatiom
{
    [RotationTimer invalidate];
}

-(void)ManualAnimatiom
{
    __weak JZParallaxButton *weakSelf = self;
    CGFloat XOffest;
    if (TouchPointInSelf.x < 0)
    {
        XOffest = - weakSelf.frame.size.width / 2;
    }else if (TouchPointInSelf.x > weakSelf.frame.size.width)
    {
        XOffest = weakSelf.frame.size.width / 2;
    }else
    {
        XOffest = TouchPointInSelf.x - weakSelf.frame.size.width / 2;
    }
    
    CGFloat YOffest;
    if (TouchPointInSelf.y < 0)
    {
        YOffest = - weakSelf.frame.size.height / 2;
    }else if (TouchPointInSelf.y > weakSelf.frame.size.height)
    {
        YOffest = weakSelf.frame.size.height / 2;
    }else
    {
        YOffest = TouchPointInSelf.y - weakSelf.frame.size.height / 2;
    }
    
    //NSLog(@"XOffest : %f , YOffest : %f",XOffest,YOffest);
    
    CGFloat XDegress = XOffest / weakSelf.frame.size.width / 2;
    CGFloat YDegress = YOffest / weakSelf.frame.size.height / 2;
    
    //NSLog(@"XDegress : %f , YDegress : %f",XDegress,YDegress);

    
    int i = 0;
    CATransform3D NewRotate,NewTranslation,NewScale;
    switch (weakSelf.RotateMethod)
    {
        case WithFinger:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(-XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(XDegress*BoundsVieTranslation*OutTranslationParameter, YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
            
        case WithFingerReverse:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(-XDegress*BoundsVieTranslation*OutTranslationParameter, +YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
            
        default:
        {
            NewRotate = CATransform3DConcat(CATransform3DMakeRotation(XDegress*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(-YDegress*RotateParameter, 1, 0, 0));
            NewTranslation = CATransform3DMakeTranslation(-XDegress*BoundsVieTranslation*OutTranslationParameter, +YDegress*BoundsVieTranslation*OutTranslationParameter, 0);
        }
            break;
    }
    NewScale = CATransform3DMakeScale(OutScaleParameter, OutScaleParameter, 1);
    
    CATransform3D TwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
    CATransform3D AllTransform = CATransform3DConcat(TwoTransform,NewScale);
    weakSelf.BoundsView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        float InScaleParameter = [weakSelf InScaleParameterWithLayerArray:LayerArray WithIndex:i];
        float InTranslationParameter = [weakSelf InTranslationParameterWithLayerArray:LayerArray WithIndex:i];
        
        
        if (i == [LayerArray count] - 1) //is spotlight
        {
            UIImageView *LayerImageView = [weakSelf.LayerArray objectAtIndex:i];
            
            CATransform3D Translation;
            switch (weakSelf.RotateMethod)
            {
                case WithFinger:
                {
                    Translation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange,0);
                }
                    break;
                    
                case WithFingerReverse:
                {
                    Translation = CATransform3DMakeTranslation(-XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, -YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange,0);
                }
                    break;
                    
                default:
                {
                    Translation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, YDegress*LayerVieTranslation*InTranslationParameter*SpotlightOutRange,0);
                }
                    break;
            }

            CATransform3D Scale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
            CATransform3D AllTransform = CATransform3DConcat(Translation,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
        }
        else //is Parallax layer
        {
            UIImageView *LayerImageView = [weakSelf.LayerArray objectAtIndex:i];
            
            CATransform3D Translation;
            switch (weakSelf.RotateMethod)
            {
                case WithFinger:
                {
                    Translation = CATransform3DMakeTranslation(-XDegress*LayerVieTranslation*InTranslationParameter, -YDegress*LayerVieTranslation*InTranslationParameter,0);
                }
                    break;
                    
                case WithFingerReverse:
                {
                    Translation = CATransform3DMakeTranslation(XDegress*LayerVieTranslation*InTranslationParameter, YDegress*LayerVieTranslation*InTranslationParameter,0);
                }
                    break;
                    
                default:
                {
                    Translation = CATransform3DMakeTranslation(-XDegress*LayerVieTranslation*InTranslationParameter, -YDegress*LayerVieTranslation*InTranslationParameter,0);
                }
                    break;
            }

            CATransform3D Scale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
            CATransform3D AllTransform = CATransform3DConcat(Translation,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
        }
        
    }

}
- (void)EndAnimation
{
    switch (self.RotateMethod)
    {
        case AutoRotate:
            [self EndAutoRotation];
            break;
            
        case WithFinger:
            [self EndManualAnimatiom];
            break;
            
        case WithFingerReverse:
            [self EndManualAnimatiom];
            break;
            
        default:
            [self EndAutoRotation];
            break;
    }
    
    __weak JZParallaxButton *weakSelf = self;
    
    CATransform3D NewRotate = CATransform3DConcat(CATransform3DMakeRotation(0, 0, 1, 0), CATransform3DMakeRotation(0, 1, 0, 0));
    CATransform3D NewTranslation = CATransform3DMakeTranslation(0,0, 0);
    
    
    CABasicAnimation *BoundsViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    BoundsViewCABasicAnimation.duration = 0.4f;
    BoundsViewCABasicAnimation.autoreverses = NO;
    BoundsViewCABasicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DConcat(NewRotate,NewTranslation)];
    BoundsViewCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:BoundsView.layer.transform];
    BoundsViewCABasicAnimation.fillMode = kCAFillModeBoth;
    BoundsViewCABasicAnimation.removedOnCompletion = YES;
    [BoundsView.layer addAnimation:BoundsViewCABasicAnimation forKey:@"BoundsViewCABasicAnimation"];
    BoundsView.layer.transform = CATransform3DPerspect(CATransform3DConcat(NewRotate,NewTranslation), CGPointMake(0, 0), zPositionMax);
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];
        CATransform3D NowTransform = LayerImageView.layer.transform;

        CATransform3D NewTranslation = CATransform3DMakeTranslation(0, 0, 0);
        CATransform3D NewScale = CATransform3DMakeScale(1, 1, 1);
        CATransform3D NewAllTransform = CATransform3DConcat(NewTranslation,NewScale);
        
        CABasicAnimation *LayerImageViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        LayerImageViewCABasicAnimation.duration = 0.4f;
        LayerImageViewCABasicAnimation.autoreverses = NO;
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
        LayerImageView.layer.transform = CATransform3DPerspect(NewAllTransform, CGPointMake(0, 0), zPositionMax);
        [CATransaction setCompletionBlock:^
         {
             if (i == [LayerArray count] - 1)
             {
                 
                 [UIView animateWithDuration: 0.1
                                       delay: 0
                                     options: (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                                  animations:^{
                                      weakSelf.SpotLightView.alpha = 0.0;
                                  }
                                  completion:^(BOOL finished){ weakSelf.isParallax = NO; }
                  ];

                 
             }
         }];
        [LayerImageView.layer addAnimation:animGroup forKey:@"LayerImageViewParallaxInitAnimation"];
        [CATransaction commit];
    }
    
}

- (void)BeginAutoRotation
{
    __weak JZParallaxButton *weakSelf = self;
    //到达起始位置
    
    CGFloat PIE = 0;
    CGFloat Degress = M_PI*2*PIE;
    //NSlog(@"Degress : %f PIE",PIE);
    CGFloat Sin = sin(Degress)/4;
    CGFloat Cos = cos(Degress)/4;
    
    int i =0;
    CATransform3D NewRotate,NewTranslation,NewScale;
    NewRotate = CATransform3DConcat(CATransform3DMakeRotation(-Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(Cos*RotateParameter, 1, 0, 0));
    NewTranslation = CATransform3DMakeTranslation(Sin*BoundsVieTranslation*OutTranslationParameter, Cos*BoundsVieTranslation*OutTranslationParameter, 0);
    NewScale = CATransform3DMakeScale(OutScaleParameter, OutScaleParameter, 1);
    
    CATransform3D TwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
    CATransform3D AllTransform = CATransform3DConcat(TwoTransform,NewScale);
    
    CABasicAnimation *BoundsLayerCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    BoundsLayerCABasicAnimation.duration = 0.4f;
    BoundsLayerCABasicAnimation.autoreverses = NO;
    BoundsLayerCABasicAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax)];
    BoundsLayerCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:BoundsView.layer.transform];
    BoundsLayerCABasicAnimation.fillMode = kCAFillModeBoth;
    BoundsLayerCABasicAnimation.removedOnCompletion = YES;
    [BoundsView.layer addAnimation:BoundsLayerCABasicAnimation forKey:@"BoundsLayerCABasicAnimation"];
    BoundsView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        
        float InTranslationParameter = [self InTranslationParameterWithLayerArray:LayerArray WithIndex:i];
        float InScaleParameter = [self InScaleParameterWithLayerArray:LayerArray WithIndex:i];
        UIImageView *LayerImageView = [LayerArray objectAtIndex:i];

        CATransform3D NewTranslation ;
        CATransform3D NewScale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
        
        if (i == [LayerArray count] - 1) //is spotlight
        {
            NewTranslation = CATransform3DMakeTranslation(Sin*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, Cos*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, 0);
        }
        else
        {
            NewTranslation = CATransform3DMakeTranslation(-Sin*LayerVieTranslation*InTranslationParameter, -Cos*LayerVieTranslation*InTranslationParameter, 0);
        }
        
        CATransform3D NewAllTransform = CATransform3DConcat(NewTranslation,NewScale);
        
        CABasicAnimation *LayerImageViewCABasicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        LayerImageViewCABasicAnimation.duration = 0.4f;
        LayerImageViewCABasicAnimation.autoreverses = NO;
        LayerImageViewCABasicAnimation.toValue = [NSValue valueWithCATransform3D:NewAllTransform];
        LayerImageViewCABasicAnimation.fromValue = [NSValue valueWithCATransform3D:LayerImageView.layer.transform];
        LayerImageViewCABasicAnimation.fillMode = kCAFillModeBoth;
        LayerImageViewCABasicAnimation.removedOnCompletion = YES;
        
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        animGroup.animations = [NSArray arrayWithObjects:LayerImageViewCABasicAnimation,nil];
        animGroup.duration = 0.4f;
        animGroup.removedOnCompletion = YES;
        animGroup.autoreverses = NO;
        animGroup.fillMode = kCAFillModeRemoved;
        
        [CATransaction begin];
        LayerImageView.layer.transform = CATransform3DPerspect(NewAllTransform, CGPointMake(0, 0), zPositionMax);
        [CATransaction setCompletionBlock:^
         {
             if (i == [LayerArray count] - 1)
             {
                 //开始周期循环
                 RotationNowStep = 0;
                 RotationTimer =  [NSTimer scheduledTimerWithTimeInterval:RotationInterval/RotationAllSteps target:weakSelf selector:@selector(RotationCreator) userInfo:nil repeats:YES];
                 weakSelf.hasPreformedBeginAnimation = YES;
             }
         }];
        [LayerImageView.layer addAnimation:animGroup forKey:@"LayerImageViewParallaxInitAnimation"];
        [CATransaction commit];
    }

    
}


- (void)RotationCreator
{
    __weak JZParallaxButton *weakSelf = self;
 
    //NSlog(@"RotationNowStep : %d of %d",RotationNowStep,RotationAllSteps);
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
    //NSlog(@"Degress : %f PIE",PIE);
    CGFloat Sin = sin(Degress)/4;
    CGFloat Cos = cos(Degress)/4;
    
    int i = 0;
    CATransform3D NewRotate,NewTranslation,NewScale;
    NewRotate = CATransform3DConcat(CATransform3DMakeRotation(-Sin*RotateParameter, 0, 1, 0), CATransform3DMakeRotation(Cos*RotateParameter, 1, 0, 0));
    NewTranslation = CATransform3DMakeTranslation(Sin*BoundsVieTranslation*OutTranslationParameter, Cos*BoundsVieTranslation*OutTranslationParameter, 0);
    NewScale = CATransform3DMakeScale(OutScaleParameter, OutScaleParameter, 1);
    
    CATransform3D TwoTransform = CATransform3DConcat(NewRotate,NewTranslation);
    CATransform3D AllTransform = CATransform3DConcat(TwoTransform,NewScale);
    BoundsView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
    
    for (int i = 0 ; i < [LayerArray count]; i++)
    {
        float InScaleParameter = [self InScaleParameterWithLayerArray:LayerArray WithIndex:i];
        float InTranslationParameter = [self InTranslationParameterWithLayerArray:LayerArray WithIndex:i];
        
        
        if (i == [LayerArray count] - 1) //is spotlight
        {
            UIImageView *LayerImageView = [weakSelf.LayerArray objectAtIndex:i];
            
            CATransform3D Translation = CATransform3DMakeTranslation(Sin*LayerVieTranslation*InTranslationParameter*SpotlightOutRange, Cos*LayerVieTranslation*InTranslationParameter*SpotlightOutRange,0);
            CATransform3D Scale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
            CATransform3D AllTransform = CATransform3DConcat(Translation,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
        }
        else //is Parallax layer
        {
            UIImageView *LayerImageView = [weakSelf.LayerArray objectAtIndex:i];
            
            CATransform3D Translation = CATransform3DMakeTranslation(-Sin*LayerVieTranslation*InTranslationParameter, -Cos*LayerVieTranslation*InTranslationParameter, 0);
            CATransform3D Scale = CATransform3DMakeScale(InScaleParameter, InScaleParameter, 1);
            CATransform3D AllTransform = CATransform3DConcat(Translation,Scale);
            
            LayerImageView.layer.transform = CATransform3DPerspect(AllTransform, CGPointMake(0, 0), zPositionMax);
        }
        
    }

    
    
}
- (void)EndAutoRotation
{
    [RotationTimer invalidate];
}

- (void)AddShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0.0f, 12.0f);
    self.layer.shadowOpacity = 0.6;
    
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

- (float)InTranslationParameterWithLayerArray:(NSMutableArray *)Array
                                    WithIndex:(int)i
{

    switch (ParallaxMethod)
    {
        case Linear:
            return (float)(i)/(float)([Array count]);
            break;
            
        case EaseIn:
            return powf((float)(i)/(float)([Array count]), 0.5f);
            break;
    
        case EaseOut:
            return powf((float)(i)/(float)([Array count]), 2.0f);
            break;
            
        default:
            return (float)(i)/(float)([Array count]);
            break;
    }
}
- (float)InScaleParameterWithLayerArray:(NSMutableArray *)Array
                                    WithIndex:(int)i
{
    
    switch (ParallaxMethod)
    {
        case Linear:
            return 1+ScaleAddition/10*((float)i/(float)([LayerArray count]));
            break;
            
        case EaseIn:
            return 1+ScaleAddition/10*powf(((float)i/(float)([LayerArray count])), 0.5f);
            break;
            
        case EaseOut:
            return 1+ScaleAddition/10*powf(((float)i/(float)([LayerArray count])), 2.0f);
            break;
            
        default:
            return 1+ScaleAddition/10*((float)i/(float)([LayerArray count]));
            break;
    }
}


@end
