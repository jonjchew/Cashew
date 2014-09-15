//
//  Step.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "Step.h"

@implementation Step

+ (instancetype) initWithJsonData: (NSDictionary *) data
{
    return [[Step alloc] initWithJSONData:data];
}

- (id) initWithJSONData: (NSDictionary *) data
{
    if (self = [super init]) {
        _distance = [[data objectForKey:@"distance"] objectForKey:@"text"];
        _timeDuration = [[data objectForKey:@"duration"] objectForKey:@"text"];
        _htmlDirections = [data objectForKey:@"html_directions"];
        _travelMode = [data objectForKey:@"travel_mode"];
    }
    return self;
}

@end
