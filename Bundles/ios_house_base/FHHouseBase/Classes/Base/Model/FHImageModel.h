//
//  FHImageModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/5/21.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHImageModel <NSObject>


@end

@interface FHImageModel : JSONModel

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end

NS_ASSUME_NONNULL_END
