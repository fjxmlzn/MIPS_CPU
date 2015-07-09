#include "ErrorHandler.h"

using std::endl;
using std::cout;

ErrorHandler::ErrorHandler()
{
    //ctor
}

ErrorHandler::~ErrorHandler()
{
    //dtor
}

void ErrorHandler::ReportError(string errMsg)
{
    cout << "[Error]   " << errMsg << endl;
}

void ErrorHandler::ReportWarning(string errMsg)
{
    cout << "[Warning] " << errMsg << endl;
}

void ErrorHandler::ReportMessage(string msg)
{
    cout << "[Message] " << msg << endl;
}
