#ifndef MIPSINSTRUCTIONLIST_H_INCLUDED
#define MIPSINSTRUCTIONLIST_H_INCLUDED

#include <map>
#include <string>

using std::map;
using std::string;

extern const map<string, unsigned int> MipsOpcodeList;
extern const map<string, unsigned int> MipsFunctList;
extern const map<string, unsigned int> MipsRegisterList;

#endif // MIPSINSTRUCTIONLIST_H_INCLUDED
