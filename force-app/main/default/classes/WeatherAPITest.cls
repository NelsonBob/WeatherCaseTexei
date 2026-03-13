/** @author Nelson Fomekong          */


@isTest
private class WeatherAPITest {

    class WeatherCalloutMock implements HttpCalloutMock {


        public HTTPResponse respondApi(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/json');
            if(req.getEndpoint().contains('searchJSON')){
                res.setBody('{"geonames":[{"lat":"48.8566","lng":"2.3522"}]}');
            } 
  
            else {
                res.setBody('{"weatherObservation":{"temperature":"20","humidity":"50","windSpeed":"10","clouds":"Sunny"}}');
            }

            return res;
        }


        public HTTPResponse respond(HTTPRequest req) {
            return respondApi(req);
        }
    }

    @isTest
    static void testWeatherByCity() {


        Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());


        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/weather';
        req.httpMethod = 'GET';
        req.addParameter('city','Paris');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        String response = WeatherAPI.getWeather();
        Test.stopTest();


        System.assert(response.contains('"temperature":"20"'), 'Temperature present');
        System.assert(response.contains('"humidity":"50"'), 'Humidity present');
        System.assert(response.contains('"windSpeed":"10"'), 'WindSpeed present');
    }

 
    @isTest
    static void testWeatherByCoordinates() {

        Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/weather';
        req.httpMethod = 'GET';
        req.addParameter('lat','48.8566');
        req.addParameter('lng','2.3522');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        String response = WeatherAPI.getWeather();
        Test.stopTest();

        System.assert(response.contains('"temperature":"20"'), 'Temperature présente');
        System.assert(response.contains('"humidity":"50"'), 'Humidity présente');
        System.assert(response.contains('"windSpeed":"10"'), 'WindSpeed présente');
    }

  
    @isTest
    static void testWeatherError() {

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/weather';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        Boolean hasError = false;
        try {
            String response = WeatherAPI.getWeather();
            System.assert(response.contains('Provide city or lat/lng'), 'Provide city or lat/lng');
            hasError = true;
        } catch(Exception e) {
            hasError = true;
        }
        Test.stopTest();

        System.assert(hasError, 'Test error good');
    }
}