//
//  LBAppDelegate.h
//  LBActionSheet
//
//  Created by Laurin Brandner on 16.02.13.
//  Copyright (c) 2013 Laurin Brandner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBActionSheet.h"

@interface LBAppDelegate : UIResponder <UIApplicationDelegate, UIActionSheetDelegate, LBActionSheetDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
