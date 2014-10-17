//
//  InfoViewController.h
//  Cashew
//
//  Created by Jonathan Chew on 10/9/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CSAnimationView.h>

@interface InfoViewController : UIViewController

- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *goBackButton;
@property (strong, nonatomic) IBOutlet CSAnimationView *cashewLater;
@property (strong, nonatomic) IBOutlet CSAnimationView *goBackButtonView;
@property (strong, nonatomic) IBOutlet UIView *touchListenerView;
@property (strong, nonatomic) IBOutlet CSAnimationView *firstQuestionView;
@property (strong, nonatomic) IBOutlet CSAnimationView *byeView;

@end

@protocol InfoViewControllerDelegate <NSObject>
@end

