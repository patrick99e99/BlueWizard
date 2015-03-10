#import <Foundation/Foundation.h>

@interface SpeechDataReader : NSObject

+(NSArray *)speechDataFromFile:(NSString *)file;
+(NSArray *)speechDataFromString:(NSString *)string;

@end
