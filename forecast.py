import datetime
import forecastio as fo
import pandas as pd
df=pd.read_csv('cities_location.csv') 
df.head()
api_key = "459009d8daa503cef1e11b190c961ce5"
date = datetime.datetime(2015,11,3,2,0,0)
for i in range(len(df)):
    col = ["cities", "time",  "temperatureMin", "temperatureMax"]
    lat=df["latitude"].iloc[i]
    lng=df["longitude"].iloc[i]
    forecast = fo.load_forecast(api_key, lat, lng, time=date)
    day = forecast.daily()
    Day=day.data[0]
    data={"cities": df["cities"].iloc[i], "time" : Day.time, "temperatureMin" : Day.temperatureMin, "temperatureMax" : Day.temperatureMax}
    if i==0 :
        weather = pd.DataFrame(data, index=[0], columns= col)
    else:
        weather1 = pd.DataFrame(data, index=[0], columns= col)
        weather = pd.concat([weather, weather1], ignore_index=True)
        
weather.to_csv("weather.csv", columns=None, header=True )
