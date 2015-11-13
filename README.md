# JZtvOSParallaxButton

[![CI Status](http://img.shields.io/travis/Fincher Justin/JZtvOSParallaxButton.svg?style=flat)](https://travis-ci.org/Fincher Justin/JZtvOSParallaxButton)
[![Version](https://img.shields.io/cocoapods/v/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)
[![License](https://img.shields.io/cocoapods/l/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)
[![Platform](https://img.shields.io/cocoapods/p/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)

## Introduction
![https://github.com/JustinFincher/JZtvOSParallaxButton/blob/master/DemoPic/JPG.jpg](https://github.com/JustinFincher/JZtvOSParallaxButton/blob/master/DemoPic/JPG.jpg)  
[中文](https://github.com/JustinFincher/JZtvOSParallaxButton#chinese) / [English](https://github.com/JustinFincher/JZtvOSParallaxButton#introduction)  
tvOS Button with Parallax Effect (ObjC).  
Apple TV HIG has a [Video](https://developer.apple.com/tvos/human-interface-guidelines/icons-and-images/images/icons-and-images-layering.mp4)  
This is a Button try to be similar. With reflection light, long press to enable parallax mode, long press to disable.  
DemoGif:  
![https://github.com/JustinFincher/JZtvOSParallaxButton/blob/master/DemoPic/GIF.gif](https://github.com/JustinFincher/JZtvOSParallaxButton/blob/master/DemoPic/GIF.gif)

## Usage
```
#import "JZParallaxButton.h"

..... //TL;DR


NSMutableArray *Layers = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"Layer1"],[UIImage imageNamed:@"Layer2"],[UIImage imageNamed:@"Layer3"],[UIImage imageNamed:@"Layer4"], nil];
    
    JZParallaxButton *NewPB = [[JZParallaxButton alloc] initButtonWithCGRect:YourRect
                                                              WithLayerArray:Layers
                                                      WithRoundCornerEnabled:YES
                                                   WithCornerRadiusifEnabled:5.0f
                                                          WithRotationFrames:100
                                                        WithRotationInterval:3.0f];
    
    
    [self.view addSubview:NewPB];
```
**WithLayerArray**:NSArray,Array of UIImage,Remember that image index in array should be from buttom to top.   
**WithRoundCornerEnabled**:BOOL  
**WithCornerRadiusifEnabled**:CGFloat  
**WithRotationFrames**:int,how many frames should be rendered if the button rotates itself for a complete turn.  
**WithRotationInterval**:CGFloat,how many seconds should the button rotates itself for a complete turn.  
(Tips: `WithRotationFrames/WithRotationInterval` indicates how a rotation & position lasts, usually it should be < 1/24 , or with any RotateMethodType the rotation animation will be lag)  

You can also tweak these parameters:  
**ScaleBase**:CGFloat , default 1.0f. When long pressed , the button scales up for a little bit, and this is how much should be scaled up.  
**ScaleAddition**:CGFloat , default 1.0f. When long pressed , the button also scales up parallax image layers to have a perspective effect. and ScaleAddition adjusts this.  
**isParallax**:BOOL, indicates the button's state.

**ParallaxMethod**:ENUM, 3 choices, this changes depth effect    
```  
typedef NS_ENUM(NSInteger, ParallaxMethodType)  
{  
    Linear = 0, //Default  
    EaseIn, //Use this when your want your foreground layer parallax more  
    EaseOut, //Use this when your want your background layer parallax more  
};  
```  
**RotateMethodType**:ENUM, 3 choices, this changes if rotation effect is automatic, or changes with finger movements.      
```
typedef NS_ENUM(NSInteger, RotateMethodType)
{
    AutoRotate = 0, //Default
    WithFinger, //Rotation for the direction where finger at.
    WithFingerReverse, //Rotation for the opposite direction where finger at.
};
```

And these:(in JZParallaxButton.m define)  
**RotateParameter** CGFloat,default 0.4. Rotation angle parameter.  
**SpotlightOutRange** CGFloat, default 5.0f. indicates the distance from button's center to the reflection light.  

To run the example project, clone the repo, and run `pod install` from the Example directory first.  
JZViewController.m contains 3 Parallax button, 2 posters and 1 icon. Remove the `//` before `addSubview` to see it.


## Installation

JZtvOSParallaxButton is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JZtvOSParallaxButton"
```


Or, grab JZParallaxButton.h and .m ,edit .m file:  
```
SpotLightView.image = [UIImage imageNamed:@"Spotlight" inBundle:bundle compatibleWithTraitCollection:nil];
```  
With  
```
SpotLightView.image = [UIImage imageNamed:@"Spotlight"];
```  
Then grab Spotlight.png from [this](https://github.com/JustinFincher/JZtvOSParallaxButton/tree/master/Pod/Assets)

## TO-DO
1.Add 3d touch support.  
## Author

Fincher Justin, zhtsu47@me.com

## License

JZtvOSParallaxButton is available under the MIT license. See the LICENSE file for more info.


##Chinese
JZtvOSParallaxButton 是一个模仿Apple TV中三维视差按钮的UIButton.  
这个按钮init的时候 是普通样式 但是长按可以开启如同[苹果设计规范](https://developer.apple.com/tvos/human-interface-guidelines/icons-and-images/images/icons-and-images-layering.mp4)这样的自转效果 同时便可以看到分层的三维效果. 长按即可回到普通样式.  

用法:同Usage  
**WithLayerArray**:NSArray,UIImage的数组,图层排序应该是从下往上进行addobject   
**WithRoundCornerEnabled**:BOOL 是否圆角（好看些 推荐）  
**WithCornerRadiusifEnabled**:CGFloat 圆角的半径  
**WithRotationFrames**:int,就是自转一周要用多少帧（这里说的不太严谨 其实指的不是帧速 而是按钮自己一周要做多少次3DTransform的Animation）   
**WithRotationInterval**:CGFloat,一周要多少秒    
(建议: `WithRotationFrames/WithRotationInterval` 表示一帧保持多少秒, 一般这个数字应该小于 1/24 , 否则对于任何RotateMethodType整个动画都会显得很卡)  

还有这些参数：  
**ScaleBase**:CGFloat , 默认1.0f. 长按的时候 有个变大的动画 这个可以改变大多少 不过默认1.0够了    
**ScaleAddition**:CGFloat , 默认 1.0f. 长按后 每个图层都会有或多或少的放大（用于制造远小近大的透视效果）这个参数调节图层放大多少.  
**isParallax**:BOOL, 通过这个读取当前状态 应该是read-only的 但没限制.

**ParallaxMethod**:枚举, 3个选择, 用于改变透视的深度效果   
```  
typedef NS_ENUM(NSInteger, ParallaxMethodType)  
{  
    Linear = 0, //默认  
    EaseIn, //如果想要前排的图层视差效果更好些    
    EaseOut, //如果想要后排的图层视差效果更好些    
};  
```  
**RotateMethodType**:枚举, 3 选择, 改变自转效果是自动的 还是跟随手指      
```
typedef NS_ENUM(NSInteger, RotateMethodType)
{  
    AutoRotate = 0, //默认    
    WithFinger, //按钮向手指按下的地方转动  
    WithFingerReverse, //按钮向手指按下的反方向转动  
};  
```   
还有这些:(在JZParallaxButton.m的define)  
**RotateParameter** CGFloat,默认 0.4. 自转的时候角度参数.  
**SpotlightOutRange** CGFloat, 默认 5.0f. 高光和按钮中心的距离（最好调大点 这样看起来真实, 4.0-7.0f差不多）.  

