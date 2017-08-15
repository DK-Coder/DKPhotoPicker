//
//  PhotoDisplayViewController.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/12.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^photoDisplayCompleteBlock)(NSArray<UIImage *> *chosen);

@interface PhotoDisplayViewController : BaseViewController

- (instancetype)initWithPhotos:(NSArray *)photos
                  chosenPhotos:(NSArray *)chosens
                   chosenIndex:(NSInteger)index;

@property (nonatomic, copy) photoDisplayCompleteBlock displayCompleteBlock;
@end
