//
//  ResultsViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/8/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "ResultsViewController.h"
#import "UberMode.h"
#import "GoogleDirection.h"
#import "UberApi.h"
#import "GoogleApi.h"
#import "StepsViewController.h"
#import "Config.h"
#import <RTAlertView.h>
#import <AFNetworking/AFNetworking.h>
#import <CSAnimationView.h>

@interface ResultsViewController ()

@end

@implementation ResultsViewController {
    NSString *_inputtedOrigin;
    NSString *_inputtedDestination;
    NSString *_originAddressURI;
    NSString *_destinationAddressURI;
    NSDictionary *_originGeocode;
    NSDictionary *_destinationGeocode;
    NSMutableArray *_uberModes;
    NSMutableArray *_travelModeResults;
    NSMutableArray *_errors;
    NSMutableArray *_successes;
    NSMutableArray *_resultsToFind;
    GoogleDirection *_drivingDirection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _inputtedDestination = @"destination";
    _inputtedOrigin = @"origin";

    _travelModeResults = [NSMutableArray array];
    _successes = [NSMutableArray array];
    _errors = [NSMutableArray array];
    _uberModes = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Executing queries

- (void)findResults
{
    [self showActivityIndicator];
    _resultsToFind = [NSMutableArray arrayWithArray:self.selectedTravelModes];
    self.tableView.hidden = YES;
    if ([_inputtedOrigin isEqualToString:self.originLocationText] && [_inputtedDestination isEqualToString:self.destinationLocationText]) {
        [self getTransportationEstimates:_originGeocode toDestination:_destinationGeocode];
    }
    
    if (![_inputtedOrigin isEqualToString:self.originLocationText]) {
        _inputtedOrigin = self.originLocationText;
        [GoogleApi getGeocode: self.originLocationText forLocation:@"origin" withBlock:^(NSDictionary *responseObject) {
            [self storeLocations:responseObject forLocation:@"origin"];
        }];
    }
    if (![_inputtedDestination isEqualToString:self.destinationLocationText]) {
        _inputtedDestination = self.destinationLocationText;
        [GoogleApi getGeocode: self.destinationLocationText forLocation:@"destination" withBlock:^(NSDictionary *responseObject) {
            [self storeLocations:responseObject forLocation:@"destination"];
        }];    }
}

- (void)getTransportationEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    // Get driving directions and estimates for Uber / driving
    if ([self.selectedTravelModes containsObject:@"driving"] || [self.selectedTravelModes containsObject:@"uber"]) {
        if (![self.selectedTravelModes containsObject:@"driving"]) {
            [_resultsToFind addObject:@"driving"];
        }
        [GoogleApi getGoogleDirections:_originGeocode toDestination:_destinationGeocode byMode:@"driving"
                             withBlock:^(NSDictionary *responseObject) {
             [self storeAndUpdateDirections:responseObject forMode:@"driving"];
         }];
    }
    
    for (NSString *travelMode in self.selectedTravelModes){
        if ([travelMode isEqualToString:@"uber"]){
            [self getUberEstimates:destinationGeocode originGeocode:originGeocode];
        }
        else if (![travelMode isEqualToString:@"driving"]){ // Get estimates for everything else besides driving
            [GoogleApi getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: travelMode withBlock:^(NSDictionary *responseObject) {
                [self storeAndUpdateDirections:responseObject forMode:travelMode];
            }];
        }
    }
}

#pragma mark - Google API response handling

- (void)storeAndUpdateDirections:(NSDictionary *)responseObject forMode: (NSString *)travelMode
{
    if ([[responseObject objectForKey:@"status"]  isEqual: @"OK"]) {
        [_successes addObject:travelMode];
        NSDictionary *data = [responseObject objectForKey:@"routes"][0];
        
        GoogleDirection *direction = [GoogleDirection initWithJsonData: data andMode: travelMode];
        
        if ([direction.mode isEqualToString:@"driving"]) {
            _drivingDirection = direction;
            if ([self.selectedTravelModes containsObject:@"driving"]) {
                [_travelModeResults addObject:direction];
            }
        }
        else {
            [_travelModeResults addObject:direction];
        }
    }
    else {
        [_errors addObject:travelMode];
    }
    [self reorderAndReloadTableView];
}

