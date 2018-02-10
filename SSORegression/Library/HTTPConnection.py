'''
@author: Kabul
Created on Mar 10, 2015
'''

'''
Example
python HTTPConnection.py HTTP POST "https://portal.asahq.org/Verify.aspx" "Content-Type:application/x-www-form-urlencoded" "username=1144113&password=D3V5a3C3cD01T2e7sT69&ip=67.217.143.193&companyId=www.asahq.org" "C:\Downloads\TEST_FILE.txt"
'''
import sys
import os
import ast
from httplib import *
from urlparse import urlparse
from urllib import *

def main( args ):
    print "Inside Main"
    test_mode = args[1]
    test_action = args[2]
    if test_mode not in ["HTTP"]:
        print "Bad Test Mode Argument! Exiting"
        sys.exit(5)
    if test_action not in ["GET","POST","PUT","DELETE"]:
        print "Bad HTTP Verb! Exiting"
        sys.exit(5)
    url = args[3]
    headers = args[4]
    parameters = args[5]
    files = args[6]
    print "Create a connection"
    connection = HttpConnection(url);
    print "Process Request"
    code,headers,message = connection.ProcessRequest(test_action, headers, parameters, files)
    print "Code: " + str(code)
    print "Headers: " + headers
    print "Message: " + message
    #print code,message
    sys.exit(0)

class HttpConnection:
    def __init__( self, url ):
        try:
            print "Check for valid URL: " + url
            o = urlparse(url)
            print "Parse Success: " + str(o)
            self.scheme = o.scheme
            self.host = o.netloc
            self.port = o.port
            if self.port is None:
                if self.scheme == 'https':
                    self.port = 443
                else:
                    self.port = 80
            else:
                if self.scheme is "":
                    if self.port != 443:
                        self.scheme = 'http'
            self.path = o.path
            print "Connecting to server: " + self.host
            if self.scheme == "https":
                self.connection = HTTPSConnection(self.host,self.port)
            else:
                self.connection = HTTPConnection(self.host,self.port)
            #return self.connection
        except Exception, e:
            print '*** Caught exception: %s: %s' % (e.__class__, e)
            sys.exit(1)
    
    def ProcessRequest( self, verb,headers, parameters, files ):
        try:
            print "Process Request"
            print "Headers:" + headers
            print "Params: " + parameters
            print "Files: " + files
            self.head = {}
            self.param = {}
            self.file = {}
            if headers != "":
                print "Process Headers Array to DICT"
                headers = headers.split(',')
                for h in headers:
                    arr = h.split(':')
                    self.head[arr[0]] = arr[1]
            
            if parameters != "":
                print "Process Parameters Array to DICT"
                parameters = parameters.split('&')
                for p in parameters:
                    arr = p.split('=')
                    self.param[arr[0]] = arr[1]
            
            if files != "":
                print "Process Files Array to DICT"
                contentType, self.param = HttpConnection.ProcessFileBody(files, parameters)
                self.head['Content-Type'] = contentType
            
            if files == "":
                self.param = urlencode(self.param)
            
            print "Headers:" + str(self.head)
            print "Params: " + str(self.param)
            connection = self.connection
            connection.connect()
            connection.request(verb,self.path,self.param,self.head)
            response = connection.getresponse()
            if response.status == 200 or response.status == 201: 
                print "Page Found Successfully, Outputting Request Body"
                response_headers = str(dict(response.getheaders())).replace('{','').replace('}','').replace("'",'').replace("'",'')
                return response.status, response_headers, response.read()
            elif response.status == 404: 
                print "Page Not Found" 
            else: 
                print response.status, None, response.reason
                return response.status, None, response.reason
            connection.close();
        except Exception, e:
            print '*** Caught exception: %s: %s' % (e.__class__, e)
            sys.exit(1)
    
    @staticmethod
    def ProcessFileBody (file_path, fields=[]):
        print "Inside ProcessFileBody"
        BOUNDARY = '----------bundary------'
        CRLF = '\r\n'
        body = []
        # Add the metadata about the upload first
        for set in fields:
            key = set.split('=')[0]
            value = set.split('=')[1]
            body.extend(
              ['--' + BOUNDARY,
               'Content-Disposition: form-data; name="%s"' % key,
               '',
               value,
               ])
        # Now add the file itself
        file_name = os.path.basename(file_path)
        f = open(file_path, 'rb')
        file_content = f.read()
        f.close()
        body.extend(
          ['--' + BOUNDARY,
           'Content-Disposition: form-data; name="file"; filename="%s"'
           % file_name,
           # The upload server determines the mime-type, no need to set it.
           'Content-Type: application/octet-stream',
           '',
           file_content,
           ])
        # Finalize the form body
        body.extend(['--' + BOUNDARY + '--', ''])
        return 'multipart/form-data; boundary=%s' % BOUNDARY, CRLF.join(body)
            
if __name__ == '__main__':
    main(sys.argv)