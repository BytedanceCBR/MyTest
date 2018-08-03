<?php

if (!class_exists('\ProtobufMessage')) {
    require 'ProtobufMessage.php';

    if (!class_exists('\ProtobufMessage')) {
        echo ' requires protobuf extension installed to run' . PHP_EOL;
        exit(1);
    }
}

const CLASS_PREFIX = "comiosbytedance";

$inDir = $argv[1];
$outDir = $argv[2];

$outputBaseName = "FRApiModel";
$outputHName = $outputBaseName.".h";
$outputMName = $outputBaseName.".m";

$typeMap = array(
    \ProtobufMessage::PB_TYPE_DOUBLE => 'NSDecimal',
    \ProtobufMessage::PB_TYPE_INT => 'NSInteger',
    \ProtobufMessage::PB_TYPE_FLOAT => 'NSDecimal',
    \ProtobufMessage::PB_TYPE_SIGNED_INT => 'NSUInteger',
    \ProtobufMessage::PB_TYPE_BOOL => 'BOOL',
    \ProtobufMessage::PB_TYPE_STRING => 'NSString *',
);

$enums = array();
$classNames = array();
$protocols = array();
$interfaces = array();
$imps = array();
$uris = array();

require_once "ocClass.php";

function parse($fullFileName, $baseName, $uri, $isGet, $fileBaseName) {
    GLOBAL $inDir, $interfaces, $classNames, $imps;
    include_once $fullFileName;

    $classFileName = "$inDir/$fileBaseName.class";
    parseStruct($fullFileName, $classFileName);

    $responseClass = $baseName."Response";
    $requestClass = $baseName."Request";

    $tmp = new $responseClass();
    $responseFields = $tmp->fields();
    list($classResponse, $responseClassName) = OcClass::getOcClassBy($responseClass, $responseFields, "TTResponseModel");
    $classNames[] = $responseClassName;

    $tmp = new $requestClass;
    $requestFields = $tmp->fields();
    list($classRequest, $requestClassName) = OcClass::getOcClassBy($requestClass, $requestFields, "TTRequestModel");
    $classNames[] = $requestClassName;

    $interfaces[] = $classRequest;
    $interfaces[] = $classResponse;
    $imps[] = OcClass::getOcRequestImpBy($requestClassName, $uri, $responseClassName, $isGet, $requestFields);
    $imps[] = OcClass::getOcResponseImpBy($responseClassName, $responseFields);
}

function endsWith($haystack, $needle) {
    return $needle === "" || (($temp = strlen($haystack) - strlen($needle)) >= 0 && strpos($haystack, $needle, $temp) !== FALSE);
}

function parseStruct($phpFile, $classFile) {
    GLOBAL $inDir, $outDir, $protocols, $classNames, $interfaces, $imps;
    $content = file_get_contents($classFile);
    $names = explode(',', $content);
    include_once $phpFile;
    foreach ($names as $name) {
        if (empty($name) || !endsWith($name, 'Struct')) {
            continue;
        }

        $tmp = new $name();
        $fields = $tmp->fields();
        list($class, $className) = OcClass::getOcClassBy($name, $fields, "JSONModel");
        $protocol = OcProtocol::getProtocolByName($name);

        $protocols[] = $protocol;
        $interfaces[] = $class;
        $classNames[] = $className;
        $imps[] = OcClass::getOcResponseImpBy($className, $fields);
    }
}

function parseCommon() {
    GLOBAL $inDir, $outDir, $protocols, $classNames, $interfaces, $imps;
    $classFile = "$inDir/pb_proto_common.php";
    $classNameFile = "$inDir/pb_proto_common.class";

    parseStruct($classFile, $classNameFile);
}

function parseEnum() {
    GLOBAL $inDir, $outDir, $enums, $protocols;
    $classFile = "$inDir/pb_proto_enum_type.php";
    $classNameFile = "$inDir/pb_proto_enum_type.enum";
    $content = file_get_contents($classNameFile);
    $names = explode(',', $content);
    include_once $classFile;
    foreach ($names as $name) {
        if (empty($name)) {
            continue;
        }

        $tmp = new $name();
        $fields = $tmp->getEnumValues();
        $enum = OcEnum::getEnumByNameFields($name, $fields);
        $enums[] = $enum;
        $protocol = OcProtocol::getEnumProtocolByName($name);
        $protocols[] = $protocol;
    }
}

function walk_tree($directory) {
    GLOBAL $uris;
    $mydir = dir($directory);
    while ($file = $mydir->read()) {
        if ((is_dir("$directory/$file")) && ($file!=".") && ($file!="..")) {
            // 不解析二级目录
            continue;
        } elseif (($file != ".") && ($file != "..")) {
            list($baseName, $extName) = explode('.', $file);
            if ($baseName == 'pb_proto_common' || $baseName == 'pb_proto_enum_type' || $extName != 'php') {
                continue;
            }

            $arr = explode("_", $baseName);
            $isGet = false;
            $total = count($arr);
            if ($arr[$total-1] == 'get') {
                $isGet = true;
                $arr = array_slice($arr, 0, $total-1);
            }

            $base = "";
            foreach ($arr as $a) {
                $base .= ucfirst(strtolower($a));
            }

            $uri = file_get_contents("$directory/$baseName.uri");

            parse("$directory/$file", $base, $uri, $isGet, $baseName);
        }
    }
    $mydir->close();
}


parseEnum();
parseCommon();
walk_tree($inDir);

// output header
$outputH = "#import <Foundation/Foundation.h>\n";
$outputH .= "#import <JSONModel/JSONModel.h>\n";
$outputH .= "#import \"TTRequestModel.h\"\n";
$outputH .= "#import \"TTResponseModel.h\"\n";
$outputH .= "#import \"FRCommonURLSetting.h\"\n\n";

foreach ($enums as $e) {
    $outputH .= $e."\n";
}

$outputH .= "@class ";
$isFirstC = false;
foreach ($classNames as $c) {
    if ($isFirstC == false) {
        $isFirstC = true;
        $outputH .= $c;
    }else {
        $outputH .= ",\n".$c;
    }
}
$outputH .= ";\n\n";

foreach ($protocols as $p) {
    $outputH .= $p;
}

$outputH .= "\n";

$baseClass = <<<EOF
@interface FRApiRequestModel : JSONModel
@property (strong, nonatomic) NSString *_uri;
@property (strong, nonatomic) NSString *_response;
@property (assign, nonatomic) BOOL _isGet;
@end

@interface FRApiResponseModel : JSONModel
@property (assign, nonatomic) NSInteger error;
@end
EOF;

$outputH .= $baseClass."\n\n";

foreach ($interfaces as $i) {
    $outputH .= $i."\n";
}

$outputH = str_replace(ucfirst(CLASS_PREFIX), '', $outputH);

file_put_contents($outDir."/".$outputHName, $outputH);

// output Imp
$outputM = "#import \"$outputHName\"\n";

$baseImp = <<<EOF
@implementation FRApiRequestModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self._uri = @"";
        self._response = @"";
        self._isGet = NO;
    }

    return self;
}
@end

@implementation FRApiResponseModel
- (instancetype) init {
    self = [super init];
    if (self) {
        self.error = 0;
    }

    return self;
}
@end
EOF;
$outputM .= $baseImp."\n\n";

foreach ($imps as $i) {
    $outputM .= $i."\n\n";
}

$outputM = str_replace(ucfirst(CLASS_PREFIX), '', $outputM);

file_put_contents($outDir."/".$outputMName, $outputM);
