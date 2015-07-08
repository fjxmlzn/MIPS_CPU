#include "Frame.h"
#include <iostream>

using namespace std;

Frame::Frame()
{
    skip = true;
    errorHandler = new ErrorHandler();
    assembler = new Assembler(errorHandler);
}


Frame::~Frame(void)
{
    if (errorHandler != NULL)
    {
        delete errorHandler;
        errorHandler = NULL;
    }
    if (assembler != NULL)
    {
        delete assembler;
        assembler = NULL;
    }
}

bool Frame::ProcessCommand(string priorCmd, vector<tagPARAM> param, string left)
{
    return assembler->ReadCommand(left);
}

void Frame::Run(int argc,char *argv[])
{
    if (argc == 1)
    {
        cout<<"MIPS Assembler [Version 0.1.0]"<<endl<<"Copyright (c) 2015 Terry Lin, Xueyue Zhang, Xingyu Jin. All rights reserved."<<endl<<endl;
        running = true;
        while (running)
        {
            cout << '>';
            string cmd;
            getline(cin, cmd);
            ReadCommand(cmd);
            cout << endl;
        }
    }
    else
    {
        string tmpCmd = "ass ";
        for (int i = 1; i < argc; i++)
        {
            tmpCmd = tmpCmd + argv[i] + ' ';
        }
        ReadCommand(tmpCmd);
    }
}
