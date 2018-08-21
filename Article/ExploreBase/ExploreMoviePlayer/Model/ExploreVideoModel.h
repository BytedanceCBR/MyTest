//
//  ExploreLeTVVideoModel.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import <Foundation/Foundation.h>
//#import "TTVideoInfo.h"
#import "TTLiveInfo.h"
#import "TTVideoPasterADModel.h"
#import "TTVideoInfoModel.h"
#import "ExploreVideoSP.h"

@interface ExploreVideoModel : NSObject

@property (nonatomic, strong) TTVideoInfoModel *videoInfo;
@property (nonatomic, strong) TTLiveInfo *liveInfo;
@property (nonatomic, strong) TTVideoPasterADModel *adInfo;

@property (nonatomic, copy)NSArray <TTVideoPasterADModel *> *preVideoADList;
@property (nonatomic, copy)NSArray <TTVideoPasterADModel *> *afterVideoADList;

- (NSArray *)allURLWithDefinitionType:(ExploreVideoDefinitionType)type;
- (BOOL)isPasterADModel;

@end
