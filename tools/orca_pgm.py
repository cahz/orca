import os
import getopt
import subprocess
import sys
import binascii


def script_usage(script_name):
    print 'Usage: {} program_file [--base_address=] [--reset_address=]'.format(script_name)
    print '[--device=] [--project_file=] [--output_file=]'
    print
    print 'program_file the bin file you wish to program.'
    print '[--family=<family_name>] the name of the target fpga family.'
    print 'Currently altera and xilinx are the only families supported.'
    print '[--base_address=<base_address>] the starting address of the code in ORCA\'s memory.'
    print '[--reset_address=<reset_address>] the address of the memory-mapped reset signal.'
    print '[--end_address=<end_address>] the address of the end of memory.'
    print '[--device=<device_number>] the target device number (xilinx specific)'
    print '[--project_file=<project_file>] the project file to open (xilinx specific)'
    print '[--debug_nets=<nets_file>] the debug netlist file for connecting to ILAs and JTAG (xilinx specific)'
    print '[--output_file=<output_file>] the output jtag file name'

if __name__ == '__main__':

    if len(sys.argv) < 2:
        script_usage(sys.argv[0])
        sys.exit(2)

    program_file = sys.argv[1]

    try:
        opts, args = getopt.getopt(sys.argv[2:], '', ['family=', 'base_address=', 'reset_address=', 'device=', 'project_file=', 'end_address=', 'debug_nets=', 'output_file='])
    except getopt.GetoptError:
        script_usage(sys.argv[0])
        sys.exit(2)

    base_address = 0x00000000
    reset_address = 0x10000000
    end_address = 0x00010000
    family = 'altera'
    device = 'xc7z*'
    project_file = 'project/project.xpr'
    debug_nets = 'project/project.runs/impl_1/debug_nets.ltx'
    output_file = 'jtag_init.tcl'

    for o, a in opts:
        if o == '--base_address':
            if ('0x' in a) or ('0X' in a):
                base_address = int(a, 16)
            else:
                base_address = int(a)
        elif o == '--reset_address':
            if ('0x' in a) or ('0X' in a):
                reset_address = int(a, 16)
            else:
                reset_address = int(a)
        elif o == '--end_address':
            if ('0x' in a) or ('0X' in a):
                end_address = int(a, 16)
            else:
                end_address = int(a)
        elif o == '--family':
            family = a
        elif o == '--device':
            device = a
        elif o == '--project_file':
            project_file = a
        elif o == '--debug_nets':
            debug_nets = a
        elif o == '--output_file':
            output_file = a
        else:
            print 'Error: Unrecognized option {}'.format(o)
            sys.exit(2)

    if family == 'altera':
        script_name = output_file
        tcl_script = open(script_name, 'w')
        tcl_script.write('set jtag_master [lindex [get_service_paths master] 0]\n')
        tcl_script.write('open_service master $jtag_master\n')
        tcl_script.write('master_write_32 $jtag_master %#010x %#010x\n' % (reset_address, 1))
        bin_file = open(program_file, 'rb')

        current_address = base_address
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
                current_address += 4

        # Write over the rest of remaining memory with zeroes.
        for i in range(current_address, end_address, 4):
            tcl_script.write('lappend values %#010x\n' % 0x00000000)

        tcl_script.write('master_write_32 $jtag_master %#010x $values\n' % base_address)
        tcl_script.write('master_write_32 $jtag_master %#010x %#010x\n' % (reset_address, 0))
        tcl_script.write('close_service master $jtag_master\n')

        bin_file.close()
        tcl_script.close()

        subprocess.Popen('system-console --cli --script={}'.format(script_name), shell=True).wait()
        print 'Done programming.'

    elif family == 'xilinx':
        BURST_LENGTH = 256
        script_name = output_file
        tcl_script = open(script_name, 'w')

        init_write_count    = 0
        file_write_count    = 0
        padding_write_count = 0
        ending_write_count  = 0

        tcl_script.write('proc orca_pgm {} {\n')
        tcl_script.write('\tset_msg_config -id "Labtoolstcl 44-481" -suppress\n')
        tcl_script.write('\topen_hw\n')
        tcl_script.write('\tconnect_hw_server\n')
        tcl_script.write('\topen_hw_target\n')
        tcl_script.write('\tset_property PROBES.FILE {{{}}} [get_hw_devices {}]\n'.format(debug_nets, device))
        tcl_script.write('\tcurrent_hw_device [get_hw_devices {}]\n'.format(device))
        tcl_script.write('\trefresh_hw_device [get_hw_devices {}]\n'.format(device))
        tcl_script.write('\treset_hw_axi [get_hw_axis]\n')
        tcl_script.write('\tcreate_hw_axi_txn init_{} [get_hw_axis hw_axi_1] -type write '.format(init_write_count))
        tcl_script.write('-address {:08x} -len 1 -data 0x00000000\n'.format(reset_address+8))
        init_write_count += 1
        tcl_script.write('\tcreate_hw_axi_txn init_{} [get_hw_axis hw_axi_1] -type write '.format(init_write_count))
        tcl_script.write('-address {:08x} -len 1 -data 0x00000000\n'.format(reset_address))
        init_write_count += 1
        tcl_script.write('\tcreate_hw_axi_txn init_{} [get_hw_axis hw_axi_1] -type write '.format(init_write_count))
        tcl_script.write('-address {:08x} -len 1 -data 0x00000001\n'.format(reset_address+8))
        init_write_count += 1

        bin_file = open(program_file, 'rb')

        current_address = base_address
        end_of_file = False
        while not end_of_file:
            data_string = ''
            for word in range(0, BURST_LENGTH):
                if not end_of_file:
                    file_data = bin_file.read(4)
                    if file_data == '':
                        file_data = '\0'
                        end_of_file = True
                        if word == 0:
                            break

                hex_data = int(binascii.hexlify(file_data), 16)
                little_endian_data = 0
                little_endian_data |= ((hex_data & 0xff000000) >> 24)
                little_endian_data |= ((hex_data & 0x00ff0000) >> 8)
                little_endian_data |= ((hex_data & 0x0000ff00) << 8)
                little_endian_data |= ((hex_data & 0x000000ff) << 24)
                if word != 0:
                    data_string = '_' + data_string
                data_string = '{:08x}'.format(little_endian_data) + data_string

            if data_string != '':
                tcl_script.write('\tcreate_hw_axi_txn file_{} [get_hw_axis hw_axi_1] -type write '.format(file_write_count))
                tcl_script.write('-address {:08x} -len {:d} -data {{'.format(current_address, BURST_LENGTH) + data_string + '}\n')
                file_write_count += 1
                current_address += 4*BURST_LENGTH

        if current_address > end_address:
            print 'Error: file length of {:d} bytes is greater than the size of instruction memory ({:d} bytes).'.format(current_address-base_address, end_address-base_address)
            sys.exit(2)

        file_end_address = current_address
        while current_address < end_address:
            tcl_script.write('\tcreate_hw_axi_txn padding_{} [get_hw_axis hw_axi_1] -type write '.format(padding_write_count))
            tcl_script.write('-address {:08x} -len {:d}\n'.format(current_address, BURST_LENGTH))
            padding_write_count += 1
            current_address += 4*BURST_LENGTH

        tcl_script.write('\tcreate_hw_axi_txn ending_{} [get_hw_axis hw_axi_1] -type write '.format(ending_write_count))
        tcl_script.write('-address {:08x} -len 1 -data 0x00000001\n'.format(reset_address))
        ending_write_count += 1

        tcl_script.write('\tputs "Resetting system..."\n')
        for i in range(0, init_write_count):
            tcl_script.write('\trun_hw_axi init_{}\n'.format(i))

        tcl_script.write('\tputs "Writing {:d} bytes from input file to {:08X}..."\n'.format(file_end_address-base_address, base_address))
        for i in range(0, file_write_count):
            tcl_script.write('\trun_hw_axi file_{}\n'.format(i))
        if file_end_address < end_address:
            tcl_script.write('\tputs "Writing {:d} bytes of 0 to the rest of instruction memory ({:08X} to {:08X})..."\n'.format(end_address-file_end_address, file_end_address, end_address))
        for i in range(0, padding_write_count):
            tcl_script.write('\trun_hw_axi padding_{}\n'.format(i))

        tcl_script.write('\tputs "Clearing resets..."\n')
        for i in range(0, ending_write_count):
            tcl_script.write('\trun_hw_axi ending_{}\n'.format(i))

        tcl_script.write('\tputs "Done."\n')

        tcl_script.write('\tclose_hw\n')
        tcl_script.write('}\n')
        tcl_script.write('orca_pgm\n')

        bin_file.close()
        tcl_script.close()

        vivado_cmd = 'vivado -mode batch -nolog -nojournal -notrace'
        tcl_src = tcl_script.name
        cmd = '{} -source {}'.format(vivado_cmd, tcl_src)
        subprocess.Popen(cmd, shell=True).wait()

    else:
        print 'Error: {} is not a supported family.'.format(family)
