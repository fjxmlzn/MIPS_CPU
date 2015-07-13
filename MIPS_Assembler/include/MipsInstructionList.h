#ifndef MIPSINSTRUCTIONLIST_H_INCLUDED
#define MIPSINSTRUCTIONLIST_H_INCLUDED

#include <map>
#include <string>
#include <vector>

using std::map;
using std::string;
using std::vector;

extern const map<string, unsigned int> MipsOpcodeList;
extern const map<string, unsigned int> MipsFunctList;
extern const map<string, unsigned int> MipsRegisterList;
extern const vector<string> instructionRegexList;
extern const string commentRegex;
extern const string labelRegex;
extern const string blankRegex;

#endif // MIPSINSTRUCTIONLIST_H_INCLUDED
