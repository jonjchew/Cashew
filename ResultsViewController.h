//
//  ResultsViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/8/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

@interface ResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *travelModeResults;
@property (strong, nonatomic) NSString *originLocationText;
@property (strong, nonatomic) NSString *destinationLocationText;
@property (strong, nonatomic) NSArray *selectedTravelModes;
@property (strong, nonatomic) NSMutableArray *uberModes;
@property (strong, nonatomic) NSDictionary *originGeocode;
@property (strong, nonatomic) NSDictionary *destinationGeocode;
@property (strong, nonatomic) NSString *originFormattedAddress;
@property (strong, nonatomic) IBOutlet UILabel *resultsTableHeader;
@property (strong, nonatomic) NSDictionary *destinationFormattedAddress;
@end
