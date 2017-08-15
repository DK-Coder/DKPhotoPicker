//
//  PhotoAlbumsViewController.m
//  DKPhotoPicker
//
//  Created by NSLog on 2017/8/9.
//  Copyright © 2017年 DK-Coder. All rights reserved.
//

#import "PhotoAlbumsViewController.h"
#import <Photos/Photos.h>
#import "ImageAndTextTableViewCell.h"
#import "PhotoListViewController.h"
#import "PhotoAlbumInfo.h"

@interface PhotoAlbumsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    PHAssetCollection *defaultAssetCollection;
}
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *assetCollectionArray;
@property (nonatomic, strong) NSMutableArray<PhotoAlbumInfo *> *photoAlbumArray;
@property (nonatomic, strong) UITableView *albumTableView;
@end

@implementation PhotoAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBarTitle = @"相册";
    [self requestPhotoAuthorization];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)systemVersion
{
    return [UIDevice currentDevice].systemVersion.floatValue;
}

- (void)requestPhotoAuthorization
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self.photoAlbumArray removeAllObjects];
            // 获取所有系统相册
            PHFetchResult *systemAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *obj in systemAlbumResult) {
                [self transformAndAddAlbumInfoIntoArray:obj];
            }
            // 获取所有用户相册
            PHFetchResult *userAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            for (PHAssetCollection *obj in userAlbumResult) {
                [self transformAndAddAlbumInfoIntoArray:obj];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (defaultAssetCollection) {
                    [self pushToPhotoListControllerWithAsset:defaultAssetCollection animated:NO];
                }
                [self.albumTableView reloadData];
            });
        } else {
            // 用户未授权
            weakifySelf();
            [self showAlertWithTitle:@"相册不可用" message:@"请到\"设置\"->\"隐私\"->\"相册\"中，将本应用的权限打开" OKTitle:@"好" OKHandler:^(UIAlertAction * _Nullable action) {
                strongifySelf();
                NSString *settingURL = nil;
                float systemVersion = [self systemVersion];
                if (systemVersion >= 10.f) {
                    settingURL = UIApplicationOpenSettingsURLString;
                } else {
                    settingURL = @"prefs:root=Privacy&path=PHOTOS";
                }
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingURL]];
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            } cancelTitle:@"取消" cancelHandle:^(UIAlertAction * _Nullable action) {
                
            } isDestructive:NO];
        }
    }];
}

- (void)transformAndAddAlbumInfoIntoArray:(PHAssetCollection *)obj
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:options];
    PHAsset *lastedAsset = nil;
    for (NSInteger i = 0, length = result.count; i < length; i++) {
        PHAsset *asset = result[i];
//        if (self.mediaType == DKPhotoDisplayMediaTypeBoth) {
//            lastedAsset = asset;
//        } else
        if (self.mediaType == DKPhotoDisplayMediaTypePhoto) {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                lastedAsset = asset;
            }
        }
//        else if (self.mediaType == DKPhotoDisplayMediaTypeVideo) {
//            if (asset.mediaType == PHAssetMediaTypeVideo) {
//                lastedAsset = asset;
//            }
//        }
    }
    PhotoAlbumInfo *album = [[PhotoAlbumInfo alloc] init];
    album.albumName = obj.localizedTitle;
    album.albumPhotoNumber = result.count;
    if (lastedAsset) {
        [self requestImageByAsset:lastedAsset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) complete:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            album.albumCoverImage = image;
            
            if (![self.photoAlbumArray containsObject:album]) {
                [self.photoAlbumArray addObject:album];
                [self.assetCollectionArray addObject:obj];
            }
        }];
    } else {
        album.albumCoverImage = [UIImage imageNamed:@"images.bundle/placeholder_photo"];
        
        [self.photoAlbumArray addObject:album];
        [self.assetCollectionArray addObject:obj];
    }
    if ([album.albumName isEqualToString:@"相机胶卷"]) {
        defaultAssetCollection = obj;
    }
}

- (void)pushToPhotoListControllerWithAsset:(PHAssetCollection *)collection animated:(BOOL)animated
{
    PhotoListViewController *controller = [[PhotoListViewController alloc] initWithChosenAssetCollection:collection];
    controller.chooseCompleteBlock = self.chooseCompleteBlock;
    controller.mediaType = self.mediaType;
    controller.maxPhotoCount = self.maxPhotoCount;
    [self.navigationController pushViewController:controller animated:animated];
}

#pragma mark - tableview 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoAlbumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageAndTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kImageAndTextTableViewCellIdentifier];
    PhotoAlbumInfo *album = self.photoAlbumArray[indexPath.row];
    cell.coverImageView.image = album.albumCoverImage;
    cell.albumNameLabel.text = album.albumName;
    cell.photoNumberInAlbum = album.albumPhotoNumber;
    
    return cell;
}

#pragma mark - tableview 代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *asset = self.assetCollectionArray[indexPath.row];
    [self pushToPhotoListControllerWithAsset:asset animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - getter
- (NSMutableArray<PHAssetCollection *> *)assetCollectionArray
{
    if (!_assetCollectionArray) {
        _assetCollectionArray = [NSMutableArray array];
    }
    return _assetCollectionArray;
}

- (NSMutableArray<PhotoAlbumInfo *> *)photoAlbumArray
{
    if (!_photoAlbumArray) {
        _photoAlbumArray = [NSMutableArray array];
    }
    return _photoAlbumArray;
}

- (UITableView *)albumTableView
{
    if (!_albumTableView) {
        _albumTableView = [[UITableView alloc] init];
        _albumTableView.frame = CGRectMake(0.f, CGRectGetMaxY(self.navigationBarView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetHeight(self.navigationBarView.frame));
        _albumTableView.dataSource = self;
        _albumTableView.delegate = self;
        _albumTableView.rowHeight = 60.f;
        _albumTableView.showsHorizontalScrollIndicator = NO;
        _albumTableView.tableFooterView = [UIView new];
        _albumTableView.separatorInset = UIEdgeInsetsMake(0.f, -20.f, 0.f, 0.f);
        _albumTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_albumTableView registerClass:[ImageAndTextTableViewCell class] forCellReuseIdentifier:kImageAndTextTableViewCellIdentifier];
        [self.view addSubview:_albumTableView];
    }
    return _albumTableView;
}
@end
