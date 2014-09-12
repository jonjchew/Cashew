//
//  UberMode.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "UberMode.h"

@implementation UberMode

+ (instancetype) initWithJsonData: (NSDictionary *) data
{
    return [[UberMode alloc] initWithJSONData:data];
}

- (id) initWithJSONData: (NSDictionary *) data
{
    if (self = [super init]) {
        _productID = [data objectForKey:@"product_id"];
        _productName = [data objectForKey:@"display_name"];
        _priceEstimate = [data objectForKey:@"estimate"];
        _lowEstimate = [data objectForKey:@"low_estimate"];
        _highEstimate = [data objectForKey:@"high_estimate"];
        self.surgeMutliplier = (int)[data objectForKey:@"high_estimate"];
    }
    return self;
}

- (void) setTimeEstimateFromSeconds:(int)timeEstimateSeconds
{
    _timeEstimate = [NSString stringWithFormat:@"%d mins", timeEstimateSeconds/60];

}

- (NSString *) formattedSurgeMultiplier
{
    NSString *surgeMultiplierString;

    if ([_productName isEqualToString:@"uberTAXI"]) {
        surgeMultiplierString = @"";
    }
    else if (self.surgeMutliplier <= 1) {
        surgeMultiplierString = @"(No surge multiplier)";
    }
    else {
        surgeMultiplierString = [NSString stringWithFormat:@"(%.1fx surge multiplier)", (double)self.surgeMutliplier];
    }
    return surgeMultiplierString;
}
@end
