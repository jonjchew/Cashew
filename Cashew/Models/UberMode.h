//
//  UberMode.h
//  Cashew
//
//  Created by Jonathan Chew on 9/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UberMode : NSObject

@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *priceEstimate;
@property (strong, nonatomic) NSString *lowEstimate;
@property (strong, nonatomic) NSString *highEstimate;
@property (assign, nonatomic) NSInteger surgeMutliplier;
@property (assign, nonatomic) NSInteger timeEstimate;
@property (assign, nonatomic) NSInteger timeDurationSeconds;

+(instancetype)initWithJsonData:(NSDictionary *)data;

-(NSString *)formattedSurgeMultiplier;
-(NSString *)formattedTimeDuration;
-(NSString *)formattedPriceAndSurgeMultiplier;
@end
