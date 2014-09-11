//
//  GoogleDirection.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "GoogleDirection.h"

@implementation GoogleDirection

//@synthesize summary = _summary;

+ (instancetype) initWithJsonData: (NSDictionary *) data andMode: (NSString *) mode
{
    return [[GoogleDirection alloc] initWithJSONData:data andMode: mode];
}

- (id) initWithJSONData: (NSDictionary *) data andMode: (NSString *) mode
{
    if (self = [super init]) {
        _mode = mode;
        _summary = [NSString stringWithFormat:@"via %@",[data objectForKey:@"summary"]];
        _distance = [[data valueForKeyPath:@"legs.distance.text"] componentsJoinedByString:@""];
        _timeDuration = [[data valueForKeyPath:@"legs.duration.text"] componentsJoinedByString:@""];
        if ([[data objectForKey:@"legs"][0] objectForKey:@"departure_time"] && [[data objectForKey:@"legs"][0] objectForKey:@"arrival_time"])
        {
            _departureTime = [[data valueForKeyPath:@"legs.departure_time.text"] componentsJoinedByString:@""];
            _arrivalTime = [[data valueForKeyPath:@"legs.arrival_time.text"] componentsJoinedByString:@""];
        }
    }
    return self;
}

@end
