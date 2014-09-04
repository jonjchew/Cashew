//
//  SearchViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface SearchViewController ()

@end

@implementation SearchViewController {
    NSDictionary *_apiKeys;
    NSString *_geocodeApiRootUrl;
    NSString *_googleDirectionsApiRootUrl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _apiKeys = [self loadSecret];

    _geocodeApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/geocode/json?key=", [_apiKeys objectForKey:@"google"]];
    _googleDirectionsApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/directions/json?key=", [_apiKeys objectForKey:@"google"]];
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
        
        
        NSString *geocodeVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Geocode"];
        [self setValue:geocode forKey:geocodeVariableName];

        // 2. Find directions once both origin and destination geocodes are done querying
        if (self.originGeocode != NULL && self.destinationGeocode != NULL) {

            NSLog(@"%@", self.originGeocode);
            NSLog(@"%@", self.destinationGeocode);
            [self getGoogleDrivingDirections: self.originGeocode toDestination: self.destinationGeocode byMode: @"driving"];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) getGoogleDrivingDirections: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode byMode: (NSString *) transportationMode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *originCoordinates = [NSString stringWithFormat:@"%@,%@", [originGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    NSString *destinationCoordinates = [NSString stringWithFormat:@"%@,%@", [destinationGeocode objectForKey:@"lat"],[originGeocode objectForKey:@"lng"]];
    
    NSString *departureTime = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + (3 * 60)];
    NSDictionary *parameters = @{@"origin": originCoordinates, @"destination":destinationCoordinates, @"departure_time":departureTime, @"mode": transportationMode};

    [manager GET:_googleDirectionsApiRootUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation);
        NSLog(@"%@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

@end
