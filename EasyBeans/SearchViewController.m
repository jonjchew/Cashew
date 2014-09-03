//
//  SearchViewController.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/2/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "SearchViewController.h"


@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.geocodeApiRootUrl = @"https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyCD1DnTDta-5-Zn7Drtp5Q-Ym5Ro219cQY&address=";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)findResults:(id)sender {
    NSString *address = self.originLocation.text;
    NSString *encodedAddress = [self rawurlencodeCFString:address];
    NSString *geocodeApiQueryString = [self.geocodeApiRootUrl stringByAppendingString:encodedAddress];
    NSURL *geocodeApiQuery = [NSURL URLWithString:geocodeApiQueryString];
    NSLog(@"%@", geocodeApiQueryString);
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:geocodeApiQuery completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:location];
        
        NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

        NSLog( @"%@", resultsDictionary);
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog( @"%@", resultsDictionary);
        });
    }];
    
    [task resume];

    
//    NSLog(@"%@",self.destinationLocation.text);
    
}

-(NSString *)rawurlencodeCFString:(NSString *)rawdata {
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef) rawdata,
                                                                                                    NULL,
                                                                                                    CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                                                    kCFStringEncodingUTF8));
    
    return escapedString == nil? @"":escapedString;
}
@end
