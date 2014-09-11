//
//  ResultsViewCell.m
//  EasyBeans
//
//  Created by Jonathan Chew on 9/10/14.
//  Copyright (c) 2014 JC. All rights reserved.
//

#import "ResultsViewCell.h"

@implementation ResultsViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectMode:(id)sender
{
    
}

@end
