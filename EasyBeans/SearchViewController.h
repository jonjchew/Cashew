//
//  SearchViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^successBlockWithResponse)(NSDictionary *responseObject);

@interface SearchViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *originLocation;
@property (strong, nonatomic) IBOutlet UITextField *destinationLocation;
- (IBAction)findResults:(id)sender;

@property (strong, nonatomic) NSDictionary *originGeocode;
@property (strong, nonatomic) NSDictionary *destinationGeocode;
@property (strong, nonatomic) NSDictionary *originFormattedAddress;
@property (strong, nonatomic) NSDictionary *destinationFormattedAddress;
@property (strong, nonatomic) NSMutableArray *googleDirections;
@property (strong, nonatomic) NSMutableArray *uberModes;

@end
