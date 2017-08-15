//
//  UIImage+ColorExtension.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/10.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorExtension)

- (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)createImageWithColor:(UIColor *)color;
@end
