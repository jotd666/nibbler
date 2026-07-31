import pathlib,shared

mamedir = pathlib.Path(r"K:\Emulation\MAME")
dumpdir = shared.this_dir / "charmap"
dumpdir.mkdir(exist_ok=True)

# execute in MAME when game is running (nibbler is circling)
# to capture all charset configurations
with (mamedir/"dump_frames").open("w") as f:
    f.write("bpset 3009\n")

    for i in range(400):
        f.write("g\n")
        fn = dumpdir / f"dump_{i:05d}"
        f.write(f"save {fn},$1000,$1000\n")
