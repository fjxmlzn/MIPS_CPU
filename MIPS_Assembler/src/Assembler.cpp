#include <fstream>
#include <sstream>
#include <iomanip>
#include "Assembler.h"
#include "ErrorHandler.h"
#include "MipsInstructionList.h"

Assembler::Assembler(ErrorHandler *errorHandler):errorHandler(errorHandler)
{
}

Assembler::~Assembler()
{
}

bool Assembler::ProcessCommand(string priorCmd, vector<tagPARAM> param, string left)
{
	if (priorCmd == "ass")
	{
	    ProcessAssCommand(param, left);
        return true;
	}
	else
	{
	    errorHandler->ReportError(string("Unknown command: ") + priorCmd);
		return true;
	}
}

bool Assembler::ProcessAssCommand(vector<tagPARAM> param, string left)
{
    string cfgInputPath;
    if (!GetValue("i", param, cfgInputPath))
    {
        errorHandler->ReportError("Please specify the input assembly code's path USING -i");
        return false;
    }

    string cfgOutputPath;
    if (!GetValue("o", param, cfgOutputPath))
    {
        errorHandler->ReportError("Please specify the output machine code's path USING -o");
        return false;
    }

    string cfgMode;
    if (!GetValue("m", param, cfgMode)
     || !(cfgMode == "bin" || cfgMode == "ver" || cfgMode == "hex"))
    {
        errorHandler->ReportWarning("Using default mode -m ver");
        cfgMode = "ver";
    }

    string tmpString;
    bool cfgAddress = GetValue("ad", param, tmpString);

    return AssembleMain(cfgMode, cfgAddress, cfgInputPath, cfgOutputPath);
}

bool Assembler::ReadCommand(string cmd)
{
    if (!CmdProcessor::ReadCommand(cmd))
    {
        errorHandler->ReportError("Fail to parse command");
        return false;
    }
    return true;
}

bool Assembler::AssembleMain(string cfgMode, bool cfgAddress, string cfgInputPath, string cfgOutputPath)
{
    vector<string> sourceCode;
    if (!AssembleImport(cfgInputPath, sourceCode)) return false;

    vector<AsmCode> asmCode;
    if (!AssembleParse(sourceCode, asmCode)) return false;

    vector<MipsCode> mipsCode;
    if (!AssembleTranslate(asmCode, mipsCode)) return false;

    if (!AssembleExport(cfgMode, cfgAddress, cfgOutputPath, mipsCode)) return false;
    return true;
}

bool Assembler::AssembleImport(string cfgInputPath, vector<string> &sourceCode)
{
    sourceCode.clear();
    ifstream inputFile(cfgInputPath.c_str());
    if (!inputFile)
    {
        errorHandler->ReportError("Could not open the input file!");
        return false;
    }
    while (!inputFile.eof())
    {
        string tmpString;
        getline(inputFile, tmpString);
        sourceCode.push_back(tmpString);
    }
    inputFile.close();
    return true;
}

