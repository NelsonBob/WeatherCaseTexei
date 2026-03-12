/**
 * @author Nelson Fomekong
 * @version 1.0.0
 */


import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getWeatherbyCoordonate from '@salesforce/apex/WeatherController.getWeatherbyCoordonate';
import getWeatherbyCity from '@salesforce/apex/WeatherController.getWeatherbyCity';

const ACCOUNT_FIELDS = ['Account.BillingCity'];
export default class WeatherComponent extends LightningElement {
  
    
    @api recordId;
    @track weatherData;
    @track errorMessage;

    city;
    refreshInterval;

    // get city from account
    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccount({ error, data }) {
        if (data) {

            this.city = data.fields.BillingCity.value;

            if(this.city){

                this.fetchWeatherByCity();
            
                
            } else {

                this.weatherData = null;
                this.errorMessage = "Unable to retrieve city information from the account.";
            }
        } 
        
        if (error) {
            
            this.errorMessage =  error.body.message;
        }
     

    }    
    connectedCallback() {

      
            
        // get weather Home Location
            if (!this.recordId) {

                 this.getLocationWeather();

                 // Set up auto-refresh every hour (3600000 milliseconds)
                 this.refreshInterval =
                        setInterval(() => this.getLocationWeather(), 3600000);
            
            }
            


    }

    disconnectedCallback() {

        if (this.refreshInterval) {
            clearInterval(this.refreshInterval);
        }

    }

    fetchWeatherByCity() {

             getWeatherbyCity({ cityName: this.city })

            .then(result => {

                this.weatherData = this.formatWeather(result);
                this.errorMessage = null;

             })

            .catch(error => {

                this.weatherData = null;
                this.errorMessage = error.body.message;

            });

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
                    ;
                });
                    
            },


        );     
        
    }
                
            
        
            
        

    formatWeather(obs) { 
        const condition = obs.clouds || '';
         return {
         location: obs.stationName ||  "Unknown",    
         temperature: obs.temperature,
         windSpeed: obs.windSpeed,
         humidity: obs.humidity,
         clouds: condition
        };
    }

    
}