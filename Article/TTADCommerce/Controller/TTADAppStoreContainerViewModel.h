//
//  TTADAppStoreContainerViewModel.h
//  Article
//
//  Created by rongyingjie on 2017/11/26.
//

@class TTImageView, SSThemedLabel;

@interface TTADAppStoreContainerViewModel : NSObject

@property (nonatomic, strong, readonly) TTImageInfosModel *imageInfoModel;
@property (nonatomic, copy, readonly) NSString *itunesId;
@property (nonatomic, copy, readonly) NSString *adId;
@property (nonatomic, copy, readonly) NSString *logExtra;
@property (nonatomic, copy, readonly) NSString *surfaceDes;
@property (nonatomic, assign, readonly) CGFloat displayTime;
@property (nonatomic, assign) BOOL isImageLoadFailed;
@property (assign) BOOL isWaitTimeout;          //表示5s倒计时完成
@property (assign) BOOL isAppStoreLoadFinish;   //appStore是否加载完成

+ (BOOL)validateInfoDict:(NSDictionary *)infoDict;

+ (BOOL)systemlowThan9;

+ (TTImageView *)initalizeImageView;

+ (SSThemedLabel *)initializeDesLabel;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (CGFloat)imageHeight:(CGFloat)screenWidth;

- (BOOL)isHiddenDescription;

@end
