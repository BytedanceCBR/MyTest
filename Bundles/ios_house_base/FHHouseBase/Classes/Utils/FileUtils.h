//
//  FileUtils.h
//  FHHouseBase
//
//  Created by leo on 2018/11/17.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUtils : NSObject
+ (NSDictionary *)readLocalFileWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