bool Assembler::AssembleParse(vector<string> sourceCode, vector<AsmCode> &asmCode)
{
    asmCode.clear();

    for (unsigned int i = 0; i < sourceCode.size(); i++)
    {
        stringstream tmpSStream(sourceCode[i]);
        string tmpS;
        vector<string> tokens;
        while(tmpSStream >> tmpS)
        {
            unsigned int nComma = tmpS.find(',');
            while ((nComma = tmpS.find(',')) != string::npos)
            {
                if (nComma != 0)
                {
                    string tmpS2 = tmpS.substr(0, nComma);
                    tokens.push_back(tmpS2);
                }
                tmpS.erase(0, nComma+1);
                tokens.push_back(",");
            }
            if (tmpS != "") tokens.push_back(tmpS);
        }

        while (true)
        {
            AsmCode tmpAsmCode;
            tmpAsmCode.lineNum = i+1;
            if (tokens.size() == 0 || tokens[0][0] == '#')  //comment
            {
                break;
            }
            else if (tokens[0][tokens[0].size()-1] == ':')
            {
                tmpAsmCode.asmType = ASM_TYPE_LABEL;
                tmpAsmCode.key = tokens[0].substr(0, tokens[0].size()-1);
                asmCode.push_back(tmpAsmCode);
                tokens.erase(tokens.begin());
            }
            else
            {
                tmpAsmCode.asmType = ASM_TYPE_SOURCE;
                tmpAsmCode.key = tokens[0];
                bool bSplit = true;
                bool bStart = false;
                for (unsigned int j = 1; j < tokens.size(); j++)
                {
                    if (tokens[j][0] == '#') break;
                    bStart = true;
                    if (tokens[j] == ",")
                    {
                        if (bSplit)
                        {
                            stringstream tmpSStream;
                            tmpSStream << "Parse error on line " << i+1 << ": " << tokens[j];
                            errorHandler->ReportError(tmpSStream.str());
                            return false;
                        }
                        else
                        {
                            bSplit = true;
                        }
                    }
                    else
                    {
                        if (!bSplit)
                        {
                            stringstream tmpSStream;
                            tmpSStream << "Parse error on line " << i+1 << ": " << tokens[j];
                            errorHandler->ReportError(tmpSStream.str());
                            return false;
                        }
                        else
                        {
                            tmpAsmCode.param.push_back(tokens[j]);
                            bSplit = false;
                        }
                    }
                }
                if (bSplit && bStart)
                {
                    stringstream tmpSStream;
                    tmpSStream << "Parse error on line " << i+1 << ": " << tokens[tokens.size()-1];
                    errorHandler->ReportError(tmpSStream.str());
                    return false;
                }
                asmCode.push_back(tmpAsmCode);
                break;
            }
        }
    }
    return true;
}

bool Assembler::AssembleTranslate(vector<AsmCode> asmCode, vector<MipsCode> &mipsCode)
{
    mipsCode.clear();
    map<string, int> labelList;
    unsigned int address = 0;
    for (unsigned int i = 0; i < asmCode.size(); i++)
    {
        if (asmCode[i].asmType == ASM_TYPE_LABEL)
        {
            if (labelList.find(asmCode[i].key) != labelList.end())
            {
                stringstream tmpSStream;
                tmpSStream << "Redefined label on line " << asmCode[i].lineNum << ": " << asmCode[i].key;
                errorHandler->ReportError(tmpSStream.str());
                return false;
            }
            labelList[asmCode[i].key] = address;
        }
        else if (asmCode[i].asmType == ASM_TYPE_SOURCE)
        {
            address += 4;
        }
    }

    address = 0;
    for (unsigned int i = 0; i < asmCode.size(); i++)
    {
        if (asmCode[i].asmType == ASM_TYPE_SOURCE)
        {
            MipsCode tmpMipsCode;
            if (!AssembleInstruction(asmCode[i], address, labelList, tmpMipsCode))
            {
                stringstream tmpSStream;
                tmpSStream << "Fail to translate on the line " << asmCode[i].lineNum;
                errorHandler->ReportError(tmpSStream.str());
                return false;
            }
            else
                mipsCode.push_back(tmpMipsCode);
            address += 4;
        }
    }

    return true;
}

