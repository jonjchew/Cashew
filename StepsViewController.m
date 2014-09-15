//
//  StepsViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/14/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "StepsViewController.h"
#import "Step.h"

@interface StepsViewController ()

@end

@implementation StepsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"StepsViewController %@", self.stepsArray);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *timeDurationLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *directionsLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *travelModeLabel = (UILabel *)[cell viewWithTag:4];

    distanceLabel.text = [[self.stepsArray objectAtIndex:indexPath.row] distance];
    timeDurationLabel.text = [[self.stepsArray objectAtIndex: indexPath.row] timeDuration];
    directionsLabel.text = [[self.stepsArray objectAtIndex: indexPath.row] htmlDirections];
    travelModeLabel.text = [[self.stepsArray objectAtIndex: indexPath.row] travelMode];
    
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
