//
//  TTUGCImageRecordManager.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/10/10.
//

#import <Foundation/Foundation.h>
#import <BDWebImageURLFilter.h>

@class FRImageInfoModel;

typedef NS_ENUM(NSUInteger, TTUGCImageRecordStatus) {
    TTUGCImageRecordStatusStart = 0,//开始记录，若上报时候还在这个状态，认为这个图片的统计还未结束，不置信，不上报。
    TTUGCImageRecordStatusAlready,//start（cell开始展示）时已经在缓存中。
    TTUGCImageRecordStatusFailed,//移出屏幕时还没载成功。
    TTUGCImageRecordStatusCostTime,//在屏幕中间时候下载并展示的。
};


@interface TTUGCImageRecordModel : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) TTUGCImageRecordStatus status;
@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) CFAbsoluteTime endTime;
@property (nonatomic, assign) CFTimeInterval costTime;

@end

@interface TTUGCImageRecordManager : NSObject

+ (instancetype)sharedInstance;

//- (BOOL)shouldRecordForKey:(NSString *)key;

//- (void)startRecordForKey:(NSString *)key;
- (void)recordAlreadyForKey:(NSString *)key;
- (void)recordCostForKey:(NSString *)key;
- (void)recordFailForKey:(NSString *)key;

- (void)trackWillAppearForImageModel:(FRImageInfoModel *)imageModel;

- (void)trackDidDisappearForImageModel:(FRImageInfoModel *)imageModel;

//- (void)trackSetImageForImageModel:(FRImageInfoModel *)imageModel;

//- (void)trackSetImageForURLStr:(NSString *)urlStr;

- (void)trackSetImageForURL:(NSURL *)url;


- (void)trackAlreadyForGifKey:(NSString *)gifKey;
- (void)trackWaitingForGifKey:(NSString *)gifKey;
- (void)trackWaitingSuccessForGifKey:(NSString *)gifKey;
- (void)trackWaitingSuccessForGifModel:(FRImageInfoModel *)gifModel;


//- (void)startRecordForGifKey:(NSString *)key;
//- (void)trackWillAppearForGifImageModel:(FRImageInfoModel *)imageModel;
//
//- (void)trackDidDisappearForImageModel:(FRImageInfoModel *)imageModel;



@end




