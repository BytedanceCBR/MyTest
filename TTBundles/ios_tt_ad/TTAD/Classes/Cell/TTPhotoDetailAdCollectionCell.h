//
//  TTPhotoDetailAdCollectionCell.h
//  Article
//
//  Created by yin on 16/8/2.
//
//

#import <UIKit/UIKit.h>
#import "TTShowImageView.h"
#import "TTPhotoDetailAdModel.h"
#import "SSThemed.h"
#import "TTPhotoDetailCellProtocol.h"

typedef void(^TTPhotoAdCellClickBlock)(void);

@interface TTPhotoDetailAdCellNextView : SSThemedView

-(instancetype)initWithFrame:(CGRect)frame clickBlock:(void (^)(void))block;

@end



@interface TTPhotoDetailAdCollectionCell : UICollectionViewCell <TTPhotoDetailCellProtocol>

@property(nonatomic, strong, readonly) TTShowImageView *imageScrollView;

@property(nonatomic) UIEdgeInsets   contentInset;


- (void)configurePhotoAdView;

- (void)refreshBlackOpaqueWithPersent:(CGFloat)persent;

- (void)refreshRightDistanceWithPersent:(CGFloat)persent;

@end

