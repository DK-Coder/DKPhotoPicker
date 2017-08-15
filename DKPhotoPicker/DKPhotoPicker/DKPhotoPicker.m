//
//  DKPhotoPicker.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "DKPhotoPicker.h"
#import "PhotoAlbumsViewController.h"

static PhotoAlbumsViewController *albumController;
static UINavigationController *rootNav;

@implementation DKPhotoPicker

+ (void)showPhotoPickerOnController:(UIViewController *)controller navigationBarColor:(UIColor *)naviColor titleColor:(UIColor *)titleColor mediaType:(DKPhotoDisplayMediaType)type maxPhotoCount:(NSUInteger)count complete:(photoChooseCompleteBlock _Nullable)block
{
    if (!albumController) {
        albumController = [[PhotoAlbumsViewController alloc] init];
        rootNav = [[UINavigationController alloc] initWithRootViewController:albumController];
    }
    albumController.navigationBarBackgroundColor = naviColor;
    albumController.titleColor = titleColor;
    albumController.chooseCompleteBlock = block;
    albumController.mediaType = type;
    albumController.maxPhotoCount = count;
    [controller presentViewController:rootNav animated:YES completion:nil];
}
@end
