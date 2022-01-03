import cligen

import strformat
import strutils
import tables
import sequtils
import os

import header

const Version = staticRead("../t3xview.nimble").fromNimble("version")

proc getPowTwo(x: uint16): int =
    return cast[int](1 shl x)

proc getSubtextureCorner(x: uint16): float =
    x.float / 1024.float

proc alignment(keys: seq[string]): int =
    var longest: int = 0

    for key in keys:
        if len(key) > longest:
            longest = len(key)

    return longest + 1

proc info(filepath: string) =
    ## Get the info of the tex3ds texture

    if not fileExists(filepath):
        echo(fmt"File '{filepath}' does not exist.")
        return

    let bin = toTex3dsHeader(readFile(filepath))

    let coordinates = {"Left": bin.left, "Top": bin.top, "Right": bin.right,
            "Bottom": bin.bottom}.toTable()
    let coordalign = alignment(coordinates.keys().toSeq())

    let dimensions = {"Width": @[bin.width, bin.width_log2], "Height": @[
            bin.height, bin.height_log2]}.toTable()
    let dimsalign = alignment(dimensions.keys().toSeq())

    echo fmt"Subtexture Count: {bin.subTextures}"
    echo "Texture Dimensions"
    for key, value in dimensions.pairs():
        let spacing = " ".repeat(coordalign - len(key))
        echo(fmt"  {key}:{spacing}{value[0]} ({getPowTwo(value[1] + 3)})")

    echo fmt"GPU_TEXTURE_MODE_PARAM: {bin.gpuTexType}"
    echo fmt"GPU_TEXCOLOR: {bin.gpuTexFormat}"
    echo fmt"Mipmap Levels: {bin.mipmapLevels}"

    echo "Subtexture Coordinates:"
    for key, value in coordinates.pairs():
        let spacing = " ".repeat(dimsalign - len(key))
        echo(fmt"  {key}:{spacing}{value} ({getSubtextureCorner(value)})")

proc version() =
    ## Print version number and exit

    echo(Version)

dispatchMulti([info, help = {"filepath": "path to the tex3ds generated file"}],
        [version])