bool Assembler::AssembleInstruction(AsmCode asmCode, unsigned int address, map<string, int> labelList, MipsCode &mipsCode)
{
    if (asmCode.key == "lw" || asmCode.key == "sw")
    {
        if (asmCode.param.size() != 3) return false;
        unsigned int opcode, rt, rs;
        int offset;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rt)) return false;
        if (!GetImmediateByParam(asmCode.param[1], offset)) return false;
        if (!GetRegisterByParam(asmCode.param[2], rs)) return false;
        mipsCode.InitIType(address, opcode, rs, rt, offset);
    }
    else if (asmCode.key == "lui")
    {
        if (asmCode.param.size() != 2) return false;
        unsigned int opcode, rt;
        int immediate;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rt)) return false;
        if (!GetImmediateByParam(asmCode.param[1], immediate)) return false;
        mipsCode.InitIType(address, opcode, 0, rt, immediate);
    }
    else if (asmCode.key == "add" || asmCode.key == "addu"
          || asmCode.key == "sub" || asmCode.key == "subu"
          || asmCode.key == "and" || asmCode.key == "or"
          || asmCode.key == "xor" || asmCode.key == "nor"
          || asmCode.key == "slt")
    {
        if (asmCode.param.size() != 3) return false;
        unsigned int opcode, rd, rs, rt, funct;
        opcode = GetOpcodeByKey(asmCode.key);
        funct = GetFunctByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rd)) return false;
        if (!GetRegisterByParam(asmCode.param[1], rs)) return false;
        if (!GetRegisterByParam(asmCode.param[2], rt)) return false;
        mipsCode.InitRType(address, opcode, rs, rt, rd, 0, funct);
    }
    else if (asmCode.key == "sll" || asmCode.key == "srl"
          || asmCode.key == "sra")
    {
        if (asmCode.param.size() != 3) return false;
        unsigned int opcode, rd, rt, funct;
        int shamt;
        opcode = GetOpcodeByKey(asmCode.key);
        funct = GetFunctByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rd)) return false;
        if (!GetRegisterByParam(asmCode.param[1], rt)) return false;
        if (!GetImmediateByParam(asmCode.param[2], shamt)) return false;
        mipsCode.InitRType(address, opcode, 0, rt, rd, shamt, funct);
    }
    else if (asmCode.key == "addi" || asmCode.key == "addiu"
          || asmCode.key == "andi" || asmCode.key == "slti"
          || asmCode.key == "sltiu")
    {
        if (asmCode.param.size() != 3) return false;
        unsigned int opcode, rt, rs;
        int immediate;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rt)) return false;
        if (!GetRegisterByParam(asmCode.param[1], rs)) return false;
        if (!GetImmediateByParam(asmCode.param[2], immediate)) return false;
        mipsCode.InitIType(address, opcode, rs, rt, immediate);
    }
    else if (asmCode.key == "beq" || asmCode.key == "bne")
    {
        if (asmCode.param.size() != 3) return false;
        unsigned int opcode, rs, rt;
        short offset;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rs)) return false;
        if (!GetRegisterByParam(asmCode.param[1], rt)) return false;
        if (!GetRelaAddressByLabel(asmCode.param[2], labelList, address, offset)) return false;
        mipsCode.InitIType(address, opcode, rs, rt, offset);
    }
    else if (asmCode.key == "blez" || asmCode.key == "bgtz"
          || asmCode.key == "bgez")
    {
        if (asmCode.param.size() != 2) return false;
        unsigned int opcode, rs;
        short offset;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rs)) return false;
        if (!GetRelaAddressByLabel(asmCode.param[1], labelList, address, offset)) return false;
        mipsCode.InitIType(address, opcode, rs, 0, offset);
    }
    else if (asmCode.key == "j" || asmCode.key == "jal")
    {
        if (asmCode.param.size() != 1) return false;
        unsigned int opcode;
        unsigned int target;
        opcode = GetOpcodeByKey(asmCode.key);
        if (!GetAbsoAddressByLabel(asmCode.param[0], labelList, address, target)) return false;
        mipsCode.InitJType(address, opcode, target);
    }
    else if (asmCode.key == "jr")
    {
        if (asmCode.param.size() != 1) return false;
        unsigned int opcode, rs, funct;
        opcode = GetOpcodeByKey(asmCode.key);
        funct = GetFunctByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rs)) return false;
        mipsCode.InitRType(address, opcode, rs, 0, 0, 0, funct);
    }
    else if (asmCode.key == "jalr")
    {
        if (asmCode.param.size() != 2) return false;
        unsigned int opcode, rd, rs, funct;
        opcode = GetOpcodeByKey(asmCode.key);
        funct = GetFunctByKey(asmCode.key);
        if (!GetRegisterByParam(asmCode.param[0], rd)) return false;
        if (!GetRegisterByParam(asmCode.param[1], rs)) return false;
        mipsCode.InitRType(address, opcode, rs, 0, rd, 0, funct);
    }
    else if (asmCode.key == "nop")
    {
        if (asmCode.param.size() != 0) return false;
        mipsCode.InitRType(0, 0, 0, 0, 0, 0, 0);
    }
    else
    {
        /*
        stringstream tmpSStream;
        tmpSStream << "Unknown instruction on line " << asmCode.lineNum << ": " << asmCode.key;
        errorHandler->ReportError(tmpSStream.str());
        */
        return false;
    }
    return true;
}

