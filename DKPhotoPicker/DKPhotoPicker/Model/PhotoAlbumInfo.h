//
//  PhotoAlbumInfo.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/11.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PhotoAlbumInfo : NSObject

@property (nullable, nonatomic, strong) UIImage *albumCoverImage;

@property (nullable, nonatomic, copy) NSString *albumName;

@property (nonatomic) NSInteger albumPhotoNumber;
@end
