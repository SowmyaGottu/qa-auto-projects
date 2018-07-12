# Custom Methods for Single Sign On Tests

def SetServerHost( Env, Interface):
    if Env == 'STAG':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "staging-app.chromeriver.com"
        else:
            return  "staging.chromeriver.com"
    elif Env == 'C4-STAG':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "staging-app.us1.chromeriver.com"
        else:
            return  "staging-pt.us1.chromeriver.com"
    elif Env == 'C4-SMOKE':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "smoke-app.us1.chromeriver.com"
        else:
            return  "smoke-pt.us1.chromeriver.com"
    elif Env == 'C4-SOTER':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "soter-app.us1.chromeriver.com"
        else:
            return  "soter-pt.us1.chromeriver.com"
    elif Env == 'QA':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "qa-app.chromeriver.com"
        else:
            return  "qa.chromeriver.com"
    elif Env == 'PROD':
        if Interface == 'JAVA' or Interface == 'MS_JAVA':
            return "app.chromeriver.com"
        else:
            return  "www.chromeriver.com"
    else:
        return "Invalid Values"

def SetPathName( TestType, Interface, Method, Override, CustomerId, AuthType):
    if Interface == "JAVA" and TestType == 'SAML':
        if Override == "PT":
            return "/login/sso/saml/platinum?CompanyID=" + CustomerId
        elif Override == "HG":
            return "/login/sso/saml/mercury?CompanyID=" + CustomerId
        else:
            return "/login/sso/saml?CompanyID=" + CustomerId
    elif Interface == "PHP" and TestType == 'SAML':
        if Override == "PT":
            return "/cr-saml/index.php?CompanyID=" + CustomerId
        elif Override == "HG":
            return "/cr-saml/index.php?CompanyID=" + CustomerId
        else:
            return "/cr-saml/index.php?CompanyID=" + CustomerId
    elif Interface == "JAVA" and TestType == "CR_SSO":
        return "/login"
    elif Interface == "PHP" and TestType == "CR_SSO":
        return "/cr-sso/test/sso-client-test.jsp"
    elif Interface == "MS_JAVA" and Method == "POST":  ## Users in BLT
        if AuthType == "EMAIL":
            return "/login/sso/saml?idp=new_post_email"
        else:
            return "/login/sso/saml?idp=new_post_uid"
    else:
        if AuthType == "EMAIL":
            return "/login/sso/saml?idp=new_get_email"
        else:
            return "/login/sso/saml?idp=new_get_uid"


def Intial_Setup( _env, _technology, _interface, _method, _override, _idpServer, _defaultApp, _auth, _server):
    # Output Variables

    CustomerId = "chromewallet.com"
    scheme = "https://"
    fullPath = ""

    if _env is None:
        _env = "STAG"

    if _method is None:
        _method = 'GET'

    if _auth == "UNIQUEID":
        CustomerId = "pbj.com"

    fullPath = scheme + SetServerHost( _env, _interface) + SetPathName( _technology, _interface, _method, _override, CustomerId, _auth)
    return fullPath
