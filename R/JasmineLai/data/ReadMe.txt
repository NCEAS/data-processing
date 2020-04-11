Title:
Firn temperatures (2013-2017) and water-level changes (2015-2017) collected at three locations in a firn-aquifer region of the southeastern part of the Greenland Ice Sheet


Summary:
The firn temperatures were collected at three different locations (FA-13, FA-15-1 and FA-15-2) in the percolation zone of the Southeast part of the Greenland Ice Sheet, about 50 km West of Helheim Glacier front. At the two FA-15 sites, water levels from pressure transducers complement the firn temperatures records. Each string of temperature sensors was installed in a borehole drilled through the aquifer, hanging in the air when above the water table and in the water when below the water table. For the two FA-15 sites, a pressure transducer was installed in the same hole, located about 1 meter below the water table and vented at the surface. Each borehole was then backfilled with unconsolidated surface snow.
For FA-13 (66.1812° N, 39.0435° W, 1563 m), firn temperatures were collected between April 09, 2013 and September 13, 2015. For FA-15-1 (66.3622° N, 39.3119° W, 1664 m), firn temperatures and water levels were collected between April 17, 2015 and February 22, 2017. For FA-15-2 (66.3548° N, 39.1788° W, 1543 m), firn temperatures and water levels were collected between August 9, 2015 and February 2, 2017.

---------------------------------------------------------------------------------------------------------------------

Sensors used and data logging strategy

Firn Temperatures: 
Model/Manufacturer: Digital Thermarray system from RST©
Spacing: FA13 temperature string was 28-m long, made of 60 nodes spaced every 0.5 meters. FA15-1 and FA15-2 temperature strings were each 55-m long made of 50 nodes with varying spacing from 0.5 meters near the surface and 5 meters near the bottom.
Specifics: Nodes are located on a single 4-conductor KevlarTM reinforced cable. 
Sensors are pre-calibrated with an accuracy of 0.07°C and no additional field calibration was required nor performed. 
Additional information about the Thermarray system can be found here:
https://www.rstinstruments.com/content/manuals/thermarray-pc.pdf

Water levels:
Model/Manufacturer: Model 330 Submersible Analog Pressure Transducer from KPSI©
Specifics: Precision of 0.1% for a total range of 68.95 kPa (10 psi). Each transducer is vented at the surface using a small vent tube connected from the transducer to a custom plastic enclosure filled with desiccant located on the mast above the snow surface. The pressure transducer was located about 2 meter below the water table to remain in range while anticipating vertical water-level fluctuations on the order of a few meters. We applied a low-voltage threshold on the pressure transducer data of 10.85V and discarded water-level data collected below that threshold.

Firn-temperature and water-level records were stored hourly (UTC time) on a CR-1000 data logger and 2-hr data were transmitted with a ST-21 Argos transmitter, both instruments from Campbell Scientific©. Lack of data transmission, erroneous transmissions, and loss of power, resulted in several data gaps.
---------------------------------------------------------------------------------------------------------------------

Geographic locations: 
Site name: FA-13
Latitude: 66.1812° N
Longitude: 39.0435° W
Elevation: 1563 meters (ellipsoid height WGS84)

Site name: FA-15-1
Latitude: 66.3622 N
Longitude: 39.3119° W
Elevation: 1664 meters (ellipsoid height WGS84)

Site name: FA-15-2
Latitude: 66.3548° N
Longitude: 39.1788° W
Elevation: 1543 meters (ellipsoid height WGS84)

Data coverage:
Site: FA-13: Firn temperatures only
- April 9, 2013 – March 26, 2015 (data available at best every 2 hours)
- July 27, 2015 – September 13, 2015 (data available at best every 2 hours)

Site: FA-15-1: Firn temperatures and water levels
- April 17, 2015 – August 7, 2016 (data available every 1 hour)
- August 8, 2016 – February 22, 2017 (data available at best every 2 hours)

Site: FA-15-2: Firn temperatures and water levels
- August 9, 2015 – August 7, 2016 (data available every 1 hour)
- August 8, 2016 – February 2, 2017 (data available at best every 2 hours)


Firn-temperature depths at each site:

FA-13:
Depths were measured (in meters) on April 9, 2013 during initial instrument deployment and not adjusted for later surface changes since no later site visits were made. Therefore, given depths do not take into account changes to the snow surface happening after instrument put-in (snow melt, snowfalls, etc.)
The depth to the water table during the instrument setup was 12.2±0.1 m and the firn-ice transition was estimated around 37 m (see Koenig et al., 2014 for details). 

