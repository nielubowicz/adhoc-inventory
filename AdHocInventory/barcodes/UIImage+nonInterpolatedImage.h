//
//  UIImage+nonInterpolatedImage.h
//  AdHocInventory
//
//  Created by chris nielubowicz on 8/13/14.
//  Copyright (c) 2014 Assorted Intelligence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NonInterpolatedImage)

+(UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale;

@end
