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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _apiKeys = [self loadSecret];

    _geocodeApiRootUrl = [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/geocode/json?key=", [_apiKeys objectForKey:@"google"]];
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
        NSLog(@"%@", self.originGeocode);
        NSLog(@"%@", self.destinationGeocode);

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
