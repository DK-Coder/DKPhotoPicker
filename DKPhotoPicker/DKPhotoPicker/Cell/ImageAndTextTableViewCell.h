//
//  ImageAndTextTableViewCell.h
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/10.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kImageAndTextTableViewCellIdentifier = @"kImageAndTextTableViewCellIdentifier";

@interface ImageAndTextTableViewCell : UITableViewCell

/**
 *  每个相册最近的一张照片
 */
@property (nonatomic, strong) UIImageView *coverImageView;

/**
 *  相册的名称
 */
@property (nonatomic, strong) UILabel *albumNameLabel;

/**
 *  相册中照片的数量
 */
@property (nonatomic) NSInteger photoNumberInAlbum;
@end
