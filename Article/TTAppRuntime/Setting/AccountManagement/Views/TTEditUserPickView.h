//
//  TTEditUserPickView.h
//  Article
//
//  Created by wangdi on 2017/3/30.
//
//

#import "SSThemed.h"

typedef enum {
    TTEditUserPickViewTypeBirthday,
    TTEditUserPickViewTypeArea
}TTEditUserPickViewType;

@interface TTEditUserProvinceModel : JSONModel

@property (nonatomic, copy) NSString *province;
@property (nonatomic, strong) NSArray *areas;

@end

@interface TTEditUserPickViewManager : NSObject

+ (instancetype)sharedInstance;
- (NSArray<TTEditUserProvinceModel *> *)provinceModels;

@end

@interface TTEditUserPickView : SSThemedView

/**
 显示选择器的方法，当为传入TTEditUserPickViewTypeArea 时，block中的textArray最多为两项，省份和城市,当传入TTEditUserPickViewTypeBirthday时，为一项，生日

 @param type 类型
 @param pickerViewHeight 高度
 @param completion 回调
 */
- (void)showWithType:(TTEditUserPickViewType)type pickerViewHeight:(CGFloat)pickerViewHeight completion:(void (^)(NSArray<NSString *> *textArray,TTEditUserPickViewType type))completion;

@end
