//
//  ResultsViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/8/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

@interface ResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
- (IBAction)loadApp:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *destinationLabel;
@property (strong, nonatomic) IBOutlet UILabel *originLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *originLocationText;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *loadAppButton;
@property (strong, nonatomic) NSString *destinationLocationText;
@property (strong, nonatomic) NSArray *selectedTravelModes;
@property (strong, nonatomic) CLLocation *currenLocation;

-(void)findResults;

@end
