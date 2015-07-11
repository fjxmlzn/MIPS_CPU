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

    void ReportError(string errMsg);
    void ReportWarning(string errMsg);
    void ReportMessage(string msg);
};

#endif // ERRORHANDLER_H
