//
//  FHHouseListModel.h
//  FHHouseBase
//
//  Created by 张静 on 2018/12/25.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import <FHHouseBase/FHImageModel.h>
#import "FHHouseTagsModel.h"
#import "FHSearchBaseItemModel.h"

NS_ASSUME_NONNULL_BEGIN

//@protocol FHSearchHouseDataItemsTagsModel<NSObject>
//
//@end
//
//
//@interface  FHSearchHouseDataItemsTagsModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *content;
//@property (nonatomic, copy , nullable) NSString *backgroundColor;
//@property (nonatomic, copy , nullable) NSString *id;
//@property (nonatomic, copy , nullable) NSString *textColor;
//
//@end

//@protocol FHSearchHouseDataItemsHouseImageModel<NSObject>
//
//@end
//
//
//@interface  FHSearchHouseDataItemsHouseImageModel  : JSONModel
//
//@property (nonatomic, copy , nullable) NSString *url;
//@property (nonatomic, copy , nullable) NSString *width;
//@property (nonatomic, strong , nullable) NSArray *urlList;
//@property (nonatomic, copy , nullable) NSString *uri;
//@property (nonatomic, copy , nullable) NSString *height;
//
//@end

@protocol FHSearchHouseDataRedirectTipsModel<NSObject>

@end


@interface  FHSearchHouseDataRedirectTipsModel  : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *text2;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property(nonatomic, copy)void (^clickRightBlock)(NSString *openUrl);


@end

@interface FHHouseListModel : NSObject

@end

NS_ASSUME_NONNULL_END
