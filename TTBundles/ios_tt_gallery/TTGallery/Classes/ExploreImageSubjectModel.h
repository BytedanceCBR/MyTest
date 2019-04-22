//
//  ExploreImageSubjectModel.h
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface ExploreImageSubjectModel : NSObject

@property(nullable, nonatomic, copy) NSString *title;
@property(nullable, nonatomic, copy) NSString *abstract;
@property(nullable, nonatomic, strong) TTImageInfosModel *imageModel;
@property(nullable, nonatomic, copy) NSString *carInfo;
@property(nullable, nonatomic, copy) NSString *carOpenURL; //scheme链接
@property(nonatomic) BOOL isOriginal;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
NS_ASSUME_NONNULL_END
