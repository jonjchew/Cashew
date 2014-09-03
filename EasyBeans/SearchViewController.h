//
//  SearchViewController.h
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *originLocation;
@property (strong, nonatomic) IBOutlet UITextField *destinationLocation;
- (IBAction)findResults:(id)sender;

@property (strong, nonatomic) NSString *originAddress;
@property (strong, nonatomic) NSString *destinationAddress;

@end