- (void)storeLocations:(NSDictionary *)responseObject forLocation:(NSString *)locationType
{
    NSDictionary *geocodeResult = [responseObject objectForKey:@"results"][0];
    NSDictionary *geocode = [[geocodeResult objectForKey:@"geometry"] objectForKey:@"location"];
    NSString *formattedAddress = [geocodeResult objectForKey:@"formatted_address"];
    
    NSString *geocodeVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Geocode"];
    NSString *labelVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Label"];
    NSString *URIVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"AddressURI"];
    
    [self setValue:geocode forKey:geocodeVariableName];
    [self setValue:[formattedAddress stringByAddingPercentEncodingWithAllowedCharacters:
                    [NSCharacterSet URLHostAllowedCharacterSet]] forKey:URIVariableName];
    UILabel *formattedLabel = [self valueForKey:labelVariableName];
    formattedLabel.text = formattedAddress;
    if (_originGeocode != NULL && _destinationGeocode != NULL) {
        [self getTransportationEstimates: _originGeocode toDestination: _destinationGeocode];
    }

}

#pragma mark - Uber API response handling

- (void)getUberEstimates:(NSDictionary *)destinationGeocode originGeocode:(NSDictionary *)originGeocode
{
    [UberApi getUberPrices: originGeocode toDestination: destinationGeocode withBlock:^(NSDictionary *responseObject) {
        if (responseObject == NULL) {
            [_errors addObject:@"uber"];
        } else {
            [_successes addObject:@"uber"];
            NSArray *modes = [responseObject objectForKey:@"prices"];
            
            for (id modeData in modes) {
                UberMode *uberMode = [UberMode initWithJsonData: modeData];
                [_uberModes addObject:uberMode];
            }
        }
    } withSecondBlock:^(NSDictionary *responseObject) {
        NSArray *modes = [responseObject objectForKey:@"times"];
        for (id modeData in modes) {
            for (UberMode *uberMode in _uberModes) {
                if ([uberMode.productID isEqualToString:[modeData objectForKey:@"product_id"]]) {
                        uberMode.timeEstimate = [[modeData objectForKey:@"estimate"] integerValue];
                        uberMode.timeDurationSeconds = uberMode.timeEstimate + _drivingDirection.timeDurationSeconds;
                        [_travelModeResults addObject:uberMode];
                        dispatch_async(dispatch_get_main_queue(), ^{
                    });
                    break;
                }
            }
        }
        [self reorderAndReloadTableView];
    }];
}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _travelModeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *modeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *timeDurationLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *fourthLabel = (UILabel *)[cell viewWithTag:4];
    
    id travelMode = [_travelModeResults objectAtIndex:indexPath.row];
    
    if ([travelMode isKindOfClass:[GoogleDirection class]]) {
        modeLabel.text = [(GoogleDirection*)travelMode mode];
        timeDurationLabel.text = [NSString stringWithFormat:@"%@ total", [travelMode timeDurationText] ];
        thirdLabel.text = [travelMode summary];
        if ([travelMode summary] != NULL) {
            thirdLabel.text = [travelMode summary];
        }
        else {
            thirdLabel.text = [NSString stringWithFormat:@"Departure time: %@", [travelMode departureTime]];
        }
        fourthLabel.text = [travelMode distance];
    }
    else {
        modeLabel.text = [travelMode productName];
        timeDurationLabel.text = [NSString stringWithFormat:@"%i mins total", (int)[travelMode timeDurationSeconds]/60];
        thirdLabel.text = [travelMode formattedPriceAndSurgeMultiplier];
        fourthLabel.text = [NSString stringWithFormat:@"~%@ to get to you", [travelMode formattedTimeDuration] ];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reorderAndReloadTableView
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeDurationSeconds" ascending:YES];
    NSArray *sortedTravelModeResults = [_travelModeResults sortedArrayUsingDescriptors:@[sortDescriptor]];
    _travelModeResults = [[NSMutableArray alloc] initWithArray: sortedTravelModeResults];
    if ([self queriesComplete]) {
        [self.tableView reloadData];
        [self hideActivityIndicator];
        if ([_errors count] > 0) {
            [self showErrorAlert:[self buildErrorMessages] withOtherTitle:nil];
        }
    }
    
}

- (BOOL)queriesComplete
{
    return [_resultsToFind count] == ([_errors count] + [_successes count]);
}

#pragma mark- Load external apps

- (void)loadGoogleMapsWithDirections:(GoogleDirection *)selectedDirection withOrigin:(NSString *)originAddressURI withDestination:(NSString *)destinationAddressURI
{
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps://"]]) {
        
        NSString *googleMapURLString =
        [NSString stringWithFormat:@"comgooglemaps-x-callback://?saddr=%@&daddr=%@&directionsmode=%@&x-success=sourceapp://?resume=true&x-source=Cashew",
                                        originAddressURI, destinationAddressURI, [(GoogleDirection*)selectedDirection mode]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapURLString]];
    } else {
        [self showErrorAlert:@"Looks like you don't have GoogleMaps installed... =(" withOtherTitle:@"Open mobile site"];
    }
}

