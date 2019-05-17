//
//  TTVideoPGCViewModel.h
//  Article
//
//  Created by 刘廷勇 on 15/11/5.
//
//

#import "JSONModel.h"

@protocol TTVideoPGC
@end

@interface TTVideoPGC : JSONModel

@property (nonatomic, copy)   NSString *userAuthInfo;
@property (nonatomic, copy)   NSString *avatarUrl;
@property (nonatomic, copy)   NSString *openUrl;
@property (nonatomic, copy)   NSString *mediaID;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *desc;

@end


@interface TTVideoPGCViewModel : JSONModel

@property (nonatomic, copy)   NSString *openUrl;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, copy)   NSString *defaultDesc;
@property (nonatomic, strong) NSArray<TTVideoPGC> *pgcList;

@end

