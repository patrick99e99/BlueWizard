#import "CodingTable.h"

@implementation CodingTable

static float k1[] = {
    -0.97850f, -0.97270f, -0.97070f, -0.96680f, -0.96290f, -0.95900f, -0.95310f, -0.94140f, -0.93360f, -0.92580f, -0.91600f, -0.90620f, -0.89650f, -0.88280f, -0.86910f, -0.85350f, -0.80420f, -0.74058f, -0.66019f, -0.56116f, -0.44296f, -0.30706f, -0.15735f, -0.00005f, 0.15725f, 0.30696f, 0.44288f, 0.56109f, 0.66013f, 0.74054f, 0.80416f, 0.85350f
};

static float k2[] = {
    -0.64000f, -0.58999f, -0.53500f, -0.47507f, -0.41039f, -0.34129f, -0.26830f, -0.19209f, -0.11350f, -0.03345f, 0.04702f, 0.12690f, 0.20515f, 0.28087f, 0.35325f, 0.42163f, 0.48553f, 0.54464f, 0.59878f, 0.64796f, 0.69227f, 0.73190f, 0.76714f, 0.79828f, 0.82567f, 0.84965f, 0.87057f, 0.88875f, 0.90451f, 0.91813f, 0.92988f, 0.98830f
};

static float k3[] = {
    -0.86000f, -0.75467f, -0.64933f, -0.54400f, -0.43867f, -0.33333f, -0.22800f, -0.12267f, -0.01733f, 0.08800f, 0.19333f, 0.29867f, 0.40400f, 0.50933f, 0.61467f, 0.72000f
};

static float k4[] = {
    -0.64000f, -0.53145f, -0.42289f, -0.31434f, -0.20579f, -0.09723f, 0.01132f, 0.11987f, 0.22843f, 0.33698f, 0.44553f, 0.55409f, 0.66264f, 0.77119f, 0.87975f, 0.98830f
};

static float k5[] = {
    -0.64000f, -0.54933f, -0.45867f, -0.36800f, -0.27733f, -0.18667f, -0.09600f, -0.00533f, 0.08533f, 0.17600f, 0.26667f, 0.35733f, 0.44800f, 0.53867f, 0.62933f, 0.72000f
};

static float k6[] = {
    -0.50000f, -0.41333f, -0.32667f, -0.24000f, -0.15333f, -0.06667f, 0.02000f, 0.10667f, 0.19333f, 0.28000f, 0.36667f, 0.45333f, 0.54000f, 0.62667f, 0.71333f, 0.80000f
};

static float k7[] = {
    -0.60000f, -0.50667f, -0.41333f, -0.32000f, -0.22667f, -0.13333f, -0.04000f, 0.05333f, 0.14667f, 0.24000f, 0.33333f, 0.42667f, 0.52000f, 0.61333f, 0.70667f, 0.80000f
};

static float k8[] = {
    -0.50000f, -0.31429f, -0.12857f, 0.05714f, 0.24286f, 0.42857f, 0.61429f, 0.80000f
};

static float k9[] = {
    -0.50000f, -0.34286f, -0.18571f, -0.02857f, 0.12857f, 0.28571f, 0.44286f, 0.60000f
};

static float k10[] = {
    -0.40000f, -0.25714f, -0.11429f, 0.02857f, 0.17143f, 0.31429f, 0.45714f, 0.60000f
};

static float rms[] = {
    0.0f, 52.0f, 87.0f, 123.0f, 174.0f, 246.0f, 348.0f, 491.0f, 694.0f, 981.0f, 1385.0f, 1957.0f, 2764.0f, 3904.0f, 5514.0f, 7789.0f
};

static float pitch[] = {
    0.0f, 1.0f, 16.0f, 17.0f, 18.0f, 19.0f, 20.0f, 21.0f, 22.0f, 23.0f, 24.0f, 25.0f, 26.0f, 27.0f, 28.0f, 29.0f, 30.0f, 31.0f, 32.0f, 33.0f, 34.0f, 35.0f, 36.0f, 36.0f, 38.0f, 39.0f, 40.0f, 41.0f, 42.0f, 44.0f, 46.0f, 48.0f, 50.0f, 52.0f, 53.0f, 56.0f, 58.0f, 60.0f, 62.0f, 65.0f, 67.0f, 70.0f, 72.0f, 75.0f, 78.0f, 80.0f, 83.0f, 86.0f, 89.0f, 93.0f, 97.0f, 100.0f, 104.0f, 108.0f, 113.0f, 117.0f, 121.0f, 126.0f, 131.0f, 135.0f, 140.0f, 146.0f, 151.0f, 157
};

static int bits[] = {
    4, 1, 6, 5, 5, 4, 4, 4, 4, 4, 3, 3, 3
};

+(float *)rms {
    return rms;
}

+(float *)pitch {
    return pitch;
}

+(NSUInteger)kSizeFor:(NSUInteger)k {
    if (k > 10) [self raiseIllegalKBinError];
    int *bits = [self bits];
    return 1 << bits[k + 2];
}

+(NSUInteger)rmsSize {
    int *bits = [self bits];
    return 1 << bits[0];
}

+(NSUInteger)pitchSize {
    int *bits = [self bits];
    return 1 << bits[2];
}

+(float *)kBinFor:(NSUInteger)k {
    switch (k) {
        case 1:
            return k1;
        case 2:
            return k2;
        case 3:
            return k3;
        case 4:
            return k4;
        case 5:
            return k5;
        case 6:
            return k6;
        case 7:
            return k7;
        case 8:
            return k8;
        case 9:
            return k9;
        case 10:
            return k10;
        default:
            [self raiseIllegalKBinError];
    }
    return nil;
}

+(int *)bits {
    return bits;
}

+(NSArray *)parameters {
    return @[
             kParameterGain,
             kParameterRepeat,
             kParameterPitch,
             kParameterK1,
             kParameterK2,
             kParameterK3,
             kParameterK4,
             kParameterK5,
             kParameterK6,
             kParameterK7,
             kParameterK8,
             kParameterK9,
             kParameterK10,
             ];
}

+(void)raiseIllegalKBinError {
    [NSException raise:@"IllegalKBinError" format:@"invalid k bin requested!"];
}

@end
