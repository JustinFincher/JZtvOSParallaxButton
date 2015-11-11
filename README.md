# JZtvOSParallaxButton

[![CI Status](http://img.shields.io/travis/Fincher Justin/JZtvOSParallaxButton.svg?style=flat)](https://travis-ci.org/Fincher Justin/JZtvOSParallaxButton)
[![Version](https://img.shields.io/cocoapods/v/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)
[![License](https://img.shields.io/cocoapods/l/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)
[![Platform](https://img.shields.io/cocoapods/p/JZtvOSParallaxButton.svg?style=flat)](http://cocoapods.org/pods/JZtvOSParallaxButton)

## Introduction
![]()
tvOS Button with Parallax Effect (ObjC).  
Apple TV HIG has a [Video](https://developer.apple.com/tvos/human-interface-guidelines/icons-and-images/images/icons-and-images-layering.mp4)  
This is a Button try to be similar. With reflection light, long press to enable parallax mode, long press to disable.  
DemoGif:

## Usage
```
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

You can also tweak these parameters:  
**ScaleBase**:CGFloat , default 1.0f. When long pressed , the button scales up for a little bit, and this is how much should be scaled up.  
**ScaleAddition**:CGFloat , default 1.0f. When long pressed , the button also scales down parallax image layers to have a perspective effect. and ScaleAddition adjusts this.  
**isParallax**:BOOL, indicates the button's state.

And these:(in JZParallaxButton.m define)  
**RotateParameter** CGFloat,default 0.4. Rotation angle parameter.  
**SpotlightOutRange** CGFloat, default 5.0f. indicates the distance from button's center to the reflection light.  

To run the example project, clone the repo, and run `pod install` from the Example directory first.


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
