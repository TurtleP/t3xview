import binarylang

struct(*tex3dsHeader, endian = l):
    u16: *subTextures

    ru3: *width_log2
    ru3: *height_log2

    ru1: *gpuTexType
    ru1: _
    u8: *gpuTexFormat
    u8: *mipmapLevels

    u16: *width
    u16: *height

    u16: *left
    u16: *top
    u16: *right
    u16: *bottom

export toTex3dsHeader
