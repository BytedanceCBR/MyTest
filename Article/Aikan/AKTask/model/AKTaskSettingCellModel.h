//
//  AKTaskSettingCellModel.h
//  Article
//
//  Created by chenjiesheng on 2018/3/1.
//

#import <Foundation/Foundation.h>

#import "AKTaskSettingCellLayoutModel.h"
typedef NS_ENUM(NSInteger,AKTaskSettingCellType)
{
    AKTaskSettingCellTypeSwitch = 0,
};

@interface AKTaskSettingCellModel : NSObject

@property (nonatomic, assign)AKTaskSettingCellType       type;
@property (nonatomic, copy)NSString                     *operationRegionTitle;
@property (nonatomic, assign)BOOL                        enable;
@property (nonatomic, copy)NSString                     *desRegionTitle;
@property (nonatomic, copy)NSString                     *desImageName;
@property (nonatomic, assign)CGSize                      desImageSize;
@property (nonatomic, copy)NSString                     *functionIdentifier;

@property (nonatomic, strong)AKTaskSettingCellLayoutModel                   *layoutModel;
@end
