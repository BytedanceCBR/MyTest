<?php

class OcClass
{
    const OC_CLASS_PREFIX = 'FR';
    const OC_CLASS_SUFFIX = 'Model';

    private static $typeMap = array(
        \ProtobufMessage::PB_TYPE_DOUBLE => array('strong', 'NSNumber *', 'nil'),
        \ProtobufMessage::PB_TYPE_INT => array('strong', 'NSNumber *', 'nil'),
        \ProtobufMessage::PB_TYPE_FLOAT => array('strong', 'NSNumber *', 'nil'),
        \ProtobufMessage::PB_TYPE_SIGNED_INT => array('strong', 'NSNumber *', 'nil'),
        \ProtobufMessage::PB_TYPE_BOOL => array('strong', 'NSNumber *', 'nil'),
        \ProtobufMessage::PB_TYPE_STRING => array('strong', 'NSString*', 'nil'),
    );

    public static function getOcClassBy($name, $fields, $extends='JSONModel') {
        $tmp = new OcClass($name, $fields, $extends);
        return $tmp->getClassCode();
    }

    public static function getOcRequestImpBy($className, $uri, $responseClassName, $isGet, $requestFields) {
        $requestMethod = "POST";
        if ($isGet) {
            $requestMethod = "GET";
        }
        $output = <<<EOF
@implementation $className
- (instancetype) init 
{
    self = [super init];
    if (self) {
        self._method = @"$requestMethod";
        self._host = [FRCommonURLSetting baseURL];
        self._uri = @"$uri";
        self._response = @"$responseClassName";
    }

    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
%s
    return params;
}

@end

EOF;
        $arr = "";
        foreach ($requestFields as $key => $field) {
            $name = $field['name'];
            $type = $field['type'];
            if (isset($field['repeated']) && $field['repeated'] === true) {
                $property = sprintf("    [params setValue:_%s forKey:@\"%s\"];\n", $name, $name);
            } else {
                if (isset(self::$typeMap[$type])) {
                    $property = sprintf("    [params setValue:_%s forKey:@\"%s\"];\n", $name, $name);
                } elseif ($field['enum']) {
                    $property = sprintf("    [params setValue:@(_%s) forKey:@\"%s\"];\n", $name, $name);
                } else {
                    $property = sprintf("    [params setValue:_%s forKey:@\"%s\"];\n", $name, $name);
                }
            }
            $arr .= $property;
        }

        $output = sprintf($output, $arr);
        return $output;
    }

    public static function getOcResponseImpBy($className, $fields) {
        $output = <<<EOF
@implementation $className
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }

    return self;
}

- (void) reset
{
%s}
EOF;
        $arr = "";
        foreach ($fields as $key => $field) {
            $name = $field['name'];
            $type = $field['type'];
            if (isset($field['repeated']) && $field['repeated'] === true) {
                if (isset(self::$typeMap[$type])) {
                    $property = "    self.$name = @[];\n";
                } else {
                    $tail = self::OC_CLASS_SUFFIX;
                    $enum = $field['enum'];
                    if ($enum) {
                        $tail = OcEnum::OC_ENUM_SUFFIX;
                    }
                    $typeClass = self::OC_CLASS_PREFIX.$type.$tail;
                    $property = "    self.$name = nil;\n";
                }
            } else {
                if (isset(self::$typeMap[$type])) {
                    list($keyword, $tmp, $default) = self::$typeMap[$type];
                    if ($className == "FRGroupInfoStructModel" && $name == "delete") {
                        $property = "    self.article_deleted = nil;\n";
                    }else {
                        $pos = strpos($name, "new_");
                        if ($pos !== false && $pos === 0) {
                            switch ($type) {
                                case \ProtobufMessage::PB_TYPE_SIGNED_INT:
                                case \ProtobufMessage::PB_TYPE_INT:
                                case \ProtobufMessage::PB_TYPE_FLOAT:
                                case \ProtobufMessage::PB_TYPE_DOUBLE:
                                    $property = "    self.$name = 0;\n";
                                    break;
                                case \ProtobufMessage::PB_TYPE_BOOL:
                                    $property = "    self.$name = YES;\n";
                                    break;
                                default:
                                    $property = "    self.$name = $default;\n";
                                    break;
                            }
                        }else {
                            $property = "    self.$name = $default;\n";
                        }
                    }
                } elseif ($field['enum']) {
                    $property = "    self.$name = 0;\n";
                } else {
                    $typeClass = self::OC_CLASS_PREFIX.$type.self::OC_CLASS_SUFFIX;
                    $property = "    self.$name = nil;\n";
                }
            }

            $arr .= $property;
        }

        if ($className == "FRGroupInfoStructModel") {
            //ugly code
            $output .=<<<EOF

+ (JSONKeyMapper *)keyMapper {
    JSONKeyMapper * keyMapper = [[JSONKeyMapper alloc] initWithJSONToModelBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"delete"]) {
            return @"article_deleted";
        }else {
            return keyName;
        }
    } modelToJSONBlock:^NSString *(NSString *keyName) {
        if ([keyName isEqualToString:@"article_deleted"]) {
            return @"delete";
        }else {
            return keyName;
        }
    }];
    return keyMapper;
}
EOF;
        }elseif ($className == "FRUGCVideoDataStructModel") {
			//ugly code
			$output .=<<<EOF
+(JSONKeyMapper*)keyMapper
{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id":@"group_id",
                                                       }];
}
EOF;
        }
        $output = sprintf($output, $arr);
        $output .= <<<EOF

