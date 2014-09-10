//
//  SearchViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultsViewController.h"

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

@interface SearchViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *originLocation;
@property (strong, nonatomic) IBOutlet UITextField *destinationLocation;
- (IBAction)findResults:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *travelModesArray;
@property (strong, nonatomic) NSMutableArray *selectedTravelModes;

@end
