import os
import pydoop.hdfs as hd
import datetime
import forecastio as fo
import pandas as pd

with hd.open("hdfs://quickstart.cloudera:8020/user/cloudera/python/cities_location.csv") as f:
    df =  pd.read_csv(f)
    
    
    df=pd.read_csv('/user/cloudera/python/cities_location.csv') 
    df.head()
    api_key = "459009d8daa503cef1e11b190c961ce5"
    #selecting the specific date
    date = datetime.datetime(2015,11,1,2,0,0)
    for i in range(len(df)):
        col = ["cities", "time",  "temperatureMin", "temperatureMax"]
        lat=df["latitude"].iloc[i]
        lng=df["longitude"].iloc[i]
        #qccesing the forecast.io API
        forecast = fo.load_forecast(api_key, lat, lng, time=date)
        day = forecast.daily()
        #retrieving infor;ation for the current day
        Day=day.data[0]
        data={"cities": df["cities"].iloc[i], "time" : Day.time, "temperatureMin" : Day.temperatureMin, "temperatureMax" : Day.temperatureMax}
        if i==0 :
            weather = pd.DataFrame(data, index=[0], columns= col)
        else:
            weather1 = pd.DataFrame(data, index=[0], columns= col)
            weather = pd.concat([weather, weather1], ignore_index=True)
        
weather.to_csv("/home/cloudera/python/weather.csv", columns=None, header=True )
#hdfs.put("/python/weather.csv", "hdfs://quickstart.cloudera:8020/user/cloudera/python/weather.csv")
os.system( "bin/hadoop fs -put /home/cloudera/python/weather.csv, hdfs://quickstart.cloudera:8020/user/cloudera/python/weather.csv" )
