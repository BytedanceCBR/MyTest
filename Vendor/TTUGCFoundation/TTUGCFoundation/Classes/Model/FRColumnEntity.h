//
//  FRColumnEntity.h
//  Article
//
//  Created by 王霖 on 16/8/1.
//
//

#import <JSONModel/JSONModel.h>

@interface FRColumnEntity : JSONModel

@property (nonatomic, copy) NSString * bookName; //连载小说名
@property (nonatomic, copy) NSString * category; //连载小说分类
@property (nonatomic, copy) NSString * columnStatusName; //连载状态（连载中/已完结）
@property (nonatomic, copy) NSString * columnDesc; //连载小说信息
@property (nonatomic, copy) NSString * abstract; //连载小说简介
@property (nonatomic, copy) NSString * thumbUrl; //连载小说封面
@property (nonatomic, strong) NSNumber * type; //连载小说类型
@property (nonatomic, strong) NSNumber * platform; // 连载小说来源平台
@property (nonatomic, copy) NSString * mediaId; //作者头条号ID
@property (nonatomic, copy) NSString * avatarUrl; //作者头像
@property (nonatomic, copy) NSString * mediaName; //作者名称
@property (nonatomic, assign) BOOL showConcernNumberFlag; //是否展示关注人数

@end
