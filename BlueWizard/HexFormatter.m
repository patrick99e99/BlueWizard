#import "HexFormatter.h"
#import "UserSettings.h"

@implementation HexFormatter

+(NSArray *)process:(NSArray *)nibbles {
    if (![[self userSettings] includeHexPrefix]) return nibbles;
    NSMutableArray *nibblesWithPrefixes = [NSMutableArray arrayWithCapacity:[nibbles count]];
    for (NSString *nibble in nibbles) {
        NSString *withPrefix = [NSString stringWithFormat:@"0x%@", nibble];
        [nibblesWithPrefixes addObject:withPrefix];
    }
    return [nibblesWithPrefixes copy];
}

+(UserSettings *)userSettings {
    return [UserSettings sharedInstance];
}

@end
