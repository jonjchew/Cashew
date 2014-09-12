//
//  GoogleDirection.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/4/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleDirection : NSObject

@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *timeDuration;
@property (assign, nonatomic) NSInteger timeDurationSeconds;
@property (strong, nonatomic) NSString *departureTime;
@property (strong, nonatomic) NSString *arrivalTime;
@property (strong, nonatomic) NSString *mode;
+ (id) initWithJsonData: (NSDictionary *) data andMode: (NSString *) mode;
//- (void) setSummary:(NSString *)summary;
@end
