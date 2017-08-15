//
//  DKPhotoPicker.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface DKPhotoPicker : NSObject

/**
 *  调用选择照片
 * @param controller 显示的控制器
 * @param naviColor 导航栏颜色
 * @param titleColor 导航栏文字颜色
 * @param type 筛选的类型，就是在相册列表中显示的媒体类型，如果是照片，就只会显示照片
 * @param count 最大可以选择照片的数量
 * @param block 选择完成后回调的照片
 */
+ (void)showPhotoPickerOnController:(UIViewController * _Nonnull)controller
                 navigationBarColor:(UIColor * _Nullable)naviColor
                         titleColor:(UIColor * _Nullable)titleColor
                          mediaType:(DKPhotoDisplayMediaType)type
                      maxPhotoCount:(NSUInteger)count
                           complete:(photoChooseCompleteBlock _Nullable)block;
@end
