#include "MipsInstructionList.h"

const map<string, unsigned int> MipsOpcodeList =
{
    {"nop",     0x00},
    {"lw",      0x23},
    {"sw",      0x2b},
    {"lui",     0x0f},
    {"add",     0x00},
    {"addu",    0x00},
    {"sub",     0x00},
    {"subu",    0x00},
    {"addi",    0x08},
    {"addiu",   0x09},
    {"and",     0x00},
    {"or",      0x00},
    {"xor",     0x00},
    {"nor",     0x00},
    {"andi",    0x0c},
    {"sll",     0x00},
    {"srl",     0x00},
    {"sra",     0x00},
    {"slt",     0x00},
    {"slti",    0x0a},
    {"sltiu",   0x0b},
    {"beq",     0x04},
    {"bne",     0x05},
    {"blez",    0x06},
    {"bgtz",    0x07},
    {"bgez",    0x01},
    {"j",       0x02},
    {"jal",     0x03},
    {"jr",      0x00},
    {"jalr",    0x00}
};

const map<string, unsigned int> MipsFunctList =
{
    {"nop",     0x00},
    {"add",     0x20},
    {"addu",    0x21},
    {"sub",     0x22},
    {"subu",    0x23},
    {"and",     0x24},
    {"or",      0x25},
    {"xor",     0x26},
    {"nor",     0x27},
    {"sll",     0x00},
    {"srl",     0x02},
    {"sra",     0x03},
    {"slt",     0x2a},
    {"jr",      0x08},
    {"jalr",    0x09}
};

const map<string, unsigned int> MipsRegisterList =
{
    {"$zero",   0x00},
    {"$at",     0x01},
    {"$v0",     0x02},
    {"$v1",     0x03},
    {"$a0",     0x04},
    {"$a1",     0x05},
    {"$a2",     0x06},
    {"$a3",     0x07},
    {"$t0",     0x08},
    {"$t1",     0x09},
    {"$t2",     0x0A},
    {"$t3",     0x0B},
    {"$t4",     0x0C},
    {"$t5",     0x0D},
    {"$t6",     0x0E},
    {"$t7",     0x0F},
    {"$s0",     0x10},
    {"$s1",     0x11},
    {"$s2",     0x12},
    {"$s3",     0x13},
    {"$s4",     0x14},
    {"$s5",     0x15},
    {"$s6",     0x16},
    {"$s7",     0x17},
    {"$t8",     0x18},
    {"$t9",     0x19},
    {"$k0",     0x1A},
    {"$k1",     0x1B},
    {"$gp",     0x1C},
    {"$sp",     0x1D},
    {"$fp",     0x1E},
    {"$ra",     0x1F},
    {"$0",      0x00},
    {"$1",      0x01},
    {"$2",      0x02},
    {"$3",      0x03},
    {"$4",      0x04},
    {"$5",      0x05},
    {"$6",      0x06},
    {"$7",      0x07},
    {"$8",      0x08},
    {"$9",      0x09},
    {"$10",     0x0A},
    {"$11",     0x0B},
    {"$12",     0x0C},
    {"$13",     0x0D},
    {"$14",     0x0E},
    {"$15",     0x0F},
    {"$16",     0x10},
    {"$17",     0x11},
    {"$18",     0x12},
    {"$19",     0x13},
    {"$20",     0x14},
    {"$21",     0x15},
    {"$22",     0x16},
    {"$23",     0x17},
    {"$24",     0x18},
    {"$25",     0x19},
    {"$26",     0x1A},
    {"$27",     0x1B},
    {"$28",     0x1C},
    {"$29",     0x1D},
    {"$30",     0x1E},
    {"$31",     0x1F},
};
