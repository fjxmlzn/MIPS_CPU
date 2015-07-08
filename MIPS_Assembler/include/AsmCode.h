#ifndef ASMCODE_H
#define ASMCODE_H

#include <string>
#include <vector>

using std::string;
using std::vector;

enum ASM_TYPE
{
    ASM_TYPE_COMMENT, ASM_TYPE_SOURCE, ASM_TYPE_LABEL
};


class AsmCode
{
public:
    AsmCode();
    virtual ~AsmCode();

    ASM_TYPE asmType;
    string key;
    vector<string> param;
    unsigned int lineNum;
};

#endif // ASMCODE_H
