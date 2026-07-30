import re,pathlib

gamename = "nibbler"

# game_specific: replace or remove I/O addresses
# if not done it will write in ROM here!!
input_dict = {
"flipscreen_2103":"write_2103",
"scroll_x_2200":"",
"scroll_y_2300":"",
"crtc_2000":"",
"crtc_2001":"",
"sound_2100":"write_sound_2100",
"sound_2101":"write_sound_2101",
"sound_2102":"write_sound_2102",
}

single_line_to_cc_protect = set()
remove_error_in_next_line = set()

remove_error_in_prev_line = set()
line_to_push_cc_protect = set() | single_line_to_cc_protect
line_to_pull_cc_protect = set() | single_line_to_cc_protect
line_to_pull_cc_prev_protect = set()


store_to_video = re.compile("GET_ADDRESS\s+(0x0[4-F]\w\w|video_ram_)",flags=re.I)   # game_specific

def game_specific(address,lines,i):
    line = lines[i]
    # game_specific
    if "unsupported return from interrupt" in line:
        line = change_instruction("rts",lines,i)
    if "replacing by tst.b" in line:
        line = remove_error(line)
    if address == 0x305f:
        # rewrite infinite loop completely
        # 1) force enable interrupts (??? but needed)
        # 2) change cpu-dependent wait
        line = """\tjbsr\tosd_enable_interrupts   | force interrupts on
0:
\tOP_W_ON_ZP_ADDRESS    addq,fast_counter_f3,#1 |  [$305f: inc fast_counter_f3]
"""+change_instruction("jbsr\tosd_small_wait",lines,i)+"\tjra\t0b\n"
        kill_code(lines,i,0x3066)
    # since game escapes irq and infinite loops, and we don't need A,X,Y save in our irq
    # we have to remove all those push and pull operations
    elif address == 0x3134:
        kill_code(lines,i,0x313A)
    elif address == 0x3068:
        kill_code(lines,i,0x306d)
    elif address == 0x3280:
        kill_code(lines,i,0x3287)
    elif address == 0x313C:
        line = remove_instruction(lines,i)
        kill_code(lines,i,0x3141)
    elif address == 0x3154:
        line = change_instruction("lea\tl_315b,a0",lines,i)+"\tjbsr\tosd_set_irq_return_address\n"

    if "[cpu_loop]" in line:
        lines[i+2] = change_instruction("jbsr\twait_1_frame",lines,i+2)
        lines[i+3] = remove_instruction(lines,i+3)
    return line




def remove_continuing_lines(lines,i):
    for j in range(i+1,i+4):
        if "[...]" in lines[j]:
            lines[j] = ""
        else:
            break


def get_line_address(line):
    try:
        toks = line.split("|")
        address = toks[1].strip(" [$").split(":")[0]
        return int(address,16)
    except (ValueError,IndexError):
        return None

def remove_continuing_lines(lines,i):
    for j in range(i+1,i+4):
        if "[...]" in lines[j]:
            lines[j] = ""
        else:
            break


def change_instruction(code,lines,i,continuing_lines=True):
    line = lines[i]
    toks = line.split("|")
    if len(toks)==2:
        toks[0] = f"\t{code}"
        if continuing_lines:
            remove_continuing_lines(lines,i)
        return " | ".join(toks)
    return line

def remove_error(line,ignore=False):
    if "ERROR" in line:
        return ""
    elif not ignore:
        raise Exception(f"No ERROR to remove in {line}")
    else:
        return line
def remove_instruction(lines,i,continuing_lines=True):
    return change_instruction("",lines,i,continuing_lines=continuing_lines)

def remove_continuing_lines(lines,i):
    for j in range(i+1,i+4):
        if "[...]" in lines[j]:
            lines[j] = ""
        else:
            break



def process_jump_table(line):

    m = re.search("\[nb_entries=(\d+)",line)
    if m:
        nb_entries = m.group(1)
        line = f"""\t.ifndef\tRELEASE
\tmove.w\t#{nb_entries},d7
\t.endif
"""+line

    return line

def get_original_instruction(line):
    toks = line.split("| [")
    if len(toks)==1:
        return ""
    inst = toks[1][7:].split("]")[0]
    return inst


def remove_code(pattern,lines,i):
    if pattern in lines[i]:
        lines[i] = remove_instruction(lines,i)
        remove_continuing_lines(lines,i)
    return lines[i]

def rebuild_lines(lines):
    return "".join(lines).splitlines(True)

def swap_lines(lines,i,j):
    lines[i],lines[j] = lines[j].rstrip()+ "| swapped\n",lines[i].rstrip()+ "| swapped\n"
    return lines[i]

def kill_code(lines,start_line,end_address):
    rval = lines[start_line]
    while True:
        address = get_line_address(lines[start_line])
        lines[start_line] = remove_instruction(lines,start_line)
        if "|" not in lines[start_line]:
            lines[start_line] = ""
        if address == end_address:
            break
        start_line+=1
    return rval

def subt(m):
    tn = m.group(1)
    rn = m.group(2)
    offset = tn.split("_")[-1]
    rval = f"""
\t.ifndef\tRELEASE
\tmove.w\t#0x{offset},d{rn}
\t.endif
\tlea\t{tn},a{rn}"""
    return rval

equates = []
global_symbols = []
equates_re = re.compile("(\w+)\s*=\s*\$(\w+)")
this_dir = pathlib.Path(__file__).absolute().parent

source_dir = this_dir / "../src"

