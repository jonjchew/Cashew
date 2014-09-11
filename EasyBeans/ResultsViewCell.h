//
//  ResultsViewCell.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/10/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *modeLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeDurationLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *fourthLabel;
- (IBAction)selectMode:(id)sender;

@end
