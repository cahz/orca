#/usr/bin/python3
import sys
import argparse

"""
This script converts binary files to intel hex files,
But it does it in a bit of a percular way. Each
row is 4 bytes wide, and the address is a word address rather than
byte like a normal intel hex file, this is because that is how
quartus expects the file.
"""


def bin2hex(bin_input,start_address):
    bin_input=bytearray(bin_input)
    #pad to multiple of 4
    while len(bin_input)&3 :
        bin_input.append(0)

    num_chunks=len(bin_input)/4
    line=":04{address:04X}00{data:08X}{cs:02X}"
    lines=[]
    def check_sum(address,data):
        s=(4 +
           ((address>>8)&0xFF) +
           (address&0xFF) +
           ((data>>24)&0xFF) +
           ((data>>16)&0xFF) +
           ((data>>8)&0xFF) +
           (data&0xFF))
        s&=0xFF
        cs= ((~s) +1)&0xFF
        return cs
    address=start_address
    for c in range(num_chunks):
        chunk=bin_input[c*4:(c+1)*4]
        data=int(chunk[0]) + (int(chunk[1])<<8) + (int(chunk[2])<<16) + (int(chunk[3])<<24)
        cs=check_sum(address,data)
        lines.append(line.format(address=address,data=data,cs=cs))
        address+=1
    #end of file
    lines.append(":00000001FF")
    return "\n".join(lines)


if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('-a','--address',default="0x0");
    parser.add_argument('-o','--output')
    parser.add_argument('bin_file')


    args=parser.parse_args()
    if "0x" in args.address:
        start_address=int(args.address,16)
    else:
        start_address=int(args.address,10)
    bin_input=open(args.bin_file).read()
    hex_out=bin2hex(bin_input,start_address)

    if args.output:
        open(args.output,"w").write(hex_out)
    else:
        sys.stdout.write(hex_out)
