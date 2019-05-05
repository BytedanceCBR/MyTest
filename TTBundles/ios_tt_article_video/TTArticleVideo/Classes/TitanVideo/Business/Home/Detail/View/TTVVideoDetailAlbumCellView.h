//
//  TTVVideoDetailAlbumCellView.h
//  Article
//
//  Created by lishuangyang on 2017/6/21.
//
//

#import "SSThemed.h"
#import "TTImageView.h"
#import "TTVArticleProtocol.h"

@interface TTVVideoDetailNatantRelateReadViewModel : NSObject

@property(nonatomic, strong, nullable)id<TTVArticleProtocol> article;
@property(nonatomic, strong, nullable)id<TTVArticleProtocol> fromArticle;
//@property(nonatomic, strong, nullable)NSDictionary * actions;
@property(nonatomic, strong, nullable)NSArray *tags;  //标题中需要高亮的字符串
@property(nonatomic, assign)BOOL pushAnimation; //push时的动画开关
@property(nonatomic, assign)BOOL useForVideoDetail; //是否是视频详情页相关视频
@property(nonatomic, assign)BOOL isCurrentPlaying;
@property(nonatomic, assign)BOOL isSubVideoAlbum;//是否是视频专辑详情页子cell
@property(nonatomic, strong, nullable)NSString *videoAlbumID;
@property(nonatomic, copy)NSDictionary *logPb;
- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController;

@end


@interface TTVVideoDetailAlbumCellView : SSThemedView

//todo
@property (nonatomic, strong) TTVVideoDetailNatantRelateReadViewModel *viewModel;
@property (nonatomic, strong)id<TTVArticleProtocol> protoedArticle;

- (void)refreshArticle:(id<TTVArticleProtocol>)article;
- (void)hideBottomLine:(BOOL)hide;

+ (TTVVideoDetailAlbumCellView *)genViewForArticle:(id<TTVArticleProtocol> )article
                                                      width:(float)width
                                                   infoFlag:(nullable NSNumber *)flag
                                             forVideoDetail:(BOOL)forVideoDetail;


@end
