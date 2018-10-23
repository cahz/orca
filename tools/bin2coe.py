
def bin2coe(input_bin):
    import struct
    i=open(input_bin).read()
    o="memory_initialization_radix=16;\nmemory_initialization_vector="

    int_list=struct.unpack("<"+"i"*(len(i)/4),i)
    return o+",\n".join([ "{:08x}".format(w) for w in int_list])


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("input_bin")
    parser.add_argument("--output",'-o')
    args=parser.parse_args()
    out=bin2coe(args.input_bin)
    if args.output:
        of=open(args.output,"w")
    else:
        of=sys.stdout
    of.write(out)
