//
//  SearchViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"
#import "UberMode.h"
#import "GoogleDirection.h"
#import "Config.h"
#import "UIColor+CashewGreen.h"
#import <RTAlertView.h>
#import <AFNetworking/AFNetworking.h>

@interface SearchViewController () 

@end

@implementation SearchViewController {
    NSString *_inputtedOrigin;
    NSString *_inputtedDestination;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originLocation.delegate = self;
    self.destinationLocation.delegate = self;
    
    _inputtedDestination = @"destination";
    _inputtedOrigin = @"origin";
    self.travelModesArray = [Config sharedConfig].travelModes;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedTravelModes = [NSMutableArray array];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _originLocation) {
        [_destinationLocation becomeFirstResponder];
    }
    if (textField == _destinationLocation) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"getResults"]) {
        ResultsViewController *viewController = (ResultsViewController *) segue.destinationViewController;
        viewController.selectedTravelModes = self.selectedTravelModes;
        viewController.originLocationText = self.originLocation.text;
        viewController.destinationLocationText = self.destinationLocation.text;
        [viewController findResults];
     }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    if ([identifier isEqualToString:@"getResults"]) {
        NSString *error = [self checkMissingField];
        if ([error isEqualToString:@"PASS"]) {
            return YES;
        }
        else {
            [self showErrorAlert:error];
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (void) showErrorAlert:(NSString*)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"Remember to %@", error];
    RTAlertView *alertView = [[RTAlertView alloc] initWithTitle:@"oops"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it!"
                                              otherButtonTitles:nil];
    alertView.messageFont = [UIFont fontWithName:@"Walkway" size:20];
    alertView.titleFont = [UIFont fontWithName:@"Walkway" size:25];
    alertView.cancelButtonFont = [UIFont fontWithName:@"Walkway" size:25];
    [alertView show];
}

- (NSString*)checkMissingField
{
    if (self.originLocation.text.length == 0) {
        return @"enter your start location!";
    }
    else if (self.destinationLocation.text.length == 0){
        return @"enter your destination!";
    }
    else if ([self.selectedTravelModes count] == 0) {
        return @"select a transportation mode to compare!";
    }
    else {
        return @"PASS";
    }
}

- (IBAction)findResults:(id)sender {

}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelModesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.travelModesArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Walkway" size:25];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *travelMode = [self.travelModesArray objectAtIndex:indexPath.row];
    if ([self.selectedTravelModes indexOfObject: travelMode] == NSNotFound) {
        [self.selectedTravelModes addObject: travelMode];
    }
    else {
        [self.selectedTravelModes removeObject: travelMode];
    }
}

@end
