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

typedef NS_ENUM(NSInteger, RotateMethodType)
{
    AutoRotate = 0,
    WithFinger,
    WithFingerReverse,
};

@interface JZParallaxButton : UIButton

//当前Button包含的所有ImageLayer
@property (nonatomic,strong) NSMutableArray *LayerArray;

//button圆角
@property (nonatomic,assign) BOOL RoundCornerEnabled;

//button圆角
@property (nonatomic,assign) CGFloat RoundCornerRadius;

//是否在Parallax
@property (nonatomic,assign) BOOL isParallax;

@property (nonatomic,assign) int RotationAllSteps;
@property (nonatomic,assign) CGFloat RotationInterval;

@property (nonatomic,assign) CGFloat ScaleBase;
@property (nonatomic,assign) CGFloat ScaleAddition;

@property (nonatomic,assign) ParallaxMethodType ParallaxMethod;
@property (nonatomic,assign) RotateMethodType RotateMethod;

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
                  WithParallaxMethod:(ParallaxMethodType)Parallax
                    WithRotateMethod:(RotateMethodType)Rotate;

@end
