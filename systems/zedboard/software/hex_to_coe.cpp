#include <iostream>

#include <iostream>
#include <fstream>
#include <assert.h>
#include <cstdlib>
#include <string>

#define MAX_ADDRESS 0x7FFFF
#define BUFFER_SIZE (MAX_ADDRESS+1)

using namespace std;
int main() {
  ifstream fin;     // declare stream variable name
  ofstream fout;
  string line;
  char output[9];	// 8 chars + termination
  /* These could be inputs */

  long max_address = MAX_ADDRESS; // 512kB
  unsigned char default_value = 0;

  unsigned char buffer[BUFFER_SIZE];
  unsigned char byte_count;

  char * p;

  long i;
  int j;
  int k;
  long address;
  long address_offset = 0;

  for (i = 0; i <= max_address; i++) {
    buffer[i] = default_value;
  }

  fin.open("test.hex", ios::in);    // open file
  assert (!fin.fail());
  getline(fin, line);
  while (!fin.eof()) {     //if not at end of file, continue reading numbers
    cout << line << endl;
		switch (line[8]) {
			case '0': {
				/* This is data */
				/* First two bytes = number of bytes in hex */
				byte_count = strtol(line.substr(1,2).c_str(), &p, 16);
				/* check address */
				address = address_offset + strtol(line.substr(3,4).c_str(), &p, 16);
				if (address <= max_address) {
					for (i = 0; i < byte_count; i++) {
						buffer[address + i] = strtol(line.substr(9+i*2,2).c_str(), &p, 16);
					}
				}
				else {
					cout << "Invalid Address" << endl;
					assert(1);
				}
				break;
			}
			case '1': {
				cout << "File complete." << endl;
				break;
			}
      case '2': {
        address_offset = strtol(line.substr(9,4).c_str(), &p, 16) << 4;
        cout << "New segment address = " << line.substr(9,4) << endl;
        break;
      }
			case '4': {
				address_offset = strtol(line.substr(9,4).c_str(), &p, 16);
				cout << "New high address = " << line.substr(9,4) << endl;
				break;
			}
			default: {
				cout << "Invalid line in hex file." << endl;
				assert(1);
				break;
			}
    } 
		getline(fin, line);
  }
  fin.close();       //close file
  /* Now genereate coe file from buffer */
  fout.open("test.coe", ios::out);
  //fout << "; COE File Generated from filename.hex" << endl;
  //fout << "memory_initialization_radix=16;" << endl;
  //fout << "memory_initialization_vector=" << endl;
	i = 0;
	while (i <= max_address) {
		//for (j= 0; j < 32; j++)
    for (j = 0; j < 32; j += 4) {
      sprintf((char*) &output, "%02X%02X%02X%02X", buffer[i+j+3], buffer[i+j+2], buffer[i+j+1], buffer[i+j]);
      fout << output << " ";
    }
    fout << endl;
    i = i + 32;
  }

  fout.close();
}
