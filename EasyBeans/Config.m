//
//  Config.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "Config.h"

@implementation Config {
    NSDictionary *_apiKeys;
}

static Config *sharedConfigDict = nil;

+(Config*)sharedConfig;
{
    if(sharedConfigDict == nil) {
        sharedConfigDict = [[super allocWithZone:NULL] init];
    }
    return sharedConfigDict;
}

- init
{
    self = [super init];
    if ( self ) {
        NSDictionary *configDictionary = [self loadSecret];
        _apiURLs = [self generateAPIUrls:configDictionary];
        _travelModes = [NSArray arrayWithArray:[configDictionary objectForKey:@"travelModes"]];
    }
    return self;
}

- (NSDictionary *)generateAPIUrls:(NSDictionary*)apiKeys
{
    NSDictionary *configDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/geocode/json?key=",
                        [apiKeys objectForKey:@"google"]], @"geocodeApiRootUrl",
        [NSString stringWithFormat:@"%@%@", @"https://maps.googleapis.com/maps/api/directions/json?key=",
                                   [apiKeys objectForKey:@"google"]], @"googleDirectionsApiRootUrl",
        [apiKeys objectForKey:@"uberServer"], @"uberServerToken",
        [apiKeys objectForKey:@"uberClientID"], @"uberClientID",
        @"https://api.uber.com/v1/estimates/price?", @"uberPriceApiRootUrl",
        @"https://api.uber.com/v1/estimates/time?", @"uberTimeApiRootUrl", nil];
    
    return configDictionary;
}

- (NSDictionary *) loadSecret {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return dict;
}

@end
