<?php

require 'ProtobufCompiler/ProtobufParser.php';

$inDir = $argv[1];
$outDir = $argv[2];

const CLASS_PREFIX = "comiosbytedance";

if (!class_exists('\ProtobufMessage')) {
    require 'ProtobufMessage.php';

    if (!class_exists('\ProtobufMessage')) {
        echo $argv[0] . ' requires protobuf extension installed to run' .  PHP_EOL;
        exit(1);
    }
}

$parser = new ProtobufParser(false);

function parse($fullFileName, $fileName, $prefix) {
    global $outDir, $parser;
    list($base, $ext) = explode('.', $fileName);

    $arr = explode("_", $base);
    $tmpArr = array();
    foreach ($arr as $a) {
        $tmpArr[] = str_replace('-', '_', $a);
    }
    $total = count($tmpArr);
    if ($tmpArr[$total-1] == 'get') {
        $tmpArr = array_slice($tmpArr, 0, $total-1);
    }
    $uri = "/".implode('/', $tmpArr);

    $base = str_replace('-', '_', $base);
    if ($prefix) {
        //添加前缀，兼容以数字开头的老接口
        $base = CLASS_PREFIX.'_'.$base;
    }

    $output = "$outDir/$base.php";
    $outputEnum = "$outDir/$base.enum";
    $outputClass = "$outDir/$base.class";
    $outputUri = "$outDir/$base.uri";

    list($enums, $classnames) = $parser->parseAdvance($fullFileName, $output);
    if ($prefix) {
        //添加前缀，兼容以数字开头的老接口
        $handle = fopen($output, "r");
        $contents = fread($handle, filesize ($output));
        fclose($handle);
        $tmpClassName = array();
        foreach ($classnames as $a) {
            $arr = explode("_", $a);
            $search = "";
            foreach ($arr as $b) {
                $search .= ucfirst(strtolower($b));
            }
            $contents = str_replace($search, ucfirst(CLASS_PREFIX).$search, $contents);

            $a = CLASS_PREFIX.'_'.$a;
            $tmpClassName[] = $a;
        }
        $handle = fopen($output, "w");
        fwrite($handle, $contents);
        fclose($handle);
        $classes = implode(',', $tmpClassName);
    } else {
        $classes = implode(',', $classnames);
    }

    $enums = implode(',', $enums);
    file_put_contents($outputEnum, $enums);
    file_put_contents($outputClass, $classes);
    file_put_contents($outputUri, $uri);
}

function walk_tree($directory) {
    $mydir = dir($directory);
    while ($file = $mydir->read()) {
        if ((is_dir("$directory/$file")) && ($file!=".") && ($file!="..")) {
            // 不解析二级目录
            continue;
        } elseif (($file != ".") && ($file != "..")) {
            list($baseName, $extName) = explode('.', $file);
            if ($extName != 'proto' || $baseName == 'common' || $baseName == 'enum_type') {
                continue;
            }

            echo "parsing: $directory/$file\n";
            parse("$directory/$file", $file, true);
        }
    }
    $mydir->close();
}

chdir($inDir);
parse('enum_type.proto', 'pb_proto_enum_type.proto', false);
parse('common.proto', 'pb_proto_common.proto', false);
walk_tree('.');
