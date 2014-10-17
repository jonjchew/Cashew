//
//  UberApi.m
//  Cashew
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "UberApi.h"
#import <AFNetworking/AFNetworking.h>
#import "Config.h"

@implementation UberApi

+ (void)getUberPrices:(NSDictionary *)originGeocode toDestination:(NSDictionary *)destinationGeocode withBlock: (successBlockWithResponse)successBlock
       withSecondBlock: (successBlockWithResponse) secondSuccessBlock
{
    NSString *uberPriceApiRootUrl = [[Config sharedConfig].apiURLs objectForKey:@"uberPriceApiRootUrl"];
    [self getUberEstimates:originGeocode toDestination:destinationGeocode withUrl:uberPriceApiRootUrl withBlock:^(NSDictionary *responseObject) {
        [self getUberTimes:originGeocode toDestination:destinationGeocode withBlock:secondSuccessBlock];
        successBlock(responseObject);
    }];
}

+ (void)getUberTimes:(NSDictionary *)originGeocode toDestination:(NSDictionary *)destinationGeocode withBlock: (successBlockWithResponse)successBlock
{
    NSString *uberTimeApiRootUrl = [[Config sharedConfig].apiURLs objectForKey:@"uberTimeApiRootUrl"];
    [UberApi getUberEstimates:originGeocode toDestination:destinationGeocode withUrl:uberTimeApiRootUrl withBlock:^(NSDictionary *responseObject) {
        successBlock(responseObject);
    }];
}

+ (void)getUberEstimates:(NSDictionary *)originGeocode toDestination:(NSDictionary *)destinationGeocode withUrl:(NSString *) apiUrl withBlock:(successBlockWithResponse)successBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *uberServerToken = [[Config sharedConfig].apiURLs objectForKey:@"uberServerToken"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Token %@",
                                         uberServerToken] forHTTPHeaderField:@"Authorization"];

    NSString *originLatitude = [originGeocode objectForKey:@"lat"];
    NSString *originLongitude = [originGeocode objectForKey:@"lng"];
    NSString *destinationLatitude = [destinationGeocode objectForKey:@"lat"];
    NSString *destinationLongitude = [destinationGeocode objectForKey:@"lng"];
    
    NSDictionary *parameters = @{@"start_latitude": originLatitude,
                                 @"start_longitude": originLongitude,
                                 @"end_latitude": destinationLatitude,
                                 @"end_longitude": destinationLongitude
                                 };
    
    [manager GET:apiUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    if (successBlock) {
        successBlock(responseObject);
    }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if(successBlock) {
            successBlock(NULL);
        }
    }];
}

@end
