//
//  TTActionSheetCellModel.h
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import <Foundation/Foundation.h>
#import "TTActionSheetModel.h"

@interface TTActionSheetCellModel : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) TTActionSheetType source;
@end
