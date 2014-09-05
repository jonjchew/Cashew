//
//  SearchViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "UberMode.h"
#import "GoogleDirection.h"

@interface SearchViewController ()

@end

@implementation SearchViewController {
    NSDictionary *_apiKeys;
    NSString *_geocodeApiRootUrl;
    NSString *_googleDirectionsApiRootUrl;
    NSString *_uberPriceApiRootUrl;
    NSString *_uberTimeApiRootUrl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _apiKeys = [self loadSecret];

    _geocodeApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/geocode/json?key=", [_apiKeys objectForKey:@"google"]];
    _googleDirectionsApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/directions/json?key=", [_apiKeys objectForKey:@"google"]];
    _uberPriceApiRootUrl = @"https://api.uber.com/v1/estimates/price?";
    _uberTimeApiRootUrl = @"https://api.uber.com/v1/estimates/time?";
    self.googleDirections = [NSMutableArray array];
    self.uberModes = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)findResults:(id)sender {
    
    // 1. Find geocoordinates based on origin and destination addresses
    [self getGeocode: self.originLocation.text forLocation:@"origin"];
    [self getGeocode: self.destinationLocation.text forLocation:@"destination"];
    
}

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

//            NSLog(@"%@", self.originGeocode);
//            NSLog(@"%@", self.destinationGeocode);
//            NSLog(@"%@", self.originFormattedAddress);
//            NSLog(@"%@", self.destinationFormattedAddress);
            
            [self getTransportationEstimates: self.originGeocode toDestination: self.destinationGeocode];

        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) getTransportationEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    [self getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: @"walking"];
    [self getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: @"bicycling"];
    [self getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: @"transit"];
    [self getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: @"driving"];
    [self getUberPrices: originGeocode toDestination: destinationGeocode];
}

- (void) getGoogleDirections: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode byMode: (NSString *) transportationMode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *originCoordinates = [NSString stringWithFormat:@"%@,%@", [originGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    NSString *destinationCoordinates = [NSString stringWithFormat:@"%@,%@", [destinationGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    
    // Add two minutes to current time as 'current' departure time
    NSString *departureTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + (2 * 60)];
    NSDictionary *parameters = @{@"origin": originCoordinates, @"destination": destinationCoordinates, @"departure_time": departureTime, @"mode": transportationMode};

    [manager GET:_googleDirectionsApiRootUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([[responseObject objectForKey:@"status"]  isEqual: @"OK"]) {
            NSDictionary *data = [responseObject objectForKey:@"routes"][0];
            
            // Create new GoogleDirection instances and store in array
            GoogleDirection *direction = [GoogleDirection initWithJsonData: data andMode: transportationMode];
            [self.googleDirections addObject: direction];
            //        NSLog(@"%@", self.googleDirections);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) getUberPrices: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    [self getUberEstimates:originGeocode toDestination:destinationGeocode withUrl:_uberPriceApiRootUrl withBlock:^(NSDictionary *responseObject) {
        NSArray *modes = [responseObject objectForKey:@"prices"];

        for (id modeData in modes) {
            UberMode *uberMode = [UberMode initWithJsonData: modeData];
            [self.uberModes addObject:uberMode];
        }
        [self getUberTimes:originGeocode toDestination:destinationGeocode];
    }];
}

- (void) getUberTimes: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    [self getUberEstimates:originGeocode toDestination:destinationGeocode withUrl:_uberTimeApiRootUrl withBlock:^(NSDictionary *responseObject) {
        NSArray *modes = [responseObject objectForKey:@"times"];
        for (id modeData in modes) {
            for (UberMode *uberMode in self.uberModes) {
                if ([uberMode.productID isEqualToString:[modeData objectForKey:@"product_id"]]) {
                    uberMode.timeEstimate = [modeData objectForKey:@"estimate"];
                    NSLog(@"%@ %@ %@", uberMode.productName, uberMode.timeEstimate, uberMode.priceEstimate);
                }
            }
        }
    }];
}

- (void) getUberEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode withUrl: (NSString *) apiUrl withBlock:(successBlockWithResponse) successBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Token %@", [_apiKeys objectForKey:@"uberServer"]] forHTTPHeaderField:@"Authorization"];
    
    NSString *originLatitude = [originGeocode objectForKey:@"lat"];
    NSString *originLongitude = [originGeocode objectForKey:@"lng"];
    NSString *destinationLatitude = [destinationGeocode objectForKey:@"lat"];
    NSString *destinationLongitude = [destinationGeocode objectForKey:@"lng"];
    
    NSDictionary *parameters = @{@"start_latitude": originLatitude, @"start_longitude": originLongitude, @"end_latitude": destinationLatitude, @"end_longitude": destinationLongitude};
    
    [manager GET:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([operation.response statusCode] == 200) {
            if (successBlock) {
                successBlock(responseObject);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) getUberEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode withUrl: (NSString *) apiUrl
{
    [self getUberEstimates:originGeocode toDestination:destinationGeocode withUrl:apiUrl withBlock:nil];
}

#pragma mark - Config

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

@end
