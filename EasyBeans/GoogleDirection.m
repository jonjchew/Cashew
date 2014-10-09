//
//  GoogleDirection.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "GoogleDirection.h"
#import "Step.h"

@implementation GoogleDirection

+(instancetype)initWithJsonData: (NSDictionary *) data andMode: (NSString *) mode
{
    return [[GoogleDirection alloc] initWithJSONData:data andMode: mode];
}

-(id)initWithJSONData: (NSDictionary *) data andMode: (NSString *) mode
{
    if (self = [super init]) {
        _mode = mode;
        _distance = [[data valueForKeyPath:@"legs.distance.text"] componentsJoinedByString:@""];
        _timeDurationText = [[data valueForKeyPath:@"legs.duration.text"] componentsJoinedByString:@""];
        _timeDurationSeconds = [[[data valueForKeyPath:@"legs.duration.value"] componentsJoinedByString:@""] integerValue];
        if (![[data objectForKey:@"summary"] isEqualToString:@""]) {
            _summary = [NSString stringWithFormat:@"via %@",[data objectForKey:@"summary"]];
        }
        if ([[data objectForKey:@"legs"][0] objectForKey:@"departure_time"] && [[data objectForKey:@"legs"][0] objectForKey:@"arrival_time"]){
            _departureTime = [[data valueForKeyPath:@"legs.departure_time.text"] componentsJoinedByString:@""];
            _arrivalTime = [[data valueForKeyPath:@"legs.arrival_time.text"] componentsJoinedByString:@""];
        }
        if ([mode isEqualToString:@"transit"]) {
            _summary = [self formattedTransitSummary:[[data objectForKey:@"legs"][0] objectForKey:@"steps"]];
        }
        _steps = [NSArray arrayWithArray:[self seedSteps:[[data objectForKey:@"legs"][0] objectForKey:@"steps"]]];
    }
    return self;
}

-(NSArray *)seedSteps:(NSArray *)stepsResponseArray
{
    NSMutableArray *stepsArray = [NSMutableArray array];
    for (NSDictionary *step in stepsResponseArray) {
        Step *stepObject = [Step initWithJsonData:step];
        [stepsArray addObject:stepObject];
    }
    return stepsArray;
}

-(NSString *)formattedTransitSummary:(NSArray *)stepsResponseArray
{
    NSArray *vehicleTypesArray = [self getVehicleTypes:stepsResponseArray];

    NSMutableString *formattedSummary = [NSMutableString stringWithString:@""];
    [formattedSummary appendString:@"via "];
    [vehicleTypesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == [vehicleTypesArray count] - 1 && [vehicleTypesArray count] > 1) {
            [formattedSummary appendString:[NSString stringWithFormat:@"and %@", vehicleTypesArray[idx]]];
        }
        else if (idx == [vehicleTypesArray count] - 2) {
            [formattedSummary appendString:[NSString stringWithFormat:@"%@ ", vehicleTypesArray[idx]]];
        }
        else if ([vehicleTypesArray count] == 1) {
            [formattedSummary appendString:vehicleTypesArray[idx]];
        }
        else {
            [formattedSummary appendString:[NSString stringWithFormat:@"%@, ", vehicleTypesArray[idx]]];
        }
    }];
    return [NSString stringWithString:formattedSummary];
}

-(NSArray *)getVehicleTypes:(NSArray *)stepsResponseArray
{
    NSMutableArray *vehicleTypesArray = [NSMutableArray array];
    for (NSDictionary *step in stepsResponseArray) {
        if ([[step objectForKey:@"travel_mode"] isEqualToString:@"TRANSIT"]) {
            NSString *vehicleType = [step valueForKeyPath:@"transit_details.line.vehicle.name"];
            vehicleType = [vehicleType lowercaseString];
            if (![vehicleTypesArray containsObject:vehicleType]) {
                [vehicleTypesArray addObject:vehicleType];
            }
        }
    }
    return [NSArray arrayWithArray:vehicleTypesArray];
}

@end
