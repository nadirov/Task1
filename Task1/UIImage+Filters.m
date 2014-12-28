//
//  UIImage+Filters.m
//  Task1
//
//  Created by Saibhan on 12/28/14.
//  Copyright (c) 2014 Saibhan Nadirov. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)

+ (UIImage*)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)mirrored:(UIImage*)image
{
    UIImageOrientation flippedOrientation = UIImageOrientationUpMirrored;
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
            flippedOrientation = UIImageOrientationDownMirrored;
            break;
        case UIImageOrientationLeft:
            flippedOrientation = UIImageOrientationLeftMirrored;
            break;
        case UIImageOrientationUp:
            flippedOrientation = UIImageOrientationUpMirrored;
            break;
        case UIImageOrientationRight:
            flippedOrientation = UIImageOrientationRightMirrored;
            break;
    }
    UIImage * flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:flippedOrientation];
    return flippedImage;
}

+ (UIImage*)blackAndWhite:(UIImage*)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CIImage *beginImage = [CIImage imageWithData:imageData];
    CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", [NSNumber numberWithFloat:0.0], @"inputContrast", [NSNumber numberWithFloat:1.1], @"inputSaturation", [NSNumber numberWithFloat:0.0], nil].outputImage;
    CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", [NSNumber numberWithFloat:0.7], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    
    CGImageRelease(cgiimage);
    return newImage;
}

@end
