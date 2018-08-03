//
//  TTAssetCell.h
//  TestPhotos
//
//  Created by tyh on 2017/4/7.
//  Copyright © 2017年 tyh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TTAssetModel;

@interface TTImagePickerCell : UICollectionViewCell

@property (nonatomic, strong) TTAssetModel *model;

@property (nonatomic, assign)BOOL isSelected;

//是否需要遮罩
@property (nonatomic, assign) BOOL isMask;

@property (nonatomic,strong,readonly)UIImageView *img;


@property (nonatomic,assign)BOOL isCellRefresh;

//是否是视频和图片混合模式
@property (nonatomic,assign)BOOL isAllMode;


@end


@interface TTImagePickerCameraCell : UICollectionViewCell



@end
