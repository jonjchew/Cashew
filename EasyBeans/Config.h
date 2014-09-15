//
//  Config.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+(Config*)sharedConfig;
- (NSDictionary *)APIKeys;

@end
