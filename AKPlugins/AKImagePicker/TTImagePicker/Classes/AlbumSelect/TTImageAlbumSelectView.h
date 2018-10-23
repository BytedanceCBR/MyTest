//
//  TTImageAlbumSelectView.h
//  Article
//
//  Created by xuzichao on 2017/4/11.
//
//

#import "SSThemed.h"

@class TTAlbumModel;

@protocol TTImageAlbumSelectViewDelegate <NSObject>

@optional

- (void)ttImageAlbumSelectViewDidSelect:(TTAlbumModel *)model;

@end

@interface TTImageAlbumSelectView : UIView



@property (nonatomic,weak) id<TTImageAlbumSelectViewDelegate> delegate;

@property (nonatomic, strong) NSArray<TTAlbumModel *> *models;

@property (nonatomic, strong) UIView *maskView;


- (void)didSelectItemWithCell:(UICollectionViewCell *)cell;
- (void)showAlbum;
- (void)hideAlbum;



@end
