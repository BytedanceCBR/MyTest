//
//  FHDetailCommonDefine.h
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#ifndef FHDetailCommonDefine_h
#define FHDetailCommonDefine_h

#define adjustImageScopeType(model) self.shadowImage.image = model.shadowImage;\
if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){\
[self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {\
    make.bottom.equalTo(self.contentView);\
    }];\
}\
if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){\
    [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {\
        make.top.equalTo(self.contentView);\
    }];\
}\
if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){\
    [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {\
        make.top.bottom.equalTo(self.contentView);\
    }];\
}\

#endif /* FHDetailCommonDefine_h */
