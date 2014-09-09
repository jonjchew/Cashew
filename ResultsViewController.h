//
//  ResultsViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/8/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *travelModeResults;

@end
