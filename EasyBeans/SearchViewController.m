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
    CGFloat _screenHeight;
    UITableView *_originLocationDropdown;
    CLLocation *_currentLocation;
    CLLocationManager *_locationManager;
    BOOL _currentLocationAvailable;
    BOOL _currentLocationSelected;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentLocationAvailable = NO;
    
    self.originLocation.delegate = self;
    self.destinationLocation.delegate = self;
    
    _inputtedDestination = @"destination";
    _inputtedOrigin = @"origin";

    self.travelModesArray = [Config sharedConfig].travelModes;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedTravelModes = [NSMutableArray array];
    
    self.compareButton.layer.cornerRadius = 25;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _screenHeight = screenRect.size.height;
    
    self.originLocationTableView.alpha = 0;
    
    [self findGPSLocation];
}

#pragma mark - Origin location textfield

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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _originLocation && _currentLocationAvailable) {
        [self showOriginLocationTableView];
    }
    if (textField == _destinationLocation) {
        [self hideOriginLocationTableView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.originLocation && [self.originLocation.text isEqualToString:@"Current Location"] &&
        [string isEqualToString:@""]) {
        self.originLocation.text = @"";
        self.originLocation.textColor = [UIColor blackColor];
    }
    return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"ResultsViewController"]) {
        ResultsViewController *viewController = (ResultsViewController *) segue.destinationViewController;
        viewController.selectedTravelModes = self.selectedTravelModes;
        viewController.originLocationText = self.originLocation.text;
        viewController.destinationLocationText = self.destinationLocation.text;
         viewController.currenLocation = _currentLocation;
        [viewController findResults];
     }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"ResultsViewController"]) {
        NSString *error = [self checkMissingField];
        if ([error isEqualToString:@"none"]) {
            return YES;
        }
        else {
            [self showErrorAlert:error];
            return NO;
        }
    }
    else {
        return YES;
    }
}

- (void) showErrorAlert:(NSString*)errorMessage
{
    RTAlertView *alertView = [[RTAlertView alloc] initWithTitle:@"oops"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it!"
                                              otherButtonTitles:nil];
    alertView.messageFont = [UIFont fontWithName:@"Walkway" size:20];
    alertView.titleFont = [UIFont fontWithName:@"weezerfont" size:25];
    alertView.cancelButtonFont = [UIFont fontWithName:@"weezerfont" size:25];
    [alertView show];
}

- (NSString*)checkMissingField
{
    if (self.originLocation.text.length == 0) {
        return @"Remember to enter your start location!";
    }
    else if (_currentLocationSelected && _currentLocation == nil) {
        return @"We couldn't find your current location. Try entering an address instead.";
    }
    else if (self.destinationLocation.text.length == 0){
        return @"Remember to enter your destination!";
    }
    else if ([self.selectedTravelModes count] == 0) {
        return @"Remember to select a transportation mode to compare!";
    }
    else {
        return @"none";
    }
}

- (IBAction)findResults:(id)sender {

}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.travelModesArray.count;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [self.travelModesArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [self determineCellFont];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Current Location";
        cell.textLabel.font = [UIFont fontWithName:@"Walkway" size:15];
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        
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
    else {
        self.originLocation.text = @"Current Location";
        self.originLocation.textColor = [UIColor blueColor];
        _currentLocationSelected = YES;
        [_destinationLocation becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (_screenHeight > 700.0) {
            return 98.0;
        }
        else if (_screenHeight > 600.0) {
            return 90.0;
        }
        else if (_screenHeight > 500.0){
            return 68.0;
        }
        else {
            return 52.0;
        }
    }
    else {
        return 30;
    }
}

- (void)showOriginLocationTableView
{
    self.originLocationTableView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.originLocationTableView setAlpha:1.0];
    }
    completion:^(BOOL finished){
     self.originLocationTableView.hidden = NO;
    }];
}

- (void)hideOriginLocationTableView
{
    [UIView animateWithDuration:0.25 animations:^{
         [self.originLocationTableView setAlpha:0.0];
     }
     completion:^(BOOL finished){
         self.originLocationTableView.hidden = YES;
     }];
}

- (UIFont *)determineCellFont
{
    if (_screenHeight > 700.0) {
        return [UIFont fontWithName:@"weezerfont" size:42];
    }
    else if (_screenHeight > 600.0) {
        return [UIFont fontWithName:@"weezerfont" size:38];
    }
    else if (_screenHeight > 500.0){
        return [UIFont fontWithName:@"weezerfont" size:30];
    }
    else {
        return [UIFont fontWithName:@"weezerfont" size:24];
    }
}

#pragma mark - GPS

- (void)findGPSLocation
{
    if (!_locationManager) {
        if([CLLocationManager locationServicesEnabled] == NO){
            NSLog(@"GPS not enabled");
        }
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = 10;
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    if ( _currentLocation == nil || newLocation.horizontalAccuracy <= _currentLocation.horizontalAccuracy ) {
        _currentLocationAvailable = YES;
        NSLog(@"%@", newLocation);
        NSLog(@"%f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        _currentLocation = newLocation;
//        self.originLocation.textColor = [UIColor blueColor];
//        self.originLocation.placeholder = @"Current location";
//        self.originLocation.attributedPlaceholder = [[NSAttributedString alloc]
//                                                     initWithString:@"Current location"                                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    }
}

- (void)stopLocationManager
{
    [_locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    
    if ( [error code] != kCLErrorLocationUnknown ){
        [self stopLocationManager];
    }
}
@end
