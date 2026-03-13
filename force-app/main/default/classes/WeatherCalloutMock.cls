/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */


@isTest
global class WeatherCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setStatusCode(200);

        if(req.getEndpoint().contains('findNearByWeatherJSON')){

            res.setBody('{"weatherObservation":{"temperature":"20","humidity":"50","windSpeed":"10","clouds":"Sunny"}}');

        } else if(req.getEndpoint().contains('searchJSON')){

            res.setBody('{"geonames":[{"lat":"48.8566","lng":"2.3522"}]}');

        }

        return res;
    }
}