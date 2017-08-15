//
//  PhotoListViewController.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "BaseViewController.h"

@class PHAssetCollection;
@interface PhotoListViewController : BaseViewController

- (instancetype)initWithChosenAssetCollection:(PHAssetCollection *)assetCollection;
@end
