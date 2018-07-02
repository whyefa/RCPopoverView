//
//  RCViewController.m
//  RCPopoverView
//
//  Created by whyefa on 06/29/2018.
//  Copyright (c) 2018 whyefa. All rights reserved.
//

#import "RCViewController.h"
#import <RCPopoverView/RCPopoverView.h>

@interface RCViewController ()
@property (nonatomic, assign) CGFloat screenwidth;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation RCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenwidth = UIScreen.mainScreen.bounds.size.width;
    self.screenHeight = UIScreen.mainScreen.bounds.size.height;
}

- (IBAction)popDefaultMenu:(id)sender {
    RCPopoverView *popoverMenu = [RCPopoverView popoverView];
    popoverMenu.style = RCPopoverViewStyleDefault;
    popoverMenu.arrowStyle = RCPopoverViewArrowStyleRound;
    [popoverMenu showToPoint:CGPointMake(20, 50) withActions:[self menuItems]];
}

- (IBAction)popDarkMenu:(id)sender {
    RCPopoverView *popoverMenu = [RCPopoverView popoverView];
    popoverMenu.style = RCPopoverViewStyleDark;
    popoverMenu.arrowStyle = RCPopoverViewArrowStyleTriangle;
    [popoverMenu showToPoint:CGPointMake(self.screenwidth-40, 50) withActions:[self menuItems]];
}

- (IBAction)popShadowMenu:(id)sender {
    RCPopoverView *popoverMenu = [RCPopoverView popoverView];
    popoverMenu.arrowStyle = RCPopoverViewArrowStyleTriangle;
    popoverMenu.borderStyle = RCPopoverViewBorderStyleShadow;
    popoverMenu.shadowParam = (RCPopoverShadow){0.4, 3, CGSizeZero};
    popoverMenu.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    [popoverMenu showToPoint:CGPointMake(20, self.screenHeight-40) withActions:[self menuItems]];
}
- (IBAction)popBorderMenu:(id)sender {
    RCPopoverView *popoverMenu = [RCPopoverView popoverView];
    popoverMenu.borderStyle = RCPopoverViewBorderStyleBoarder;
    popoverMenu.separatorColor = UIColor.greenColor;
    [popoverMenu showToPoint:CGPointMake(self.screenwidth-40, self.screenHeight-40) withActions:[self menuItems]];
}

- (NSArray *)menuItems {
    RCPopoverAction *action1 = [RCPopoverAction actionWithTitle:@"分享到微信" handler:^(RCPopoverAction *action) {
        NSLog(@"分享到微信");
    }];
    RCPopoverAction *action2 = [RCPopoverAction actionWithTitle:@"分享到QQ" handler:^(RCPopoverAction *action) {
        NSLog(@"分享到QQ");
    }];
    RCPopoverAction *action3 = [RCPopoverAction actionWithTitle:@"退出登录" handler:^(RCPopoverAction *action) {
        NSLog(@"退出登录");
    }];
    return @[action1, action2, action3];
}

@end
