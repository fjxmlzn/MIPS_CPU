#ifndef MIPSCODE_H
#define MIPSCODE_H

#include <iostream>
#include <string>
#include <vector>

using std::vector;
using std::string;

enum MIPS_TYPE
{
    MIPS_TYPE_R, MIPS_TYPE_I, MIPS_TYPE_J
};

class MipsCode
{
public:
    MipsCode();
    virtual ~MipsCode();

    void InitRType(unsigned int address, unsigned int opcode,
                   unsigned int rs, unsigned int rt, unsigned int rd, unsigned int shamt, unsigned int funct);
    void InitIType(unsigned int address, unsigned int opcode,
                   unsigned int rs, unsigned int rt, short immediate);
    void InitJType(unsigned int address, unsigned int opcode, unsigned int jAaddress);

    MIPS_TYPE mipsType;
    unsigned int address;
    unsigned int code;
};

#endif // MIPSCODE_H
