#import "SpeechDataReader.h"

@interface SpeechDataReader ()

@end

@implementation SpeechDataReader

+(NSArray *)speechDataFromFile:(NSString *)file {
    NSArray *dataFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"lpc"
                                                            inDirectory:nil];
    NSString *foundFile;
    for (NSString *dataFile in dataFiles) {
        NSString *key = [[file componentsSeparatedByString:@"/"] lastObject];
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
    NSMutableArray *lpc = [NSMutableArray arrayWithCapacity:[string length]];
    for (NSString *hexString in [string componentsSeparatedByString:@","]) {
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        unsigned int hex;
        [scanner scanHexInt: &hex];
        [lpc addObject:[NSNumber numberWithUnsignedInteger:hex]];
    }
    return [lpc copy];
}

@end
