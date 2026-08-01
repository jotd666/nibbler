# we're trying to work cleanly this time: instead of generating pics and storing them, we generate them
# and return the list, it takes 1 or 2 seconds

import glob,shutil,os,re,pathlib,struct
from PIL import Image
from shared import *
import bitplanelib
import gen_cluts




def doit(nb_colors,offset,nb_cluts,kind,ref_clut_index,dump_it=False):
    cluts = gen_cluts.doit(nb_colors)
    tilegen = dump_dir / "tilegen" / kind
    pal4_file = sheets_path / f"{kind}_color_{ref_clut_index:02x}.png"  # reference sheet with all colors represented

    cluts = cluts[offset:]

    rval = []
    if dump_it:
        tilegen.mkdir(exist_ok=True,parents=True)

    source = Image.open(pal4_file)

    # this reference clut has all 4 colors different. We can use that to generate
    # the other cluts (mame gfx save only saves up to 32 cluts, we need 64)
    ref_clut = cluts[ref_clut_index]
    for i in range(0,nb_cluts):
        this_clut = cluts[i]
        dest = Image.new("RGB",source.size)
        if len(set(this_clut))>1:  # avoid all black
            rep_dict = {k:v for k,v in zip(ref_clut,this_clut)}
            #rep_dict[magenta] = magenta
            #rep_dict[ref_clut[0]] = magenta           # Mr Do makes tiles transparent, always

            dest_file = tilegen / f"pal_{i:02x}.png"
            if True:
                src = source.load()
                dst = dest.load()

                width, height = source.size

                for y in range(height):
                    for x in range(width):
                        pix = src[x, y]
                        newpix = rep_dict.get(pix)
                        if not newpix:
                            print(f"{pal4_file}:{i} color {pix} not found at {x},{y}")
                            newpix = pix
                        dst[x, y] = newpix
            if dump_it:
                dest.save(dest_file)

        rval.append(dest)
    return rval

def get_rom_table(rom_data,address,size):
    offset = address-0x6000
    return [rom_data[i*2+offset]+256*rom_data[i*2+offset+1] for i in range(size)]

def doit_rom_tiles(dump_it=False):
    rom_file = this_dir.parent / "rom.bin"
    if dump_it:
        cdump_dir = dump_dir / "rom_tiles"
        cdump_dir.mkdir(exist_ok=True)

    with rom_file.open("rb") as f:
        contents = f.read()[0x3000:]  # gfx stuff starts at 0x6000

    rt_plane1 = []
    rt_plane2 = []
    # collect rom tables pointing on 0x48 bytes of data (head)
    for fp_address,sp_address in [(0x60C0,0x6310),(0x6a00,0x6c50),(0x6560,0x67B0)]:
        rt_plane1.extend(get_rom_table(contents,fp_address,8))
        rt_plane2.extend(get_rom_table(contents,sp_address,8))

    d = {}
    color = [(0,0,0),(255,255,0XDE),(255,0,0),(255,255,0XDE)]  # clut 3

    for r72_plane1,r72_plane2 in zip(rt_plane1,rt_plane2):
        data_plane1 = contents[r72_plane1-0x6000:r72_plane1-0x6000+0x48]
        data_plane2 = contents[r72_plane2-0x6000:r72_plane2-0x6000+0x48]
        offset = 0
        for i in range(9):
            cdata_plane1 = data_plane1[offset:offset+8]  # one char data
            cdata_plane2 = data_plane2[offset:offset+8]  # one char data
            img = Image.new("RGB",(8,8))
            imgdat = img.load()
            for col,(c1,c2) in enumerate(zip(cdata_plane1,cdata_plane2)):
                for row in range(8):
                    palindex = 0
                    if (c1 & 1):
                        palindex += 2
                    c1 >>= 1
                    if (c2 & 1):
                        palindex += 1
                    c2 >>= 1
                    imgdat[row,col] = color[palindex]
            if dump_it:
                imgs = ImageOps.scale(img,5,resample=Image.Resampling.NEAREST)
                imgs.save(cdump_dir/f"pic_{r72_plane1:04x}_{i}.png")
            offset += 8

def doit_fg_tiles(dump_it=False):
    return doit(nb_colors=4,offset=0,nb_cluts=8,kind="tiles_8x8_fg",ref_clut_index=0x0,dump_it=dump_it)
def doit_bg_tiles(dump_it=False):
    return doit(nb_colors=4,offset=8,nb_cluts=8,kind="tiles_8x8_bg",ref_clut_index=0x0,dump_it=dump_it)

if __name__ == "__main__":
##    doit_fg_tiles(True)
##    doit_bg_tiles(True)
    doit_rom_tiles(True)
