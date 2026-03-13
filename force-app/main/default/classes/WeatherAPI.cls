/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */

@RestResource(urlMapping='/weather/*')
global with sharing class WeatherAPI {

    @HttpGet
    global static String getWeather(){

        RestRequest req = RestContext.request;

        String city = req.params.get('city');
        String latStr = req.params.get('lat');
        String lngStr = req.params.get('lng');

        Map<String,Object> result;

        if(city != null){

            result = WeatherController.getWeatherbyCity(city);

        }
        else if(latStr != null && lngStr != null){

            Double lat = Double.valueOf(latStr);
            Double lng = Double.valueOf(lngStr);

            result = WeatherController.getWeatherbyCoordonate(lat,lng);
        }
        else{

            throw new AuraHandledException('Provide city or lat/lng');
        }

        return JSON.serialize(result);
    }
}