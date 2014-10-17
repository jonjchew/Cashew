//
//  InfoViewController.m
//  Cashew
//
//  Created by Jonathan Chew on 10/9/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController {
    NSUInteger _tapCount;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.touchListenerView addGestureRecognizer:singleTapGestureRecognizer];
    self.cashewLater.hidden = YES;
    self.goBackButtonView.hidden = YES;
    self.byeView.hidden = YES;
    self.firstQuestionView.hidden = YES;
    self.goBackButton.layer.cornerRadius = 25;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        _tapCount = 0;
}

- (IBAction)goBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_tapCount == 0) {
        self.firstQuestionView.hidden = NO;
        [self.firstQuestionView startCanvasAnimation];
        _tapCount += 1;
    }
    else if (_tapCount == 1) {
        self.cashewLater.hidden = NO;
        [self.cashewLater startCanvasAnimation];
        _tapCount += 1;
    }
    else if (_tapCount == 2) {
        self.goBackButtonView.hidden = NO;
        self.byeView.hidden = NO;
        [self.byeView startCanvasAnimation];
        [self.goBackButtonView startCanvasAnimation];
        _tapCount += 1;
    }
}

@end
