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
#import <AFNetworking/AFNetworking.h>

@interface ResultsViewController ()

@end

@implementation ResultsViewController {
    NSDictionary *_apiKeys;
    NSString *_geocodeApiRootUrl;
    NSString *_googleDirectionsApiRootUrl;
    NSString *_inputtedOrigin;
    NSString *_inputtedDestination;
    GoogleDirection *_drivingDirection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeAPIs];

    _inputtedDestination = @"destination";
    _inputtedOrigin = @"origin";

    self.travelModeResults = [NSMutableArray array];
    self.uberModes = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([_inputtedOrigin isEqualToString:self.originLocationText] && [_inputtedDestination isEqualToString:self.destinationLocationText]) {
        [self getTransportationEstimates:self.originGeocode toDestination:self.destinationGeocode];
    }
    
    if (![_inputtedOrigin isEqualToString:self.originLocationText]) {
        [self getGeocode: self.originLocationText forLocation:@"origin"];
    }
    if (![_inputtedDestination isEqualToString:self.destinationLocationText]) {
        [self getGeocode: self.destinationLocationText forLocation:@"destination"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Google API calls

- (void) getGeocode: (NSString *) addressString forLocation: (NSString *) locationType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"address": addressString};
    
    [manager GET:_geocodeApiRootUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *geocodeResult = [responseObject objectForKey:@"results"][0];
        NSDictionary *geocode = [[geocodeResult objectForKey:@"geometry"] objectForKey:@"location"];
        NSString *formattedAddress = [geocodeResult objectForKey:@"formatted_address"];
        
        NSString *geocodeVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Geocode"];
        NSString *addressVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"FormattedAddress"];
        [self setValue:geocode forKey:geocodeVariableName];
        [self setValue:formattedAddress forKey:addressVariableName];
        
        // 2. Find directions once both origin and destination geocodes are done querying
        if (self.originGeocode != NULL && self.destinationGeocode != NULL) {
            [self getTransportationEstimates: self.originGeocode toDestination: self.destinationGeocode];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void) getTransportationEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    // Get driving directions and estimates for uber / driving
    if ([self.selectedTravelModes containsObject:@"driving"] || [self.selectedTravelModes containsObject:@"uber"]) {
        [self getGoogleDirections:self.originGeocode toDestination:self.destinationGeocode byMode:@"driving"];
    }
    
    for (NSString *travelMode in self.selectedTravelModes){
        if ([travelMode isEqualToString:@"uber"]){
            [UberApi getUberPrices: originGeocode toDestination: destinationGeocode withBlock:^(NSDictionary *responseObject) {
                NSArray *modes = [responseObject objectForKey:@"prices"];
                
                for (id modeData in modes) {
                    UberMode *uberMode = [UberMode initWithJsonData: modeData];
                    [self.uberModes addObject:uberMode];
                }

            } withSecondBlock:^(NSDictionary *responseObject) {
                NSArray *modes = [responseObject objectForKey:@"times"];
                for (id modeData in modes) {
                    for (UberMode *uberMode in self.uberModes) {
                        if ([uberMode.productID isEqualToString:[modeData objectForKey:@"product_id"]]) {
                            uberMode.timeEstimate = [[modeData objectForKey:@"estimate"] integerValue];
                            [self.travelModeResults addObject:uberMode];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            break;
                        }
                    }
                }
            }];
        }
        else if (![travelMode isEqualToString:@"driving"]){ // Get estimates for everything else besides driving
            [self getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: travelMode];
        }
    }
}

- (void) getGoogleDirections: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode byMode: (NSString *) transportationMode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *originCoordinates = [NSString stringWithFormat:@"%@,%@",
                                   [originGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    NSString *destinationCoordinates = [NSString stringWithFormat:@"%@,%@",
                                        [destinationGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    
    // Add two minutes to current time as 'current' departure time
    NSString *departureTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + (2 * 60)];
    NSDictionary *parameters = @{@"origin": originCoordinates,
                                 @"destination": destinationCoordinates,
                                 @"departure_time": departureTime,
                                 @"mode": transportationMode};
    
    [manager GET:_googleDirectionsApiRootUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"status"]  isEqual: @"OK"]) {
            NSDictionary *data = [responseObject objectForKey:@"routes"][0];
            
            // Create new GoogleDirection instances and store in array
            GoogleDirection *direction = [GoogleDirection initWithJsonData: data andMode: transportationMode];
            
            if ([direction.mode isEqualToString:@"driving"]) {
                _drivingDirection = direction;
                if ([self.selectedTravelModes containsObject:@"driving"]) {
                    [self.travelModeResults addObject:direction];
                }
            }
            else {
                [self.travelModeResults addObject:direction];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            NSLog(@"%@ %@", direction.mode, direction.timeDuration);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelModeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *modeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *timeDurationLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *fourthLabel = (UILabel *)[cell viewWithTag:4];
    UIButton *selectModeButton = (UIButton *)[cell viewWithTag:5];
    [selectModeButton addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchUpInside];
    
    id travelMode = [self.travelModeResults objectAtIndex:indexPath.row];
    
    if ([travelMode isKindOfClass:[GoogleDirection class]]) {
        modeLabel.text = [(GoogleDirection*)travelMode mode];
        timeDurationLabel.text = [travelMode timeDuration];
        thirdLabel.text = [travelMode summary];
        fourthLabel.text = [travelMode distance];
    }
    else {
        modeLabel.text = [travelMode productName];
        timeDurationLabel.text = [NSString stringWithFormat:@"%i mins total", (_drivingDirection.timeDurationSeconds + [travelMode timeEstimate])/60];

        thirdLabel.text = [NSString stringWithFormat:@"%@, %@", [travelMode priceEstimate], [travelMode formattedSurgeMultiplier] ];
        fourthLabel.text = [NSString stringWithFormat:@"will take about %@ to get to you", [travelMode formattedTimeDuration] ];
    }
    
    return cell;
}

- (void)selectMode:(UIButton *)sender
{
        CGPoint center= sender.center;
        CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        NSLog(@"%i",indexPath.row);
}

# pragma mark - Helpers

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

- (void)initializeAPIs
{
    _apiKeys = [self loadSecret];
    _geocodeApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/geocode/json?key=",
                          [_apiKeys objectForKey:@"google"]];
    _googleDirectionsApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/directions/json?key=",
                                   [_apiKeys objectForKey:@"google"]];
}

@end
