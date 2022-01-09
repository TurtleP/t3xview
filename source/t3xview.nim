import cligen

import strformat
import strutils
import tables
import os

import t3xheader
import strings
import enums

const Version = staticRead("../t3xview.nimble").fromNimble("version")

proc getPowTwoDimensions(x: uint16, y: uint16): auto =
    return (width: cast[int](1 shl x), height: cast[int](1 shl y))

proc longest(values: auto): int =
    for corner in values:
        let strCorner = $corner.norm
        if len(strCorner) > result:
            result = len(strCorner)

proc getSubtextureCorners(x: Tex3dsSubtexture): auto =
    let corners = @[x.left, x.top, x.right, x.bottom]
    var values = newSeq[tuple[norm: uint16, subc: float]]()

    for corner in corners:
        values.add((corner, corner.float / 1024.float))

    return values

var filename: string
var useFile: bool

proc fileEcho(value: string) =
    var file: File = stdout

    if useFile:
        var mode: FileMode = fmWrite
        if fileExists(filename):
            mode = fmAppend

        file = open(filename, mode)

    writeLine(file, value)
    flushFile(file)

    if useFile:
        file.close()

proc info(filepath: string, dump: bool = false) =
    ## Get the info of the tex3ds texture

    if not fileExists(filepath):
        echo(fmt"File '{filepath}' does not exist.")
        return

    let bin = toTex3dsHeader(readFile(filepath))

    if dump:
        useFile = true
        let (_, name, _) = splitFile(filepath)
        filename = fmt"{name}.txt"

    fileEcho(SubTextureCount.format(bin.numSubTextures))
    fileEcho(GPUTextureMode.format(GPU_TEXTURE_MODE_PARAM(bin.gpuTexType)))
    fileEcho(GPUTextureFormat.format(GPU_TEXCOLOR(bin.gpuTexFormat)))
    fileEcho(CubeMapSkyBox.format(bool(bin.gpuTexType and (1 shl 6))))
    fileEcho(MipMapLevels.format(bin.mipmapLevels))

    let powTwoSize = getPowTwoDimensions(bin.width_log2 + 3, bin.height_log2 + 3)
    fileEcho(TextureSize.format(powTwoSize.width, powTwoSize.height))

    for index in 0 ..< bin.numSubTextures.int:
        fileEcho(SubTextureIndex.format(index))
        fileEcho(SubTextureDimensions)
        fileEcho(SubTextureSize.format(bin.subTextures[index].width,
                bin.subTextures[index].height))
        fileEcho(SubTextureCoordinates)

        let corners = getSubtextureCorners(bin.subTextures[index])
        let padding = longest(corners) + 1

        for index, corner in corners.pairs():
            let aligned = alignLeft($corner.norm, padding)
            fileEcho(SubTextureCoordinateInfo[index].format(aligned, corner.subc))

proc version() =
    ## Print version number and exit

    echo(Version)

dispatchMulti([info, help = {"filepath": "path to the tex3ds generated file",
        "dump": "whether to dump output to a file"}], [version])
