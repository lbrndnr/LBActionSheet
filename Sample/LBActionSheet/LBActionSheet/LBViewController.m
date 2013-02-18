//
//  LBViewController.m
//  LBActionSheet
//
//  Created by Laurin Brandner on 18.02.13.
//  Copyright (c) 2013 Laurin Brandner. All rights reserved.
//

#import "LBViewController.h"

@interface LBViewController ()

@end

@implementation LBViewController

-(void)viewDidAppear:(BOOL)animated {
    LBActionSheet* sheet = [[LBActionSheet alloc] initWithTitle:@"Title" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Destructive" otherButtonTitles:@"Other Buttons", nil];
    [sheet showInView:self.view];
}

@end
