//
//  JZParallaxButton.h
//  JZtvOSParallaxButton
//
//  Created by Fincher Justin on 15/11/10.
//  Copyright © 2015年 Fincher Justin. All rights reserved.
//


//记得添加3D Touch
#import <UIKit/UIKit.h>

@interface JZParallaxButton : UIButton

//当前Button包含的所有ImageLayer
@property (nonatomic) NSMutableArray *LayerArray;



//视差效果大小
@property (nonatomic) CGFloat ParallaxEffectParameter;

//button圆角
@property (nonatomic) BOOL RoundCornerEnabled;

//button圆角
@property (nonatomic) CGFloat RoundCornerRadius;

//是否在Parallax
@property (nonatomic) BOOL isParallax;

@property (nonatomic) int RotationAllSteps;
@property (nonatomic) CGFloat RotationInterval;

@property (nonatomic) CGFloat ScaleBase;
@property (nonatomic) CGFloat ScaleAddition;

- (instancetype)initButtonWithCGRect:(CGRect)RectInfo
                      WithLayerArray:(NSMutableArray *)ArrayOfLayer
              WithRoundCornerEnabled:(BOOL)isRoundCorner
           WithCornerRadiusifEnabled:(CGFloat)Radius
                  WithRotationFrames:(int)Frames
                WithRotationInterval:(CGFloat)Interval;
@end
