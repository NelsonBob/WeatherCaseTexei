/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */
@RestResource(urlMapping='/weather/*')
global with sharing class WeatherAPI {

    @HttpGet
    global static Map<String,Object> getWeather(){

        RestRequest req = RestContext.request;

        String city = req.requestParams.get('city');
        String latStr = req.requestParams.get('lat');
        String lngStr = req.requestParams.get('lng');

        if(city != null){

            return WeatherController.getWeatherbyCity(city);

        }
        else if(latStr != null && lngStr != null){

            Double lat = Double.valueOf(latStr);
            Double lng = Double.valueOf(lngStr);

            Map<String,Object> weather =
                WeatherController.getWeatherbyCoordonate(lat,lng);

            return weather;
        }
        else{

            throw new AuraHandledException(
                'Provide city or lat/lng'
            );
        }
    }
}