//
//  TTMoviePlayerControlFinishAdAction.h
//  Article
//
//  Created by songxiangwu on 2016/9/22.
//
//

#import <Foundation/Foundation.h>
#import "TTPlayerControlView.h"
@class SSThemedLabel;
@class ExploreActionButton;
@class TTImageView;
@class ExploreOrderedData;


@interface TTMoviePlayerControlFinishAdAction : NSObject

@property (nonatomic, strong) TTImageView *logoImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) ExploreActionButton *actionBtn;
@property (nonatomic, assign, readonly) BOOL isAd;
@property (nonatomic, assign) BOOL isIndetail; //不同的位置打点不同

- (instancetype)initWithBaseView:(UIView <TTPlayerControlView> *)baseView;
- (void)layoutSubviews;
- (void)refreshSubView:(BOOL)hasFinished;
- (void)setData:(ExploreOrderedData *)data;

@end
