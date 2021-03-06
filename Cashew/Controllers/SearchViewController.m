//
//  SearchViewController.m
//  Cashew
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"
#import "UberMode.h"
#import "GoogleDirection.h"
#import "Config.h"
#import "UIColor+Cashew.h"
#import <RTAlertView.h>
#import <AFNetworking/AFNetworking.h>
#import <Reachability/Reachability.h>

@interface SearchViewController () 

@end

@implementation SearchViewController {
    CGFloat _screenHeight;
    UITableView *_originLocationDropdown;
    CLLocation *_currentLocation;
    CLLocationManager *_locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.originLocation.delegate = self;
    self.destinationLocation.delegate = self;

    self.travelModesArray = [Config sharedConfig].travelModes;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectedTravelModes = [NSMutableArray array];
    
    self.compareButton.layer.cornerRadius = 25;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _screenHeight = screenRect.size.height;
    self.originLocationTableView.alpha = 0;
    
    [self.fromToImageView setImage:[UIImage imageNamed:@"FromTo"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if (textField == _originLocation && [self currentLocationAvailable]) {
        [self showOriginLocationTableView];
    }
    if (textField == _destinationLocation) {
        if ([[_originLocation.text lowercaseString] isEqualToString:@"current location"] && [self currentLocationAvailable]) {
            [self selectCurrentLocation];
        }
        [self hideOriginLocationTableView];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.originLocation && [self.originLocation.text isEqualToString:@"Current Location"]) {
        if ([string isEqualToString:@""]) {
            [self unselectCurrentLocation];
            return YES;
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.originLocation) {
        [self unselectCurrentLocation];
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
        NSString *error = [self checkErrors];
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

#pragma mark - Error handling

- (void) showErrorAlert:(NSString*)errorMessage
{
    RTAlertView *alertView = [[RTAlertView alloc] initWithTitle:@"oops"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"got it!"
                                              otherButtonTitles:nil];
    alertView.messageFont = [UIFont fontWithName:@"Walkway" size:20];
    alertView.titleFont = [UIFont fontWithName:@"weezerfont" size:28];
    alertView.cancelButtonFont = [UIFont fontWithName:@"Walkway" size:25];
    [alertView show];
}

- (NSString*)checkErrors
{
    if (self.originLocation.text.length == 0) {
        return @"Remember to enter your start location!";
    }
    else if ([self currenLocationSelected] && ![self currentLocationAvailable]) {
        return @"We couldn't find your current location. Try entering an address instead.";
    }
    else if (self.destinationLocation.text.length == 0){
        return @"Remember to enter your destination!";
    }
    else if ([self.selectedTravelModes count] == 0) {
        return @"Remember to select a transportation mode to compare!";
    }
    else if ([self connectivityNotAvailable]) {
        return @"Looks like we can't find a connection!";
    }
    else {
        return @"none";
    }
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
        
        UIImageView *travelModeIcon = [self getTravelModeIconImageView];
        
        travelModeIcon.image = [UIImage imageNamed:[self.travelModesArray objectAtIndex:indexPath.row]];
        [cell.contentView addSubview:travelModeIcon];
        [travelModeIcon setAlpha:0];
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell" forIndexPath:indexPath];
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(7.0, 0.0, 220.0, 25.0)];
        [cell.contentView addSubview:locationLabel];
        locationLabel.text = @"Current Location";
        locationLabel.font = [UIFont fontWithName:@"Walkway" size:15];
        locationLabel.textColor = [UIColor blueColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];

        UIImageView *travelModeIcon;
        for (id subview in cell.contentView.subviews) {
            if ([subview isKindOfClass: [UIImageView class]]) {
                travelModeIcon = subview;
            }
        }
        
        if (travelModeIcon.alpha == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                [travelModeIcon setAlpha:1.0];
            } completion:nil];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [travelModeIcon setAlpha:0.0];
            } completion:nil];
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
        [self selectCurrentLocation];
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
            return 88.0;
        }
        else if (_screenHeight > 500.0) {
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

- (UIImageView *)getTravelModeIconImageView
{
    if (_screenHeight > 700.0) {
        return [[UIImageView alloc] initWithFrame:CGRectMake(288, 12, 74, 74)];
    }
    else if (_screenHeight > 600.0) {
        return [[UIImageView alloc] initWithFrame:CGRectMake(269, 14, 60, 60)];
    }
    else if (_screenHeight > 500.0) {
        if (self.tableView.frame.size.width > 300.0) {
            return [[UIImageView alloc] initWithFrame:CGRectMake(245, 9, 50, 50)];
        }
        else {
            return [[UIImageView alloc] initWithFrame:CGRectMake(230, 10, 48, 48)];
        }
    }
    else {
        return [[UIImageView alloc] initWithFrame:CGRectMake(242, 6, 40, 40)];
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
        return [UIFont fontWithName:@"weezerfont" size:54];
    }
    else if (_screenHeight > 600.0) {
        return [UIFont fontWithName:@"weezerfont" size:48];
    }
    else if (_screenHeight > 500.0){
        return [UIFont fontWithName:@"weezerfont" size:40];
    }
    else {
        return [UIFont fontWithName:@"weezerfont" size:26];
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
        _currentLocation = newLocation;
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

- (BOOL)currentLocationAvailable
{
    return _currentLocation != nil;
}

- (BOOL)currenLocationSelected
{
    return [self.originLocation.text isEqualToString:@"Current Location"];
}

- (void)selectCurrentLocation
{
    _originLocation.textColor = [UIColor blueColor];
    _originLocation.text = @"Current Location";
    
    UIImage *toImage = [UIImage imageNamed:@"FromToCurrentLocation"];
    [UIView transitionWithView:self.fromToImageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.fromToImageView.image = toImage;
                    } completion:nil];
}

- (void)unselectCurrentLocation
{
    self.originLocation.text = @"";
    self.originLocation.textColor = [UIColor blackColor];
    [self.fromToImageView setImage:[UIImage imageNamed:@"FromTo"]];
    
    UIImage *toImage = [UIImage imageNamed:@"FromTo"];
    [UIView transitionWithView:self.fromToImageView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.fromToImageView.image = toImage;
                    } completion:nil];
}

#pragma mark - connectivity

- (BOOL)connectivityNotAvailable
{
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"google.com"];
    NetworkStatus status = [myNetwork currentReachabilityStatus];

    if (status == NotReachable) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
