//
//  GoogleApi.h
//  Cashew
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GoogleApi : NSObject

+ (void)getGeocodeWithAddress: (NSString *) addressString forLocation: (NSString *) locationType withBlock: (successBlockWithResponse) successBlock;
+ (void)getAddressWithGeocode:(CLLocation *)currentLocation forLocation: (NSString *) locationType withBlock: (successBlockWithResponse) successBlock;
+ (void)getGoogleDirections: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode byMode: (NSString *) transportationMode
                   withBlock: (successBlockWithResponse) successBlock;
@end
