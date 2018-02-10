import HTTPConnection

def PostRequest(Url,Username,Password,CompanyID):
	# Make Connection Object
	test_action = "POST";
	headers = "Content-Type:application/x-www-form-urlencoded";
	parameters = "username=1144113&password=D3V5a3C3cD01T2e7sT69&ip=67.217.143.193&companyId=www.asahq.org";
	files = "";
	print "Create a connection";
	connection = HTTPConnection.HttpConnection(Url);
	print "Process Request"
	code,headers,message = connection.ProcessRequest(test_action, headers, parameters, files)
	print "Code: " + str(code)
	print "Headers: " + headers
	print "Message: " + message

def GetRequest(Url):
	test_action = "GET";
	headers = "";
	parameters = "";
	files = "";
	print "Create a connection";
	connection = HTTPConnection.HttpConnection(Url);
	print "Process Request"
	code,headers,message = connection.ProcessRequest(test_action, headers, parameters, files)
	print "Code: " + str(code)
	print "Headers: " + headers
	print "Message: " + message