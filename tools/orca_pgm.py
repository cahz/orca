import os
import getopt
import subprocess
import sys
import binascii


def script_usage(script_name):
    print 'Usage: {} program_file [--base_address=] [--reset_address=]'.format(script_name)
    print
    print 'program_file the bin file you wish to program.'
    print '[--base_address=<base_address>] the starting address of the code in ORCA\'s memory.'
    print '[--reset_address=<reset_address>] the address of the memory-mapped reset signal.'

if __name__ == '__main__':

    if len(sys.argv) < 2:
       script_usage(sys.argv[0])
       sys.exit(2) 

    program_file = sys.argv[1]

    try:
        opts, args = getopt.getopt(sys.argv[2:], '', ['base_address=', 'reset_address='])
    except getopt.GetoptError:
        script_usage(sys.argv[0])
        sys.exit(2)
	
    base_address = 0x00000000
    reset_address = 0x10000000	

    for o, a in opts:
        if o == '--base_address':
            base_address = a  
        elif o == '--reset_address':
            reset_address = a
        else:
            print 'Error: Unrecognized option {}'.format(o)
            sys.exit(2)

    script_name = 'jtag_init.tcl'
    tcl_script = open(script_name, 'w')
    tcl_script.write('set jtag_master [lindex [get_service_paths master] 0]\n')
    tcl_script.write('open_service master $jtag_master\n')
    tcl_script.write('master_write_32 $jtag_master %#010x %#010x\n' % (reset_address, 1))
    bin_file = open(program_file, 'rb') 

    while 1:
        word = bin_file.read(4)
        if word == '':
            break
        else:
            word = int(binascii.hexlify(word), 16)
            little_endian_word = 0
            little_endian_word |= ((word & 0xff000000) >> 24)
            little_endian_word |= ((word & 0x00ff0000) >> 8)
            little_endian_word |= ((word & 0x0000ff00) << 8)
            little_endian_word |= ((word & 0x000000ff) << 24)
            tcl_script.write('lappend values %#010x\n' % little_endian_word) 

    tcl_script.write('master_write_32 $jtag_master %#010x $values\n' % base_address)
    tcl_script.write('master_write_32 $jtag_master %#010x %#010x\n' % (reset_address, 0))
    tcl_script.write('close_service master $jtag_master\n')

    tcl_script.close()
    bin_file.close()

    system_console = '/nfs/opt/altera/15.1/quartus/sopc_builder/bin/system-console' 
    subprocess.Popen('{} --cli --script={}'.format(system_console, script_name), shell=True).wait()
