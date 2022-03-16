//
//  HDModulator.h
//  MIDI Soundboard
//
//  Created by denglibing on 2022/3/15.
//  Copyright © 2022 Mixed In Key. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HDModulatorMidiValue) {
    HDModulatorMidiInit = -1001,    // 初始化
    HDModulatorMidiEmpty = -1000,   // 空一拍
    
    HDModulatorMidiLowLowDo = -24,
    HDModulatorMidiLowLowRe = -22,
    HDModulatorMidiLowLowMi = -20,
    HDModulatorMidiLowLowFa = -19,
    HDModulatorMidiLowLowSol = -17,
    HDModulatorMidiLowLowLa = -15,
    HDModulatorMidiLowLowSi = -13,
    
    HDModulatorMidiLowDo = -12,
    HDModulatorMidiLowRe = -10,
    HDModulatorMidiLowMi = -8,
    HDModulatorMidiLowFa = -7,
    HDModulatorMidiLowSol = -5,
    HDModulatorMidiLowLa = -3,
    HDModulatorMidiLowSi = -1,
    
    HDModulatorMidiDo = 0,
    HDModulatorMidiRe = 2,
    HDModulatorMidiMi = 4,
    HDModulatorMidiFa = 5,
    HDModulatorMidiSol = 7,
    HDModulatorMidiLa = 9,
    HDModulatorMidiSi = 11,
    
    HDModulatorMidiHighDo = 12,
    HDModulatorMidiHighRe = 14,
    HDModulatorMidiHighMi = 16,
    HDModulatorMidiHighFa = 17,
    HDModulatorMidiHighSol = 19,
    HDModulatorMidiHighLa = 21,
    HDModulatorMidiHighSi = 23,
    
    HDModulatorMidiHighHighDo = 24,
    HDModulatorMidiHighHighRe = 26,
    HDModulatorMidiHighHighMi = 28,
    HDModulatorMidiHighHighFa = 29,
    HDModulatorMidiHighHighSol = 31,
    HDModulatorMidiHighHighLa = 33,
    HDModulatorMidiHighHighSi = 35,
};

NS_ASSUME_NONNULL_BEGIN

/// 节拍数据对象
@interface HDModulatorItem : NSObject

/// 节拍的间隔时间
@property (nonatomic, assign) NSTimeInterval interval;

/// 节拍应该的拍数
@property (nonatomic, assign) NSUInteger hitCount;

/// 节拍的总拍数，和 beatHitCount 可以组合成 3/4、6/8 等节拍
@property (nonatomic, assign) NSUInteger allCount;

/// 钢琴曲中的音阶（主旋律）和 modulators 互斥
@property (nonatomic, assign) NSInteger modulator;

/// 钢琴曲中的音阶（副旋律/伴奏）和 minorModulators 互斥
@property (nonatomic, assign) NSInteger minorModulator;

/// 钢琴曲中的音阶（该拍子中又包含多个音阶） （主旋律）
@property (nonatomic, copy) NSArray <HDModulatorItem *>*modulators;

/// 钢琴曲中的音阶（该拍子中又包含多个音阶）（副旋律/伴奏）
@property (nonatomic, copy) NSArray <HDModulatorItem *>*minorModulators;

/// MIDI的音阶（主旋律）
@property (nonatomic, assign) HDModulatorMidiValue midiModulator;

/// MIDI的音阶（副旋律/伴奏）
@property (nonatomic, assign) HDModulatorMidiValue midiMinorModulator;

+ (instancetype)initModulator:(HDModulatorMidiValue)midiModulator;

@end


/// 一首曲子的节拍及音阶信息
@interface HDModulator : NSObject

/// 节拍的间隔时间
@property (nonatomic, assign) NSTimeInterval beatInterval;

/// 节拍应该的拍数
@property (nonatomic, assign) NSUInteger beatHitCount;

/// 节拍的总拍数，和 beatHitCount 可以组合成 3/4、6/8 等节拍
@property (nonatomic, assign) NSUInteger beatAllCount;

/// 音阶组合（数据结构是树形结构）
@property (nonatomic, copy) NSArray <HDModulatorItem *>*beatModulators;

/// 音阶组合（数据结构是队列结构）（主旋律）
@property (nonatomic, copy) NSMutableArray <HDModulatorItem *>*combineModulators;

/// 音阶组合（数据结构是队列结构）（副旋律/伴奏）
@property (nonatomic, copy) NSMutableArray <HDModulatorItem *>*combineMinorModulators;

/// 通过钢琴的音阶（1-7）转换成MIDI的音阶
/// @param modulator 钢琴的音阶（1-7）
+ (HDModulatorMidiValue)midiModulator:(NSInteger)modulator;

+ (instancetype)loadPlist:(NSString *)plist;

- (void)logModulator;

@end

NS_ASSUME_NONNULL_END
