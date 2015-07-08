#include "CmdProcessor.h"


CmdProcessor::CmdProcessor(void):skip(false)
{
}


CmdProcessor::~CmdProcessor(void)
{
}

void CmdProcessor::ClearHSpace(string &cmd)
{
	while (cmd[0] == ' ')
		cmd.erase(0, 1);
}

bool CmdProcessor::ReadCommand(string cmd)
{
	vector<tagPARAM> param;
    if (skip)
    {
        return ProcessCommand("", param, cmd);
    }
    else
    {
        unsigned int pSpace = cmd.find(' ');
        unsigned int pDot = cmd.find('.');
        if (pSpace != string::npos && (pDot > pSpace || pDot == string::npos))
        {
            string priorCmd = cmd.substr(0, pSpace);
            string left = cmd.substr(pSpace + 1);
            ClearHSpace(left);
            while (left.size() != 0)
            {
                tagPARAM tempParam;
                if (left[0] != '-') return false;
                left.erase(0, 1);
                ClearHSpace(left);
                if (left.size() == 0) return false;
                unsigned int pSubSpace = left.find(' ');
                if (pSubSpace == string::npos) pSubSpace = left.size();
                tempParam.key = left.substr(0, pSubSpace);
                left.erase(0, pSubSpace + 1);
                ClearHSpace(left);

                if (left[0] != '-')
                {
                    pSubSpace = left.find(' ');
                    if (pSubSpace == string::npos) pSubSpace = left.size();
                    tempParam.value = left.substr(0, pSubSpace);
                    left.erase(0, pSubSpace + 1);
                    ClearHSpace(left);
                }
                else
                {
                    tempParam.value = "";
                }

                param.push_back(tempParam);
            }
            return ProcessCommand(priorCmd, param, "");
        }
        else if (pDot < pSpace || pSpace == string::npos)
        {
            string priorCmd = cmd.substr(0, pDot);
            string left = cmd.substr(pDot + 1);
            return ProcessCommand(priorCmd, param, left);
        }
        else
        {
            return ProcessCommand(cmd, param, "");
        }
    }
	return false;
}

bool CmdProcessor::GetValue(string key, vector<tagPARAM> param, string &value)
{
	for (unsigned int i = 0; i < param.size(); i++)
	{
		if (param[i].key == key)
		{
			value = param[i].value;
			return true;
		}
	}
	return false;
}
