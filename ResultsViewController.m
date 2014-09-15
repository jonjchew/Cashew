//
//  ResultsViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/8/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "ResultsViewController.h"
#import "UberMode.h"
#import "GoogleDirection.h"
#import "UberApi.h"
#import "GoogleApi.h"
#import "StepsViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ResultsViewController ()

@end

@implementation ResultsViewController {
    NSString *_inputtedOrigin;
    NSString *_inputtedDestination;
    GoogleDirection *_drivingDirection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _inputtedDestination = @"destination";
    _inputtedOrigin = @"origin";

    self.travelModeResults = [NSMutableArray array];
    self.uberModes = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([_inputtedOrigin isEqualToString:self.originLocationText] && [_inputtedDestination isEqualToString:self.destinationLocationText]) {
        [self getTransportationEstimates:self.originGeocode toDestination:self.destinationGeocode];
    }
    
    if (![_inputtedOrigin isEqualToString:self.originLocationText]) {
        _inputtedOrigin = self.originLocationText;
        [GoogleApi getGeocode: self.originLocationText forLocation:@"origin" withBlock:^(NSDictionary *responseObject) {
            [self assignGeocode:responseObject forLocation:@"origin"];
        }];
    }
    if (![_inputtedDestination isEqualToString:self.destinationLocationText]) {
        _inputtedDestination = self.destinationLocationText;
        [GoogleApi getGeocode: self.destinationLocationText forLocation:@"destination" withBlock:^(NSDictionary *responseObject) {
            [self assignGeocode:responseObject forLocation:@"destination"];
        }];    }
}

- (void) getTransportationEstimates: (NSDictionary *) originGeocode toDestination: (NSDictionary *) destinationGeocode
{
    // Get driving directions and estimates for Uber / driving
    if ([self.selectedTravelModes containsObject:@"driving"] || [self.selectedTravelModes containsObject:@"uber"]) {
        [GoogleApi getGoogleDirections:self.originGeocode toDestination:self.destinationGeocode byMode:@"driving"
                             withBlock:^(NSDictionary *responseObject) {
             [self storeAndUpdateDirections:responseObject forMode:@"driving"];
         }];
    }
    
    for (NSString *travelMode in self.selectedTravelModes){
        if ([travelMode isEqualToString:@"uber"]){
            [self getUberEstimates:destinationGeocode originGeocode:originGeocode];
        }
        else if (![travelMode isEqualToString:@"driving"]){ // Get estimates for everything else besides driving
            [GoogleApi getGoogleDirections: originGeocode toDestination: destinationGeocode byMode: travelMode withBlock:^(NSDictionary *responseObject) {
                [self storeAndUpdateDirections:responseObject forMode:travelMode];
            }];
        }
    }
}

#pragma mark - Google API response handling

- (void)storeAndUpdateDirections:(NSDictionary *)responseObject forMode: (NSString *)travelMode
{
    if ([[responseObject objectForKey:@"status"]  isEqual: @"OK"]) {
        NSDictionary *data = [responseObject objectForKey:@"routes"][0];
        
        GoogleDirection *direction = [GoogleDirection initWithJsonData: data andMode: travelMode];
        
        if ([direction.mode isEqualToString:@"driving"]) {
            _drivingDirection = direction;
            if ([self.selectedTravelModes containsObject:@"driving"]) {
                [self.travelModeResults addObject:direction];
            }
        }
        else {
            [self.travelModeResults addObject:direction];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void) assignGeocode:(NSDictionary *)responseObject forLocation:(NSString *)locationType
{
    NSDictionary *geocodeResult = [responseObject objectForKey:@"results"][0];
    NSDictionary *geocode = [[geocodeResult objectForKey:@"geometry"] objectForKey:@"location"];
    NSString *formattedAddress = [geocodeResult objectForKey:@"formatted_address"];
    
    NSString *geocodeVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Geocode"];
    NSString *addressVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"FormattedAddress"];
    NSString *labelVariableName = [NSString stringWithFormat:@"%@%@",locationType,@"Label"];
    [self setValue:geocode forKey:geocodeVariableName];
    [self setValue:formattedAddress forKey:addressVariableName];
    UILabel *formattedLabel = [self valueForKey:labelVariableName];
    formattedLabel.text = formattedAddress;
    if (self.originGeocode != NULL && self.destinationGeocode != NULL) {
        [self getTransportationEstimates: self.originGeocode toDestination: self.destinationGeocode];
    }

}

#pragma mark - Uber API response handling

- (void)getUberEstimates:(NSDictionary *)destinationGeocode originGeocode:(NSDictionary *)originGeocode
{
    [UberApi getUberPrices: originGeocode toDestination: destinationGeocode withBlock:^(NSDictionary *responseObject) {
        NSArray *modes = [responseObject objectForKey:@"prices"];
        
        for (id modeData in modes) {
            UberMode *uberMode = [UberMode initWithJsonData: modeData];
            [self.uberModes addObject:uberMode];
        }
        
    } withSecondBlock:^(NSDictionary *responseObject) {
        NSArray *modes = [responseObject objectForKey:@"times"];
        for (id modeData in modes) {
            for (UberMode *uberMode in self.uberModes) {
                if ([uberMode.productID isEqualToString:[modeData objectForKey:@"product_id"]]) {
                    uberMode.timeEstimate = [[modeData objectForKey:@"estimate"] integerValue];
                    [self.travelModeResults addObject:uberMode];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    break;
                }
            }
        }
    }];
}

#pragma mark - Table View methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.travelModeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *modeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *timeDurationLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *fourthLabel = (UILabel *)[cell viewWithTag:4];
    UIButton *selectModeButton = (UIButton *)[cell viewWithTag:5];
    [selectModeButton addTarget:self action:@selector(selectMode:) forControlEvents:UIControlEventTouchUpInside];
    
    id travelMode = [self.travelModeResults objectAtIndex:indexPath.row];
    
    if ([travelMode isKindOfClass:[GoogleDirection class]]) {
        modeLabel.text = [(GoogleDirection*)travelMode mode];
        timeDurationLabel.text = [travelMode timeDuration];
        thirdLabel.text = [travelMode summary];
        fourthLabel.text = [travelMode distance];
    }
    else {
        modeLabel.text = [travelMode productName];
        timeDurationLabel.text = [NSString stringWithFormat:@"%i mins total", (_drivingDirection.timeDurationSeconds + [travelMode timeEstimate])/60];

        thirdLabel.text = [NSString stringWithFormat:@"%@, %@", [travelMode priceEstimate], [travelMode formattedSurgeMultiplier] ];
        fourthLabel.text = [NSString stringWithFormat:@"will take about %@ to get to you", [travelMode formattedTimeDuration] ];
    }
    
    return cell;
}

- (void)selectMode:(UIButton *)sender
{
        CGPoint center= sender.center;
        CGPoint rootViewPoint = [sender.superview convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        NSLog(@"%i",indexPath.row);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSteps"]) {
        StepsViewController *viewController = (StepsViewController *) segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id selectedDirection = [self.travelModeResults objectAtIndex:indexPath.row];
        if ([selectedDirection isKindOfClass:[GoogleDirection class]]) {
            viewController.stepsArray = [selectedDirection steps];
        }
        else {
            viewController.stepsArray = _drivingDirection.steps;
        }
    }
}



@end
