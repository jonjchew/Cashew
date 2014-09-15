//
//  Step.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Step : NSObject

+ (instancetype) initWithJsonData: (NSDictionary *) data;

@property (strong, nonatomic) NSString *distance;
@property (strong, nonatomic) NSString *timeDuration;
@property (strong, nonatomic) NSString *htmlDirections;
@property (strong, nonatomic) NSString *travelMode;

@end
