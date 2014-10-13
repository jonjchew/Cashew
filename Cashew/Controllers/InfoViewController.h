//
//  InfoViewController.h
//  Cashew
//
//  Created by Jonathan Chew on 10/9/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController

- (IBAction)goBack:(id)sender;

@end

@protocol InfoViewControllerDelegate <NSObject>
@end

