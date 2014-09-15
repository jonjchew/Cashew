//
//  StepsViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "StepsViewController.h"
#import "Step.h"

@interface StepsViewController ()

@end

@implementation StepsViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *timeDurationLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *travelModeLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *directionsLabel = (UILabel *)[cell viewWithTag:4];
    
    NSString *htmlDirectionString = [[self.stepsArray objectAtIndex: indexPath.row] htmlDirections];
    
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
    
    NSMutableAttributedString *attrDirectionString = [[NSMutableAttributedString alloc] initWithData:[htmlDirectionString dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:nil error:nil];

    distanceLabel.text = [[self.stepsArray objectAtIndex:indexPath.row] distance];
    timeDurationLabel.text = [[self.stepsArray objectAtIndex: indexPath.row] timeDuration];
    directionsLabel.attributedText = attrDirectionString;
    travelModeLabel.text = [[self.stepsArray objectAtIndex: indexPath.row] travelMode];
    
    return cell;
}

@end
