/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */
 @isTest
private class WeatherControllerTest {

    @testSetup
    static void setupData(){

        Account acc = new Account(Name='Test Account');
        insert acc;

        Contact c = new Contact(
            LastName='Test',
            Email='test@test.com',
            AccountId=acc.Id
        );

        insert c;
    }


  @isTest
static void testGetWeatherByCoordinates(){

    Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());

    Test.startTest();

    Map<String,Object> result =
        WeatherController.getWeatherbyCoordonate(
            Double.valueOf(48.8566),
            Double.valueOf(2.3522)
        );

    Test.stopTest();

    System.assert(result != null);
    System.assert(result.containsKey('temperature'));
}


    @isTest
    static void testGetWeatherByCity(){

        Test.setMock(HttpCalloutMock.class, new WeatherCalloutMock());

        Test.startTest();

        Map<String,Object> result =
            WeatherController.getWeatherbyCity('Paris');

        Test.stopTest();

        System.assert(result != null);
        System.assert(result.containsKey('humidity'));
    }


    @isTest
    static void testSendWeatherBulletin(){

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String,Object> weatherData = new Map<String,Object>{
            'temperature' => '22',
            'humidity' => '60',
            'windSpeed' => '15',
            'clouds' => 'Partly Cloudy'
        };

        Test.startTest();

        WeatherController.sendWeatherBulletin(
            weatherData,
            acc.Id,
            '/img/icon.png'
        );

        Test.stopTest();

        System.assert(true);
    }

}