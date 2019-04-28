//
//  TTArticleInfoView.h
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import "SSThemed.h"
#import "TTDiggButton.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleTagView.h"
#import "TTAlphaThemedButton.h"

@protocol TTInfoViewProtocol <NSObject>

- (void)digButtonClick:(TTDiggButton * _Nonnull)button;

@optional
- (void)commentButtonClick;

@end

@interface TTArticleInfoView : SSThemedView

@property (nonatomic) BOOL hideTimeLabel;
@property (nonatomic, weak) id<TTInfoViewProtocol> _Nullable delegate;
@property (nonatomic, strong) TTArticleTagView * _Nonnull typeIconView;
@property (nonatomic, strong) TTDiggButton * _Nonnull digButton;
@property (nonatomic, strong) TTAlphaThemedButton * _Nonnull commentButton;
@property (nonatomic, strong) SSThemedLabel * _Nonnull timeLabel;

- (void)refreshDiggButton:(ExploreOrderedData * _Nullable)orderedData;
- (void)refreshCommentButton:(ExploreOrderedData * _Nullable)orderedData;
- (void)digButtonClicked;
- (void)commentButtonClicked;
- (void)layoutInfoView;
- (void)updateInfoView:(ExploreOrderedData * _Nullable)orderedData;

@end
