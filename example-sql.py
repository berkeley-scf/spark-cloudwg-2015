from pyspark.sql import SQLContext, Row
sqlc = SQLContext(sc)

import re

lines = sc.textFile('/data/airline').filter(lambda line: "Year" not in line.split(',')[0]).repartition(24)

def replace_NAs(str, repl = '-9999'):
    str = re.sub(",NA,",","+repl+",",str)
    str = re.sub(",NA,",","+repl+",",str)
    str = re.sub(",NA$",","+repl,str)
    str = re.sub("^NA,",repl+",",str)
    return(str)


rows = lines.map(replace_NAs).map(lambda l: l.split(',')).map(lambda p: Row(year = int(p[0]), month = int(p[1]), dayOfMonth = int(p[2]), dayOfWeek = int(p[3]), DepTime = int(p[4]), CRSDepTime = int(p[5]), ArrTime = int(p[6]), CRSArrTime = int(p[7]), UniqueCarrier = p[8], FlightNum = int(p[9]), TailNum = p[10], ActualElapsedTime = int(p[11]), CRSElapsedTime = int(p[12]), AirTime = int(p[13]), ArrDelay = int(p[14]), DepDelay = int(p[15]), Origin = p[16], Dest = p[17], Distance = int(p[18]), TaxiIn = int(p[19]), TaxiOut = int(p[20]), Cancelled = int(p[21]), CancellationCode = int(p[22]), Diverted = int(p[23]), CarrierDelay = int(p[24]), WeatherDelay = int(p[25]), NASDelay = int(p[26]), SecurityDelay = int(p[27]), LateAircraftDelay = int(p[28])))

sch = sqlc.createDataFrame(rows)
sch.registerTempTable("records")

subset = sqlc.sql("SELECT year,month,dayOfWeek,CRSDepTime,DepDelay,ArrDelay,Dest FROM records WHERE Origin = 'SFO'")

subset.count()  # 137 sec.
subset.take(5)

lines.filter(lambda line: "SFO" in line.split(',')[16]).count()  # 42 sec.

sch.saveAsParquetFile('/data/parquet')  # 2.2 Gb (90% reduction) 

# restart PySpark
data = sqlc.parquetFile('/data/parquet')

