//
//  SearchViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"


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

    [[self retrieveOriginGeolocationTask] resume];
    [[self retrieveDestinationGeolocationTask] resume];
    [self retrieveOriginGeolocationTask]
    
}

- (NSURLSessionDownloadTask *)retrieveOriginGeolocationTask {

    NSURL *geocodeApiOriginQuery = [self buildGeocodeQueryWithAddress:self.originLocation.text];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:geocodeApiOriginQuery completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:location];
        
        NSDictionary *originGeolocationDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        NSLog( @"%@", originGeolocationDictionary);
        
    }];
    return task;
}

- (NSURLSessionDownloadTask *)retrieveDestinationGeolocationTask {

    NSURL *geocodeApiDestinationQuery = [self buildGeocodeQueryWithAddress:self.destinationLocation.text];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:geocodeApiDestinationQuery completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:location];
        
        NSDictionary *destinationGeolocationDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

        NSLog( @"%@", destinationGeolocationDictionary);
        
    }];
    return task;
}

-(NSString *)rawUrlEncodeCFString:(NSString *)rawdata {
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef) rawdata,
                                                                                                    NULL,
                                                                                                    CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                                                    kCFStringEncodingUTF8));
    
    return escapedString == nil? @"":escapedString;
}

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

- (NSURL *) buildGeocodeQueryWithAddress: (NSString *) address
{
    NSString *encodedAddress = [self rawUrlEncodeCFString:address];
    NSString *geocodeApiQueryString = [NSString stringWithFormat:@"%@%@%@", _geocodeApiRootUrl, @"&address=", encodedAddress];

    return [NSURL URLWithString:geocodeApiQueryString];
}
@end
