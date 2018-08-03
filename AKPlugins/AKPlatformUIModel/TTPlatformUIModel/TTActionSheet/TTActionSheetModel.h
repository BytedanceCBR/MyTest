//
//  TTActionSheetModel.h
//  Article
//
//  Created by zhaoqin on 8/27/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTActionSheetType) {
    TTActionSheetTypeDislike,
    TTActionSheetTypeReport
};

@interface TTActionSheetModel : NSObject
@property (nonatomic, assign) TTActionSheetType type;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSString *inputString;
@end
