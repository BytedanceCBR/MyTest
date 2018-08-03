//
//  ExploreMovieViewModel.h
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import <Foundation/Foundation.h>
#import "TTMoviePlayerDefine.h"
#import "TTGroupModel.h"
#import "ExploreVideoSP.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTVArticleProtocol.h"

@interface ExploreMovieViewModel : NSObject
@property (nonatomic, assign          ) ExploreMovieViewType type;
@property (nonatomic, strong, nullable) TTGroupModel         *gModel;
@property (nonatomic, copy, nullable  ) NSString             *aID;
//track urls
@property(nonatomic, assign)            CGFloat              effectivePlayTime;
@property (nonatomic, strong, nullable) NSArray              *clickTrackURLs;
@property(nonatomic, strong, nullable ) NSString             *clickTrackUrl;
@property(nonatomic, strong, nullable ) NSArray              *playTrackUrls;
@property(nonatomic, strong, nullable ) NSArray              *activePlayTrackUrls;
@property(nonatomic, strong, nullable ) NSArray              *effectivePlayTrackUrls;
@property(nonatomic, strong, nullable ) NSArray              *playOverTrackUrls;
@property(nonatomic, copy, nullable )   NSString             *videoThirdMonitorUrl;
@property(nonatomic, assign)            NSInteger            trackSDK;

@property (nonatomic, copy, nullable  ) NSString             *cID;
@property (nonatomic, copy, nullable  ) NSString             *logExtra;
@property (nonatomic, copy, nullable  ) NSString             *gdLabel;
@property (nonatomic, copy, nullable  ) NSString             *movieTitle;
@property (nonatomic, assign)           TTVideoPlayType      videoPlayType;
@property (nonatomic, assign)           ExploreVideoDefinitionType currentDefinitionType;
@property (nonatomic, assign)           ExploreVideoDefinitionType lastDefinitionType;
@property (nonatomic, assign)           BOOL                 shouldNotRemoveAllMovieView; //是否不要移除其他所有的播放器（默认为NO）
@property (nonatomic, assign)           BOOL                 useSystemPlayer;
@property (nonatomic, copy, nullable  ) NSString             *auithorId;

+ (nullable ExploreMovieViewModel *)viewModelWithOrderData:(nullable ExploreOrderedData *)orderedData;
+ (nullable ExploreMovieViewModel *)viewModelWithArticleVideoAdExtra:(nullable id<TTVArticleProtocol> )article;
@end
