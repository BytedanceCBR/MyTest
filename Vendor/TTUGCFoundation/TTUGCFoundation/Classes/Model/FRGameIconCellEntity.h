//
//  FRGameIconCellEntity.h
//  Article
//
//  Created by 王霖 on 16/7/12.
//
//

#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSUInteger, FRGameIconCellType) {
    FRGameIconCellTypeMEDIA = 1,
    FRGameIconCellTypeDOWNLOAD,
    FRGameIconCellTypeGIFT
};

@protocol FRGameIconCellEntity
@end

@interface FRGameIconCellEntity : JSONModel

@property (nonatomic, assign) FRGameIconCellType type;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * icon;
@property (nonatomic, copy) NSString * openUrl;

@end
