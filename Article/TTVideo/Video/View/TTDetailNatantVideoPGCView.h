//
//  TTDetailNatantVideoPGCView.h
//  Article
//
//  Created by Ray on 16/4/15.
//
//

#import "TTDetailNatantViewBase.h"
#import "TTVArticleProtocol.h"
#import "TTImageView.h"

@class Article;

NS_ASSUME_NONNULL_BEGIN

@protocol TTDetailNatantVideoPGCViewDelegate <NSObject>

- (void)updateRecommendView;
- (void)videoPGCViewClearRedpacket;
@end

@interface TTDetailNatantVideoPGCView : TTDetailNatantViewBase

@property (nonatomic, weak, nullable) id<TTDetailNatantVideoPGCViewDelegate> delegate;
@property (nonatomic, assign) CGFloat originViewHeight;
@property (nonatomic, assign) CGFloat changedViewHeight;
@property (nonatomic, strong, nullable) TTImageView *arrowTag;
@property (nonatomic, strong, nullable) SSThemedLabel *recommendLabel;
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) SSThemedView        *bottomLine;
@property (nonatomic, assign) BOOL isRecommendList;
@property (nonatomic, assign) BOOL detectTop;
@property (nonatomic, assign) BOOL detectBottom;
@property (nonatomic, assign) BOOL onTop;
@property (nonatomic, strong) NSString *enterFrom;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSDictionary *logPb;
//@property (nonatomic, strong, nullable) FRRedpackStructModel *redpacketModel;
- (void)refreshWithArticle:(id<TTVArticleProtocol> _Nullable)article;
- (void)refreshSubscribeButtonTitle;

//Video Detail View callback when scroll up or down
- (void)recommendListWillDisplay;
- (void)recommendListEndDisplay;

@end

NS_ASSUME_NONNULL_END