- (void)loadUberWithPreferences:(UberMode *)selectedMode withOrigin:(NSString *)originAddressURI withDestination:(NSString *)destinationAddressURI
{
    NSString *uberAppURLString = [NSString stringWithFormat:@"uber://?action=setPickup?pickup[formatted_address]=%@&dropoff[formatted_address]=%@&product_id=%@",
                               originAddressURI, destinationAddressURI, selectedMode.productID];
    NSLog(@"%@", uberAppURLString);
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
//        NSString *uberURLString = [NSString stringWithFormat:@"uber://?action=setPickup?pickup[formatted_address]=%@&dropoff[formatted_address]=%@&product_id=%@",
//                                   originAddressURI, destinationAddressURI, selectedMode.productID];
//        NSLog(uberURLString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uberAppURLString]];
    }
    else {
        [self showErrorAlert:@"Looks like you don't have Uber installed... =(" withOtherTitle:@"Download Uber"];
    }
}


- (IBAction)loadApp:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    id selectedDirection = [_travelModeResults objectAtIndex:indexPath.row];
   
    
    if ([selectedDirection isKindOfClass:[GoogleDirection class]]) {
        [self loadGoogleMapsWithDirections:selectedDirection withOrigin:_originAddressURI withDestination:_destinationAddressURI];
    }
    else {
        [self loadUberWithPreferences:selectedDirection withOrigin:_originAddressURI withDestination:_destinationAddressURI];
    }
}


#pragma mark - Activity indicator

- (void)showActivityIndicator
{
    [self.activityIndicator startAnimating];
    self.progressView.alpha = 1.0;
}

- (void)hideActivityIndicator
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self.progressView setAlpha:0.0];
                     }
                     completion:^(BOOL finished){
                         [self.activityIndicator stopAnimating];
                     }];
    
}

#pragma mark - Error handling

- (NSString *)buildErrorMessages
{
    NSMutableString *errorMessage = [NSMutableString string];
    NSMutableString *uberErrorMessage = [NSMutableString stringWithString:@""];

    if ([_errors containsObject:@"uber"]) {
        [_errors removeObject:@"uber"];
        if (![self.selectedTravelModes containsObject:@"driving"] && [_errors containsObject:@"driving"]) {
            [_errors removeObject:@"driving"];
        }
        [uberErrorMessage appendString:@"No Uber results were found"];
        if ([_errors count] > 0) {
            [uberErrorMessage appendString:@", either"];
            uberErrorMessage = [NSMutableString stringWithFormat:@" %@", uberErrorMessage];
        }
        [uberErrorMessage appendString:@"."];
    }

    if ([_errors count] > 0) {
        [errorMessage appendString:@"No "];
        [_errors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![_errors[idx] isEqualToString:@"uber"]) {
                if (idx == [_errors count] - 1 && [_errors count] > 1) {
                    [errorMessage appendString:[NSString stringWithFormat:@"and %@", _errors[idx]]];
                }
                else if (idx == [_errors count] - 2) {
                    [errorMessage appendString:[NSString stringWithFormat:@"%@ ", _errors[idx]]];
                }
                else if ([_errors count] == 1) {
                    [errorMessage appendString:_errors[idx]];
                }
                else {
                    [errorMessage appendString:[NSString stringWithFormat:@"%@, ", _errors[idx]]];
                }
            }
        }];
        [errorMessage appendString:[NSString stringWithFormat:@" directions were found."]];
    }

    [errorMessage appendString:uberErrorMessage];
    return errorMessage;
}

- (void)showErrorAlert:(NSString *)errorMessage withOtherTitle:(NSString *)otherTitle
{
    RTAlertView *alertView = [[RTAlertView alloc] initWithTitle:@"sorry.."
                                                        message:errorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"aw man.."
                                              otherButtonTitles:otherTitle, nil];
    alertView.messageFont = [UIFont fontWithName:@"Walkway" size:20];
    alertView.titleFont = [UIFont fontWithName:@"weezerfont" size:30];
    if ([otherTitle length] == 0) {
        alertView.cancelButtonFont = [UIFont fontWithName:@"weezerfont" size:25];
    }
    else {
       alertView.cancelButtonFont = [UIFont fontWithName:@"weezerfont" size:15];
    }
    alertView.otherButtonFont = [UIFont fontWithName:@"weezerfont" size:15];
    [alertView show];
}

- (void)alertView:(RTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]){
        if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Open mobile site"]) {
            NSString *googleMapURL = [NSString stringWithFormat:@"https://maps.google.com?saddr=%@&daddr=%@",
                                      _originAddressURI, _destinationAddressURI];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapURL]];
            
        } else{
            NSString *uberUrl = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=%@&pickup_address=%@&dropoff_address=%@",
                                 [[Config sharedConfig].apiURLs objectForKey:@"uberClientID"], _originAddressURI, _destinationAddressURI ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uberUrl]];
        }
    }
}

@end