bool Assembler::AssembleExport(string cfgMode, bool cfgAddress, string cfgOutputPath, vector<MipsCode> mipsCode)
{
    ofstream outputFile;
    if (cfgMode == "bin")
        outputFile.open(cfgOutputPath.c_str(), ios_base::out | ios_base::binary);
    else
        outputFile.open(cfgOutputPath.c_str(), ios_base::out);
    if (!outputFile)
    {
        errorHandler->ReportError("Could not save to the output file!");
        return false;
    }

    for (unsigned int i = 0; i < mipsCode.size(); i++)
    {
        if (cfgAddress && !(cfgMode == "bin")) outputFile << "0x" << hex << setw(8) << setfill('0') << mipsCode[i].address << ": ";
        if (cfgMode == "hex")
            outputFile << "0x" << hex << setw(8) << setfill('0') << mipsCode[i].code << endl;
        else if (cfgMode == "ver")
            outputFile << "32'h" << hex << setw(8) << setfill('0') << mipsCode[i].code << endl;
        else
            outputFile.write(reinterpret_cast<const char*>(&mipsCode[i].code), sizeof(mipsCode[i].code));
    }
    outputFile.close();
    return true;
}

unsigned int Assembler::GetOpcodeByKey(string key)
{
    auto it = MipsOpcodeList.find(key);
    if (it == MipsOpcodeList.end())
    {
        errorHandler->ReportError("Internal error!");
        return -1;
    }
    else
    {
        return it->second;
    }
}

unsigned int Assembler::GetFunctByKey(string key)
{
    auto it = MipsFunctList.find(key);
    if (it == MipsFunctList.end())
    {
        errorHandler->ReportError("Internal error!");
        return -1;
    }
    else
    {
        return it->second;
    }
}

bool Assembler::GetRegisterByParam(string param, unsigned int &reg)
{
    auto it = MipsRegisterList.find(param);
    if (it == MipsRegisterList.end())
    {
        return false;
    }
    else
    {
        reg = it->second;
        return true;
    }
}

bool Assembler::GetImmediateByParam(string param, int &immediate)
{
    stringstream tmpSStream(param);
    if (param.size() >= 2 &&  param[0] == '0' && (param[1] == 'x' || param[1] == 'X'))
    {
        if (!(tmpSStream >> hex >> immediate)) return false;
    }
    else
    {
        if (!(tmpSStream >> dec >> immediate)) return false;
    }
    return true;
}

bool Assembler::GetRelaAddressByLabel(string label, map<string, int> labelList, unsigned int address, short &offset)
{
    address += 4;
    auto it = labelList.find(label);
    if (it == labelList.end()) return false;
    int tmpOffset = it->second - address;
    offset = tmpOffset >> 2;
    return true;
}

bool Assembler::GetAbsoAddressByLabel(string label, map<string, int> labelList, unsigned int address, unsigned int &target)
{
    auto it = labelList.find(label);
    if (it == labelList.end()) return false;
    target = it->second >> 2;
    return true;
}
