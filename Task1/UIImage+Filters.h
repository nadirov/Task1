//
//  UIImage+Filters.h
//  Task1
//
//  Created by Saibhan on 12/28/14.
//  Copyright (c) 2014 Saibhan Nadirov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Filters)
+ (UIImage*)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;
+ (UIImage*)mirrored:(UIImage*)oldImage;
+ (UIImage*)blackAndWhite:(UIImage*)oldImage;
@end
