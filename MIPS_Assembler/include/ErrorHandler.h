#ifndef ERRORHANDLER_H
#define ERRORHANDLER_H

#include <iostream>
#include <string>

using std::string;

class ErrorHandler
{
public:
    ErrorHandler();
    virtual ~ErrorHandler();

    virtual void ReportError(string errMsg);
    virtual void ReportWarning(string errMsg);
    virtual void ReportMessage(string msg);
};

#endif // ERRORHANDLER_H
