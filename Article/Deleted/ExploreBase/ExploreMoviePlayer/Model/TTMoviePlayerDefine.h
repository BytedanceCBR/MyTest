//
//  TTMoviePlayerDefine.h
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

typedef NS_ENUM(NSUInteger, ExploreMovieViewType){
    ExploreMovieViewTypeList,
    ExploreMovieViewTypeDetail,
    ExploreMovieViewTypeVideoFloat_main,
    ExploreMovieViewTypeVideoFloat_related,
    ExploreMovieViewTypeLiveChatRoom, //直播室
    ExploreMovieViewTypeUnknow,
};

typedef NS_ENUM(NSUInteger, ExploreMovieViewSubType){
    ExploreMovieViewTypeUnkown,
    ExploreMovieViewTypeReadHistory,
    ExploreMovieViewTypePushHistory,
    ExploreMovieViewTypeFloatMain,
    ExploreMovieViewTypeFloatRelated,
};

typedef NS_OPTIONS(NSUInteger, TTVideoPasterADEnableOptions) {
    TTVideoEnablePrePaster = 1 << 0,
    TTVideoEnableMidPaster = 1 << 1,
    TTVideoEnableAfterPaster = 1 << 2,
    TTVideoEnablePasterALL = (TTVideoEnablePrePaster |
                              TTVideoEnableMidPaster |
                              TTVideoEnableAfterPaster)
};


@class ArticleVideoPosterView;
@class ExploreMovieView;
@protocol ExploreMovieViewCellProtocol <NSObject>

- (BOOL)hasMovieView;
- (BOOL)isPlayingMovie;
- (BOOL)isMovieFullScreen;
- (nullable id)movieView;
- (nullable id)detachMovieView;
- (void)attachMovieView:(nullable id)movieView;

- (CGRect)logoViewFrame;
@optional
- (nullable ArticleVideoPosterView *)posterView;
- (nullable id)ttv_playerController;
- (BOOL)ttv_canUseNewPlayer;
- (CGRect)movieViewFrameRect;

@end
