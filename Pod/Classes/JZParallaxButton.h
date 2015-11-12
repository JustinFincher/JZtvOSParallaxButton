//
//  JZParallaxButton.h
//  JZtvOSParallaxButton
//
//  Created by Fincher Justin on 15/11/10.
//  Copyright © 2015年 Fincher Justin. All rights reserved.
//


//记得添加3D Touch
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ParallaxMethodType)
{
    Linear = 0,
    EaseIn,
    EaseOut,
};

@interface JZParallaxButton : UIButton

//当前Button包含的所有ImageLayer
@property (nonatomic) NSMutableArray *LayerArray;

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

@property (nonatomic,assign) ParallaxMethodType ParallaxMethod;

- (instancetype)initButtonWithCGRect:(CGRect)RectInfo
                      WithLayerArray:(NSMutableArray *)ArrayOfLayer
              WithRoundCornerEnabled:(BOOL)isRoundCorner
           WithCornerRadiusifEnabled:(CGFloat)Radius
                  WithRotationFrames:(int)Frames
                WithRotationInterval:(CGFloat)Interval;

- (instancetype)initButtonWithCGRect:(CGRect)RectInfo
                      WithLayerArray:(NSMutableArray *)ArrayOfLayer
              WithRoundCornerEnabled:(BOOL)isRoundCorner
           WithCornerRadiusifEnabled:(CGFloat)Radius
                  WithRotationFrames:(int)Frames
                WithRotationInterval:(CGFloat)Interval
                  WithParallaxMethod:(ParallaxMethodType)Parallax;

@end
