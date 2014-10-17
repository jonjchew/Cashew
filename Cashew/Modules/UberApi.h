//
//  UberApi.h
//  Cashew
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

@interface UberApi : NSObject

+ (void)getUberPrices:(NSDictionary *)originGeocode toDestination:(NSDictionary *)destinationGeocode withBlock: (successBlockWithResponse)successBlock
       withSecondBlock:(successBlockWithResponse)secondSuccessBlock;
@end
