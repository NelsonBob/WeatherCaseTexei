/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */

public with sharing class WeatherController {

    static   String username = System.Label.GeoNames_Username;
    static  String geonamesUrl = System.Label.GeoNames_Url;
    static String email = System.Label.EmailExp;
    static String baseUrl = System.Label.baseUrl;

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

    // Logic to send weather bulletin via email
    @AuraEnabled
    public static void sendWeatherBulletin(Map<String, Object> weatherData, Id accountId, String urlIcon) {

        List<Contact> contacts = [
            SELECT Email 
            FROM Contact 
            WHERE AccountId = : accountId 
            AND Email != null
        ];

        if (contacts.isEmpty()) {
          throw new AuraHandledException('No contact found with the provided ID, or the contact does not have an email address.');
        }

        String senderEmail = System.Label.EmailExp;


        OrgWideEmailAddress owner = [
             SELECT Id 
             FROM OrgWideEmailAddress 
             WHERE Address = :senderEmail 
             LIMIT 1
        ];

        String iconUrls = baseUrl + urlIcon;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Contact contact : contacts) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] { contact.Email });

   
            mail.setOrgWideEmailAddressId(owner.Id);

            String subject = 'Weather Bulletin ';
            String body = 'Weather bulletin : <br/>' +
                      'Temperature : ' + weatherData.get('temperature') + '°C<br/>' +
                      'Humidity : ' + weatherData.get('humidity') + '%<br/>' +
                      'Wind Speed : ' + weatherData.get('windSpeed') + ' km/h<br/>' +
                      'Conditions : ' + weatherData.get('clouds') + '<br/>' +
                      'Icône : <br/><img src="' + iconUrls + '" alt="Weather icon" width="80"/><br/>';

            mail.setSubject(subject);
            mail.setHtmlBody(body);

            emails.add(mail);
        }

        Messaging.sendEmail(emails);
    }   
}    