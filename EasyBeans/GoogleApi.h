//
//  GoogleApi.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

#import <Foundation/Foundation.h>

@interface GoogleApi : NSObject

+ (void) getGeocode: (NSString *) addressString forLocation: (NSString *) locationType withBlock: (successBlockWithResponse) successBlock;
+ (void) getGoogleDirections: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode byMode: (NSString *) transportationMode
                   withBlock: (successBlockWithResponse) successBlock;
@end
