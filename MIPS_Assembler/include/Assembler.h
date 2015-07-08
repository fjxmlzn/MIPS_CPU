#ifndef ASSEMBLER_H
#define ASSEMBLER_H

#include <iostream>
#include <map>
#include "CmdProcessor.h"
#include "MipsCode.h"
#include "AsmCode.h"

using std::vector;

class ErrorHandler;

class Assembler: public CmdProcessor
{
public:
    ErrorHandler *errorHandler;

    Assembler(ErrorHandler *errorHandler);
    virtual ~Assembler();

    bool ProcessAssCommand(vector<tagPARAM> param, string left);

    virtual bool ProcessCommand(string priorCmd, vector<tagPARAM> param, string left);
    virtual bool ReadCommand(string cmd);

private:
    bool AssembleMain(string cfgMode, bool cfgAddress, string cfgInputPath, string cfgOutputPath);
    bool AssembleImport(string cfgInputPath, vector<string> &sourceCode);
    bool AssembleParse(vector<string> sourceCode, vector<AsmCode> &asmCode);
    bool AssembleTranslate(vector<AsmCode> asmCode, vector<MipsCode> &mipsCode);
    bool AssembleInstruction(AsmCode asmCode, unsigned int address, map<string, int> labelList, MipsCode &mipsCode);
    bool AssembleExport(string cfgMode, bool cfgAddress, string cfgOutputPath, vector<MipsCode> mipsCode);

    unsigned int GetOpcodeByKey(string key);
    unsigned int GetFunctByKey(string key);
    bool GetRegisterByParam(string param, unsigned int &reg);
    bool GetImmediateByParam(string param, int &immediate);
    bool GetRelaAddressByLabel(string label, map<string, int> labelList, unsigned int address, short &offset);
    bool GetAbsoAddressByLabel(string label, map<string, int> labelList, unsigned int address, unsigned int &target);
};

#endif // ASSEMBLER_H
