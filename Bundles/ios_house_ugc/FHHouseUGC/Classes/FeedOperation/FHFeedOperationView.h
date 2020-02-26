//
//  FHFeedOperationView.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/14.
//

#import "TTFeedPopupView.h"
#import "TTFeedDislikeConfig.h"
#import "FHFeedOperationOption.h"
#import "FHUGCConfigModel.h"
#import "FHHouseUGCHeader.h"

//NS_ASSUME_NONNULL_BEGIN
//
//@interface FHFeedOperationView : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN

@class FHFeedOperationView;
@class FHFeedOperationWord;

typedef void (^TTFeedDislikeBlock)(FHFeedOperationView * view);
typedef void (^TTFeedDislikeOptionBlock)(FHFeedOperationView * view, FHFeedOperationOptionType dislikeType);
typedef void (^TTFeedDislikeCommandBlock)(FHFeedOperationWord *word);

typedef NS_ENUM(NSInteger, TTFeedDislikeViewPushFrom) {
    TTFeedDislikeViewPushFromRight,
    TTFeedDislikeViewPushFromLeft,
};

@protocol TTFeedDislikeCommand <NSObject>
- (void)execute;
@end

@interface FHFeedOperationViewModel : NSObject {
    NSArray<NSDictionary *> *_keywords;
}

@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *keywords;
@property (nonatomic, strong, nullable) NSString *groupID;
@property (nonatomic, strong, nullable) NSString *userID;
@property (nonatomic, strong, nullable) NSString *adID;
@property (nonatomic, strong, nullable) NSString *videoID;
@property (nonatomic, strong, nullable) NSString *categoryID;
@property (nonatomic, copy, nullable) NSString *logExtra;
@property (nonatomic, copy, nullable) NSString *source;
@property (nonatomic, strong, nullable) NSDictionary *extrasDict;
@property (nonatomic, strong, nullable) NSDictionary *trackExtraDict; // 埋点透传字段(modern模式使用)
@property (nonatomic, assign)           BOOL dislikeFilterFlag;  //https://wiki.bytedance.net/pages/viewpage.action?pageId=175543655
@property(nonatomic, strong, nullable) NSArray <FHUGCConfigDataPermissionModel> *permission;
//是否置顶
@property (nonatomic, assign) BOOL isTop;
//是否加精
@property (nonatomic, assign) BOOL isGood;
//类型
@property (nonatomic, assign)   FHUGCFeedListCellType       cellType;
//编辑记录
@property (nonatomic, assign)   BOOL       hasEdit;
//区分来源
@property (nonatomic, copy , nullable) NSString *groupSource;
@end

//------------------------------------------------------------------

@interface FHFeedOperationView : TTFeedPopupView

@property (nonatomic, strong) FHFeedOperationWord *selectdWord;
@property (nonatomic, copy) void(^dislikeTracerBlock)(void);

- (void)refreshWithModel:(nullable FHFeedOperationViewModel *)model;

- (nonnull NSArray<NSDictionary *> *)selectedWords;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
    didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
didDislikeWithOptionBlock:(TTFeedDislikeOptionBlock)didDislikeWithOptionBlock;

- (void)showAtPoint:(CGPoint)arrowPoint
           fromView:(UIView *)fromView
    didDislikeBlock:(TTFeedDislikeBlock)didDislikeBlock
           pushFrom:(TTFeedDislikeViewPushFrom)pushFrom;

+ (void)dismissIfVisible;

+ (void)enable;

+ (void)disable;

+ (BOOL)isFeedDislikeRefactorEnabled;

/** 在Pod库外使用TTFeedDislikeView的相关图片资源，需要传入此bundle来获取 */
+ (NSBundle *)resourceBundle;

@end

NS_ASSUME_NONNULL_END


