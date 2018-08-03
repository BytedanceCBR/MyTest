//
//  TTVDetailCarCard.h
//  Article
//
//  Created by pei yun on 2017/8/25.
//
//

#import <Mantle/Mantle.h>

@interface TTVDetailCarCard : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) int card_type;
@property (nonatomic, strong) NSString *cover_url;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *series_name;
@property (nonatomic, strong) NSString *open_url;

@end
