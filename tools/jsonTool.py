#! /usr/bin/python
import json
from sys import argv

classList = {}

def capitalize(name):
    if len(name) == 0 :
        return name
    return name[0].capitalize() + name[1:]

def underLineToCamel(name,firstCap = False):
    if name.find('_') < 0 :
        if firstCap:
            
            return capitalize(name)
        return name
        
    items = name.split('_')
    if firstCap:
        camel = capitalize(items[0])
    else:
        camel = items[0]

        
    for i in range(1,len(items)):
        camel = camel + capitalize(items[i])
        
    return camel


def defaultKeyMap(key):

    if key == "errno":
        return "dErrno"
    return key
    
def simpleTypeName(ktype):
    
    if ktype == "<type 'int'>" or  ktype == "<type 'float'>":
        #return "NSNumber"
        return "NSString"
    elif ktype == "<type 'bool'>":
        return "BOOL"
    elif ktype == "<type 'str'>" or ktype == "<type 'unicode'>":
        return "NSString"
    return None
        
    
def iterItem(item,className,f):
    
    if not str(type(item)) == "<type 'dict'>" :
        print "item type is: " , type(item)
        return

    for k , v in item.items():
        ktype = str(type(v))

        if ktype == "<type 'list'>":
            it = v[0]
            ittype = str(type(it))
            if ittype == "<type 'dict'>":
                subname = className + "_" +k
                subname = underLineToCamel(subname)
                printProtocol(subname,f)
                newdict = contactlist(v)
                iterItem(newdict,subname,f)
            
        elif k == "log_pb":
            pass
        elif ktype == "<type 'dict'>":
            subname = className + "_"+k
            subname = underLineToCamel(subname,True)
            iterItem(v,subname,f)

    printHeader(item,className,f)
 
def contactlist(item):
    newdict = {}
    for it in item:
        ittype = str(type(it))
        if ittype == "<type 'dict'>":
            for k, v in it.items():
                newdict[k] = v
    return newdict


def printHeader(item,className,of):

    t = str(type(item))
    if not  t == "<type 'dict'>" :
        print "error type: " , t
        print "item is  : " , item
        print "className is: " , className
        return None

    global classList
    varlist = {}

    s = "@interface %sModel : JSONModel \n" % (className)
    of.write(s)

    for k , v in item.items():
        ktype = str(type(v))
        pname = underLineToCamel(defaultKeyMap(k))

        of.write("\n")

        if ktype == "<type 'int'>" or  ktype == "<type 'float'>":
            of.write( "@property (nonatomic, copy , nullable) NSString *%s;" %  pname)
        elif ktype == "<type 'bool'>":
            of.write( "@property (nonatomic, assign) BOOL %s;" % pname )
        elif ktype == "<type 'str'>" or ktype == "<type 'unicode'>":
            of.write( "@property (nonatomic, copy , nullable) NSString *%s;" % pname)
        elif ktype == "<type 'dict'>" and k == "log_pb": #for log 
            of.write( "@property (nonatomic, strong , nullable) NSDictionary *%s;" % pname)
        elif ktype == "<type 'dict'>":
            classType = className + underLineToCamel(pname,True) + "Model"
            of.write( "@property (nonatomic, strong , nullable) %s *%s ;  " % (classType, pname))
        elif ktype == "<type 'list'>":

            it = v[0]
            t = str(type(it))
            nn = simpleTypeName(t)
            if nn == None :
                of.write( "@property (nonatomic, strong , nullable) NSArray<%sModel> *%s;" % (className+underLineToCamel(defaultKeyMap(k),True),pname))
            else:
                of.write("@property (nonatomic, strong , nullable) NSArray *%s;" % (pname))
                
        else:
            #print "type is: " , ktype , "for key : " , pname 
            of.write( "@property (nonatomic)         typename<Optional>* %s;" % pname)
        if not pname == k :
            varlist[k] = pname

    classList[className] = varlist
    of.write( "\n@end\n\n")

def printProtocol(className,f):
    f.write("@protocol %sModel<NSObject>\n"%className)
    f.write("@end\n\n")

def printImplemention(className , mapKeys , of):

    of.write("@implementation %sModel\n" % (className))
    if mapKeys != None and len(mapKeys) > 0:
        of.write( "+ (JSONKeyMapper*)keyMapper\n")
        of.write("{\n")
        of.write("  NSDictionary *dict = @{\n")
        #print "  return [[JSONKeyMapper alloc] initWithDictionary:@{",
        index = 1
        value = ""
        for k,v in mapKeys.items():
            value += "    @\"%s\": @\"%s\",\n" % (v,k)
            index+= 1
        of.write( value)
        of.write( "  };\n")
        of.write( "  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {\n")
        of.write( "     return dict[keyName]?:keyName;\n")
        of.write( "  }];\n")
        of.write( "}\n")
        
    #gen option
    of.write( "+ (BOOL)propertyIsOptional:(NSString *)propertyName\n")
    of.write( "{\n")
    of.write( "    return YES;\n")
    of.write( "}\n")
    
    of.write("@end\n\n")
    
def makeJson(path,className):

    f = file(path)
    j = json.load(f,encoding='utf8')
    f.close()
    
    
    fileName = "%sModel.h" % (className)
    of = open(fileName , "w")

    of.write("//GENERATED CODE , DON'T EDIT\n")
    of.write("#import <JSONModel.h>\n")
    of.write("NS_ASSUME_NONNULL_BEGIN\n")
    iterItem(j,className,of)
    of.write("\nNS_ASSUME_NONNULL_END\n")
    of.write("//END OF HEADER")

    print "\n\n\n\n"
    print "//for implementation"

    mFileName = "%sModel.m" % (className)
    impF = open(mFileName,"w")
    impF.write("//GENERATED CODE , DON'T EDIT\n")
    impF.write("#import \"%s\"\n"%(fileName))

    for k , v in classList.items():
        printImplemention(k,v,impF)

    impF.close()
    
    

if __name__ == '__main__':

    if len(argv) < 3:
        print "Usage: jsonTool , jsonpath  className\n"
        exit(0)
    makeJson(argv[1],argv[2])
    
