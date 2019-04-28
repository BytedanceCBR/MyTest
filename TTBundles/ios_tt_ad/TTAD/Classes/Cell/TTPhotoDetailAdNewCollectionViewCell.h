//
//  TTPhotoDetailAdNewCollectionViewCell.h
//  Article
//
//  Created by ranny_90 on 2017/4/11.
//
//

#import <UIKit/UIKit.h>
#import "TTShowImageView.h"
#import "SSThemed.h"
#import "TTPhotoDetailAdModel.h"
#import "TTAlphaThemedButton.h"
#import "TTPhotoDetailCellProtocol.h"


//通投广告的view
@interface TTPhotoDetailAdNormalView : SSThemedView

@property(nonatomic, strong) TTShowImageView *imageScrollView;

@property(nonatomic, strong) SSThemedLabel *titleLabel;

-(void)configureDetailModel:(TTPhotoDetailAdModel *)detailModel WithAdImage:(UIImage *)adImag;
-(CGSize)updateFrame;

@end



//创意广告的view
@interface TTPhotoDetailAdCreativeView : SSThemedView

@property(nonatomic, strong) TTShowImageView *imageScrollView;

@property(nonatomic, strong) SSThemedLabel *titleLabel;

@property(nonatomic, strong) SSThemedLabel *creativeTitleLabel;

@property(nonatomic, strong) TTAlphaThemedButton *creativeButton;


-(void)configureDetailModel:(TTPhotoDetailAdModel *)detailModel WithAdImage:(UIImage *)adImage;
-(CGSize)updateFrame;

@end



//容器view
@interface TTPhotoDetailAdContainView : SSThemedView


-(void)configureADPhotoViewWithModel:(TTPhotoDetailAdModel *)adModel WithImage:(UIImage *)adImage;

-(void)setImageScrollViewDelegate:(id)delegate;

-(CGSize)updateFrame;
@end


//广告cell
@interface TTPhotoDetailAdNewCollectionViewCell : UICollectionViewCell <TTPhotoDetailCellProtocol>


@property (nonatomic, strong) TTPhotoDetailAdContainView *containView;

-(void)configureAdPhotoView;


-(void)setImageScrollViewDelegate:(id)delegate;

- (void)refreshBlackOpaqueWithPersent:(CGFloat)persent;


@end
