#include "MipsCode.h"

MipsCode::MipsCode()
{
    //ctor
}

MipsCode::~MipsCode()
{
    //dtor
}

void MipsCode::InitRType(unsigned int address, unsigned int opcode,
                         unsigned int rs, unsigned int rt, unsigned int rd, unsigned int shamt, unsigned int funct)
{
    mipsType = MIPS_TYPE_R;
    this->address = address;
    code = (opcode & 0x0000003F) << 26;
    code |= (rs & 0x0000001F) << 21;
    code |= (rt & 0x0000001F) << 16;
    code |= (rd & 0x0000001F) << 11;
    code |= (shamt & 0x0000001F) << 6;
    code |= (funct & 0x0000003F);
}

void MipsCode::InitIType(unsigned int address, unsigned int opcode,
                         unsigned int rs, unsigned int rt, short immediate)
{
    mipsType = MIPS_TYPE_I;
    this->address = address;
    code = (opcode & 0x0000003F) << 26;
    code |= (rs & 0x0000001F) << 21;
    code |= (rt & 0x0000001F) << 16;
    code |= (0x0000FFFF & immediate);
}

void MipsCode::InitJType(unsigned int address, unsigned int opcode, unsigned int jAddress)
{
    mipsType = MIPS_TYPE_J;
    this->address = address;
    code = (opcode & 0x0000003F) << 26;
    code |= (jAddress & 0x03FFFFFFFF);
}
