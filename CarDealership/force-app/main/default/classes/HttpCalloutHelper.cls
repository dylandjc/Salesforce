/**
    @author: Dan Thoreson
    @date: 23-Aug-2022
    @description: Helper class for making callouts.
    @test class: HttpCalloutHelperTest
**/
public class HttpCalloutHelper {
    // These and the completedCallouts list are used in unit tests to verify callouts were made
    public enum Callout {
        SEND_SMS,
        SEND_SLACK_MSG
    }
    
    public static List<Callout> completedCallouts {
        get {
            if(completedCallouts == null) {
                completedCallouts = new List<Callout>();
            }
    
            return completedCallouts;
        }
    
        set;
    }    

    //SA: This gives us more freedom to control request body from outside of this class.
    public static HttpResponse makeCallout(String httpCalloutName, String requestBody, String endpoint, Map<String, String> additionalHeaders, String methodName){
        return makeCallout(httpCalloutName, requestBody, null, endpoint, additionalHeaders, methodName);
    }

    // This supports unit testing by specifying and logging the callout purpose (when one system has multiple purposes)
    public static HttpResponse makeCallout(String httpCalloutName, String requestBody, String endpoint, Map<String, String> additionalHeaders, String methodName, Callout thisCallout) {
        logCallout(httpCalloutName);
        return makeCallout(httpCalloutName, requestBody, null, endpoint, additionalHeaders, methodName);
    }    

    //RH: This gives us more freedom to control headers from outside of this class.
    public static HttpResponse makeCallout(String httpCalloutName, String requestBody, String endpoint){
        return makeCallout(httpCalloutName, requestBody, null, endpoint, new Map<String, String>(), '');
    }

    public static HttpResponse makeCallout(String httpCalloutName, String requestBody, Blob requestBodyBlob, String endpoint, Map<String, String> additionalHeaders, String methodName){
        //----Get custom metadata that host the required information to perform the callout----//
        Http_Callout__mdt httpCalloutSetting = getHttpCalloutSetting(httpCalloutName);

        if (httpCalloutSetting == null) {
            return null;
        }

        logCallout(httpCalloutName);

        //----Create a wrapper class to host the data, this makes it easier to pass to methods----//
        HttpInputParameterWrapper inputsWrapper = new HttpInputParameterWrapper(
            httpCalloutSetting,
            requestBody,
            requestBodyBlob,
            endpoint,
            additionalHeaders,
            methodName
        );

        //----Modify the input parameters based on the type of callout----//
        applyDefaults(inputsWrapper);

        //----Create a wrapper class to host the objects required for a callout----//
        HttpCalloutWrapper httpWrapper = new HttpCalloutWrapper(inputsWrapper);

        //----Prepare and set callout authorization headers from custom setting. This could be very customized for each callout, so have to be specific----//
        httpWrapper.setHeaders();
        httpWrapper.setRequestMethod();
        httpWrapper.setEndpoint();
        httpWrapper.setTimeout();
        httpWrapper.setBody();

        //----Make callout. Return the response----//
        return httpWrapper.send();
    }
    // applydefaultcars with inputswrapper and add additional header here //   TODO

    private static void applyDefaults(HttpInputParameterWrapper inputsWrapper) {
        if (inputsWrapper.httpCalloutSetting.DeveloperName == 'Slack') { // TODO - Constants
            // applySlackDefaults(inputsWrapper);  // TODO - Create method
        } else if (inputsWrapper.httpCalloutSetting.DeveloperName ==  'SMS') { // TODO - Constants
            // applySmsDefaults(inputsWrapper);  // TODO - Create method
        } else if(inputsWrapper.httpCalloutSetting.DeveloperName == 'CARS_22'){
            applyCarDefaults(inputsWrapper);
        }
    }    

    private static void applyCarDefaults(HttpInputParameterWrapper inputsWrapper){
        inputsWrapper.addAdditionalHeader('x-api-key', getToken(inputsWrapper.httpCalloutSetting));
    }

    public static String getToken(Http_Callout__mdt cm){
        return cm.Token__c;
    }

    public static Http_Callout__mdt getHttpCalloutSetting(String httpCalloutName) {
        return [
                SELECT Id, Named_Credential__c, Token__c, Method__c, Timeout__c, Endpoint__c, DeveloperName
                  FROM Http_Callout__mdt
                 WHERE DeveloperName = :httpCalloutName
                 LIMIT 1];
    }    

