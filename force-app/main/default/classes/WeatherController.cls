/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */

public with sharing class WeatherController {

    // String username = System.Label.GeoNames_Username;
    // String geonamesUrl = System.Label.GeoNames_Url;

        


    // method to get weather information based on current location
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeatherbyCoordonate(Double latitude, Double longitude) {
        String username = 'nelsonfomekong';
        String geonamesUrl = 'http://api.geonames.org/';
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

}
    