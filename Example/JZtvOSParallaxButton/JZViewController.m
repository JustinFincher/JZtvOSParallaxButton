//
//  JZViewController.m
//  JZtvOSParallaxButton
//
//  Created by Fincher Justin on 11/11/2015.
//  Copyright (c) 2015 Fincher Justin. All rights reserved.
//

#import "JZViewController.h"

#define SIDEWIDTH 80
#import "JZParallaxButton.h"

@interface JZViewController ()

@end

@implementation JZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //从下往上
    NSMutableArray *Layers = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"Layer1"],[UIImage imageNamed:@"Layer2"],[UIImage imageNamed:@"Layer3"],[UIImage imageNamed:@"Layer4"], nil];
    
    JZParallaxButton *NewPB = [[JZParallaxButton alloc] initButtonWithCGRect:CGRectMake(SIDEWIDTH, 100, self.view.frame.size.width - SIDEWIDTH * 2, (self.view.frame.size.width - SIDEWIDTH * 2) / 320 * 180)
                                                              WithLayerArray:Layers
                                                      WithRoundCornerEnabled:YES
                                                   WithCornerRadiusifEnabled:5.0f
                                                          WithRotationFrames:100
                                                        WithRotationInterval:3.0f];
    
    
    [self.view addSubview:NewPB];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