FA-15-1 and FA-15-2:
Initial depths were measured (in meters) on April 17, 2015 (FA-15-1) and August 9, 2015 (FA-15-2) during initial instrument deployment and were estimated again on Aug 4, 2016  (FA-15-1) and August 6, 2015 (FA-15-2) when a site visit was made to collect the data stored in the logger. 
The depth to the water table during the instrument setup was 19.9 m at FA-15-1 and  14.6 m at FA-15-2 and the firn-ice transition was estimated around 32 m (see Miller et al., submitted for details). 

ARGOS transmission and processing:
Data were transmitted via ARGOS by the mean of 5 buffers (15 data points or 31 bytes of data can be stored in each buffer) sent out individually every 12-minutes but transmissions were based on over-head satellite availability. Data were made available from ARGOS, compiled in a daily email as hexadecimal pairs. 
Processing steps consisted of compiling daily files into a single dataset, decoding from hexadecimal to decimal via binary and removing outliers due to corrupted transmissions. We removed outliers by combining data redundancy (several transmissions of a same message over time) and a median 1-D filter.

Data organization:
The dataset is available in a .csv format and composed of several files.

Firn temperatures and associated depths can be found in two different files:
The sensor depths are provided in meters, with zero being the snow surface, negative numbers meaning temperature node was located above the surface, and maximum number representing greatest depth reached in the borehole. 
The first column (status) provide either an “as-found” or an “as-left” depth profile for the top three nodes that have been readjusted during site visit after initial install. From fourth node to the bottom, the depth are adjusted down approximately to reflect the change in surface height but do not account for compaction. More accurate snow height estimates can be found in the associated weather station (iWS) record (Reijmer et al., 2020).
NaNs are present when depths were not reported.

The firn temperatures are provided in degree Celsius. The first 4 columns provide the time stamp: Year, Month, Day and Hour in Universal Coordinated Time (UTC). Data gaps due to lack of data transmission, erroneous transmissions, faulty sensor, or loss of power are filled with NaN.

Water levels:
The first 4 columns provide the time stamp: Year, Month, Day and Hour in Universal Coordinated Time (UTC). The fifth column provides the relative water level in meters with the first data point set at zero. Data gaps due to lack of data transmission, erroneous transmissions, faulty sensor, or loss of power are filled with NaN.


---------------------------------------------------------------------------------------------------------------------



Associated manuscripts presenting the data: 

For site FA-13: 
Koenig, L. S. et al. (2014). Initial in situ measurements of perennial meltwater storage in the Greenland firn aquifer. Geophysical Research Letters, 41(1), 2013GL058083. https://doi.org/10.1002/2013GL058083

For sites FA-15-1 and FA-15-2: 
Miller O. L. et al. Hydrology of a perennial firn aquifer in Southeast Greenland: an overview driven by field data. Water Resources Research (submitted)

Data acknowledgement:
The firn-temperature data were collected with support from NSF grants 1311655, 1417987 and 1417993.
https://www.nsf.gov/awardsearch/showAward?AWD_ID=1311655
https://www.nsf.gov/awardsearch/showAward?AWD_ID=1417987
https://www.nsf.gov/awardsearch/showAward?AWD_ID=1417993

Data Creators: 
Clém Miège, Richard Forster, Ludovic Brucker, Lora Koenig, Olivia Miller and Kip Solomon

Data Set Contacts:
Clém Miège and Richard Forster


Related ADC datasets:

Weather station: April 20, 2014 to July 20, 2017 
Carleen Reijmer, Peter Kuipers Munneke, and Paul Smeets. 2018. Helhein firn aquifer weather station data and melt rates, Greenland, 2014-2016. Arctic Data Center. doi:10.18739/A2K06X15R

Chemistry Data: July/Aug 2015 and July/Aug 2016
Olivia Miller, Kip Solomon, Clément Miège, Richard Forster, and Lora Koenig. 2019. Physical and chemical data from a firn aquifer in Southeast Greenland, 2015-2016. Arctic Data Center. doi:10.18739/A2F18SF5B.
Olivia Miller and Kip Solomon. 2019. Hydrologic data from a firn aquifer in Southeast Greenland, 2015-2016. Arctic Data Center. doi:10.18739/A26T0GW4P.

Firn Aquifer Extents: 
Clément Miège. 2018. Spatial extent of Greenland firn aquifer detected by airborne radars, 2010-2014. Arctic Data Center. doi:10.18739/A2985M.

---------------------------------------------------------------------------------------------------------------------
