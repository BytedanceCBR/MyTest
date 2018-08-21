//
//  TTVideoInfoModel.h
//  Article
//
//  Created by Dai Dongpeng on 6/2/16.
//
//

#import <JSONModel/JSONModel.h>
#import "ExploreVideoSP.h"

@interface TTVideoURLInfo : JSONModel

@property (nonatomic, assign) ExploreVideoDefinitionType videoDefinitionType;
@property (nonatomic, copy) NSString <Optional> *vType;
@property (nonatomic, copy) NSString *mainURLStr;
@property (nonatomic, copy) NSString <Optional> *backupURL1;
@property (nonatomic, copy) NSString <Optional> *backupURL2;
@property (nonatomic, copy) NSString <Optional> *backupURL3;
@property (nonatomic, strong) NSNumber <Optional> *vHeight;
@property (nonatomic, strong) NSNumber <Optional> *vWidth;
@property (nonatomic, strong) NSNumber <Optional> *size;

- (NSArray *)allURLForVideoID:(NSString *)videoID;

@end

@interface TTVideoURLInfoMap : JSONModel

@property (nonatomic, strong) TTVideoURLInfo *video1; //标清 360p
@property (nonatomic, strong) TTVideoURLInfo <Optional> *video2; // 480p
@property (nonatomic, strong) TTVideoURLInfo <Optional> *video3; // 720p

@end


@interface TTVideoInfoModel : JSONModel

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString <Optional> *userID;
@property (nonatomic, strong) TTVideoURLInfoMap *videoURLInfoMap;
@property (nonatomic, strong) NSNumber <Optional> *videoDuration;

- (NSArray *)allURLWithDefinition:(ExploreVideoDefinitionType)type;
- (NSInteger)videoSizeForType:(ExploreVideoDefinitionType)type;
- (NSString *)definitionStrForType:(ExploreVideoDefinitionType)type;
- (TTVideoURLInfo *)videoInfoForType:(ExploreVideoDefinitionType)type;

@end
