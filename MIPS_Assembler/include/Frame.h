#ifndef FRAME_H
#define FRAME_H

#include "CmdProcessor.h"
#include "ErrorHandler.h"
#include "Assembler.h"

class Frame: public CmdProcessor
{
public:
	bool running;
	ErrorHandler *errorHandler;
	Assembler *assembler;

	Frame();
	~Frame(void);

	virtual bool ProcessCommand(string priorCmd, vector<tagPARAM> param, string left);

	void Run(int argc,char *argv[]);
};

#endif // FRAME_H