@end
EOF;
        return $output;
    }

    public function __construct($name, $fields, $extends) {
        $this->name = $name;
        $this->fields = $fields;
        $this->extends = $extends;
    }

    public function getClassCode() {
        $class = self::OC_CLASS_PREFIX.$this->name.self::OC_CLASS_SUFFIX;
        $output = sprintf("@interface  %s : %s\n", $class, $this->extends);
        foreach ($this->fields as $key => $field) {
            if (isset($field['repeated']) && $field['repeated'] === true) {
                $required = false;
                $property = $this->getArrayProperty($field['name'], $required, $field['type'], $field['enum']);
            } else {
                $required = isset($field['required']) ? $field['required'] : false;
                $property = $this->getProperty($field['name'], $required, $field['type'], $field['enum']);
            }

            $output .= $property;
        }
        $output .= "@end\n";

        return array($output, $class);
    }

    private function getArrayProperty($name, $required, $type, $enum) {
        $ret = "";
        if (isset(self::$typeMap[$type])) {
            $optional = $required ? "" : "<Optional>";
            $ret = sprintf("@property (strong, nonatomic) NSArray%s *%s;\n", $optional, $name);
        } else {
            $tail = self::OC_CLASS_SUFFIX;
            if ($enum) {
                $optional = $required ? "" : "<Optional>";
                $ret = sprintf("@property (strong, nonatomic) NSArray%s *%s;\n", $optional, $name);
            } else {
                $typeClass = self::OC_CLASS_PREFIX.$type.$tail;
                $optional = $required ? "<$typeClass>" : "<$typeClass, Optional>";
                $ret = sprintf("@property (strong, nonatomic) NSArray%s *%s;\n", $optional, $name);
            }
        }

        return $ret;
    }

    private function getProperty($name, $required, $type, $enum) {
        $ret = "";
        if (isset(self::$typeMap[$type])) {
            list($keyword, $ocType, $default) = self::$typeMap[$type];
            $optional = $required ? "" : "<Optional>";
            if ($type == \ProtobufMessage::PB_TYPE_STRING) {
                $ret = sprintf("@property (%s, nonatomic) NSString%s *%s;\n", $keyword, $optional, $name);
            } else {
                if ($this->name == "GroupInfoStruct" && $name == "delete") {
                    $ret = sprintf("@property (%s, nonatomic) NSNumber%s *%s;\n", $keyword, $optional, "article_deleted");
                }else {
                    $pos = strpos($name, "new_");
                    if ($pos !== false && $pos === 0) {
                        switch ($type) {
                            case \ProtobufMessage::PB_TYPE_SIGNED_INT:
                            case \ProtobufMessage::PB_TYPE_INT:
                                $ret = sprintf("@property (assign, nonatomic) int64_t %s;\n", $name);
                                break;
                            case \ProtobufMessage::PB_TYPE_BOOL:
                                $ret = sprintf("@property (assign, nonatomic) BOOL %s;\n", $name);
                                break;
                            case \ProtobufMessage::PB_TYPE_FLOAT:
                            case \ProtobufMessage::PB_TYPE_DOUBLE:
                                $ret = sprintf("@property (assign, nonatomic) double %s;\n", $name);
                                break;
                            default:
                                break;
                        }
                    }else {
                        $ret = sprintf("@property (%s, nonatomic) NSNumber%s *%s;\n", $keyword, $optional, $name);
                    }
                }
            }
        } else {
            if ($enum) {
                $ret = sprintf("@property (assign, nonatomic) %s%s%s %s;\n",
                    self::OC_CLASS_PREFIX, $type, OcEnum::OC_ENUM_SUFFIX, $name);
            } else {
                $optional = $required ? "" : "<Optional>";
                $ret = sprintf("@property (strong, nonatomic) %s%s%s%s *%s;\n",
                    self::OC_CLASS_PREFIX, $type, self::OC_CLASS_SUFFIX, $optional, $name);
            }
        }

        return $ret;
    }
}

class OcProtocol
{
    public static function getProtocolByName($name) {
        $tmp = new OcProtocol($name);
        return $tmp->getProtocol();
    }

    public static function getEnumProtocolByName($name) {
        $tmp = new OcProtocol($name);
        return $tmp->getEnumProtocol();
    }

    public function __construct($name) {
        $this->name = $name;
    }

    public function getEnumProtocol() {
        return sprintf("@protocol %s%s%s @end\n", OcClass::OC_CLASS_PREFIX, $this->name, OcEnum::OC_ENUM_SUFFIX);
    }

    public function getProtocol() {
        return sprintf("@protocol %s%s%s @end\n", OcClass::OC_CLASS_PREFIX, $this->name, OcClass::OC_CLASS_SUFFIX);
    }
}

class OcEnum
{
    const OC_ENUM_SUFFIX = "";
    public static function getEnumByNameFields($name, $fields) {
        $tmp = new OcEnum($name, $fields);
        return $tmp->getEnum();
    }

    public function __construct($name, $fields) {
        $this->name = $name;
        $this->fields = $fields;
    }

    public function getEnum() {
        $enumName = OcClass::OC_CLASS_PREFIX.$this->name.self::OC_ENUM_SUFFIX;
        $output = sprintf("typedef NS_ENUM(NSInteger, %s) {\n", $enumName);
        foreach ($this->fields as $key => $value) {
            $output .= sprintf("    %s%s = %s,\n", $enumName, $key, $value);
        }
        $output .= "};\n";

        return $output;
    }
}
