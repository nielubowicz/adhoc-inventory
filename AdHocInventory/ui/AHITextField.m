//
//  AHITextField.m
//  AdHocInventory
//
//  Created by chris nielubowicz on 10/9/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import "AHITextField.h"

@implementation AHITextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CALayer *layer = self.layer;
        layer.cornerRadius = 2.0f;
        layer.borderColor = [UIColor lightTealColor].CGColor;
        layer.borderWidth = 2.0f;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
