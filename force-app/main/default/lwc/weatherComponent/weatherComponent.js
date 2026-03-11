/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */


import { LightningElement, track, api, wire } from 'lwc';
import getWeatherbyCoordonate from '@salesforce/apex/WeatherController.getWeatherbyCoordonate';


const ACCOUNT_FIELDS = ['Account.BillingCity'];
export default class WeatherComponent extends LightningElement {
    @api weatherData;
    @track errorMessage;

    city;
    refreshInterval;


    connectedCallback() {

      

            this.getLocationWeather();

            // refresh toutes les heures
            this.refreshInterval =
            setInterval(() => this.getLocationWeather(), 3600000);


    }

    disconnectedCallback() {

        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }

    }




        getLocationWeather() {

            navigator.geolocation.getCurrentPosition(
                (position) => {

                    getWeatherbyCoordonate({

                        latitude: position.coords.latitude,
                        longitude: position.coords.longitude
                    })
                    .then ( weatherData => {
                        this.weatherData = this.formatWeather(weatherData);
                         this.errorMessage = null;
                     
                    })
                    .catch((error) => {

                        this.weatherData = null;
                        this.errorMessage = error.message;
                    })
                    
                    ;
                },


            );     
        
        }
                
            
        
            
        

        formatWeather(obs) { 
            const condition = obs.clouds || '';
            return {
                location: obs.stationName || this.city || "Unknown",
                
            temperature: obs.temperature,
            windSpeed: obs.windSpeed,
            humidity: obs.humidity,
            clouds: condition
            };
         }

    
}