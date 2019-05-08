//
//  TTDetailNatantRelateReadViewModel.h
//  Article
//
//  Created by Ray on 16/4/7.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "Article.h"
#import "TTDeviceHelper.h"

typedef void(^AlbumClickAction)(Article * _Nullable article);

@interface TTDetailNatantRelatedItemModel : JSONModel

@property (nonatomic, strong, nullable) NSString * title;
@property (nonatomic, strong, nullable) NSString *schema;
@property (nonatomic, strong, nullable) NSString *typeName;
@property (nonatomic, strong, nullable) NSNumber *typeDayColor;
@property (nonatomic, strong, nullable) NSNumber *typeNightColor;
@property (nonatomic, strong, nullable) NSString *groupId;
@property (nonatomic, strong, nullable) NSString *itemId;
@property (nonatomic, strong, nullable) NSString *impressionID;
@property (nonatomic, strong, nullable) NSString *aggrType;
@property (nonatomic, strong, nullable) NSDictionary *middle_image;

@end

@interface TTDetailNatantRelateReadViewModel : NSObject

@property(nonatomic, strong, nullable)Article * article;
@property(nonatomic, strong, nullable)Article * fromArticle;
@property(nonatomic, strong, nullable)NSDictionary * actions;
@property(nonatomic, strong, nullable)NSDictionary *logPb;
@property(nonatomic, strong, nullable)NSArray *tags;  //标题中需要高亮的字符串
@property(nonatomic, assign)BOOL pushAnimation; //push时的动画开关
@property(nonatomic, assign)BOOL useForVideoDetail; //是否是视频详情页相关视频
@property(nonatomic, assign)BOOL isCurrentPlaying;
@property(nonatomic, assign)BOOL isVideoAlbum;//是否是视频详情页视频专辑cell
@property(nonatomic, assign)BOOL isSubVideoAlbum;//是否是视频专辑详情页子cell
@property(nonatomic, strong, nullable)NSString *videoAlbumID;
@property (nonatomic, strong, nullable) AlbumClickAction didSelectVideoAlbum;
@property(nonatomic, strong, nullable) TTDetailNatantRelatedItemModel * releatedItem;

+ (CGSize)imgSizeForViewWidth:(CGFloat)width;

- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController;

- (float)titleHeightForArticle:(nullable Article *)article cellWidth:(float)width;

@end

@interface TTDetailNatantRelateReadPureTitleViewModel : TTDetailNatantRelateReadViewModel
+ (nullable NSAttributedString *)showTitleForTitle:(nullable NSString *)title tags:(nullable NSArray *)tags;
@end

@interface TTDetailNatantRelateReadRightImgViewModel : TTDetailNatantRelateReadPureTitleViewModel

@end

