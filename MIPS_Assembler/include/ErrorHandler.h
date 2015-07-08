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
};

#endif // ERRORHANDLER_H