    /**
        @author: Dan Thoreson
        @date: 28-Aug-2020
        @description: Logs completed callout in static map, used for unit testing This helps us verify that callouts are completed under specific conditions.   
    **/    
    public static void logCallout(String calloutName) {   
        Callout thisCallout;

        // This is an example of how this would be implemented, but we don't need it. 
        // if(calloutName == 'Slack') { 
        //     thisCallout = Callout.SEND_SLACK_MSG;
        // } else if(calloutName == 'SMS') { 
        //     thisCallout = Callout.SEND_SMS;
        // }
        
        if(thisCallout != null) {
            HttpCalloutHelper.completedCallouts.add(thisCallout);
        }
    }
    
    
    public class HttpInputParameterWrapper {
        public String requestBody;
        public Blob requestBodyBlob;
        public String endpoint;
        public Map<String, String> additionalHeaders;
        public String methodName;
        public Http_Callout__mdt httpCalloutSetting;

        // Provides the ability to specify an endpoint without going to the
        // named credentials
        public Boolean provideEndpoint {get {
            if(provideEndpoint == null) {
                provideEndpoint = false;
            }
            return provideEndpoint;
        } set;}        

        public HttpInputParameterWrapper(Http_Callout__mdt httpCalloutSetting, String requestBody, Blob requestBodyBlob, String endpoint, Map<String, String> additionalHeaders, String methodName) {
            this.requestBody = requestBody;
            this.requestBodyBlob = requestBodyBlob;
            this.endpoint = endpoint;
            this.methodName = methodName;
            this.httpCalloutSetting = httpCalloutSetting;

            setAdditionalHeaders(additionalHeaders);
        }

        private void setAdditionalHeaders(Map<String, String> additionalHeaders) {
            if (additionalHeaders == null) {
                this.additionalHeaders = new Map<String, String>();
            } else {
                this.additionalHeaders = additionalHeaders;
            }
        }

        public void addAdditionalHeader(String key, String value) {
            if (!this.additionalHeaders.keySet().contains(key)) {
                this.additionalHeaders.put(key, value);
            }
        }
    }    

    public class HttpCalloutWrapper {
        public Http http  {get; set;}
        public HttpRequest req {get; set;}
        public HttpResponse res  {get; set;}
        public Http_Callout__mdt httpCalloutSetting {get; set;}
        public HttpInputParameterWrapper inputsWrapper {get; set;}

        public HttpCalloutWrapper(HttpInputParameterWrapper inputsWrapper) {
            this.http = new Http();
            this.req = new HttpRequest();
            this.res = new HttpResponse();
            this.inputsWrapper = inputsWrapper;
            this.httpCalloutSetting = inputsWrapper.httpCalloutSetting;
        }

        public void setHeaders() {
            for(String headerName : inputsWrapper.additionalHeaders.keyset()){
                String headerValueFromMap = inputsWrapper.additionalHeaders.get(headerName);
                this.req.setHeader(headerName, headerValueFromMap);
            }
        }

        public void setRequestMethod() {
            if (String.isNotBlank(inputsWrapper.methodName)) {
                this.req.setMethod(inputsWrapper.methodName);
            } else {
                this.req.setMethod(this.httpCalloutSetting.Method__c);
            }
        }

        public void setEndpoint() {
            setDefaultEndpoint();

            this.req.setEndpoint(inputsWrapper.endpoint);
        }

        public void setBody() {
            if (inputsWrapper.requestBodyBlob != null) {
                this.req.setBodyAsBlob(inputsWrapper.requestBodyBlob);
            } else if(String.isNotBlank(inputsWrapper.requestBody)) {
                this.req.setBody(inputsWrapper.requestBody);
            }
        }

        public void setTimeout() {
            if(this.httpCalloutSetting.Timeout__c != null) {
                this.req.setTimeout(Integer.ValueOf(this.httpCalloutSetting.Timeout__c));
            }
        }

        private void setEndpointFromNamedCredential() {
            String endpoint = 'callout:';

            endpoint += httpCalloutSetting.Named_Credential__c;

            if (inputsWrapper.endpoint != null) {
                endpoint += inputsWrapper.endpoint;
            }

            inputsWrapper.endpoint = endpoint;
        }

        private void setDefaultEndpoint() {
            String endpoint = '';

            if (inputsWrapper.endpoint != null) {
                endpoint += inputsWrapper.endpoint;
            }

            inputsWrapper.endpoint = endpoint;
        }

        public HttpResponse send() {
            return this.http.send(this.req);
        }
    }    
}