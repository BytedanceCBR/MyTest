//
//  FHHomeBannerView.h
//  Article
//
//  Created by 谢飞 on 2018/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface FHHomeBannerItem : UIView
@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subTitleLabel;
@end

@interface FHHomeBannerBoardView : UIView

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray<FHHomeBannerItem*>* currentItems;

- (instancetype)initWithRowCount:(NSInteger)count;

-(void)addItems:(NSArray<FHHomeBannerItem*>*)items;

@end

@interface FHHomeBannerView : UIView

@property (nonatomic, assign, readonly) NSInteger rowCount;
@property (nonatomic, assign, readonly) NSInteger rowHight;
@property (nonatomic, copy) void(^clickedCallBack)(NSInteger index);

@property (nonatomic, strong) NSArray<FHHomeBannerItem *>*currentItems;

-(instancetype)initWithRowCount:(NSInteger)rowCount;

- (instancetype)initWithRowCount:(NSInteger)rowCount withRowHight:(NSInteger) rowHight;

-(void)addItemViews:(NSArray<FHHomeBannerItem *> *)items;

@end

NS_ASSUME_NONNULL_END
