//
//  LBAppDelegate.m
//  LBActionSheet
//
//  Created by Laurin Brandner on 16.02.13.
//  Copyright (c) 2013 Laurin Brandner. All rights reserved.
//

#import "LBAppDelegate.h"

@implementation LBAppDelegate

-(void)shouldntwork:(UIButton*)sender {
    LBActionSheet* actionSheet = [[LBActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Other Title", nil];
    [actionSheet setCancelButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-cancel"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [actionSheet setCancelButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-cancel-pressed"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateHighlighted];
    [actionSheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [actionSheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button-pressed"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateHighlighted];
    actionSheet.backgroundImage = [UIImage imageNamed:@"actionsheet-background"];
    [actionSheet addButtonWithTitle:@"Another Title"];
    
    NSMutableDictionary* titleAttributes = [NSMutableDictionary new];
    [titleAttributes setObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f] forKey:UITextAttributeFont];
    [titleAttributes setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [titleAttributes setObject:[UIColor colorWithWhite:0.0f alpha:0.5f] forKey:UITextAttributeTextShadowColor];
    [titleAttributes setObject:[NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)] forKey:UITextAttributeTextShadowOffset];
    [actionSheet setButtonTitleAttributes:titleAttributes forState:UIControlStateNormal];
    [actionSheet setButtonTitleAttributes:titleAttributes forState:UIControlStateHighlighted];
    
    UIImageView* separator = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.window.frame), 3.0f)];
    separator.image = [UIImage imageNamed:@"actionsheet-separator"];
    [actionSheet insertControl:separator atIndex:2];
    
    [actionSheet showInView:self.window];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController* viewController = [UIViewController new];
    CGFloat tabBarHeight = 44.0f;
    UITabBar* tabBar = [[UITabBar alloc] initWithFrame:(CGRect){{0.0f, CGRectGetHeight(window.frame)-tabBarHeight-CGRectGetHeight(application.statusBarFrame)}, {CGRectGetWidth(window.frame), tabBarHeight}}];
    viewController.view.backgroundColor = [UIColor whiteColor];
    [viewController.view addSubview:tabBar];
    window.rootViewController = viewController;
    self.window = window;
    
    [self.window makeKeyAndVisible];
    
    LBActionSheet* actionSheet = [[LBActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Other Title", nil];
    [actionSheet setCancelButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-cancel"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [actionSheet setCancelButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-cancel-pressed"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateHighlighted];
    [actionSheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateNormal];
    [actionSheet setDefaultButtonBackgroundImage:[[UIImage imageNamed:@"actionsheet-button-pressed"] stretchableImageWithLeftCapWidth:7 topCapHeight:0] forState:UIControlStateHighlighted];
    actionSheet.backgroundImage = [UIImage imageNamed:@"actionsheet-background"];
    [actionSheet addButtonWithTitle:@"Another Title"];
    
    NSMutableDictionary* titleAttributes = [NSMutableDictionary new];
    [titleAttributes setObject:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f] forKey:UITextAttributeFont];
    [titleAttributes setObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [titleAttributes setObject:[UIColor colorWithWhite:0.0f alpha:0.5f] forKey:UITextAttributeTextShadowColor];
    [titleAttributes setObject:[NSValue valueWithCGSize:CGSizeMake(0.0f, 1.0f)] forKey:UITextAttributeTextShadowOffset];
    [actionSheet setButtonTitleAttributes:titleAttributes forState:UIControlStateNormal];
    [actionSheet setButtonTitleAttributes:titleAttributes forState:UIControlStateHighlighted];
    
    UIImageView* separator = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(window.frame), 3.0f)];
    separator.image = [UIImage imageNamed:@"actionsheet-separator"];
    [actionSheet insertControl:separator atIndex:2];
    
    [actionSheet showFromTabBar:tabBar];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Shouldn't work" forState:UIControlStateNormal];
    button.frame = CGRectMake(20.0f, 20.0f, 280.0f, 30.0f);
    [button addTarget:self action:@selector(shouldntwork:) forControlEvents:UIControlEventTouchUpInside];
    [viewController.view addSubview:button];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
