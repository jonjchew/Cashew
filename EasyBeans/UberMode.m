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
        _surgeMutliplier = [self formatSurgeMultiplier:[[data objectForKey:@"surge_multiplier"] integerValue]];
    }
    return self;
}

- (void) setTimeEstimateFromSeconds:(int)timeEstimateSeconds
{
    _timeEstimate = [NSString stringWithFormat:@"%d mins", timeEstimateSeconds/60];

}

- (NSString *) formatSurgeMultiplier:(int)surgeMulitplierInt
{
    NSString *surgeMultiplierString;

    if ([_productName isEqualToString:@"uberTAXI"]) {
        surgeMultiplierString = @"";
    }
    else if (surgeMulitplierInt == 0) {
        surgeMultiplierString = @"(No surge multiplier)";
    }
    else {
        surgeMultiplierString = [NSString stringWithFormat:@"(%.1fx surge multiplier)", (double)surgeMulitplierInt];
    }
    return surgeMultiplierString;
}
@end
