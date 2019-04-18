//
//  FHSpringboardView.h
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHSpringboardItemView <NSObject>

@end

@protocol FHSpringboardIconItemViewDelegate <NSObject>

@end

@interface FHSpringboardIconItemView : UIView<FHSpringboardItemView>
@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, assign) CGFloat iconBottomPadding;
@property (nonatomic, weak) id<FHSpringboardIconItemViewDelegate> delegate;

- (instancetype)initWithIconBottomPadding:(CGFloat)padding;

@end

@interface FHSpringboardView : UIView

@property(nonatomic,strong) NSArray<FHSpringboardIconItemView*>*currentIconItems;
@property(nonatomic , copy) void (^tapIconBlock)(NSInteger index);


- (instancetype)initWithRowCount:(NSInteger)count;
-(void)addItems:(NSArray<FHSpringboardIconItemView*>*)items;
@end

NS_ASSUME_NONNULL_END
