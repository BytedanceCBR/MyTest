//
//  TSVActivityEntranceModel.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <JSONModel/JSONModel.h>
#import <TTImage/TTImageInfosModel.h>

typedef NS_ENUM(NSUInteger, TSVActivityEntranceStyle){
    TSVActivityEntranceStyleA = 1,
    TSVActivityEntranceStyleB = 2,
    TSVActivityEntranceStyleC = 3,
};

@interface TSVActivityEntranceModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *groupID;
@property (nonatomic, copy) NSString<Optional> *forumID;
@property (nonatomic, strong) NSDictionary<Optional> *logPb;
@property (nonatomic, copy) NSString<Optional> *label;
@property (nonatomic, copy) NSString<Optional> *name;
@property (nonatomic, copy) NSString<Optional> *openURL;
@property (nonatomic, copy) NSString<Optional> *activityInfo;
@property (nonatomic, assign)TSVActivityEntranceStyle style;
@property (nonatomic, strong) TTImageInfosModel<Optional> *coverImageModel;
@property (nonatomic, strong) TTImageInfosModel<Optional> *animatedImageModel;

@end
