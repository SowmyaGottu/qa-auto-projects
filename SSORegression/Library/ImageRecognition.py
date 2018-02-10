import pyscreeze
import os

def Verify_Dashboard_Icon(Haystack, Needle):
    print "Needle: " + Needle
    print "Haystack: " + Haystack
    
    result = pyscreeze.locate( Needle, Haystack )
    
    print "Result: " + str(result)

    if result is not None:
        return True
    else:
        return False

if __name__ == '__main__':
    Verify_Dashboard_Icon('C:\SSORegression\Resources\..\TempImages\TEtm7zWt.png','C:\SSORegression\Images\UnsubmittedExpenses.png')