def f_rest_of_jump_table_code(nb_cases):
    rval = f"""    and.w\t#0xFF,d4
\tcmp.b\t#{nb_cases}*2,d4
\tjcs\t0f
\tBREAKPOINT\t"case out of range {nb_cases}"
0:
    add.w    d4,d4             | 32 bits
    move.l  (a4,d4.w),a4
    jmp     (a4)
"""
    return rval

# various dirty but at least automatic patches applying on the converted code
with open(source_dir / "conv.s") as f:
    lines = list(f)

    for i,line in enumerate(lines):
        m = equates_re.match(line)
        if m:
            line = f"{m.group(1)} = 0x{m.group(2)}\n"
            equates.append(line)
            line = ""

        if any(x in line for x in ("dsw_2106","in0_2104","in1_2105","in2_2107")):
            line = line.rstrip() + " [unchecked_address]\n"

        address = get_line_address(line)


        if "[return]" in line:
            if "MAKE_" in line:
                line = ""
            else:
                line = change_instruction("rts",lines,i)

        elif "[nop]" in line:
            line = remove_instruction(lines,i)

        elif "[push_function]" in line:
            toks = line.split()
            line = remove_instruction(lines,i)
            pa = toks[1].strip("#")
            lines[i+1] = change_instruction(f"pea\t{pa}",lines,i+1)
        elif "[breakpoint]" in line and address:
            line = f'\tBREAKPOINT "{address:04x}"\n{line}'

        elif "[cc_ok]" in line:
            if "rts" in line and "ret]" not in line: # conditional return
                lines[i-1] = remove_error(lines[i-1],True)
            else:
                lines[i+1] = remove_error(lines[i+1],True)


        line = process_jump_table(line)


        # pre-add video_address tag if we find a store instruction to an explicit 3000-3FFF address
        m = store_to_video.search(line)
        if m:
            g = m.group(1)
            line = line.rstrip() + " [video_address]\n"
        if "[video_address" in line or "[unchecked_address" in line:
            line = line.replace("_ADDRESS","_UNCHECKED_ADDRESS")

            if "[video_address" in line:
                vbd_macro =  "MAYBE_VIDEO_BYTE_DIRTY" if "[video_address_maybe]" in line else "VIDEO_BYTE_DIRTY"

                # if it's a write, insert a "VIDEO_DIRTY" macro after the write
                for j in range(i+1,len(lines)):
                    next_line = lines[j]
                    if "[...]" not in next_line:
                        break
                    if ",(a0)" in next_line or "clr" in next_line:
                        lines[j] = next_line+f"\t{vbd_macro} | [...]\n"
                        break
                    elif ",(a0,d2.w)" in next_line:
                        lines[j] = next_line+f"\tadd.w\td2,a0 | [...]\n\t{vbd_macro} | [...]\n"
                        break
                    elif ",(a0,d1.w)" in next_line:
                        lines[j] = next_line+f"\tadd.w\td1,a0 | [...]\n\t{vbd_macro} | [...]\n"
                        break
        if "[pop_stack]" in line:
            line = change_instruction("addq\t#4,sp",lines,i)

        line = re.sub("#(i[xy][hl])",r"\1",line)

        ###############################################
        # game_specific
        lines[i] = line
        line = game_specific(address,lines,i)


        ###############################################
        if address in remove_error_in_prev_line:
            lines[i-1] = remove_error(lines[i-1].strip()+f" ({address:04x})")
        if address in remove_error_in_next_line:
            lines[i+1] = remove_error(lines[i+1].strip()+f" ({address:04x})")
        if address in line_to_pull_cc_protect:
            # protect the sub instructions if any
            for j in range(i+1,len(lines)):
                if not "[...]" in lines[j]:
                    break

            lines[j-1] += "\tPOP_SR\n"
            if j-1==i:
                line = lines[i]

        if address in line_to_push_cc_protect:
            # protect the sub instructions
            line = "\tPUSH_SR\n"+line
        if address in line_to_pull_cc_prev_protect:
            # protect the sub instructions
            line = "\tPOP_SR\n"+line

        if "GET_ADDRESS" in line:
            val = line.split()[1].split(",")[0]
            osd_call = input_dict.get(val)
            if osd_call is not None:

                if osd_call:
                    if isinstance(osd_call,list):
                        # choose depending on read/write
                        if "a,(" in line:
                            osd_call = osd_call[1]
                        else:
                            osd_call = osd_call[0]
                    if osd_call:
                        line = change_instruction(f"jbsr\tosd_{osd_call}",lines,i)
                    else:
                        line = remove_instruction(lines,i)
                else:
                    line = remove_instruction(lines,i)
                lines[i+1] = remove_instruction(lines,i+1)

        if "[global]" in line:
            label = line.split(":")[0]
            global_symbols.append(label)
            line = f"{label}:\n"


        lines[i] = line

    # remove duplicate VIDEO_BYTE_DIRTY
    lines = rebuild_lines(lines)
    new_lines = []
    prev_line = ""
    for line in lines:
        if "VIDEO_BYTE_DIRTY" in line and "VIDEO_BYTE_DIRTY" in prev_line:
            pass
        else:
            new_lines.append(line)
        prev_line = line

with open(source_dir / "data.inc","w") as fw:
    fw.writelines(equates)

with open(source_dir / f"{gamename}.68k","w") as fw:

    fw.write(f"""\t.include "data.inc"
""")
    for g in global_symbols:
        fw.write(f"\t.global\t{g}\n")

    fw.write("""wait_1_frame:
\tmove.w\t#200,d7
0:
\tjbsr\tosd_small_wait
\tdbf\td7,0b
\tmoveq\t#0,d7
\trts
""")
    fw.writelines(new_lines)
