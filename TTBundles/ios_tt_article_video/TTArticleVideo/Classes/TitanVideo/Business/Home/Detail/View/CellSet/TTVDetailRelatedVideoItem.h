//
//  TTVDetailRelatedVideoItem.h
//  Article
//
//  Created by pei yun on 2017/5/10.
//
//

#import "TTVDetailRelatedTableViewItem.h"
#import "TTImageView.h"
#import "TTVDetailRelatedVideoInfoDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTVVideoRelatedType) {
    TTVVideoRelatedTypeUnknown = 0,
    TTVVideoRelatedTypeArticle = 1 << 0,
    TTVVideoRelatedTypeAlbum   = 1 << 1,
    TTVVideoRelatedTypeSubject = 1 << 2,
    TTVVideoRelatedTypeAd      = 1 << 3
};

@interface TTVDetailRelatedVideoItem : TTVDetailRelatedTableViewItem

@property (nonatomic, strong) id<TTVDetailRelatedVideoInfoDataProtocol> article;
@property (nonatomic, strong, nullable) id<TTVDetailRelatedADInfoDataProtocol> relatedADInfo;
@property (nonatomic, strong) id fromArticle;
@property(nonatomic, strong, nullable)NSDictionary * actions;
@property(nonatomic, strong, nullable)NSArray *tags;  //标题中需要高亮的字符串
@property(nonatomic, assign)BOOL pushAnimation; //push时的动画开关
@property(nonatomic, assign)BOOL isCurrentPlaying;
@property(nonatomic, assign)BOOL isVideoAlbum;//是否是视频详情页视频专辑cell
@property(nonatomic, assign)BOOL isSubVideoAlbum;//是否是视频专辑详情页子cell
@property(nonatomic, strong, nullable)NSString *videoAlbumID;

@end

@interface TTVDetailRelatedVideoCell : TTVDetailRelatedTableViewCell

@property(nonatomic, strong, nullable)SSThemedLabel *titleLabel;
@property(nonatomic, strong, nullable)TTImageView *picImageView;
@property(nonatomic, strong, nullable)UILabel *fromLabel;
@property(nonatomic, strong, nullable)UILabel *commentCountLabel;
@property(nonatomic, strong, nullable)UIView * timeInfoBgView;
@property(nonatomic, strong, nullable)SSThemedImageView * videoIconView;
@property(nonatomic, strong, nullable)SSThemedLabel * videoDurationLabel;
@property(nonatomic, strong, nullable)SSThemedLabel *albumLogo;
@property(nonatomic, strong, nullable)SSThemedView *albumCover;
@property(nonatomic, strong, nullable)SSThemedLabel *albumCount;

@property (nonatomic, strong, nullable)SSThemedButton* actionButton;
@property (nonatomic, strong, nullable)SSThemedButton* downloadIcon;

@end

NS_ASSUME_NONNULL_END
