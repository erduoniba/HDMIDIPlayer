//
//  HDModulator.m
//  MIDI Soundboard
//
//  Created by denglibing on 2022/3/15.
//  Copyright © 2022 Mixed In Key. All rights reserved.
//

#import "HDModulator.h"

#import "MJExtension.h"

@implementation HDModulatorItem

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"minorModulator": @"mmodulator",
        @"minorModulators": @"mmodulators",
    };
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"modulators": @"HDModulatorItem",
        @"minorModulators": @"HDModulatorItem"
    };
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _midiModulator = HDModulatorMidiEmpty;
        _midiMinorModulator = HDModulatorMidiEmpty;
    }
    return self;
}

+ (instancetype)initModulator:(HDModulatorMidiValue)midiModulator {
    HDModulatorItem *item = [[HDModulatorItem alloc] init];
    item.midiModulator = midiModulator;
    return item;
}

- (HDModulatorMidiValue)midiModulator {
    if (_modulator) {
        // 555表示高高5阶：level为   value为5
        // -555表示低低5阶
        NSInteger level = [[NSString stringWithFormat:@"%ld", (long)_modulator] length];
        NSInteger value = [HDModulator midiModulator:_modulator % 10];
        if (_modulator < 0 && level > 1) {
            // 如果是负数，则会多一个负号，需要 - 2 操作
            return value - (level - 2) * 12;
        }
        
        return value + (level - 1) * 12;
    }
    return _midiModulator;
}

- (HDModulatorMidiValue)midiMinorModulator {
    if (_minorModulator) {
        // 555表示高高5阶：level为   value为5
        // -555表示低低5阶
        NSInteger level = [[NSString stringWithFormat:@"%ld", (long)_minorModulator] length];
        NSInteger value = [HDModulator midiModulator:labs(_minorModulator % 10)];
        if (_minorModulator < 0 && level > 1) {
            // 如果是负数，则会多一个负号，需要 -1 操作
            return value - (level - 1) * 12;
        }
        
        return value + (level - 1) * 12;
    }
    return _midiMinorModulator;
}

@end



@implementation HDModulator

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"beatInterval": @"interval",
        @"beatHitCount": @"hitCount",
        @"beatAllCount": @"allCount",
        @"beatModulators": @"modulators",
    };
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"beatModulators": @"HDModulatorItem"
    };
}

+ (HDModulatorMidiValue)midiModulator:(NSInteger)modulator {
    NSDictionary *tempDict = @{
        @1 : @0,
        @2 : @2,
        @3 : @4,
        @4 : @5,
        @5 : @7,
        @6 : @9,
        @7 : @11,
    };
    if ([tempDict.allKeys containsObject:@(modulator)]) {
        return [tempDict[@(modulator)] integerValue];
    }
    return HDModulatorMidiEmpty;
}

+ (instancetype)loadPlist:(NSString *)plist {
    NSString *filePath = [NSBundle.mainBundle pathForResource:plist ofType:@"plist"];
    HDModulator *model = [HDModulator mj_objectWithFile:filePath];
    return model;
}

- (void)logModulator {
    for (HDModulatorItem *item in self.combineModulators) {
        NSLog(@"七音阶（主）：%ld MIDI音阶：%ld 下一拍时间间隔：%f", item.modulator, item.midiModulator, item.interval);
    }
    
    for (HDModulatorItem *item in self.combineMinorModulators) {
        NSLog(@"七音阶（副）：%ld MIDI音阶：%ld 下一拍时间间隔：%f", item.minorModulator, item.midiMinorModulator, item.interval);
    }
}

- (NSMutableArray <HDModulatorItem *>*)combineModulators {
    if (!_combineModulators) {
        _combineModulators = [NSMutableArray array];
        for (HDModulatorItem *item in self.beatModulators) {
            item.interval = self.beatInterval;
            [self addModulatorItem:item];
        }
    }
    return _combineModulators;
}

- (void)addModulatorItem:(HDModulatorItem *)item {
    if (item.modulators.count > 0) {
        NSTimeInterval beatInterval = item.interval / item.modulators.count;
        for (HDModulatorItem *mm in item.modulators) {
            mm.interval = beatInterval;
            [self addModulatorItem:mm];
        }
    }
    else {
        [_combineModulators addObject:item];
    }
}

- (NSMutableArray <HDModulatorItem *>*)combineMinorModulators {
    if (!_combineMinorModulators) {
        _combineMinorModulators = [NSMutableArray array];
        for (HDModulatorItem *item in self.beatModulators) {
            item.interval = self.beatInterval;
            [self addMinorModulatorItem:item];
        }
    }
    return _combineMinorModulators;
}

- (void)addMinorModulatorItem:(HDModulatorItem *)item {
    if (item.minorModulators.count > 0) {
        NSTimeInterval beatInterval = item.interval / item.minorModulators.count;
        for (HDModulatorItem *mm in item.minorModulators) {
            mm.interval = beatInterval;
            [self addMinorModulatorItem:mm];
        }
    }
    else {
        [_combineMinorModulators addObject:item];
    }
}

@end
