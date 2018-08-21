//
//  TTUserSettingsDataSource.h
//  Pods
//
//  Created by 苏瑞强 on 17/3/7.
//
//

#import <Foundation/Foundation.h>

@protocol TTUserSettingsDatasource <NSObject>

@optional
- (NSDictionary *)currentConfiguration;//当前所有的用户手动设置项

@end

