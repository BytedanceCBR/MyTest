//
//  EncyclopediaModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/15.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol EncyclopediaItemFilterWordModel<NSObject>
@end
@interface EncyclopediaItemFilterWordModel : JSONModel
@property (nonatomic, copy, nullable) NSString *id;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, assign) BOOL isSelected;
@end

@protocol EncyclopediaItemImageModel<NSObject>
@end
@interface EncyclopediaItemImageModel : JSONModel
@property (nonatomic, copy, nullable) NSString *uri;
@property (nonatomic, copy, nullable) NSString *url;
@end

@interface EncyclopediaItemMediaModel : JSONModel
@property (nonatomic, copy, nullable) NSString *avatarUrl;
@property (nonatomic, copy, nullable) NSString *mediaId;
@property (nonatomic, copy, nullable) NSString *name;
@end

@protocol EncyclopediaItemModel<NSObject>
@end

@interface EncyclopediaItemModel : JSONModel
@property (nonatomic, copy, nullable) NSString *mediaName;
@property (nonatomic, assign) BOOL banComment;
@property (nonatomic, copy, nullable) NSString *abstract;
@property (nonatomic, strong) EncyclopediaItemImageModel *image;
@property (nonatomic, copy) NSArray<EncyclopediaItemImageModel> *imageList;
@property (nonatomic, assign,) NSInteger articleType;
@property (nonatomic, copy, nullable) NSString *tag;
@property (nonatomic, assign) NSInteger hasM3u8Video;
@property (nonatomic, copy, nullable) NSArray *keywords;
@property (nonatomic, assign) NSInteger hasMp4Video;
@property (nonatomic, assign) NSInteger articleSubType;
@property (nonatomic, assign) NSInteger buryCount;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, copy, nullable) NSArray *label;
@property (nonatomic, copy, nullable) NSString *source;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, copy, nullable) NSString *articleUrl;
@property (nonatomic, assign) NSInteger publishTime;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, copy, nullable) NSString *displayUrl;
@property (nonatomic, copy, nullable) NSString *itemId;
@property (nonatomic, assign) NSInteger repinCount;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, strong) EncyclopediaItemMediaModel *mediaInfo;
@property (nonatomic, copy, nullable) NSString *groupId;
@property (nonatomic, copy, nullable) NSArray<EncyclopediaItemFilterWordModel> *filterWords;
@property (nonatomic, strong, nullable) NSDictionary *logPb;
@property (nonatomic, copy, nullable) NSString *imprId;
@property (nonatomic, copy, nullable) NSString *searchId;

@end

@interface EncyclopediaDataModel : JSONModel
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy, nullable) NSString *imprId;
@property (nonatomic, strong, nullable) NSDictionary *logPb;
@property (nonatomic, copy, nullable) NSArray *items;
@property (nonatomic, copy, nullable) NSString *searchId;
@end

@interface EncyclopediaModel : JSONModel<FHBaseModelProtocol>
@property (strong, nonatomic, nullable) EncyclopediaDataModel *data;
@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@end

@interface EncyclopediaConfigDataModel : JSONModel<FHBaseModelProtocol>
@property (strong, nonatomic, nullable) NSArray *items;
@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@end


NS_ASSUME_NONNULL_END
