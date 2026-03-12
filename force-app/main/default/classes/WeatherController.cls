/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */

public with sharing class WeatherController {

    static   String username = System.Label.GeoNames_Username;
    static  String geonamesUrl = System.Label.GeoNames_Url;

    // method to get weather information based on current location
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeatherbyCoordonate(Double latitude, Double longitude) {
        String url = geonamesUrl + 'findNearByWeatherJSON?lat=' + latitude + '&lng=' + longitude + '&username=' + username;
        Http Http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = Http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> weatherData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return (Map<String, Object>) weatherData.get('weatherObservation');
        } else {
            throw new AuraHandledException('Failed to retrieve weather data. Status code: ' + response.getStatusCode());
        }
    }


    // method to get weather information based on city name
     // Weather by city
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeatherbyCity(String cityName) {

        String url = geonamesUrl + 'searchJSON?q=' + EncodingUtil.urlEncode(cityName,'UTF-8')
                     + '&maxRows=1&username=' + username;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if(response.getStatusCode() != 200) {
            throw new AuraHandledException('Erreur API GeoNames: ' + response.getStatus());
        }

        Map<String,Object> searchResult =
            (Map<String,Object>) JSON.deserializeUntyped(response.getBody());

        List<Object> geonames =
            (List<Object>) searchResult.get('geonames');

       
        if(geonames == null || geonames.isEmpty()) {
            throw new AuraHandledException('Ville introuvable : ' + cityName);
        }

        Map<String,Object> geo = (Map<String,Object>) geonames[0];

        Double latitude = Double.valueOf(String.valueOf(geo.get('lat')));
        Double longitude = Double.valueOf(String.valueOf(geo.get('lng')));

        return getWeatherbyCoordonate(latitude, longitude);
    }
}
    