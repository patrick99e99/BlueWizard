#import "SpeechDataReader.h"

@interface SpeechDataReader ()

@end

@implementation SpeechDataReader

+(NSArray *)speechDataFromFile:(NSString *)file {
    NSArray *dataFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"lpc"
                                                            inDirectory:nil];
    NSString *foundFile;
    for (NSString *dataFile in dataFiles) {
        NSString *key = [[dataFile componentsSeparatedByString:@"/"] lastObject];
        key           = [[[key componentsSeparatedByString:@"."] firstObject] lowercaseString];

        if ([key isEqualToString:file]) {
            foundFile = dataFile;
            break;
        }
    }
    
    NSAssert(foundFile, @"file not found!");
    file = foundFile;
    
    NSData *myData = [NSData dataWithContentsOfFile:file];
    NSString *string = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    return [self speechDataFromString:string];
}

+(NSArray *)speechDataFromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@","];
    NSMutableArray *speechData = [NSMutableArray arrayWithCapacity:[components count]];
    for (NSString *component in components) {
        NSScanner *scanner = [NSScanner scannerWithString:component];
        unsigned int hex;
        [scanner scanHexInt: &hex];
        [speechData addObject:[NSNumber numberWithUnsignedInteger:hex]];
    }
    return [speechData copy];
}

@end
