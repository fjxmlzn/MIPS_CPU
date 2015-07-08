#pragma once

#include <string>
#include <vector>

using namespace std;

struct tagPARAM
{
	string key;
	string value;
};

class CmdProcessor
{
public:
    bool skip;

	CmdProcessor(void);
	~CmdProcessor(void);

	static void ClearHSpace(string &cmd);
	static bool GetValue(string key, vector<tagPARAM> param, string &value);

	virtual bool ReadCommand(string cmd);
	virtual bool ProcessCommand(string priorCmd, vector<tagPARAM> param, string left) = 0;
};

