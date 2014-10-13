//
//  CashewNavigationController.m
//  Cashew
//
//  Created by Jonathan Chew on 10/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "CashewNavigationController.h"
#import "UIColor+CashewGreen.h"

@implementation CashewNavigationController

- (void)viewDidLoad
{
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"weezerfont" size:30],
                                                NSFontAttributeName, nil]];
    self.navigationBar.barTintColor = [UIColor cashewGreenColor];
    self.navigationBar.tintColor = [UIColor whiteColor]; 
}


@end
