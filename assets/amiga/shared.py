from PIL import Image,ImageOps
import os,sys,bitplanelib,subprocess,json,pathlib

this_dir = pathlib.Path(__file__).absolute().parent

data_dir = this_dir / ".." / ".."


src_dir = this_dir / ".." / ".." / "src" / "amiga"

magenta = (254,0,254)
black = (0,0,0)

sheets_path = this_dir / ".." / "sheets"
dump_dir = this_dir / "dumps"

fg_used_tile_cluts_file = this_dir / "fg_used_tile_cluts.json"
used_graphics_dir = this_dir / "used_graphics"

FG_NB_TILES = 0x200
FG_NB_CLUTS = 7
BG_NB_TILES = 0x100
BG_NB_CLUTS = 7



def palette_pad(palette,pad_nb):
    palette += (pad_nb-len(palette)) * [(0x10,0x20,0x30)]

def ensure_empty(d):
    if os.path.exists(d):
        for f in os.listdir(d):
            x = os.path.join(d,f)
            if os.path.isfile(x):
                os.remove(x)
    else:
        os.makedirs(d)

def ensure_exists(d):
    if os.path.exists(d):
        pass
    else:
        os.makedirs(d)




def add_tile(table,index,cluts=[0],merge_cluts=True):
    if isinstance(index,range):
        pass
    elif not isinstance(index,(list,tuple)):
        index = [index]
    for idx in index:
        cluts = list(cluts)
        if idx in table and merge_cluts:
            cluts += table[idx]
        table[idx] = sorted(set(cluts))



def read_used_tiles(used_tiles_name,tile_cluts,nb_tiles,nb_cluts):
    with open(used_graphics_dir / used_tiles_name,"rb") as f:
        for index in range(nb_tiles):
            d = f.read(nb_cluts)
            cluts = [i for i,c in enumerate(d) if c]
            if cluts:
                add_tile(tile_cluts,index,cluts=cluts)





alphanum_tile_codes = set(range(0,16)) | set(range(0x40,0XA0))



if __name__ == "__main__":
    raise Exception("no main!")