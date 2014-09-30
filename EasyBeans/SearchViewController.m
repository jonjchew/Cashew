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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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


- (IBAction)findResults:(id)sender {
    [sender setSelected:YES];
}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelModesArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.travelModesArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Walkway" size:25];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

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


#pragma mark - Config

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

@end
