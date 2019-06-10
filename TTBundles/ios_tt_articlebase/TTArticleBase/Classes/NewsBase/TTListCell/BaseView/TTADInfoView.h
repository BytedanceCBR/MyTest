//
//  TTADInfoView.h
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleTagView.h"
#import "TTImageView.h"

//https://wiki.bytedance.com/pages/viewpage.action?pageId=53806666
//广告创意通投Cell InfoView  推广->来源文字->评论数->发布时间

@interface TTADInfoView : SSThemedView

@property (nonatomic, strong) TTArticleTagView * _Nonnull typeIconView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull sourceLabel;
@property (nonatomic, strong) TTImageView * _Nonnull sourceImageView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull commentLabel;
@property (nonatomic, strong) SSThemedLabel * _Nonnull timeLabel;
@property (nonatomic, strong) SSThemedImageView * _Nonnull locationIcon;
@property (nonatomic, strong) SSThemedLabel * _Nonnull locationLabel;
@property (nonatomic, strong) ExploreOrderedData *_Nonnull orderedData;

- (void)refreshCommentLabel:(ExploreOrderedData * _Nonnull)orderedData;
- (void)layoutInfoView;
- (void)updateInfoView:(ExploreOrderedData * _Nonnull)orderedData;
- (nonnull NSArray<NSString *> *)randomSourceBackgroundColors;
@end
