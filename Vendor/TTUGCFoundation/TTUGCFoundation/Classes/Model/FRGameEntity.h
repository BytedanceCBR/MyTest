//
//  FRGameEntity.h
//  Article
//
//  Created by 王霖 on 16/7/8.
//
//

#import <JSONModel/JSONModel.h>

@protocol FRGameIconCellEntity;

@interface FRGameEntity : JSONModel

@property (nonatomic, copy) NSString * name; //游戏名称
@property (nonatomic, copy) NSString * genre; //游戏类型
@property (nonatomic, copy) NSString * avatar; //游戏logo
@property (nonatomic, copy) NSArray <FRGameIconCellEntity, Optional> * iconCells; // icon列表
@property (nonatomic, copy) NSString <Optional> * introductionUrl; // 介绍url
@property (nonatomic, copy) NSString * coverUrl; // 头部图片url

@end
