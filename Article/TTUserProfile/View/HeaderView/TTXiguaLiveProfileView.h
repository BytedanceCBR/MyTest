//
//  TTXiguaLiveProfileView.h
//  Article
//
//  Created by lishuangyang on 2017/12/14.
//

#import "TTImageView.h"

@protocol TTXiguaLiveViewModelProtocol <NSObject>

@optional

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *watchCount;
@property (nonatomic, strong, readonly) NSString *roomID;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *avatarUrl;
@property (nonatomic, strong, readonly) NSString *groupID;
@property (nonatomic, strong, readonly) NSString *groupSource;
@property (nonatomic, strong, readonly) NSNumber *creatTime;
@property (nonatomic, strong, readonly) NSString *streamUrl;
@property (nonatomic, strong, readonly) NSString *streamId;
@property (nonatomic, strong, readonly) NSString *flvPullUrl;
@property (nonatomic, strong, readonly) NSString *alternatePullUrl;
@property (nonatomic, strong, readonly) NSDictionary *largeImage;
@property (nonatomic, strong, readonly) NSString *categoryName;
@property (nonatomic, strong, readonly) NSString *logPb;

- (FRImageInfoModel *)largeImageModel;

@end

@interface TTXiguaLiveProfileModel : NSObject<TTXiguaLiveViewModelProtocol>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *watchCount;
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *groupSource;
@property (nonatomic, strong) NSString *streamUrl;
@property (nonatomic, strong) NSString *flvPullUrl;
@property (nonatomic, strong) NSString *alternatePullUrl;
@property (nonatomic, strong) NSDictionary *largeImage;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *logPb;

- (FRImageInfoModel *)largeImageModel;

@end

@interface TTXiguaLiveProfileView : SSThemedView

@property (nonatomic, strong) id<TTXiguaLiveViewModelProtocol> liveModel;

@end
